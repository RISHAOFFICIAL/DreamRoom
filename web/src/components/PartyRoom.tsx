import React from 'react';
import type { Party } from '../types';
import { Users, Layout, Zap, Flame, Crown, Sparkles, BarChart3 } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { socket } from '../socket';
import HostAnalytics from './HostAnalytics';

interface Props {
  party: Party;
  userName: string;
}

const PartyRoom: React.FC<Props> = ({ party, userName }) => {
  const me = party.participants.find(u => u.name === userName);
  const isHost = me?.isHost;

  const [isBuilding, setIsBuilding] = React.useState(false);
  const [showAnalytics, setShowAnalytics] = React.useState(false);

  React.useEffect(() => {
    // Only send if we are NOT the host (host is likely on iOS)
    // Actually, on web anyone can simulate building
    socket.emit('updateBuildingState', party.id, isBuilding);
  }, [isBuilding, party.id]);

  const handleToggleGoldenHour = () => {
    socket.emit('toggleGoldenHour', party.id, !party.isGoldenHour);
  };

  const handleTriggerReveal = () => {
    socket.emit('triggerReveal', party.id);
  };

  return (
    <div className={`min-h-screen transition-colors duration-1000 font-serif ${party.isGoldenHour ? 'bg-[#1a1405]' : 'bg-[#0E0C14]'} text-white`}>
      {/* Header */}
      <header className={`border-b ${party.isGoldenHour ? 'border-[#E8C97A]/30' : 'border-[#E8C97A]/10'} p-6 flex justify-between items-center transition-colors duration-1000 bg-opacity-80 backdrop-blur-md sticky top-0 z-10`}>
        <div className="flex items-center gap-4">
          <div className={`${party.isGoldenHour ? 'bg-[#E8C97A] text-[#0E0C14]' : 'bg-[#E8C97A]/20 text-[#E8C97A]'} px-4 py-1 rounded-full font-bold text-sm transition-all duration-1000`}>
            {party.id}
          </div>
          <h2 className={`text-xl transition-colors duration-1000 ${party.isGoldenHour ? 'text-[#E8C97A]' : 'text-white/80'}`}>
            {party.isGoldenHour ? 'Golden Hour Active' : 'DreamRoom Party'}
          </h2>
        </div>
        <div className="flex items-center gap-6">
          {isHost && (
            <button 
<<<<<<< HEAD
              onClick={() => setShowAnalytics(true)}
              className="flex items-center gap-2 text-[#E8C97A]/60 hover:text-[#E8C97A] transition-colors text-sm uppercase tracking-widest font-bold"
            >
              <BarChart3 className="w-4 h-4" />
              Insights
=======
              onClick={() => setShowAnalytics(!showAnalytics)}
              className={`p-2 rounded-lg transition-colors ${showAnalytics ? 'bg-[#E8C97A] text-black' : 'text-[#E8C97A] hover:bg-[#E8C97A]/10'}`}
              title="Host Analytics"
            >
              <BarChart3 className="w-5 h-5" />
>>>>>>> bbaf5ab (Implement Entitlements System and Host Analytics Dashboard)
            </button>
          )}
          <div className="flex items-center gap-2 text-[#5E8FA7]">
            <Users className="w-5 h-5" />
            <span>{party.participants.length} Present</span>
          </div>
          {party.isGoldenHour ? (
            <div className="flex items-center gap-2 text-[#E8C97A] animate-pulse">
              <Zap className="w-4 h-4 fill-current" />
              <span className="font-bold uppercase tracking-widest text-sm">Collective Flow</span>
            </div>
          ) : (
            <div className="text-[#E8C97A]/60 italic">Building...</div>
          )}
        </div>
      </header>

      <main className="p-8 max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* Collective Activity Sidebar */}
        <div className="lg:col-span-1 space-y-6">
          {isHost && showAnalytics && (
            <motion.div 
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              className="space-y-6"
            >
              <HostAnalytics party={party} />
              <div className="border-t border-[#E8C97A]/10 pt-6" />
            </motion.div>
          )}

          <div className={`p-6 rounded-2xl border transition-all duration-1000 ${party.isGoldenHour ? 'bg-[#2a220a] border-[#E8C97A]/40 shadow-[0_0_20px_rgba(232,201,122,0.1)]' : 'bg-[#16141D] border-[#E8C97A]/10'}`}>
            <h3 className="text-[#E8C97A] uppercase tracking-widest text-xs font-bold mb-4 flex items-center gap-2">
               Participants {party.isGoldenHour && <Flame className="w-3 h-3 fill-current" />}
            </h3>
            <ul className="space-y-4">
              {party.participants.map((user) => (
                <li key={user.id} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={`w-2 h-2 rounded-full ${user.isBuilding ? 'bg-[#E8C97A] animate-ping' : (user.name === userName ? 'bg-green-400' : 'bg-[#5E8FA7]')}`} />
                    <span className={user.name === userName ? 'text-white' : 'text-white/60'}>
                      {user.name} 
                      {user.isHost && <Crown className="w-3 h-3 inline ml-2 text-[#E8C97A]" />}
                    </span>
                  </div>
                  {user.isBuilding && (
                    <motion.div 
                      initial={{ opacity: 0, x: -5 }}
                      animate={{ opacity: 1, x: 0 }}
                      className="text-[10px] text-[#E8C97A] uppercase tracking-tighter italic font-bold"
                    >
                      Clipping...
                    </motion.div>
                  )}
                </li>
              ))}
            </ul>
          </div>

          <div className={`p-6 rounded-2xl border transition-all duration-1000 ${party.isGoldenHour ? 'bg-[#2a220a] border-[#E8C97A]/40' : 'bg-[#16141D] border-[#E8C97A]/10'}`}>
             <h3 className="text-[#E8C97A] uppercase tracking-widest text-xs font-bold mb-4">The Gathering</h3>
             <p className="text-sm text-white/40 leading-relaxed italic mb-6">
               {party.isGoldenHour 
                 ? "The collective energy is peaking. Your visions are merging into a singular sanctuary. Prepare for the final reveal."
                 : "Focus your intentions. Add items to your board on the app. The collective reveal begins when the host initiates the Golden Hour."}
             </p>
             
             {isHost && (
               <div className="space-y-3">
                 <button 
                  onClick={handleToggleGoldenHour}
                  className={`w-full py-3 rounded-lg font-serif font-bold transition-all flex items-center justify-center gap-2 ${party.isGoldenHour ? 'bg-white text-black hover:bg-white/90' : 'bg-[#E8C97A] text-[#0E0C14] hover:bg-[#d4b05a]'}`}
                 >
                   <Zap className="w-4 h-4" />
                   {party.isGoldenHour ? 'Exit Golden Hour' : 'Force Golden Hour'}
                 </button>
                 
                 {party.isGoldenHour && (
                   <button 
                    onClick={handleTriggerReveal}
                    className="w-full py-3 rounded-lg font-serif font-bold bg-white text-black hover:bg-white/90 animate-bounce"
                   >
                     Trigger The Big Reveal
                   </button>
                 )}
               </div>
             )}

             {!isHost && (
                <button 
                  onMouseDown={() => setIsBuilding(true)}
                  onMouseUp={() => setIsBuilding(false)}
                  onMouseLeave={() => setIsBuilding(false)}
                  className={`w-full py-4 rounded-lg font-serif font-bold transition-all flex flex-col items-center justify-center gap-1 border ${isBuilding ? 'bg-[#E8C97A] text-[#0E0C14] border-[#E8C97A]' : 'bg-transparent text-[#E8C97A] border-[#E8C97A]/20 hover:border-[#E8C97A]/60'}`}
                >
                  <div className="flex items-center gap-2">
                    <Sparkles className={`w-4 h-4 ${isBuilding ? 'animate-spin' : ''}`} />
                    {isBuilding ? 'Building Reality...' : 'Hold to Build'}
                  </div>
                  <span className="text-[10px] uppercase tracking-widest opacity-60">Add Energy to the DreamRoom</span>
                </button>
             )}
          </div>
        </div>

        {/* Live Canvas Mockup */}
        <div className="lg:col-span-3">
          <div className={`relative aspect-video rounded-3xl border transition-all duration-1000 overflow-hidden shadow-2xl flex items-center justify-center ${party.isGoldenHour ? 'bg-[#1a1405] border-[#E8C97A]/60 shadow-[0_0_50px_rgba(232,201,122,0.2)]' : 'bg-black border-[#E8C97A]/20'}`}>
            {/* Background elements */}
            <div className={`absolute inset-0 transition-opacity duration-1000 pointer-events-none ${party.isGoldenHour ? 'opacity-30' : 'opacity-10'}`}>
              <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-[#E8C97A] via-transparent to-transparent"></div>
            </div>

            <div className="text-center space-y-4 z-10">
              <Layout className={`w-16 h-16 mx-auto transition-colors duration-1000 ${party.isGoldenHour ? 'text-[#E8C97A]' : 'text-[#E8C97A]/20'}`} />
              <div className={`text-2xl transition-colors duration-1000 ${party.isGoldenHour ? 'text-[#E8C97A] font-bold tracking-widest' : 'text-[#E8C97A]'}`}>
                {party.isGoldenHour ? 'THE GOLDEN GATHERING' : 'Collective Energy Building'}
              </div>
              <div className="flex items-center justify-center gap-2">
                 {party.participants.filter(p => p.isBuilding).map(p => (
                   <motion.div
                     key={p.id}
                     initial={{ scale: 0 }}
                     animate={{ scale: 1 }}
                     exit={{ scale: 0 }}
                     className="w-8 h-8 rounded-full bg-[#E8C97A]/10 border border-[#E8C97A]/30 flex items-center justify-center text-[10px] font-bold text-[#E8C97A]"
                   >
                     {p.name[0]}
                   </motion.div>
                 ))}
                 {party.participants.filter(p => p.isBuilding).length > 0 && (
                   <span className="text-[#E8C97A] text-xs font-serif italic ml-2">are building right now...</span>
                 )}
              </div>
              <p className="text-white/40 max-w-xs mx-auto">
                {party.isGoldenHour 
                  ? "A divine connection has been established. The witness period is complete."
                  : "Watch as everyone contributes to the gathering. The final vision will be unveiled soon."}
              </p>
            </div>

            {/* Simulated particles */}
            <AnimatePresence>
              {[...Array((party.isGoldenHour ? 40 : 10) + (party.participants.filter(p => p.isBuilding).length * 10))].map((_, i) => (
                <motion.div
                  key={i}
                  className="absolute w-1 h-1 bg-[#E8C97A] rounded-full"
                  initial={{ opacity: 0 }}
                  animate={{
                    x: [Math.random() * 800 - 400, Math.random() * 800 - 400],
                    y: [Math.random() * 600 - 300, Math.random() * 600 - 300],
                    opacity: [0, 0.8, 0],
                    scale: [1, party.isGoldenHour ? 2 : 1, 1],
                  }}
                  exit={{ opacity: 0 }}
                  transition={{
                    duration: party.isGoldenHour ? 2 + Math.random() * 2 : 5 + Math.random() * 5,
                    repeat: Infinity,
                    ease: "linear"
                  }}
                />
              ))}
            </AnimatePresence>
          </div>
        </div>
      </main>

      <AnimatePresence>
        {showAnalytics && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            <HostAnalytics 
              party={party} 
              onClose={() => setShowAnalytics(false)} 
            />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default PartyRoom;
