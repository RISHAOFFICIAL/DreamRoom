import { useState, useEffect } from 'react'
import { socket } from './socket'
import type { Party } from './types'
import JoinRoom from './components/JoinRoom'
import PartyRoom from './components/PartyRoom'
import RevealSequence from './components/RevealSequence'
import AdminDashboard from './components/AdminDashboard'
import './index.css'

function App() {
  const [party, setParty] = useState<Party | null>(null)
  const [userName, setUserName] = useState('')
  const [joined, setJoined] = useState(false)
  const [isRevealing, setIsRevealing] = useState(false)
  const [initialPartyId, setInitialPartyId] = useState('')
  const [isAdmin, setIsAdmin] = useState(false)

  useEffect(() => {
    const path = window.location.pathname
    if (path === '/admin') {
      setIsAdmin(true)
      return
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

  if (isRevealing && party) {
    return <RevealSequence party={party} userName={userName} />
  }

  if (joined && party) {
    return <PartyRoom party={party} userName={userName} />
  }

  return <JoinRoom onJoin={handleJoin} initialPartyId={initialPartyId} />
}

export default App
