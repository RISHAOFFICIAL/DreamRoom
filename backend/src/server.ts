import * as Sentry from "@sentry/node";
import { nodeProfilingIntegration } from "@sentry/profiling-node";
import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';
import cors from 'cors';
import dotenv from 'dotenv';
import { setupSocket, getAllParties, getParty, saveParty } from './socket.js';
import { queryTeamDb } from './db.js';
import type { ClientToServerEvents, ServerToClientEvents, InterServerEvents, SocketData } from './types.js';

dotenv.config();

Sentry.init({
  dsn: process.env.SENTRY_DSN || "https://examplePublicKey@o0.ingest.sentry.io/0",
  integrations: [
    nodeProfilingIntegration(),
  ],
  tracesSampleRate: 1.0,
});

const app = express();
app.use(cors());
app.use(express.json());

const httpServer = createServer(app);
const io = new Server<
  ClientToServerEvents,
  ServerToClientEvents,
  InterServerEvents,
  SocketData
>(httpServer, {
  cors: {
    origin: "*", // Allow all origins for the sandbox/preview
    methods: ["GET", "POST"]
  }
});

// Redis Adapter Setup
const pubClient = createClient({ url: process.env.REDIS_URL || 'redis://localhost:6379' });
const subClient = pubClient.duplicate();

Promise.all([pubClient.connect(), subClient.connect()]).then(() => {
  io.adapter(createAdapter(pubClient, subClient));
  console.log('Redis adapter initialized');
}).catch(err => {
  console.error('Redis connection error:', err);
});

setupSocket(io);

app.get('/health', (req, res) => {
  res.send({ status: 'ok' });
});

// Admin dashboard data
app.get('/api/admin/parties', async (req, res) => {
  const parties = await getAllParties();
  res.send(parties);
});

app.post('/api/admin/parties/:partyId/golden', async (req, res) => {
  const { partyId } = req.params;
  const { enabled } = req.body;
  const party = await getParty(partyId);
  if (!party) return res.status(404).send('Party not found');
  
  party.isGoldenHour = enabled;
  party.isManualGoldenHour = enabled;
  await saveParty(party);
  io.to(partyId).emit('goldenHourToggled', enabled);
  io.to(partyId).emit('partyUpdated', party);
  res.send({ status: 'ok', isGoldenHour: party.isGoldenHour });
});

app.get('/api/archive/:userId', (req, res) => {
  const { userId } = req.params;
  const boards = queryTeamDb(`
    SELECT b.* 
    FROM archived_boards b
    JOIN board_participants p ON b.id = p.board_id
    WHERE p.user_id = '${userId.replace(/'/g, "''")}'
    ORDER BY b.created_at DESC
  `);
  res.send(boards || []);
});

// Dream Shop APIs
app.get('/api/owned-kits/:userId', (req, res) => {
  const { userId } = req.params;
  const kits = queryTeamDb(`
    SELECT kit_id FROM owned_kits WHERE user_id = '${userId.replace(/'/g, "''")}'
  `);
  res.send(kits ? kits.map((k: any) => k.kit_id) : []);
});

app.post('/api/unlock-kit', (req, res) => {
  const { userId, kitId } = req.body;
  if (!userId || !kitId) return res.status(400).send('Missing userId or kitId');
  
  queryTeamDb(`
    INSERT OR IGNORE INTO owned_kits (user_id, kit_id)
    VALUES ('${userId.replace(/'/g, "''")}', '${kitId.replace(/'/g, "''")}')
  `);
  
  res.send({ status: 'ok', kitId });
});

Sentry.setupExpressErrorHandler(app);

// Invite link generation
app.get('/invite/:partyId', (req, res) => {
  const { partyId } = req.params;
  // This would normally serve a web page for guest join
  // For now, it just returns the party ID info
  res.send({
    partyId,
    joinUrl: `https://${process.env.WEB_URL || 'dreamroom.app'}/join/${partyId}`
  });
});

const PORT = process.env.PORT || 3001;

httpServer.listen(PORT, () => {
  console.log(`DreamRoom backend running on port ${PORT}`);
});
