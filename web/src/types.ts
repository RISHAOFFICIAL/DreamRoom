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
