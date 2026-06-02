import { useState, useEffect } from 'react'
import { socket } from './socket'
import type { Party } from './types'
import JoinRoom from './components/JoinRoom'
import PartyRoom from './components/PartyRoom'
import RevealSequence from './components/RevealSequence'
import AdminDashboard from './components/AdminDashboard'
import DreamArchive from './components/DreamArchive'
import { DreamShop } from './components/DreamShop'
import { Archive, ShoppingBag, ArrowLeft } from 'lucide-react'
import './index.css'

function App() {
  const [party, setParty] = useState<Party | null>(null)
  const [userName, setUserName] = useState('')
  const [userId, setUserId] = useState(localStorage.getItem('dreamroom_userId') || '')
  const [joined, setJoined] = useState(false)
  const [isRevealing, setIsRevealing] = useState(false)
  const [initialPartyId, setInitialPartyId] = useState('')
  const [isAdmin, setIsAdmin] = useState(false)
  const [showArchive, setShowArchive] = useState(false)
  const [showShop, setShowShop] = useState(false)

  useEffect(() => {
    const path = window.location.pathname
    if (path === '/admin') {
      setIsAdmin(true)
      return
    }

    if (path === '/archive') {
      setShowArchive(true)
    }

    if (path === '/shop') {
      setShowShop(true)
    }

    // Handle join via URL: /join/PARTYID
    if (path.startsWith('/join/')) {
      const id = path.split('/join/')[1]
      if (id) {
        setInitialPartyId(id.toUpperCase())
      }
    }

    socket.on('partyUpdated', (updatedParty: Party) => {
      setParty(updatedParty)
      if (updatedParty.status === 'reveal') {
        setIsRevealing(true)
      }
    })

    socket.on('joined', ({ userId: newUserId }) => {
      setUserId(newUserId)
      localStorage.setItem('dreamroom_userId', newUserId)
    })

    socket.on('goldenRevealTriggered', () => {
      setIsRevealing(true)
    })

    socket.on('goldenHourToggled', (enabled: boolean) => {
      console.log('Golden Hour:', enabled);
      // We could trigger a toast or sound here
    })

    socket.on('error', (msg: string) => {
      alert(msg)
    })

    return () => {
      socket.off('partyUpdated')
      socket.off('goldenRevealTriggered')
      socket.off('goldenHourToggled')
      socket.off('error')
    }
  }, [])

  const handleJoin = (name: string, partyId: string, ssid?: string) => {
    setUserName(name)
    socket.connect()
    socket.emit('joinParty', partyId, name, ssid)
    setJoined(true)
  }

  if (isAdmin) {
    return <AdminDashboard />
  }

  if (showArchive && userId) {
    return <DreamArchive userId={userId} onBack={() => setShowArchive(false)} />
  }

  if (showShop && userId) {
    return (
      <div className="relative">
        <button 
          onClick={() => setShowShop(false)}
          className="fixed top-8 left-8 z-50 flex items-center gap-2 bg-[#1A1822] text-[#E8C97A] px-4 py-2 rounded-full border border-[#2D2A37] hover:bg-[#2D2A37] transition-all"
        >
          <ArrowLeft className="w-4 h-4" /> Back to Ritual
        </button>
        <DreamShop userId={userId} />
      </div>
    )
  }

  if (isRevealing && party) {
    return <RevealSequence party={party} userName={userName} />
  }

  if (joined && party) {
    return <PartyRoom party={party} userName={userName} />
  }

  return (
    <div className="relative">
      <JoinRoom onJoin={handleJoin} initialPartyId={initialPartyId} />
      {userId && (
        <div className="fixed bottom-6 right-6 flex flex-col gap-2 items-end">
          <button 
            onClick={() => setShowShop(true)}
            className="flex items-center gap-2 bg-[#E8C97A] border border-[#E8C97A]/20 px-4 py-2 rounded-full text-black text-xs uppercase tracking-widest font-bold hover:opacity-90 transition-all shadow-xl"
          >
            <ShoppingBag className="w-4 h-4" /> Dream Shop
          </button>
          <button 
            onClick={() => setShowArchive(true)}
            className="flex items-center gap-2 bg-[#16141D] border border-[#E8C97A]/20 px-4 py-2 rounded-full text-[#E8C97A] text-xs uppercase tracking-widest font-bold hover:bg-[#2a220a] transition-all shadow-xl"
          >
            <Archive className="w-4 h-4" /> View Archive
          </button>
        </div>
      )}
    </div>
  )
}

export default App
