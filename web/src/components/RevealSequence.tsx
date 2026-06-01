import React, { useState, useEffect } from 'react';
import type { Party } from '../types';
import { motion, AnimatePresence } from 'framer-motion';
import { Apple, Sparkles } from 'lucide-react';

interface Props {
  party: Party;
  userName: string;
}

const RevealSequence: React.FC<Props> = ({ party, userName }) => {
  const [step, setStep] = useState<'anticipation' | 'reveal' | 'celebration'>('anticipation');

  useEffect(() => {
    // Sound trigger placeholder
    console.log('Playing Golden Hour Soundscape...');
    
    const timer1 = setTimeout(() => setStep('reveal'), 4000);
    const timer2 = setTimeout(() => setStep('celebration'), 10000);
    return () => {
      clearTimeout(timer1);
      clearTimeout(timer2);
    };
  }, []);

  return (
    <div className="min-h-screen bg-[#0E0C14] flex items-center justify-center overflow-hidden relative">
      {/* Background Glow */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-[#E8C97A]/20 via-transparent to-transparent opacity-50" />

      <AnimatePresence mode="wait">
        {step === 'anticipation' && (
          <motion.div
            key="anticipation"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 1.1 }}
            className="text-center space-y-4 z-10"
          >
            <div className="text-[#E8C97A] text-sm uppercase tracking-[0.5em] font-bold">The Golden Hour</div>
            <h2 className="text-6xl font-serif text-white italic">Silence Your Mind</h2>
          </motion.div>
        )}

        {step === 'reveal' && (
          <motion.div
            key="reveal"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="text-center space-y-12 z-10 w-full max-w-4xl px-8"
          >
            <div className="space-y-2">
              <h2 className="text-[#E8C97A] text-4xl font-serif">The Collective Vision</h2>
              <p className="text-white/60 font-serif italic">Witnessed by {party.participants.length} dreamers</p>
            </div>

            {/* Mock Board Canvas */}
            <motion.div
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              className="aspect-video bg-black rounded-3xl border-2 border-[#E8C97A] shadow-[0_0_50px_rgba(232,201,122,0.2)] flex items-center justify-center relative overflow-hidden"
            >
               <div className="text-[#E8C97A]/20 text-8xl font-serif italic">DREAMS</div>
               {/* Visual Noise/Assets would go here */}
               <motion.div
                 className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"
                 initial={{ opacity: 0 }}
                 animate={{ opacity: 1 }}
                 transition={{ delay: 1 }}
               />
            </motion.div>
          </motion.div>
        )}

        {step === 'celebration' && (
          <motion.div
            key="celebration"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-center space-y-12 z-10 w-full max-w-2xl px-8"
          >
            <div className="space-y-4">
              <Sparkles className="w-12 h-12 text-[#E8C97A] mx-auto mb-4" />
              <h2 className="text-[#E8C97A] text-5xl font-serif italic">Manifest with Us, {userName}</h2>
              <p className="text-white/80 font-serif text-lg leading-relaxed">
                The gathering doesn't end here. Your dreams have been witnessed. Now, bring them to life.
              </p>
            </div>

            <div className="space-y-6">
              <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                <motion.a
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  href="https://apps.apple.com/app/dreamroom"
                  className="w-full sm:w-auto bg-[#E8C97A] text-[#0E0C14] px-10 py-5 rounded-full font-bold flex items-center justify-center gap-3 shadow-[0_0_30px_rgba(232,201,122,0.3)] transition-all"
                >
                  <Apple className="w-6 h-6 fill-current" />
                  <div className="text-left">
                    <div className="text-[10px] uppercase tracking-widest leading-none">Get the App</div>
                    <div className="text-lg font-serif italic">Continue the Gathering</div>
                  </div>
                </motion.a>
              </div>
              <p className="text-white/40 text-sm">Join 2,500+ gathering leaders building their future.</p>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Cinematic Particles */}
      <div className="absolute inset-0 pointer-events-none">
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-1 h-1 bg-[#E8C97A] rounded-full"
            initial={{
              x: Math.random() * window.innerWidth,
              y: Math.random() * window.innerHeight,
              opacity: 0
            }}
            animate={{
              y: [null, Math.random() * -200],
              opacity: [0, 0.8, 0]
            }}
            transition={{
              duration: 2 + Math.random() * 3,
              repeat: Infinity,
              ease: "easeOut",
              delay: Math.random() * 5
            }}
          />
        ))}
      </div>
    </div>
  );
};

export default RevealSequence;
