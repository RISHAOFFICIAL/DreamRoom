import React, { useState } from 'react';
import { Sparkles, Wifi } from 'lucide-react';

interface Props {
  onJoin: (name: string, partyId: string, ssid?: string) => void;
  initialPartyId?: string;
}

const JoinRoom: React.FC<Props> = ({ onJoin, initialPartyId }) => {
  const [name, setName] = useState('');
  const [partyId, setPartyId] = useState(initialPartyId || '');
  const [ssid, setSsid] = useState('');

  React.useEffect(() => {
    if (initialPartyId) {
      setPartyId(initialPartyId);
    }
  }, [initialPartyId]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (name && partyId) {
      onJoin(name, partyId.toUpperCase(), ssid || undefined);
    }
  };

  return (
    <div className="min-h-screen bg-[#0E0C14] flex items-center justify-center p-4">
      <div className="max-w-md w-full space-y-8 text-center">
        <div className="space-y-2">
          <h1 className="text-5xl font-serif text-[#E8C97A] flex items-center justify-center gap-3">
            DreamRoom <Sparkles className="w-8 h-8" />
          </h1>
          <p className="text-[#5E8FA7] font-serif italic text-lg">Your dreams, witnessed.</p>
        </div>

        <form onSubmit={handleSubmit} className="mt-8 space-y-6 bg-[#16141D] p-8 rounded-2xl border border-[#E8C97A]/20 shadow-2xl">
          <div className="space-y-4">
            <div>
              <label htmlFor="name" className="block text-left text-sm font-medium text-[#E8C97A]/60 uppercase tracking-widest mb-1">
                Your Name
              </label>
              <input
                id="name"
                type="text"
                required
                className="w-full bg-[#0E0C14] border border-[#E8C97A]/20 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-[#E8C97A] transition-colors"
                placeholder="Avery"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </div>
            <div>
              <label htmlFor="partyId" className="block text-left text-sm font-medium text-[#E8C97A]/60 uppercase tracking-widest mb-1">
                Party ID
              </label>
              <input
                id="partyId"
                type="text"
                required
                className="w-full bg-[#0E0C14] border border-[#E8C97A]/20 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-[#E8C97A] transition-colors uppercase"
                placeholder="GOLDEN"
                value={partyId}
                onChange={(e) => setPartyId(e.target.value)}
              />
            </div>
            <div>
              <label htmlFor="ssid" className="block text-left text-sm font-medium text-[#E8C97A]/60 uppercase tracking-widest mb-1 flex items-center gap-2">
                WiFi SSID <Wifi className="w-3 h-3" />
              </label>
              <input
                id="ssid"
                type="text"
                className="w-full bg-[#0E0C14] border border-[#E8C97A]/20 rounded-lg px-4 py-3 text-white focus:outline-none focus:border-[#E8C97A] transition-colors"
                placeholder="Home_WiFi (optional)"
                value={ssid}
                onChange={(e) => setSsid(e.target.value)}
              />
              <p className="text-[10px] text-white/30 text-left mt-1 italic">3+ on same SSID triggers Golden Hour.</p>
            </div>
          </div>

          <button
            type="submit"
            className="w-full bg-[#E8C97A] text-[#0E0C14] font-serif font-bold py-3 rounded-lg hover:bg-[#d4b05a] transition-all transform hover:scale-[1.02] active:scale-[0.98] shadow-lg shadow-[#E8C97A]/10"
          >
            Enter the DreamRoom
          </button>
        </form>
      </div>
    </div>
  );
};

export default JoinRoom;
