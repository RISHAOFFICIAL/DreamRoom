import { execSync } from 'child_process';

export const queryTeamDb = (sql: string) => {
  try {
    // Sanitize and wrap in team-db command
    const output = execSync(`team-db "${sql.replace(/"/g, '\\"')}"`).toString();
    return JSON.parse(output);
  } catch (error) {
    console.error('team-db error:', error);
    return null;
  }
};

export const archiveBoard = async (party: any) => {
  const boardId = `${party.id}_${Date.now()}`;
  const mockItems = [
    { id: '1', url: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=400&q=80', x: 15, y: 15, rotation: -5, scale: 1.1, addedBy: 'System' },
    { id: '2', url: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=400&q=80', x: 55, y: 10, rotation: 3, scale: 1.0, addedBy: 'System' },
    { id: '3', url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80', x: 25, y: 55, rotation: 8, scale: 1.2, addedBy: 'System' },
    { id: '4', url: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=400&q=80', x: 65, y: 50, rotation: -2, scale: 1.0, addedBy: 'System' },
  ];

  const finalState = JSON.stringify({
    participants: party.participants,
    items: party.items && party.items.length > 0 ? party.items : mockItems,
    createdAt: party.createdAt,
    finishedAt: Date.now(),
    isGoldenHour: party.isGoldenHour
  }).replace(/'/g, "''"); // Escape single quotes for SQL

  const host = party.participants.find((p: any) => p.isHost);
  const hostName = (host?.name || 'Unknown').replace(/'/g, "''");
  
  // Insert into archived_boards
  queryTeamDb(`
    INSERT INTO archived_boards (id, party_id, host_id, host_name, created_at, status, final_state_json)
    VALUES ('${boardId}', '${party.id}', '${party.hostId}', '${hostName}', ${party.createdAt}, 'finished', '${finalState}')
  `);

  // Insert participants
  for (const user of party.participants) {
    const userName = user.name.replace(/'/g, "''");
    queryTeamDb(`
      INSERT OR IGNORE INTO board_participants (board_id, user_id, user_name)
      VALUES ('${boardId}', '${user.id}', '${userName}')
    `);
  }
};
