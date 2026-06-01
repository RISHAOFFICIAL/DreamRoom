export interface User {
  id: string;
  name: string;
  isHost: boolean;
  isBuilding?: boolean;
  ssid?: string;
}

export interface Party {
  id: string;
  hostId: string;
  status: 'building' | 'reveal' | 'finished';
  participants: User[];
  createdAt: number;
  isGoldenHour: boolean;
}

export interface ServerToClientEvents {
  partyUpdated: (party: Party) => void;
  goldenRevealTriggered: (partyId: string) => void;
  goldenHourToggled: (enabled: boolean) => void;
  error: (message: string) => void;
}

export interface ClientToServerEvents {
  createParty: (hostName: string, ssid?: string) => void;
  joinParty: (partyId: string, userName: string, ssid?: string) => void;
  triggerReveal: (partyId: string) => void;
  toggleGoldenHour: (partyId: string, enabled: boolean) => void;
  updateBuildingState: (partyId: string, isBuilding: boolean) => void;
}

export interface InterServerEvents {
  ping: () => void;
}

export interface SocketData {
  userId: string;
  partyId: string;
}
