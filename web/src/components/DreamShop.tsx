import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';

const SHOP_KITS = [
  {
    id: 'sanctuary',
    name: 'The Sanctuary Pack',
    description: 'Cinematic soundscapes and luxury botanical assets for deep focus.',
    price: '$4.99',
    cover: '/assets/sanctuary/cover.png',
    assets: ['Misty Mountain BG', 'Golden Fern', 'Raw Linen Texture', 'Zen Forest Audio']
  },
  {
    id: 'cosmic',
    name: 'Cosmic Manifestation',
    description: 'Nebula backgrounds and celestial elements for big dreaming.',
    price: '$3.99',
    cover: 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?auto=format&fit=crop&w=800&q=80',
    assets: ['Deep Space BG', 'Star Dust Overlay', 'Moon Phase Clips', 'Etheric Audio']
  }
];

export const DreamShop: React.FC<{ userId: string }> = ({ userId }) => {
  const [ownedKits, setOwnedKits] = useState<string[]>([]);
  const [purchasing, setPurchasing] = useState<string | null>(null);

  useEffect(() => {
    fetch(`/api/owned-kits/${userId}`)
      .then(res => res.json())
      .then(setOwnedKits)
      .catch(err => console.error('Failed to fetch owned kits:', err));
  }, [userId]);

  const handlePurchase = async (kitId: string) => {
    setPurchasing(kitId);
    // Simulate payment delay
    await new Promise(resolve => setTimeout(resolve, 1500));
    
    try {
      const res = await fetch('/api/unlock-kit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId, kitId })
      });
      
      if (res.ok) {
        setOwnedKits(prev => [...prev, kitId]);
      }
    } catch (err) {
      console.error('Purchase failed:', err);
    } finally {
      setPurchasing(null);
    }
  };

  return (
    <div className="p-8 bg-[#0E0C14] min-h-screen text-white font-serif">
      <h1 className="text-4xl mb-8 text-[#E8C97A] italic">The Dream Shop</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {SHOP_KITS.map(kit => (
          <motion.div 
            key={kit.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-[#1A1822] border border-[#2D2A37] rounded-lg overflow-hidden flex flex-col"
          >
            <div className="h-48 overflow-hidden">
              <img src={kit.cover} alt={kit.name} className="w-full h-full object-cover transition-transform duration-700 hover:scale-110" />
            </div>
            <div className="p-6 flex-grow">
              <div className="flex justify-between items-start mb-2">
                <h2 className="text-2xl text-[#E8C97A]">{kit.name}</h2>
                <span className="text-sm font-sans bg-[#2D2A37] px-2 py-1 rounded">{kit.price}</span>
              </div>
              <p className="text-gray-400 mb-4 font-sans text-sm">{kit.description}</p>
              <div className="space-y-1 mb-6">
                {kit.assets.map(asset => (
                  <div key={asset} className="text-xs text-gray-500 flex items-center">
                    <span className="w-1 h-1 bg-[#E8C97A] rounded-full mr-2" />
                    {asset}
                  </div>
                ))}
              </div>
              
              {ownedKits.includes(kit.id) ? (
                <button className="w-full py-3 rounded bg-green-900/20 text-green-400 border border-green-900/50 cursor-default">
                  Unlocked & Ready
                </button>
              ) : (
                <button 
                  onClick={() => handlePurchase(kit.id)}
                  disabled={purchasing !== null}
                  className="w-full py-3 rounded bg-[#E8C97A] text-black font-bold transition-opacity hover:opacity-90 disabled:opacity-50"
                >
                  {purchasing === kit.id ? 'Unlocking...' : 'Purchase Kit'}
                </button>
              )}
            </div>
          </motion.div>
        ))}
      </div>
    </div>
  );
};
