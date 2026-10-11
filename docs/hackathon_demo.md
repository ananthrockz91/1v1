# 1v1 Platform — Hackathon Live Demonstration Guide

This guide provides an end-to-end, deterministic script to demonstrate the **1v1 Real-Time Multiplayer Gaming Platform** and its first flagship title, **Triangle Tactics**, in under 2 minutes.

---

## 1. Prerequisites & Environment Setup

### 1.1 Start Local PostgreSQL
Ensure PostgreSQL is active on port `5432` with user `postgres` and password `postgres`:
```bash
brew services start postgresql@16 # or pg_ctl start
psql -U postgres -c "SELECT 1;"
```

### 1.2 Start the Serverpod 4.0.4 Backend
From the monorepo root:
```bash
cd one_v_one_server
dart bin/main.dart
```
The Serverpod server boots in development mode, listening on:
- Web Server / API: `http://localhost:8080`
- Insights & WebSockets: `http://localhost:8081`

### 1.3 Launch Flutter Clients
Open two separate terminal windows or browser tabs to demonstrate real-time multiplayer:

**Client A (Player 1 — Neon Teal):**
```bash
cd one_v_one_flutter
flutter run -d macos # or -d chrome --web-port=3000
```

**Client B (Player 2 — Amber Orange):**
```bash
cd one_v_one_flutter
flutter run -d chrome --web-port=3001
```

---

## 2. The 2-Minute Live Demo Flow

### Act 1: Brand Experience & Game Catalogue (0:00 – 0:25)
1. **Show Home Screen**:
   - Highlight the dark graphite aesthetic (`#0A0D14`), neon teal & amber identity chips, and clear status indicators.
2. **Open Game Catalogue**:
   - Tap **"Game Catalogue"** to showcase platform extensibility.
   - Point out **"Triangle Tactics"** (marked **PLAYABLE NOW**).
   - Point out future roadmap titles: **Tic-Tac-Toe Duel**, **Connect Four**, and **Memory Duel** (marked **COMING SOON**).

---

### Act 2: Private Match Creation & Streaming Connection (0:25 – 0:50)
1. **Player A Creates Room**:
   - On Client A, tap **"Create Room"**.
   - The app navigates to the Waiting Lobby and generates an unambiguous 6-character room code (e.g., `TR7K2M`).
   - The Serverpod backend assigns Player A to `player1` and sets the match to `waitingForPlayers`.
2. **Player B Joins Room**:
   - On Client B, tap **"Join Room"** on the home screen.
   - Enter the 6-character room code `TR7K2M` and tap **"Join Room"**.
   - **Real-Time Streaming Event**:
     - Player B calls `joinMatch()`.
     - The server atomically sets status to `active` and broadcasts a `PlayerJoinedEvent` via Serverpod WebSocket streaming.
     - **Both clients immediately and simultaneously transition to the active `GameScreen` without polling.**

---

### Act 3: Triangle Tactics Real-Time Gameplay & Invariant Enforcement (0:50 – 1:30)
1. **Quiet Move (Turn Transition)**:
   - Client A (Teal) taps peg `(0, 0)` then peg `(1, 0)`.
   - The edge glows teal, the turn switches to Client B (Amber).
   - Client B sees the line appear in real time over the Serverpod event stream.
2. **Move Validation / Server Authority**:
   - Attempt to click on Client A during Client B's turn: The board is non-interactive.
   - Even if forced over network, the Serverpod `MatchService` validates `m.playerId == state.activePlayerId` and rejects out-of-turn moves with an authoritative `400 Invalid move`.
3. **Triangle Completion & Bonus Turn**:
   - Play the remaining 2 edges of the top elementary triangle:
     - Edge `(0, 0)` to `(1, 1)`
     - Edge `(1, 0)` to `(1, 1)`
   - The player completing the triangle immediately captures the face with a colored fill and glowing centroid.
   - **The score increments by 1 point, and the capturing player immediately gets a bonus extra turn**, visually confirmed by the active turn indicator remaining on their side.

---

### Act 4: Daily Scheduled Maintenance & Idempotency Demo (1:30 – 1:50)
1. **Show the Scheduled Maintenance**:
   - In production, Serverpod executes `DailyMaintenanceFutureCall` at **1:00 AM Asia/Kolkata (IST)** (`cron: 30 19 * * *` UTC).
2. **Trigger the Job on Demand**:
   - On the Home Screen, scroll to **"HACKATHON DEMO CONTROLS"** (or use the Leaderboard screen toolbar icon).
   - Tap **"Trigger Daily Scheduled Processing"**.
   - The Serverpod `DailyMaintenanceProcessor`:
     - Identifies finished matches from the previous 24-hour cycle.
     - Computes wins, losses, draws, win rates, and triangles captured.
     - Upserts daily leaderboard rankings in PostgreSQL with complete idempotency.
     - Cleans abandoned lobbies older than 24 hours.
   - A success banner confirms: *"Job Completed! Cleaned N lobbies, M players aggregated."*
3. **Verify Leaderboard**:
   - Tap the **Leaderboards** icon to inspect both the **Daily Leaderboard** (aggregated by the scheduled job) and **All-Time Rankings**.

---

### Act 5: Automated Quality Gate Verification (1:50 – 2:00)
Run the automated release validation runner in the terminal to demonstrate that all quality gates pass:
```bash
dart run tool/release_check.dart
```

**Expected Console Output:**
```
================================================================
  1v1 MULTIPLAYER GAMING PLATFORM — RELEASE QUALITY GATES
================================================================

--> Running Gate 1: Code Formatting...
    ✓ Passed in 0.47s

--> Running Gate 2: Monorepo Static Analysis...
    ✓ Passed in 4.50s

--> Running Gate 3: Game Core Pure Engine Tests...
    ✓ Passed in 1.57s

--> Running Gate 4: Serverpod Backend Integration Tests...
    ✓ Passed in 2.73s

--> Running Gate 5: Flutter Client Widget Tests...
    ✓ Passed in 3.20s

================================================================
                    RELEASE VALIDATION SUMMARY
================================================================
Gate 1: Code Formatting                  [PASS]  (0.47s)
Gate 2: Monorepo Static Analysis         [PASS]  (4.50s)
Gate 3: Game Core Pure Engine Tests      [PASS]  (1.57s)
Gate 4: Serverpod Backend Integration Tests [PASS]  (2.73s)
Gate 5: Flutter Client Widget Tests      [PASS]  (3.20s)
================================================================
Total Execution Time: 12.49s
Report written to: tool/release_check_report.json

>>> ALL QUALITY GATES PASSED! SYSTEM IS READY FOR RELEASE. <<<
```

---

## 3. Summary of Key Architectural Proof Points
- **No Mock Streaming**: Uses Serverpod's real WebSocket `match` event stream.
- **Server-Authoritative**: Client sends only coordinate clicks (`(r1, c1)` to `(r2, c2)`); the backend transaction engine calculates invariants, edges, and scores.
- **Pure Rules Engine**: `packages/game_core` has zero UI/network/database dependencies and is 100% covered by property-based and exhaustive state validation tests.
- **Real Scheduled Job**: Uses Serverpod's native recurring cron future calls (`30 19 * * *` UTC = 1:00 AM IST) backed by audit tables.
