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
  witnesses: string[];
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
  isBuilderHosted?: boolean;
}
