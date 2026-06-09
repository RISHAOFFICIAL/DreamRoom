import React, { useEffect, useState } from 'react';
import type { Party } from '../types';
import { Activity, Users, Clock, Zap, ExternalLink } from 'lucide-react';

const AdminDashboard: React.FC = () => {
  const [parties, setParties] = useState<Party[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const handleToggleGoldenHour = async (partyId: string, enabled: boolean) => {
    try {
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL || 'http://localhost:3001'}/api/admin/parties/${partyId}/golden`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ enabled })
      });
      if (!response.ok) throw new Error('Failed to toggle golden hour');
      fetchParties();
    } catch (err) {
      alert(err instanceof Error ? err.message : 'Unknown error');
    }
  };

  const fetchParties = async () => {
    try {
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL || 'http://localhost:3001'}/api/admin/parties`);
      if (!response.ok) throw new Error('Failed to fetch parties');
      const data = await response.json();
      setParties(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchParties();
    const interval = setInterval(fetchParties, 5000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="min-h-screen bg-[#0E0C14] text-white font-serif p-8">
      <header className="max-w-7xl mx-auto mb-12 flex justify-between items-center">
        <div>
          <h1 className="text-4xl font-bold text-[#E8C97A] mb-2 flex items-center gap-3">
            <Activity className="w-8 h-8" /> DreamRoom Admin
          </h1>
          <p className="text-white/40 italic">Live gathering monitoring dashboard</p>
        </div>
        <div className="bg-[#16141D] border border-[#E8C97A]/20 px-6 py-3 rounded-xl flex items-center gap-8">
          <div className="text-center">
            <div className="text-[#E8C97A] font-bold text-2xl">{parties.length}</div>
            <div className="text-[10px] uppercase tracking-widest text-white/40">Active Parties</div>
          </div>
          <div className="text-center">
            <div className="text-[#5E8FA7] font-bold text-2xl">
              {parties.reduce((acc, p) => acc + p.participants.length, 0)}
            </div>
            <div className="text-[10px] uppercase tracking-widest text-white/40">Total Dreamers</div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto">
        {loading && parties.length === 0 ? (
          <div className="text-center py-20 text-[#E8C97A] animate-pulse">Initializing connection...</div>
        ) : error ? (
          <div className="bg-red-900/20 border border-red-500/50 p-6 rounded-xl text-red-200">
            Error: {error}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {parties.map((party) => (
              <div key={party.id} className={`p-6 rounded-2xl border transition-all duration-500 ${party.isGoldenHour ? 'bg-[#2a220a] border-[#E8C97A]/40 shadow-[0_0_20px_rgba(232,201,122,0.1)]' : 'bg-[#16141D] border-[#E8C97A]/10'}`}>
                <div className="flex justify-between items-start mb-6">
                  <div>
                    <div className="text-[#E8C97A] font-mono text-sm font-bold mb-1">{party.id}</div>
                    <div className="text-xs text-white/40 flex items-center gap-1">
                      <Clock className="w-3 h-3" /> {new Date(party.createdAt).toLocaleTimeString()}
                    </div>
                  </div>
                  <div className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-tighter ${
                    party.status === 'building' ? 'bg-blue-500/20 text-blue-300' : 
                    party.status === 'reveal' ? 'bg-purple-500/20 text-purple-300' : 'bg-green-500/20 text-green-300'
                  }`}>
                    {party.status}
                  </div>
                </div>

                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2 text-sm">
                      <Users className="w-4 h-4 text-[#5E8FA7]" />
                      <span>{party.participants.length} Participants</span>
                    </div>
                    {party.isGoldenHour && (
                      <div className="flex items-center gap-1 text-[#E8C97A] text-[10px] font-bold animate-pulse">
                        <Zap className="w-3 h-3 fill-current" /> GOLDEN {party.isManualGoldenHour && '(MANUAL)'}
                      </div>
                    )}
                  </div>

                  <div className="flex flex-wrap gap-2">
                    {party.participants.map(p => (
                      <div key={p.id} title={p.name} className={`w-8 h-8 rounded-full flex items-center justify-center text-[10px] font-bold border ${p.isHost ? 'border-[#E8C97A] text-[#E8C97A]' : 'border-white/10 text-white/60'}`}>
                        {p.name[0]}
                      </div>
                    ))}
                  </div>

                  <div className="pt-4 mt-4 border-t border-white/5 flex justify-between items-center">
                    <a 
                      href={`/join/${party.id}`} 
                      target="_blank" 
                      rel="noopener noreferrer"
                      className="text-[10px] uppercase tracking-widest text-[#5E8FA7] hover:text-[#E8C97A] transition-colors flex items-center gap-1"
                    >
                      View Live Room <ExternalLink className="w-3 h-3" />
                    </a>
                    <button 
                      onClick={() => handleToggleGoldenHour(party.id, !party.isGoldenHour)}
                      className={`text-[10px] px-3 py-1 rounded border transition-colors ${party.isGoldenHour ? 'border-red-500/50 text-red-400 hover:bg-red-500/10' : 'border-[#E8C97A]/50 text-[#E8C97A] hover:bg-[#E8C97A]/10'}`}
                    >
                      {party.isGoldenHour ? 'Disable Golden' : 'Force Golden'}
                    </button>
                  </div>
                </div>
              </div>
            ))}
            {parties.length === 0 && (
              <div className="col-span-full text-center py-20 bg-[#16141D] rounded-3xl border border-dashed border-white/10">
                <p className="text-white/20 italic text-xl">No active gatherings found.</p>
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  );
};

export default AdminDashboard;
