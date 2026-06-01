export interface User {
  id: string;
  name: string;
  isHost: boolean;
  isBuilding?: boolean;
  ssid?: string;
  ipGroup?: string;
}

export interface BoardItem {
  id: string;
  url: string;
  x: number;
  y: number;
  rotation: number;
  scale: number;
  addedBy: string;
}

export interface Party {
  id: string;
  hostId: string;
  status: 'building' | 'reveal' | 'finished';
  participants: User[];
  items: BoardItem[];
  createdAt: number;
  isGoldenHour: boolean;
  isManualGoldenHour?: boolean;
}

export interface ServerToClientEvents {
  partyUpdated: (party: Party) => void;
  joined: (data: { userId: string; partyId: string }) => void;
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
  finishParty: (partyId: string) => void;
}

export interface InterServerEvents {
  ping: () => void;
}

export interface SocketData {
  userId: string;
  partyId: string;
}
