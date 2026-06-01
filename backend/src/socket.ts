import { Server } from 'socket.io';
import type { Socket } from 'socket.io';
import { v4 as uuidv4 } from 'uuid';
import type { 
  ClientToServerEvents, 
  ServerToClientEvents, 
  InterServerEvents, 
  SocketData,
  Party,
  User
} from './types.js';
import { trackEvent } from './analytics.js';

export const parties = new Map<string, Party>();

const checkGoldenHour = (party: Party): boolean => {
  const ssidCounts: Record<string, number> = {};
  
  party.participants.forEach(user => {
    if (user.ssid) {
      ssidCounts[user.ssid] = (ssidCounts[user.ssid] || 0) + 1;
    }
  });

  return Object.values(ssidCounts).some(count => count >= 3);
};

export const setupSocket = (io: Server<ClientToServerEvents, ServerToClientEvents, InterServerEvents, SocketData>) => {
  io.on('connection', (socket) => {
    console.log('User connected:', socket.id);

    socket.on('createParty', (hostName, ssid) => {
      const partyId = uuidv4().substring(0, 8).toUpperCase();
      const hostId = uuidv4();
      
      const host: User = {
        id: hostId,
        name: hostName,
        isHost: true,
        ssid
      };

      const newParty: Party = {
        id: partyId,
        hostId,
        status: 'building',
        participants: [host],
        createdAt: Date.now(),
        isGoldenHour: false
      };

      parties.set(partyId, newParty);
      socket.data.userId = hostId;
      socket.data.partyId = partyId;
      socket.join(partyId);
      
      socket.emit('partyUpdated', newParty);
      
      trackEvent(hostId, 'party_created', {
        party_id: partyId,
        host_id: hostId,
        is_manual_override: false
      });

      console.log(`Party created: ${partyId} by ${hostName}`);
    });

    socket.on('joinParty', (partyId, userName, ssid) => {
      const party = parties.get(partyId);
      
      if (!party) {
        socket.emit('error', 'Party not found');
        return;
      }

      const userId = uuidv4();
      const newUser: User = {
        id: userId,
        name: userName,
        isHost: false,
        ssid
      };

      party.participants.push(newUser);
      socket.data.userId = userId;
      socket.data.partyId = partyId;
      socket.join(partyId);

      const wasGoldenHour = party.isGoldenHour;
      party.isGoldenHour = checkGoldenHour(party);

      io.to(partyId).emit('partyUpdated', party);

      if (!wasGoldenHour && party.isGoldenHour) {
        io.to(partyId).emit('goldenHourToggled', true);
        trackEvent(party.hostId, 'golden_hour_activated', {
          party_id: partyId,
          trigger: 'wifi_detection'
        });
      }

      trackEvent(userId, 'party_joined', {
        party_id: partyId,
        guest_id: userId,
        join_method: 'link'
      });

      console.log(`User ${userName} joined party: ${partyId}`);
    });

    socket.on('triggerReveal', (partyId) => {
      const party = parties.get(partyId);
      
      if (!party) {
        socket.emit('error', 'Party not found');
        return;
      }

      party.status = 'reveal';
      io.to(partyId).emit('partyUpdated', party);
      io.to(partyId).emit('goldenRevealTriggered', partyId);

      trackEvent(party.hostId, 'golden_reveal_triggered', {
        party_id: partyId,
        participant_count: party.participants.length
      });

      console.log(`Reveal triggered for party: ${partyId}`);
    });

    socket.on('toggleGoldenHour', (partyId, enabled) => {
      const party = parties.get(partyId);
      if (!party) {
        socket.emit('error', 'Party not found');
        return;
      }

      // Check if the requester is the host (optional but recommended)
      // For now, let's assume any trigger is valid for the MVP override
      
      const wasGoldenHour = party.isGoldenHour;
      party.isGoldenHour = enabled;

      io.to(partyId).emit('partyUpdated', party);
      
      if (wasGoldenHour !== enabled) {
        io.to(partyId).emit('goldenHourToggled', enabled);
        trackEvent(party.hostId, 'golden_hour_toggled', {
          party_id: partyId,
          enabled,
          trigger: 'manual_override'
        });
      }
    });

    socket.on('updateBuildingState', (partyId, isBuilding) => {
      const party = parties.get(partyId);
      if (!party) return;

      const user = party.participants.find(u => u.id === socket.data.userId);
      if (user) {
        user.isBuilding = isBuilding;
        io.to(partyId).emit('partyUpdated', party);
      }
    });

    socket.on('disconnect', () => {
      console.log('User disconnected:', socket.id);
      // Optional: Cleanup SSID counts if necessary
    });
  });
};
