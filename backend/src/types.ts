export interface User {
  id: string;
  name: string;
  isHost: boolean;
  isBuilding?: boolean;
  ssid?: string;
  ipGroup?: string;
  isBuilder?: boolean;
  ownedKits?: string[];
  nearbyDevicesCount?: number;
}

export interface BoardItem {
  id: string;
  url: string;
  x: number;
  y: number;
  rotation: number;
  scale: number;
  addedBy: string;
  witnesses: string[]; // List of user names/IDs who witnessed this
}

export interface GoldenSpark {
  id: string;
  fromName: string;
  itemId: string;
  timestamp: number;
}

export interface Party {
  id: string;
  hostId: string;
  status: 'building' | 'reveal' | 'finished';
  participants: User[];
  items: BoardItem[];
  sparks: GoldenSpark[];
  createdAt: number;
  isGoldenHour: boolean;
  isManualGoldenHour?: boolean;
  isBuilderHosted?: boolean; // Builder Plan host
}

export interface ServerToClientEvents {
  partyUpdated: (party: Party) => void;
  joined: (data: { userId: string; partyId: string }) => void;
  goldenRevealTriggered: (partyId: string) => void;
  goldenHourToggled: (enabled: boolean) => void;
  itemWitnessed: (data: { itemId: string; witnessedBy: string; spark: GoldenSpark }) => void;
  error: (message: string) => void;
}

export interface ClientToServerEvents {
  createParty: (hostName: string, ssid?: string) => void;
  joinParty: (partyId: string, userName: string, ssid?: string) => void;
  triggerReveal: (partyId: string) => void;
  toggleGoldenHour: (partyId: string, enabled: boolean) => void;
  updateBuildingState: (partyId: string, isBuilding: boolean) => void;
  witnessItem: (partyId: string, itemId: string) => void;
  addItem: (partyId: string, item: Omit<BoardItem, 'witnesses'>) => void;
  finishParty: (partyId: string) => void;
}

export interface InterServerEvents {
  ping: () => void;
}

export interface SocketData {
  userId: string;
  partyId: string;
}
