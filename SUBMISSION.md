# 🏆 1v1 — Competitive Real-Time Multiplayer Platform

> **Build Something Real: The Serverpod Hackathon Submission**  
> **Live App (Serverpod Cloud):** [https://onevone.serverpod.space/](https://onevone.serverpod.space/)  
> **Serverpod Cloud API:** [https://onevone.api.serverpod.space/](https://onevone.api.serverpod.space/)  
> **Live Diagnostics & Health Probe:** [https://onevone.serverpod.space/healthz](https://onevone.serverpod.space/healthz)  
> **Code Repository:** [GitHub Repository](https://github.com/ananthrockz91/1v1)  

---

## 💡 Project Description

### What 1v1 Does
**1v1** is a competitive, full-stack multiplayer gaming platform built entirely in Dart. It features two strategic 1v1 arenas:
1. **Triangle Tactics**: A territory-capture game on an equilateral triangular peg lattice where players draw edges to complete triangles for bonus turns and points.
2. **Gravity Drop Duel**: A tactical Connect Four arena featuring gravity physics, variable grid dimensions (7×6, 8×7, 9×8 Connect-5), and 4-angle vector win detection.

Players can jump into instant **Solo Practice vs. a Minimax Tactical Bot** or challenge friends worldwide via **Authoritative Online 1v1 Multiplayer** with sub-50ms WebSocket synchronization, seamless **QR code scanning**, and **deep link room sharing** (`?room=CODE`). After any match, players can inspect the **Deterministic Replay Scrubber** to analyze their strategy move-by-move.

### How It Uses Serverpod & Flutter
- **Flutter Web & Mobile (Frontend)**: Delivers a responsive cyberpunk dark-mode interface with Riverpod state management, custom Canvas geometry rendering, a zero-latency Web Audio API sound synthesizer, and dynamic deep-link routing.
- **Serverpod 4.0.4 (Backend)**: Runs as an authoritative production server on Serverpod Cloud backed by managed PostgreSQL. The backend manages WebSocket game sessions (`session.messages`), enforces ACID transaction locks (`session.db.transaction`), validates 100% of player moves authoritatively with zero client trust, manages user profiles with `serverpod_auth_idp`, runs scheduled Cron Future Calls for leaderboard compaction, serves custom avatars via Native Cloud Storage (`session.storage`), and serves the compiled Flutter web application bundle directly.

---

## ⚖️ How 1v1 Meets the Judging Criteria

### 1. Does It Work?
*Criteria: "It runs, the core flow completes, nothing critical is faked."*

- **Live & Fully Deployed**: Deployed and running 24/7 on official **Serverpod Cloud** infrastructure with a managed PostgreSQL cluster at [https://onevone.serverpod.space/](https://onevone.serverpod.space/).
- **Zero Faked Data**:
  - Every match, move history record, user profile, ELO rating, and daily leaderboard entry is read and written directly to PostgreSQL.
  - No mock timers, fake polling, or dummy bots pretending to be multiplayer: online matches use genuine bidirectional Serverpod WebSocket streams (`session.messages`).
- **Complete End-to-End User Flow**:
  1. **Authentication / Guest Access**: Register an account with email/password or use instant guest mode via `serverpod_auth_idp`.
  2. **Room Creation & Auto-Join**: Create a private room, copy the invite link, or scan the live QR code on a second device or tab; the app auto-detects `?room=CODE` and connects instantly.
  3. **Real-Time Gameplay**: Both players tap "Ready to Play", the match launches simultaneously, and moves synchronize in real-time over WebSockets with tactile audio.
  4. **Victory & ELO Progression**: On game completion, win/loss stats and ELO ratings are updated in the database, and the match is archived for historical replay scrubbing.
  5. **Live In-App Admin Board**: Judges can tap the Memory Chip icon in the top AppBar to inspect live DB latency (ms), active room counts, player profiles, and trigger the nightly maintenance Future Call in real time.

---

### 2. Use of the Serverpod Stack
*Criteria: "Doing real work, not sitting behind a static page."*

1v1 does not just use Serverpod as a basic CRUD REST gateway. It leverages **15 distinct Serverpod subsystems** doing heavy, real-world work:

1. **100% Authoritative Server Move Validation**: Zero client trust. Every online move is validated inside `session.db.transaction` with strict optimistic locking (`clientStateVersion == match.stateVersion`) before any database commit or WebSocket broadcast.
2. **Real-Time WebSocket Streaming (`session.messages`)**: Bidirectional pub/sub event channels (`match_$matchId`) stream moves, player turn handoffs, forfeit events, and game-over packets with sub-50ms latency.
3. **Scheduled Tasks & Cron Future Calls (`DailyMaintenanceCall`)**: Background cron worker registered at server boot (`pod.registerFutureCall`) running nightly at 1:00 AM IST to purge abandoned lobbies (>30 min), compact daily match wins into leaderboard standings, and flush stale caches.
4. **Native Cloud Storage (`session.storage` & `FileUploader`)**: Generates secure pre-signed binary upload descriptors for custom player avatars, verifies file persistence, and attaches public CDN URLs to player profiles.
5. **In-Memory Caching (`session.caches.local`)**: Multi-tiered RAM caching with automatic group invalidation (`session.caches.local.invalidateGroup`) to handle high-concurrency leaderboard queries and profile lookups with 5-minute TTLs.
6. **Authentication & Identity (`serverpod_auth_idp`)**: Secure password hashing and JWT issuance integrated with an `onAfterAccountCreated` lifecycle hook that automatically provisions a `PlayerProfile` with 1200 base ELO.
7. **Custom Built-In Web Server Routes**: Mounts a custom `/healthz` diagnostic probe on `pod.webServer` querying live database connectivity and latency, while serving the compiled Flutter single-page application directly without reverse proxy overhead.
8. **Declarative Database Migrations**: Schema evolutions for 5 relational tables (`game_match`, `match_move_record`, `player_profile`, `daily_leaderboard`, `scheduled_job_log`) managed through Serverpod declarative migrations.

---

### 3. Craft and Technical Creativity
*Criteria: "Rough is fine, careless is not."*

- **Pure Shared Rules Engine (`packages/game_core`)**:
  - The game logic, coordinate lattices, and win validators exist in a pure Dart package with zero external dependencies.
  - **Shared by Frontend & Backend**: The exact same rules engine powers the authoritative Serverpod backend validator, the client-side optimistic UI preview, and the offline tactical minimax bot.
- **Zero-Latency Web Audio API Synthesizer**:
  - Rather than loading laggy external MP3 files, the app embeds a browser-native Web Audio API synthesizer (`window.oneVOneAudio`) generating distinct procedural harmonic frequencies for edge clicks, triangle captures, bonus turns, and victory arpeggios.
- **Deterministic Match Replay Scrubber**:
  - Every match move is logged. The replay engine can fast-forward, rewind, pause, and step through past matches with synchronized capture audio and turn indicators.
- **Optimistic UI with Instant Server Rollback**:
  - Players experience instantaneous tap responses. If an invalid move or race condition occurs, the client automatically rolls back to the authoritative server state.
- **Comprehensive Quality Gates & Testing**:
  - **24 automated test suites** passing cleanly with zero warnings.
  - Includes **Property-Based Testing** (50 seeded random games verifying mathematical board invariants at every single ply) and an **Exhaustive Small-Board Validator** traversing all reachable game states on order-2 geometry.

---

### 4. Usefulness
*Criteria: "A clear user with a clear problem, and this helps."*

#### 🎯 Vision & Mission
- **Vision**: To become the premier micro-break gaming platform that transforms idle downtime into engaging, brain-stimulating refreshments.
- **Mission**: Deliver elegant, high-cognition, deterministic strategy mini-games engineered for quick 2-to-3 minute mental reboots—free of ads, bloated downloads, or predatory microtransactions.

#### 👤 The User & Problem
- **The Micro-Break Dilemma**: Knowledge workers, students, developers, and thinkers frequently need a quick 2-to-3 minute pause between meetings, study sessions, or deep-work sprints to reset their focus.
- **The Current Alternatives Fail**:
  - Social media feeds lead to passive, draining doom-scrolling rather than active mental refreshment.
  - Mainstream mobile games are bloated (often requiring 1–2 GB downloads), riddled with unskippable video ads, predatory pay-to-win mechanics, and prolonged matchmaking queues.
  - There is a severe lack of lightweight, intellectually stimulating 1v1 games that can be launched immediately with a friend or colleague for a quick tactical showdown.

#### 🚀 How 1v1 Solves This
- **Brain-Sharpening Mini-Games**: Titles like *Triangle Tactics* and *Gravity Drop Duel* engage spatial reasoning, geometry, and forward planning. They deliver a satisfying, complete mental workout in under 180 seconds.
- **Zero-Barrier Instant Access**:
  - **Live on Web Today**: Runs instantly in any desktop or mobile browser at [onevone.serverpod.space](https://onevone.serverpod.space/) with zero download or installation.
  - **Seamless Friend Challenges**: Colleague across the desk or friend on Slack? Generate a room link or QR code, and your opponent joins the match within 3 seconds.
- **Future-Ready Mobile Native Roadmap**:
  - Because 1v1 is built with **Flutter**, the exact same codebase compiles natively to **iOS and Android**. 
  - As we scale the platform with new brain-training titles, native mobile builds with push notifications, offline local pass-and-play, and home-screen widgets will provide frictionless on-the-go refreshment.
- **Play Anywhere — Online or Offline**:
  - When in transit or in areas with spotty connectivity, players can seamlessly switch to the client-side tactical minimax bot for instant offline brain practice with zero latency.
- **Pure Competitive Integrity**:
  - Powered by Serverpod's authoritative validation and ACID transaction locks, players enjoy 100% fair, cheat-free, deterministic games with no pay-to-win distractions.
