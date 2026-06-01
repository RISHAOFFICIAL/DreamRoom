# DreamRoom - Vision Board Gathering Platform

DreamRoom is a social ritual platform for building vision boards together in real-time. This repository is organized as a monorepo containing the core components of the DreamRoom ecosystem.

## Project Structure

- **`/ios`**: The native iOS application built with SwiftUI. It features a tactile board canvas, "The Archive" for clipping inspiration, and the cinematic "Golden Reveal" sequence.
- **`/backend`**: The real-time infrastructure powered by Node.js, Express, and Socket.io. It uses Redis for horizontal scaling and SQLite for persistent "Witnessing" history.
- **`/web`**: The web guest portal and admin dashboard. Allows participants to join gatherings via browser and provides hosts with a live monitoring dashboard.

## Key Features

- **The Golden Hour**: A specialized luxury UI and soundscape triggered when participants are in physical proximity (same WiFi) or via manual host override.
- **Witnessing History**: A persistent archive of completed vision boards and the "witnesses" who were present.
- **Dream Kits**: Thematic asset packs (Sanctuary, City of Dreams, Cosmic Manifestation) with integrated ambient soundscapes.
- **Real-time Sync**: High-performance synchronization across mobile and web participants.

## Getting Started

### Backend
1. Navigate to `/backend`.
2. Install dependencies: `npm install`.
3. Start the dev server: `npm run dev`.
*Requires a running Redis instance for full scaling support.*

### Web Portal
1. Navigate to `/web`.
2. Install dependencies: `npm install`.
3. Start the Vite dev server: `npm run dev`.

### iOS App
1. Open the project in Xcode from the `/ios` directory.
2. Ensure the backend URL in `SocketService.swift` matches your local or deployed backend.

## Detroit Tour Configuration
The current build is optimized for the "City of Dreams" Detroit Tour, featuring specialized branding and scaling support for 100+ simultaneous participants.
