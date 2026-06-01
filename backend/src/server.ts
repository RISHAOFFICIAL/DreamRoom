import * as Sentry from "@sentry/node";
import { nodeProfilingIntegration } from "@sentry/profiling-node";
import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';
import { setupSocket, parties } from './socket.js';
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

setupSocket(io);

app.get('/health', (req, res) => {
  res.send({ status: 'ok' });
});

// Admin dashboard data
app.get('/api/admin/parties', (req, res) => {
  res.send(Array.from(parties.values()));
});

app.post('/api/admin/parties/:partyId/golden', (req, res) => {
  const { partyId } = req.params;
  const { enabled } = req.body;
  const party = parties.get(partyId);
  if (!party) return res.status(404).send('Party not found');
  
  party.isGoldenHour = enabled;
  io.to(partyId).emit('goldenHourToggled', enabled);
  io.to(partyId).emit('partyUpdated', party);
  res.send({ status: 'ok', isGoldenHour: party.isGoldenHour });
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
