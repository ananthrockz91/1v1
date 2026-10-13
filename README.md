# 1v1 — Competitive Multiplayer Gaming Platform

> **Deterministic turn-based strategy gaming platform built with Flutter and Serverpod.**

[![Serverpod Cloud](https://img.shields.io/badge/Serverpod%20Cloud-LIVE-brightgreen)](https://onevone.serverpod.space/)
[![Serverpod](https://img.shields.io/badge/Serverpod-4.0.4-blue)](https://serverpod.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.20+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart)](https://dart.dev)
[![Tests](https://img.shields.io/badge/Tests-54%20Passing-success)](packages/game_core)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

- 🌐 **Live Web Application:** [https://onevone.serverpod.space/](https://onevone.serverpod.space/)
- 🔌 **Serverpod Cloud API:** [https://onevone.api.serverpod.space/](https://onevone.api.serverpod.space/)
- 🩺 **System Health Probe:** [https://onevone.serverpod.space/healthz](https://onevone.serverpod.space/healthz)
- 🏆 **Hackathon Reviewers & Judges:** See [`HACKATHON_SHOWCASE.md`](HACKATHON_SHOWCASE.md) and [`SUBMISSION.md`](SUBMISSION.md) for the complete 15-subsystem Serverpod evaluation package.

---

## 📖 Overview

**1v1** is a modern, full-stack multiplayer gaming platform built 100% in **Dart**, featuring a **Flutter** client and a **Serverpod** backend backed by PostgreSQL.

The platform is designed around deterministic strategy games where outcomes are dictated entirely by skill, tactics, and foresight. It isolates mathematical game rules into pure Dart packages (`packages/game_core`) that run identically on the client and server, enabling instantaneous client-side move validation, offline solo play against AI, step-by-step match replay scrubbing, and authoritative server synchronization over WebSockets.

---

## 🎮 Playable Game Titles

### 1. Flagship Title: Triangle Tactics
A territorial geometry strategy game played on an equilateral triangular lattice of pegs of order $n$:
- **Lattice Geometry:** $V = \frac{(n + 1)(n + 2)}{2}$ discrete pegs, $E = \frac{3n(n + 1)}{2}$ connectable edge segments, and $F = n^2$ elementary triangular faces.
- **Rules of Play:** Players take turns connecting adjacent pegs with colored neon edges. Completing an elementary triangle claims that face for the player, scores 1 point, and awards an **instant bonus turn**. The player with the most triangles when all edges are placed wins.
- **Engine Package:** [`packages/game_core/lib/src/triangle_tactics/`](packages/game_core/lib/src/triangle_tactics/)
- **Rules Documentation:** [`docs/game_rules.md`](docs/game_rules.md)

### 2. Gravity Drop Duel (Connect Four)
A vertical column tactical game featuring variable arena sizes:
- **Variable Arenas:**
  - **Classic 7×6**: 42 slots, Connect 4.
  - **Tactical 8×7**: 56 slots, Connect 4.
  - **Grand 9×8**: 72 slots, Connect 5.
- **Features:** 4-angle vector win detection ($0^\circ, 45^\circ, 90^\circ, 135^\circ$), column drop guides, bouncy disc animations, and an offline 2-ply minimax lookahead bot with tactical defensive blocking.
- **Engine Package:** [`packages/game_core/lib/src/connect_four/`](packages/game_core/lib/src/connect_four/)

### 3. Reversi (Othello Duel)
A territorial disk-flipping game on a standard 8×8 grid:
- **Features:** Real-time legal move ray-casting in all 8 cardinal directions, dynamic tile flip previews, and an offline heuristic AI evaluating corner dominance, mobility, and positional stability matrices.
- **Engine Package:** [`packages/game_core/lib/src/reversi/`](packages/game_core/lib/src/reversi/)

---

## ✨ Platform Features

- **Real-Time Multiplayer over WebSockets:** Sub-50ms bidirectional move synchronization using Serverpod stream channels (`session.messages`), eliminating HTTP polling.
- **Instant Room Sharing & Deep Linking:** Dynamically generated in-app QR codes and auto-join URLs (`?room=CODE`) that pre-fill room codes upon opening.
- **Deterministic Match Replay Scrubber:** Step-by-step interactive replayer allowing players to scrub forward, backward, or auto-play completed matches move-by-move.
- **Zero-Latency Web Audio API Synthesizer:** Pure procedural audio synthesis using browser oscillators in JavaScript/Dart, providing tactile audio feedback without external audio files.
- **Offline Solo Play vs Tactical AI:** Play offline against tactical minimax or heuristic bots with no server connection required.
- **Player Profiles & ELO Ratings:** Persistent player identities with custom avatar uploads via signed cloud storage and ELO rating tracking.
- **Daily Leaderboards:** Nightly aggregation of player wins with in-memory caching and cache group invalidation.
- **In-App Live Admin Dashboard:** Real-time server telemetry showing uptime, PostgreSQL query latency, active rooms, player counts, cache status, and manual maintenance triggers.

---

## 🏗 System Architecture

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        FRONTEND — FLUTTER MULTIPLATFORM CLIENT                         │
│  ┌─────────────────────────┐  ┌─────────────────────────┐  ┌─────────────────────────┐ │
│  │   Flutter Cyberpunk UI  │  │   Riverpod State Engine │  │  Deterministic Replayer │ │
│  │  (Dark Graphite Neon)   │  │  (Match / Player / ELO) │  │   (Move Scrubber/Audit) │ │
│  └─────────────────────────┘  └─────────────────────────┘  └─────────────────────────┘ │
│  ┌─────────────────────────┐  ┌─────────────────────────┐  ┌─────────────────────────┐ │
│  │  Tactile Sound Engine   │  │   QR Code & Deep Link   │  │   Pure Rules Engines    │ │
│  │ (Web Audio Synthesizer) │  │  (?room=CODE Auto-Join) │  │  (packages/game_core)   │ │
│  └─────────────────────────┘  └─────────────────────────┘  └─────────────────────────┘ │
└───────────────────────────────────────────┬────────────────────────────────────────────┘
                                            │ WebSocket Streams & Type-Safe RPC
                                            ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│             SERVERPOD CLOUD PRODUCTION BACKEND (https://onevone.serverpod.space)       │
│                                                                                        │
│  ┌────────────────────────────────────────┐  ┌──────────────────────────────────────┐  │
│  │ Built-in Web Server (SPA & Static)     │  │ Live Diagnostic Probe (/healthz)     │  │
│  └────────────────────────────────────────┘  └──────────────────────────────────────┘  │
│                                                                                        │
│  ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│  │ Serverpod 4.0.4 RPC Endpoints (one_v_one_server/lib/src/endpoints/)              │  │
│  │  • MatchEndpoint (Streaming WebSockets, room lobbies, live turn dispatch)        │  │
│  │  • PlayerEndpoint (Profile cache, ELO updates, avatar signed upload descriptors) │  │
│  │  • LeaderboardEndpoint (Compacted daily & all-time standings with 5-min TTL)     │  │
│  │  • AdminEndpoint (Live system metrics, cache clearing, manual maintenance trigger)│  │
│  └────────────────────────────────────────┬─────────────────────────────────────────┘  │
│                                           │                                            │
│  ┌────────────────────────────────────────┴─────────────────────────────────────────┐  │
│  │ Serverpod Core Subsystems:                                                       │  │
│  │  • Real-Time Message Hub: session.messages (WebSocket pub/sub over match channels)│  │
│  │  • High-Performance RAM Cache: session.caches.local (Group invalidation)         │  │
│  │  • Task Scheduler: Future Calls & Cron (DailyMaintenanceCall at 1:00 AM IST)     │  │
│  │  • Native Cloud Storage: session.storage & FileUploader (Avatars)                │  │
│  │  • Security & Identity: serverpod_auth_idp (JWTs, passwords, profile hooks)      │  │
│  │  • ACID Database Transactions: session.db.transaction with Optimistic Locking    │  │
│  └────────────────────────────────────────┬─────────────────────────────────────────┘  │
└───────────────────────────────────────────┼────────────────────────────────────────────┘
                                            │ ACID SQL Queries & ORM Mappings
                                            ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                        MANAGED POSTGRESQL 16 CLUSTER DATABASE                          │
│  ┌───────────────────────────────┐  ┌───────────────────────────────┐                  │
│  │ game_match (Optimistic Locks) │  │ match_move_record (Log Diff)  │                  │
│  ├───────────────────────────────┤  ├───────────────────────────────┤                  │
│  │ player_profile (ELO & Stats)  │  │ daily_leaderboard (Cron Rolls)│                  │
│  ├───────────────────────────────┴──┴───────────────────────────────┤                  │
│  │ scheduled_job_log (Execution audits & duration telemetry)        │                  │
│  └──────────────────────────────────────────────────────────────────┘                  │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

For detailed architectural topology and sequence diagrams, see [`docs/architecture.md`](docs/architecture.md).

---

## 📁 Repository Structure

```text
1v1/
├── packages/
│   ├── game_core/               # Pure Dart deterministic game rules engines
│   │   ├── lib/src/triangle_tactics/ # Triangle Tactics geometry and rules
│   │   ├── lib/src/connect_four/     # Connect Four board and minimax AI
│   │   └── lib/src/reversi/          # Reversi board and heuristic AI
│   └── game_test_support/       # Invariant fuzzers and exhaustive exploration tools
│
├── one_v_one_server/            # Serverpod backend application
│   ├── lib/
│   │   ├── server.dart          # Server bootstrap, routes, auth & future calls
│   │   └── src/
│   │       ├── endpoints/       # MatchEndpoint, PlayerEndpoint, LeaderboardEndpoint, AdminEndpoint
│   │       ├── models/          # .spy.yaml entity definitions (ORM models)
│   │       ├── services/        # MatchService, PlayerService, DailyMaintenanceProcessor
│   │       ├── jobs/            # DailyMaintenanceCall (Cron future calls)
│   │       └── web/             # /healthz route & static asset serving
│   ├── migrations/              # Tracked declarative database schema migrations
│   └── web/                     # Flutter Web SPA deployment assets
│
├── one_v_one_client/            # Auto-generated type-safe Serverpod client package
│   └── lib/                     # Protocol definitions and endpoint callers
│
├── one_v_one_flutter/           # Cross-platform Flutter frontend application
│   └── lib/
│       ├── providers/           # Riverpod state notifiers (match, player, theme)
│       ├── screens/             # Game screens, hubs, lobbies, admin board, replay
│       └── widgets/             # CustomPainter boards, dialogs, avatars, telemetry
│
├── docs/                        # In-depth architectural & operational documentation
│   ├── architecture.md          # Topology, sequence diagrams, and state machines
│   ├── game_rules.md            # Mathematical formulas and algorithmic rules
│   ├── serverpod_features.md    # 15-subsystem technical guide with code snippets
│   ├── test_strategy.md         # Multi-tier testing matrix and quality gates
│   └── threat_model.md          # Security analysis and mitigation strategies
│
├── HACKATHON_SHOWCASE.md        # Dedicated hackathon presentation & judge package
└── SUBMISSION.md                # Official hackathon submission statement
```

---

## 🛠 Local Setup & Development

### Prerequisites
- **Dart SDK:** 3.10+ (tested on Dart 3.13)
- **Flutter SDK:** 3.20+ (tested on Flutter 3.47)
- **PostgreSQL:** 16+ running locally on port 5432 (`postgres`/`postgres`)
- **Serverpod CLI:** 4.0.4 (`dart pub global activate serverpod_cli`)

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ananth/1v1.git
   cd 1v1
   ```

2. **Install dependencies across the workspace:**
   ```bash
   dart pub get
   ```

3. **Initialize the local database and apply migrations:**
   ```bash
   psql -U postgres -c "CREATE DATABASE one_v_one;"
   cd one_v_one_server
   dart bin/main.dart --mode production --apply-migrations
   cd ..
   ```

4. **Start the Serverpod backend:**
   ```bash
   cd one_v_one_server
   serverpod start
   ```
   *The server starts on port `8080` (API), `8081` (Insights), and `8082` (Web server).*

5. **Launch the Flutter client in a new terminal:**
   ```bash
   cd one_v_one_flutter
   flutter run -d chrome
   ```

---

## 🧪 Automated Testing & Verification

The repository enforces strict continuous verification across all tiers with **24 automated test suites (54 tests)** passing cleanly:

- **Suite A (Pure Engine):** Invariant assertion tests, 50 pseudo-random simulations, and exhaustive state space exploration on board size $n=2$.
- **Suite B (Serialization):** Round-trip JSON codecs and game replay validation.
- **Suite C (Server Integration):** Room creation, match joining, transactional move handling, and concurrency locks.
- **Suite D (UI & CustomPainter):** Triangular board rendering, peg selection, disc drop animations, and screen navigation.
- **Suite E (Multiplayer Interaction):** Turn indicators, bonus turn propagation, and game catalogue browsing.
- **Suite F (Security & Invariants):** Out-of-turn move rejection, replay tampering detection, and audit trail validation.
- **Suite G (Scheduled Job):** 1:00 AM IST daily maintenance execution, idempotency verification, and stale lobby cleanup.

Run all test suites locally:
```bash
# Run pure game engine tests
cd packages/game_core && dart test

# Run Flutter widget & unit tests
cd ../../one_v_one_flutter && flutter test

# Run Serverpod server tests (uses embedded PostgreSQL, no Docker required)
cd ../one_v_one_server && dart test

# Run static analysis across packages
dart analyze packages/game_core one_v_one_server one_v_one_flutter
```

---

## 📚 Documentation Directory

| Document | Purpose & Description |
|---|---|
| [`HACKATHON_SHOWCASE.md`](HACKATHON_SHOWCASE.md) | Dedicated hackathon presentation package and 15-subsystem judge evaluation guide. |
| [`SUBMISSION.md`](SUBMISSION.md) | Official hackathon submission statement mapping our architecture to judging criteria. |
| [`DEMO_SCRIPT.md`](DEMO_SCRIPT.md) | 2-minute video presentation transcript and demonstration flow. |
| [`docs/serverpod_features.md`](docs/serverpod_features.md) | Exhaustive guide of all 15 Serverpod subsystems with code references and configurations. |
| [`docs/architecture.md`](docs/architecture.md) | System topology, sequence diagrams, and state machines. |
| [`docs/game_rules.md`](docs/game_rules.md) | Complete mathematical and algorithmic rules specifications. |
| [`docs/test_strategy.md`](docs/test_strategy.md) | Exhaustive test matrix and validation gates. |
| [`docs/threat_model.md`](docs/threat_model.md) | Security analysis, threat vectors, and mitigations. |
| [`docs/release_checklist.md`](docs/release_checklist.md) | Pre-flight release verification checklist. |

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
