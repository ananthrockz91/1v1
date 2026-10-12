# 1v1 — Real-Time Multiplayer Gaming Platform

> **Play. Compete. Win.**

[![Serverpod Cloud](https://img.shields.io/badge/Serverpod%20Cloud-LIVE-brightgreen)](https://onevone.serverpod.space/)
[![Serverpod](https://img.shields.io/badge/Serverpod-4.0.4-blue)](https://serverpod.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.20+-02569B?logo=flutter)](https://flutter.dev)

- 🌐 **Live Web Application:** [https://onevone.serverpod.space/](https://onevone.serverpod.space/)
- 🔌 **Serverpod Cloud API:** [https://onevone.api.serverpod.space/](https://onevone.api.serverpod.space/)
- 🩺 **Cloud Health Check:** [https://onevone.serverpod.space/healthz](https://onevone.serverpod.space/healthz)
- 🏆 **Hackathon Presentation Package & Judge Guide:** [`HACKATHON_SHOWCASE.md`](HACKATHON_SHOWCASE.md)

**1v1** is a production-minded, extensible, real-time multiplayer gaming platform built with **Serverpod 4.0.4**, **PostgreSQL**, and **Flutter**.

The platform features an architectural separation between deterministic game rules engines and full-stack multiplayer services, demonstrated with its first flagship title: **Triangle Tactics** — an original territory strategy game on a discrete triangular lattice.

---

## Architecture Overview

```
                      ┌────────────────────────────────────────┐
                      │            Flutter Client              │
                      │  (Riverpod, CustomPainter, Streaming)  │
                      └───────────────────▲────────────────────┘
                                          │ WebSocket Stream / RPC
                                          │
                      ┌───────────────────▼────────────────────┐
                      │       Serverpod 4.0.4 Backend          │
                      │  (Endpoints, Streaming, Scheduled Job)│
                      └──────────────┬───────────────▲─────────┘
                                     │               │
                    PostgreSQL ACID  │               │ Imports Pure
                    Transactions     │               │ Rules Engine
                                     ▼               │
                      ┌──────────────┴────┐   ┌──────┴─────────────────┐
                      │    PostgreSQL     │   │   packages/game_core   │
                      │ (Matches, Moves,  │   │ (Pure Dart, Zero Net/UI│
                      │  Leaderboards)    │   │  Invariants, Replay)   │
                      └───────────────────┘   └────────────────────────┘
```

### Monorepo Structure

- **`packages/game_core`**: Pure, deterministic rules engine written in plain Dart with zero dependencies on Serverpod, Flutter, network, or databases. Contains mathematical board geometry formulas, move validation, invariant verification, and game replay codecs.
- **`packages/game_test_support`**: Shared test harness providing reference match scenarios, a seeded pseudo-random match generator (`RandomMatchSimulator`), and an exhaustive state space validator (`ExhaustiveSmallBoardValidator`).
- **`one_v_one_server`**: Server-authoritative Serverpod 4.0.4 backend with PostgreSQL persistence, optimistic concurrency control, real-time WebSocket streaming, and a scheduled daily maintenance cron job.
- **`one_v_one_client`**: Auto-generated type-safe Serverpod client library.
- **`one_v_one_flutter`**: Cross-platform Flutter client with a dark graphite aesthetic (`#0A0D14`), neon teal & amber identity cues, custom painter triangular lattice board, Riverpod state management, matchmaking lobbies, and leaderboards.
- **`tool/release_check.dart`**: Unified quality gate runner enforcing formatting, static analysis, pure rules tests, backend integration tests, and Flutter widget tests.
- **`docs/`**: Comprehensive architectural specifications, game rules, threat model, test strategy, release checklists, and demo scripts.

---

## Flagship Game: Triangle Tactics

Triangle Tactics is played on a triangular lattice of order $n$:
- **Lattice Nodes:** $V = \frac{(n + 1)(n + 2)}{2}$ discrete peg vertices.
- **Lattice Edges:** $E = \frac{3n(n + 1)}{2}$ connectable segments between adjacent nodes.
- **Triangular Faces:** $F = n^2$ elementary faces ($F_{\text{up}} = \frac{n(n + 1)}{2}$, $F_{\text{down}} = \frac{n(n - 1)}{2}$).

### Rules & Mechanics
1. Players take turns connecting two adjacent, unlinked lattice nodes.
2. If an edge placement completes one or two elementary triangular faces:
   - The moving player captures the face(s) and scores 1 point per face.
   - **The player is immediately awarded a bonus turn.**
3. If no triangle is completed, the turn passes to the opposing player.
4. The match terminates when all $E$ edges are occupied. The player with the most captured triangles wins (or draws on equal score).

---

## Daily Scheduled Maintenance (1:00 AM IST)

The platform runs a native Serverpod scheduled future call (`DailyMaintenanceFutureCall`) configured via cron:
- **Cron Expression:** `30 19 * * *` (19:30 UTC = 1:00 AM Asia/Kolkata / IST).
- **Guarantees:**
  - Aggregates daily match outcomes into daily leaderboard rankings.
  - Cleans stale abandoned match lobbies older than 24 hours.
  - Strictly idempotent: backfilling or re-running on the same date replaces existing daily leaderboard rows without duplicates.
  - Audit logging in `scheduled_job_log` table.
- **Hackathon Demo Trigger:** Can be executed on demand via the client UI or RPC endpoint (`client.admin.triggerDailyMaintenance()`).

---

## Getting Started

### 1. Prerequisites
- **Dart SDK:** 3.10+ (tested on Dart 3.13)
- **Flutter SDK:** 3.20+ (tested on Flutter 3.47)
- **PostgreSQL:** 16+ running locally on port 5432 (default credentials: `postgres`/`postgres`)

### 2. Install Dependencies
From the repository root:
```bash
dart pub get
```

### 3. Database Setup
Create the development and test databases:
```bash
psql -U postgres -c "CREATE DATABASE one_v_one;"
psql -U postgres -c "CREATE DATABASE one_v_one_test;"
```

Apply Serverpod migrations:
```bash
cd one_v_one_server
dart bin/main.dart --mode production --apply-migrations
cd ..
```

### 4. Running the Quality Gates
Verify formatting, static analysis, and all automated test suites:
```bash
dart run tool/release_check.dart
```

### 5. Running the Application

**Start the Serverpod Backend:**
```bash
cd one_v_one_server
dart bin/main.dart
```

**Start the Flutter Client:**
```bash
cd one_v_one_flutter
flutter run -d macos # or -d chrome
```

---

## Automated Test Suites

The test matrix covers all layers of the platform:
- **Suite A (Pure Engine):** Mathematical invariant verification, 50 seeded random simulations, and exhaustive exploration of all reachable states on board size $n=2$.
- **Suite B (Serialization):** Round-trip JSON codecs and game replay validation.
- **Suite C (Server Integration):** Room creation, match joining, move processing, and optimistic locking against concurrent tampering.
- **Suite D (UI/Widget):** Triangular board CustomPainter, peg selection, tap-to-move detection, and screen navigation.
- **Suite E (Multiplayer Interaction):** Turn indicators, extra turn propagation, and game catalogue browsing.
- **Suite F (Security & Invariants):** Authoritative rejection of out-of-turn moves, replay tampering detection, and audit trail consistency.
- **Suite G (Scheduled Job):** 1:00 AM IST daily maintenance execution, idempotency verification, and stale lobby cleanup.

---

## Documentation

- [`docs/serverpod_features.md`](docs/serverpod_features.md) — Exhaustive guide of all Serverpod features utilized across the platform.
- [`docs/architecture.md`](docs/architecture.md) — System topology, transaction flows, and state machines.
- [`docs/game_rules.md`](docs/game_rules.md) — Complete mathematical specification of Triangle Tactics.
- [`docs/test_strategy.md`](docs/test_strategy.md) — Exhaustive test matrix and validation gates.
- [`docs/threat_model.md`](docs/threat_model.md) — Security analysis, threat vectors, and mitigations.
- [`docs/release_checklist.md`](docs/release_checklist.md) — Pre-flight release verification checklist.
- [`docs/hackathon_demo.md`](docs/hackathon_demo.md) — 2-minute live demonstration flow.
