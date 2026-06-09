import React, { useState, useEffect } from 'react';
import { Sparkles, Calendar, Users, ChevronRight, Archive, Download, CheckCircle2 } from 'lucide-react';
import { motion } from 'framer-motion';

interface BoardItem {
  id: string;
  url: string;
  x: number;
  y: number;
  rotation: number;
  scale: number;
  addedBy?: string;
}

interface ArchivedBoard {
  id: string;
  party_id: string;
  host_id: string;
  host_name: string;
  created_at: number;
  status: string;
  final_state_json: string;
}

interface Props {
  userId: string;
  onBack: () => void;
}

const MOCK_ITEMS: BoardItem[] = [
  { id: '1', url: 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=400&q=80', x: 15, y: 15, rotation: -5, scale: 1.1 },
  { id: '2', url: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=400&q=80', x: 55, y: 10, rotation: 3, scale: 1.0 },
  { id: '3', url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400&q=80', x: 25, y: 55, rotation: 8, scale: 1.2 },
  { id: '4', url: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=400&q=80', x: 65, y: 50, rotation: -2, scale: 1.0 },
];

const DreamArchive: React.FC<Props> = ({ userId, onBack }) => {
  const [boards, setBoards] = useState<ArchivedBoard[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedBoard, setSelectedBoard] = useState<ArchivedBoard | null>(null);
  const [isExporting, setIsExporting] = useState(false);
  const [exportSuccess, setExportExportSuccess] = useState(false);

  useEffect(() => {
    fetch(`${window.location.origin.replace(':5173', ':3001')}/api/archive/${userId}`)
      .then(res => res.json())
      .then(data => {
        setBoards(data);
        setLoading(false);
      })
      .catch(err => {
        console.error('Failed to fetch archive:', err);
        setLoading(false);
      });
  }, [userId]);

  const handleExport = () => {
    setIsExporting(true);
    // Simulate high-res rendering and download
    setTimeout(() => {
      setIsExporting(false);
      setExportExportSuccess(true);
      setTimeout(() => setExportExportSuccess(false), 3000);
    }, 2000);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0E0C14] flex items-center justify-center">
        <div className="text-[#E8C97A] animate-pulse font-serif italic text-xl">Opening the Archive...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0E0C14] text-white font-serif p-8">
      <header className="max-w-4xl mx-auto flex justify-between items-center mb-12">
        <div className="flex items-center gap-4">
          <Archive className="text-[#E8C97A] w-8 h-8" />
          <h1 className="text-4xl text-[#E8C97A]">Dream Archive</h1>
        </div>
        <button 
          onClick={onBack}
          className="text-white/40 hover:text-[#E8C97A] transition-colors uppercase tracking-widest text-xs"
        >
          Back to Gathering
        </button>
      </header>

      <main className="max-w-4xl mx-auto">
        {boards.length === 0 ? (
          <div className="text-center py-20 bg-[#16141D] rounded-3xl border border-[#E8C97A]/10">
            <Sparkles className="w-12 h-12 text-[#E8C97A]/20 mx-auto mb-4" />
            <p className="text-white/40 italic text-lg">No witnessed dreams yet.</p>
            <p className="text-white/20 text-sm mt-2 uppercase tracking-widest">Your journey begins at the next gathering.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-6">
            {boards.map((board) => (
              <motion.div
                key={board.id}
                whileHover={{ scale: 1.01 }}
                onClick={() => setSelectedBoard(board)}
                className="bg-[#16141D] border border-[#E8C97A]/10 rounded-2xl p-6 flex items-center justify-between cursor-pointer hover:border-[#E8C97A]/30 transition-all group"
              >
                <div className="flex items-center gap-6">
                  <div className="w-16 h-16 bg-[#E8C97A]/5 rounded-xl border border-[#E8C97A]/20 flex items-center justify-center text-[#E8C97A]">
                    <Calendar className="w-6 h-6" />
                  </div>
                  <div className="space-y-1">
                    <h3 className="text-xl text-[#E8C97A] group-hover:text-white transition-colors">
                      Gathering: {board.party_id}
                    </h3>
                    <div className="flex items-center gap-4 text-sm text-white/40 italic">
                      <span className="flex items-center gap-1">
                        <Users className="w-3 h-3" /> Hosted by {board.host_name}
                      </span>
                      <span>{new Date(board.created_at).toLocaleDateString()}</span>
                    </div>
                  </div>
                </div>
                <ChevronRight className="text-[#E8C97A]/20 group-hover:text-[#E8C97A] transition-all" />
              </motion.div>
            ))}
          </div>
        )}
      </main>

      {/* Detail Modal */}
      {selectedBoard && (() => {
        const boardData = JSON.parse(selectedBoard.final_state_json);
        const items = boardData.items && boardData.items.length > 0 ? boardData.items : MOCK_ITEMS;
        
        return (
          <div className="fixed inset-0 bg-black/95 backdrop-blur-md z-50 flex items-center justify-center p-4">
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="bg-[#16141D] border border-[#E8C97A]/30 rounded-3xl max-w-4xl w-full p-8 relative overflow-hidden flex flex-col md:flex-row gap-8"
            >
              <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-[#E8C97A] to-transparent opacity-50" />
              
              <button 
                onClick={() => setSelectedBoard(null)}
                className="absolute top-6 right-8 text-white/40 hover:text-white transition-colors z-20"
              >
                ✕
              </button>

              {/* Vision Board Preview */}
              <div className="flex-1 space-y-6">
                <div className="space-y-2">
                  <div className="text-[#E8C97A] text-xs uppercase tracking-[0.5em] font-bold">Witnessed History</div>
                  <h2 className="text-3xl">Gathering {selectedBoard.party_id}</h2>
                  <p className="text-white/40 italic">Held on {new Date(selectedBoard.created_at).toLocaleString()}</p>
                </div>

                <div className="aspect-video bg-black rounded-2xl border border-[#E8C97A]/20 relative overflow-hidden shadow-2xl">
                  {/* Canvas Background */}
                  <div className="absolute inset-0 opacity-20 bg-[radial-gradient(circle_at_center,_var(--tw-gradient-stops))] from-[#E8C97A] via-transparent to-transparent" />
                  
                  {/* Render Board Items */}
                  {items.map((item: BoardItem) => (
                    <motion.div
                      key={item.id}
                      style={{
                        position: 'absolute',
                        left: `${item.x}%`,
                        top: `${item.y}%`,
                        rotate: `${item.rotation}deg`,
                        scale: item.scale,
                        width: '25%',
                      }}
                      initial={{ opacity: 0, scale: 0 }}
                      animate={{ opacity: 1, scale: item.scale }}
                      className="shadow-xl rounded-sm overflow-hidden border border-white/10"
                    >
                      <img src={item.url} alt="Board item" className="w-full h-auto" />
                    </motion.div>
                  ))}
                  
                  <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                     <div className="text-[#E8C97A]/5 text-6xl font-bold italic tracking-tighter select-none">DREAMROOM</div>
                  </div>
                </div>
              </div>

              {/* Sidebar Info */}
              <div className="w-full md:w-64 flex flex-col justify-between">
                <div className="space-y-8 pt-4">
                  <div className="space-y-4">
                    <h4 className="text-[#E8C97A] uppercase tracking-widest text-xs font-bold">The Collective</h4>
                    <div className="flex flex-wrap gap-2">
                      {boardData.participants.map((p: any) => (
                        <div key={p.id} className="px-3 py-1 bg-[#E8C97A]/5 border border-[#E8C97A]/10 rounded-full text-sm text-white/60">
                          {p.name} {p.isHost && '👑'}
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="space-y-4">
                    <h4 className="text-[#E8C97A] uppercase tracking-widest text-xs font-bold">Stats</h4>
                    <div className="space-y-2 text-sm text-white/40 italic">
                       <p>Items Manifested: {items.length}</p>
                       <p>Golden Hour: {boardData.isGoldenHour ? 'Activated' : 'Manual'}</p>
                    </div>
                  </div>
                </div>

                <div className="space-y-3 mt-8">
                  <button 
                    onClick={handleExport}
                    disabled={isExporting}
                    className="w-full py-4 bg-[#E8C97A] text-[#0E0C14] rounded-xl font-bold hover:bg-[#f0d89e] transition-all flex items-center justify-center gap-2 relative overflow-hidden"
                  >
                    {isExporting ? (
                       <span className="animate-pulse">Exporting...</span>
                    ) : exportSuccess ? (
                       <>
                         <CheckCircle2 className="w-5 h-5" />
                         Saved
                       </>
                    ) : (
                       <>
                         <Download className="w-5 h-5" />
                         High-Res Export
                       </>
                    )}
                    {isExporting && (
                       <motion.div 
                         className="absolute bottom-0 left-0 h-1 bg-white/30"
                         initial={{ width: 0 }}
                         animate={{ width: '100%' }}
                         transition={{ duration: 2 }}
                       />
                    )}
                  </button>
                  <button 
                    onClick={() => setSelectedBoard(null)}
                    className="w-full py-4 bg-white/5 border border-white/10 rounded-xl text-white/60 hover:bg-white/10 transition-all text-sm uppercase tracking-widest"
                  >
                    Close
                  </button>
                </div>
              </div>
            </motion.div>
          </div>
        );
      })()}
    </div>
  );
};

export default DreamArchive;

