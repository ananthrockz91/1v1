# 1v1 Multiplayer Gaming Platform Implementation Plan

> **For Agent:** REQUIRED SUB-SKILL: Follow phased execution with rigorous automated testing at each boundary.

**Goal:** Build a production-grade, extensible real-time 1v1 multiplayer gaming platform with authoritative Serverpod backend, pure deterministic Dart rules engine for "Triangle Tactics", interactive Flutter client, automated quality gates, daily background processing, and complete test suites.

**Architecture:** Monorepo with strict separation of concerns: pure `game_core` rules engine (zero UI/network/db dependencies), `game_test_support` fixtures/generators, `server` with Serverpod endpoints, PostgreSQL transactional state transitions, Serverpod real-time streaming, daily cron job (1:00 AM IST), and `client` Flutter app with Riverpod state management.

**Tech Stack:** Flutter 3.47.0, Dart 3.13.0, Serverpod 4.0.4, PostgreSQL, Riverpod, GoRouter.

---

### Phase 1: Architecture, Documentation & Interface Contracts
- Establish monorepo workspace configuration (`packages/game_core`, `packages/game_test_support`, `one_v_one_server`, `one_v_one_client`, `one_v_one_flutter`).
- Write comprehensive docs:
  - `docs/architecture.md`: Platform & game engine boundary, event streaming, data models.
  - `docs/game_rules.md`: Mathematical formulation of triangular lattice, node coordinates, edge connections, triangle closures, scoring, turn order, ruleset versioning.
  - `docs/test_strategy.md`: Multi-suite strategy (Suites A through G).
  - `docs/threat_model.md`: Security analysis, anti-cheat, authorization.
  - `docs/release_checklist.md`: Gates, checks, and criteria.

### Phase 2: Pure Deterministic Rules Engine (`game_core`)
- Implement board lattice representation (`BoardGeometry`, `GridNode`, `BoardEdge`, `TriangleFace`).
- Formulate coordinate mapping and formulas:
  - For side length $n$: $Nodes = (n+1)(n+2)/2$, $Triangles = n^2$, $Edges = 3n(n+1)/2$.
- Implement game state, move validation, deterministic transition function:
  - `TriangleTacticsState`, `TriangleTacticsMove`, `MoveResult`, `RuleViolation`.
  - Extra turn on triangle completion; turn switch on no completion.
  - Terminal state evaluation (all edges occupied) and winner determination.
- Implement comprehensive Invariant Validator:
  - All edges belong to board; no duplicates; triangles owned once; scores match owned count; history replayability.
- Implement serialization / deserialization with ruleset versioning (`1.0.0`).
- Suite A:
  - Unit tests for geometry, moves, triangle ownership, match completion.
  - Seeded random match simulator with invariant verification across hundreds of games.
  - Exhaustive state space verification on small board ($n=2$).
  - Reference scenarios for developers.

### Phase 3: Authoritative Serverpod Backend & Transactions
- Serverpod models:
  - `PlayerProfile`: id, username, stats, createdAt.
  - `GameMatch`: matchId, gameType, rulesetVersion, status, player1Id, player2Id, activePlayerId, player1Score, player2Score, stateVersion, winnerId, moveCount, boardSize.
  - `MatchMoveRecord`: matchId, moveIndex, playerId, node1Id, node2Id, edgeId, trianglesClaimed, extraTurn, stateVersion, timestamp.
  - `DailyLeaderboard`: date, playerId, wins, losses, draws, trianglesCaptured, winRate.
- Transactional move processing:
  - Row locking / optimistic concurrency control via `stateVersion`.
  - Pure rules engine transition applied inside database transaction.
  - Atomically save move record, update match state, scores, active turn, terminal status.
- Match lifecycle endpoints:
  - Create match, join match, match state, submit move, resign, room codes, matchmaking queue.
- Reconnection & audit replay from stored move records.

### Phase 4: Serverpod Real-Time Streaming & Flutter Client
- Match stream session handlers:
  - Isolate events by matchId with subscription authorization.
  - Broadcast confirmed committed state changes (`MatchStarted`, `MoveAccepted`, `TurnChanged`, `PlayerResigned`, `MatchCompleted`).
  - Client state reconciliation on reconnect.
- Flutter UI (`one_v_one_flutter`):
  - Dark graphite theme with teal (`#00E5FF`) and amber (`#FFAB00`) accents.
  - Home screen: Play Online, Create Private Room, Join Room, Game Catalogue, Recent Matches, Quick Stats.
  - Game Catalogue: Triangle Tactics (playable), Coming Soon cards (Tic-Tac-Toe, Connect Four, Memory Duel).
  - Lobby: Room code sharing, readiness, waiting indicator.
  - Triangle Tactics Board: Interactive canvas/gesture board rendering equilateral triangular lattice nodes, edge hover/select previews, line drawing animations, player-colored triangle capture fills, score badges, extra turn animations, connection badges.
  - Results modal: Winner banner, final scores, rematch request, back home.
  - Leaderboard screen: Daily & All-time tabs, player ranking, win rates, triangles captured.
  - State management via Riverpod.

### Phase 5: Daily Scheduled Job & Statistics
- Real Serverpod scheduled background job configured for 1:00 AM IST (Asia/Kolkata).
- Tasks:
  - Expire stale matchmaking requests (> 5 mins).
  - Expire abandoned waiting lobbies (> 1 hour).
  - Handle abandoned active matches with timeout policy.
  - Aggregate daily player stats and write daily leaderboard rows.
  - Maintain job run audit log table (`ScheduledJobLog`).
  - Full idempotency guarantee: rerun on same date does not corrupt or duplicate stats.
- Provide a developer manual trigger endpoint and CLI command for instant demonstration.

### Phase 6: Release Validation System & Verification
- Create automated release verification script: `dart run tool/release_check.dart`.
- Run formatting, analysis, Suite A (pure engine), Suite B (serialization), Suite C (backend transactions), Suite D (streaming), Suite E (Flutter widgets), Suite F (security), Suite G (reliability).
- Generate structured report (JSON + terminal summary).
- Set up GitHub Actions CI workflow (`.github/workflows/ci.yml`).
- Create 2-minute demonstration script (`docs/hackathon_demo.md`) with reproducible steps.
