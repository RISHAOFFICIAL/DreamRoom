import React from 'react';
import { Party, User } from '../types';

interface HostAnalyticsProps {
  party: Party;
  onClose: () => void;
}

const HostAnalytics: React.FC<HostAnalyticsProps> = ({ party, onClose }) => {
  const participantCount = party.participants.length;
  
  // Calculate completion percentage (target 5 items per person)
  const itemsPerUser = party.participants.map(user => ({
    name: user.name,
    count: party.items.filter(item => item.addedBy === user.id).length
  }));

  const completedCount = itemsPerUser.filter(u => u.count >= 5).length;
  const completionPercentage = participantCount > 0 
    ? Math.round((completedCount / participantCount) * 100) 
    : 0;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-md">
      <div className="w-full max-w-2xl bg-[#1a1a1a] border border-[#E8C97A]/30 rounded-xl p-8 shadow-2xl">
        <div className="flex justify-between items-center mb-8">
          <h2 className="text-3xl font-serif text-[#E8C97A]">Gathering Insights</h2>
          <button 
            onClick={onClose}
            className="text-white/50 hover:text-white transition-colors"
          >
            ✕ Close
          </button>
        </div>

        <div className="grid grid-cols-2 gap-6 mb-8">
          <div className="bg-white/5 rounded-lg p-6 border border-white/10">
            <p className="text-sm uppercase tracking-widest text-white/40 mb-1">Party Density</p>
            <p className="text-4xl font-light text-white">{participantCount} <span className="text-sm text-white/40">Dreamers</span></p>
          </div>
          <div className="bg-white/5 rounded-lg p-6 border border-white/10">
            <p className="text-sm uppercase tracking-widest text-white/40 mb-1">Board Completion</p>
            <p className="text-4xl font-light text-[#E8C97A]">{completionPercentage}%</p>
          </div>
        </div>

        <div className="space-y-4 max-h-60 overflow-y-auto pr-2">
          <p className="text-sm uppercase tracking-widest text-white/40 mb-2">Participant Progress</p>
          {itemsPerUser.map((user, i) => (
            <div key={i} className="flex items-center justify-between group">
              <span className="text-white/80 font-serif">{user.name}</span>
              <div className="flex items-center gap-4 flex-1 ml-8">
                <div className="h-1 bg-white/10 flex-1 rounded-full overflow-hidden">
                  <div 
                    className={`h-full transition-all duration-500 ${user.count >= 5 ? 'bg-[#E8C97A]' : 'bg-white/40'}`}
                    style={{ width: `${Math.min((user.count / 5) * 100, 100)}%` }}
                  />
                </div>
                <span className={`text-xs font-mono w-8 text-right ${user.count >= 5 ? 'text-[#E8C97A]' : 'text-white/40'}`}>
                  {user.count}/5
                </span>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-10 pt-6 border-t border-white/10 flex justify-between items-center">
          <div className="flex items-center gap-3">
            <div className={`w-3 h-3 rounded-full animate-pulse ${party.isGoldenHour ? 'bg-[#E8C97A] shadow-[0_0_10px_#E8C97A]' : 'bg-white/20'}`} />
            <span className="text-sm text-white/60">
              {party.isGoldenHour ? 'Golden Hour Active' : 'Waiting for Ritual Density'}
            </span>
          </div>
          {party.isBuilderHosted && (
            <span className="px-3 py-1 bg-[#E8C97A]/20 text-[#E8C97A] border border-[#E8C97A]/30 rounded-full text-xs uppercase tracking-tighter">
              Builder Session
            </span>
          )}
        </div>
      </div>
    </div>
  );
};

export default HostAnalytics;
