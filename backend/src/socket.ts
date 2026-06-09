import { Server } from 'socket.io';
import { v4 as uuidv4 } from 'uuid';
import type { 
  ClientToServerEvents, 
  ServerToClientEvents, 
  InterServerEvents, 
  SocketData,
  Party,
  User,
  BoardItem,
  GoldenSpark
} from './types.js';
import { trackEvent } from './analytics.js';
import redisClient from './redisClient.js';
import { archiveBoard, queryTeamDb } from './db.js';

const PARTY_PREFIX = 'party:';

// Helper to fetch owned kits from the shared database
const getOwnedKits = (userId: string): string[] => {
  try {
    const result = queryTeamDb(`SELECT kit_id FROM owned_kits WHERE user_id = '${userId.replace(/'/g, "''")}'`);
    return Array.isArray(result) ? result.map((r: any) => r.kit_id) : [];
  } catch (e) {
    console.error('Error fetching owned kits:', e);
    return [];
  }
};

// Luxury assets configuration
const LUXURY_KITS = ['sanctuary-pack', 'urban-vision', 'manifest-gold'];
const KIT_ASSETS: Record<string, string[]> = {
  'sanctuary-pack': ["sanctuary_01", "sanctuary_02", "sanctuary_03"],
  'urban-vision': ["urban_01", "urban_02", "urban_03"],
  'manifest-gold': ["gold_01", "gold_02", "gold_03"]
};
const ALL_LUXURY_ASSETS = Object.values(KIT_ASSETS).flat();

export const getParty = async (partyId: string): Promise<Party | null> => {
  const data = await redisClient.get(`${PARTY_PREFIX}${partyId}`);
  return data ? JSON.parse(data) : null;
};

export const saveParty = async (party: Party): Promise<void> => {
  await redisClient.set(`${PARTY_PREFIX}${party.id}`, JSON.stringify(party), {
    EX: 86400 // Expire after 24 hours
  });
};

export const getAllParties = async (): Promise<Party[]> => {
  const keys = await redisClient.keys(`${PARTY_PREFIX}*`);
  if (keys.length === 0) return [];
  const data = await redisClient.mGet(keys);
  return data.map(d => JSON.parse(d!));
};

const checkGoldenHour = (party: Party): boolean => {
  const ssidCounts: Record<string, number> = {};
  const ipGroupCounts: Record<string, number> = {};
  
  party.participants.forEach(user => {
    if (user.ssid) {
      ssidCounts[user.ssid] = (ssidCounts[user.ssid] || 0) + 1;
    }
    if (user.ipGroup) {
      ipGroupCounts[user.ipGroup] = (ipGroupCounts[user.ipGroup] || 0) + 1;
    }
  });

  const hasThreeSameSsid = Object.values(ssidCounts).some(count => count >= 3);
  const hasThreeSameIpGroup = Object.values(ipGroupCounts).some(count => count >= 3);
  const hasThreeNearbyViaBluetooth = party.participants.some(user => (user.nearbyDevicesCount || 0) >= 2);

  return hasThreeSameSsid || hasThreeSameIpGroup || hasThreeNearbyViaBluetooth;
};

export const setupSocket = (io: Server<ClientToServerEvents, ServerToClientEvents, InterServerEvents, SocketData>) => {
  io.on('connection', (socket) => {
    console.log('User connected:', socket.id);

    socket.on('createParty', async (hostName, ssid) => {
      const partyId = uuidv4().substring(0, 8).toUpperCase();
      const hostId = uuidv4();
      
      const host: User = {
        id: hostId,
        name: hostName,
        isHost: true,
        ssid,
        ipGroup: socket.handshake.address,
        isBuilder: true, // For MVP demo, host is always a Builder
        ownedKits: getOwnedKits(hostId)
      };

      const newParty: Party = {
        id: partyId,
        hostId,
        status: 'building',
        participants: [host],
        items: [],
        sparks: [],
        createdAt: Date.now(),
        isGoldenHour: false,
        isBuilderHosted: host.isBuilder
      };

      await saveParty(newParty);
      socket.data.userId = hostId;
      socket.data.partyId = partyId;
      socket.join(partyId);
      
      socket.emit('joined', { userId: hostId, partyId });
      socket.emit('partyUpdated', newParty);
      
      trackEvent(hostId, 'party_created', {
        party_id: partyId,
        host_id: hostId,
        is_builder: host.isBuilder
      });

      console.log(`Party created: ${partyId} by ${hostName}`);
    });

    socket.on('joinParty', async (partyId, userName, ssid) => {
      const party = await getParty(partyId);
      
      if (!party) {
        socket.emit('error', 'Party not found');
        return;
      }

      const userId = uuidv4();
      const newUser: User = {
        id: userId,
        name: userName,
        isHost: false,
        ssid,
        ipGroup: socket.handshake.address,
        isBuilder: false,
        ownedKits: getOwnedKits(userId)
      };

      party.participants.push(newUser);
      socket.data.userId = userId;
      socket.data.partyId = partyId;
      socket.join(partyId);

      socket.emit('joined', { userId, partyId });
      
      const wasGoldenHour = party.isGoldenHour;
      if (!party.isManualGoldenHour) {
        party.isGoldenHour = checkGoldenHour(party);
      }

      await saveParty(party);
      io.to(partyId).emit('partyUpdated', party);

      if (!wasGoldenHour && party.isGoldenHour) {
        io.to(partyId).emit('goldenHourToggled', true);
        trackEvent(party.hostId, 'golden_hour_activated', {
          party_id: partyId,
          trigger: 'proximity_detection'
        });
      }

      trackEvent(userId, 'party_joined', {
        party_id: partyId,
        guest_id: userId
      });

      console.log(`User ${userName} joined party: ${partyId}`);
    });

    socket.on('addItem', async (partyId, itemData) => {
      const party = await getParty(partyId);
      if (!party) return;

      const user = party.participants.find(u => u.id === socket.data.userId);
      if (!user) return;

      // Entitlement Check for Luxury Assets
      const assetUrl = itemData.url;
      if (assetUrl && ALL_LUXURY_ASSETS.includes(assetUrl)) {
        const hasKit = user.ownedKits?.some(kitId => {
          return KIT_ASSETS[kitId]?.includes(assetUrl);
        });
        
        if (!hasKit && !user.isBuilder && !party.isBuilderHosted) {
          socket.emit('error', 'Luxury asset requires Builder Plan or Kit purchase');
          return;
        }
      }

      const newItem: BoardItem = {
        ...itemData,
        witnesses: []
      };

      party.items.push(newItem);
      await saveParty(party);
      io.to(partyId).emit('partyUpdated', party);

      trackEvent(user.id, 'item_added', {
        party_id: partyId,
        item_id: newItem.id,
        is_luxury: assetUrl && ALL_LUXURY_ASSETS.includes(assetUrl)
      });
    });

    socket.on('witnessItem', async (partyId, itemId) => {
      const party = await getParty(partyId);
      if (!party) return;

      const user = party.participants.find(u => u.id === socket.data.userId);
      if (!user) return;

      const item = party.items.find(i => i.id === itemId);
      if (!item) return;

      if (!item.witnesses.includes(user.name)) {
        item.witnesses.push(user.name);
      }

      const spark: GoldenSpark = {
        id: uuidv4(),
        fromName: user.name,
        itemId: itemId,
        timestamp: Date.now()
      };

      if (!party.sparks) party.sparks = [];
      party.sparks.push(spark);

      await saveParty(party);
      
      io.to(partyId).emit('itemWitnessed', { 
        itemId, 
        witnessedBy: user.name,
        spark 
      });
      io.to(partyId).emit('partyUpdated', party);

      trackEvent(user.id, 'item_witnessed', {
        party_id: partyId,
        item_id: itemId
      });
    });

    socket.on('updateNearbyDevices', async (partyId, count) => {
      const party = await getParty(partyId);
      if (!party) return;

      const user = party.participants.find(u => u.id === socket.data.userId);
      if (user) {
        user.nearbyDevicesCount = count;

        const wasGoldenHour = party.isGoldenHour;
        if (!party.isManualGoldenHour) {
          party.isGoldenHour = checkGoldenHour(party);
        }

        await saveParty(party);
        io.to(partyId).emit('partyUpdated', party);

        if (!wasGoldenHour && party.isGoldenHour) {
          io.to(partyId).emit('goldenHourToggled', true);
          trackEvent(party.hostId, 'golden_hour_activated', {
            party_id: partyId,
            trigger: 'bluetooth_proximity'
          });
        }
      }
    });

    socket.on('triggerReveal', async (partyId) => {
      const party = await getParty(partyId);
      if (!party) return;

      party.status = 'reveal';
      await saveParty(party);
      io.to(partyId).emit('partyUpdated', party);
      io.to(partyId).emit('goldenRevealTriggered', partyId);

      trackEvent(party.hostId, 'golden_reveal_triggered', {
        party_id: partyId,
        participant_count: party.participants.length
      });
    });

    socket.on('toggleGoldenHour', async (partyId, enabled) => {
      const party = await getParty(partyId);
      if (!party) return;

      const wasGoldenHour = party.isGoldenHour;
      party.isGoldenHour = enabled;
      party.isManualGoldenHour = true; 
      
      await saveParty(party);
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

    socket.on('updateBuildingState', async (partyId, isBuilding) => {
      const party = await getParty(partyId);
      if (!party) return;

      const user = party.participants.find(u => u.id === socket.data.userId);
      if (user) {
        user.isBuilding = isBuilding;
        await saveParty(party);
        io.to(partyId).emit('partyUpdated', party);
      }
    });

    socket.on('finishParty', async (partyId) => {
      const party = await getParty(partyId);
      if (!party) return;

      party.status = 'finished';
      await saveParty(party);
      await archiveBoard(party);
      
      io.to(partyId).emit('partyUpdated', party);
      console.log(`Party ${partyId} finished and archived.`);
    });

    socket.on('disconnect', async () => {
      const { userId, partyId } = socket.data;
      if (userId && partyId) {
        const party = await getParty(partyId);
        if (party) {
          const originalCount = party.participants.length;
          party.participants = party.participants.filter(p => p.id !== userId);
          
          if (party.participants.length !== originalCount) {
            const wasGoldenHour = party.isGoldenHour;
            if (!party.isManualGoldenHour) {
              party.isGoldenHour = checkGoldenHour(party);
            }
            
            await saveParty(party);
            io.to(partyId).emit('partyUpdated', party);
            
            if (wasGoldenHour && !party.isGoldenHour) {
              io.to(partyId).emit('goldenHourToggled', false);
            }
          }
        }
      }
    });
  });
};
