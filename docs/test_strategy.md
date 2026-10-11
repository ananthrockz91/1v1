# Test Strategy: 1v1 Multiplayer Platform

## 1. Multi-Tiered Test Architecture
The test suite is structured into 7 segregated suites:

```
[Suite A: Pure Engine & Geometry] --> No network / DB / UI
[Suite B: Serialization & Replay] --> Deterministic state codecs
[Suite C: Serverpod Integration]  --> PostgreSQL transactions, endpoints
[Suite D: Real-Time Multiplayer]  --> 2-client streaming & recovery
[Suite E: Flutter Presentation]   --> Riverpod & interactive canvas UI
[Suite F: Security & Abuse]       --> Malicious payloads, anti-cheat
[Suite G: Reliability & Load]     --> Concurrency & background processing
```

---

## 2. Suite Breakdown

### Suite A: Pure Game Logic (`packages/game_core/test`)
- **Board Geometry:** Node, edge, and triangle counts match mathematical theorems for $n \in [2, 5]$.
  - $Nodes = (n+1)(n+2)/2$
  - $Triangles = n^2$
  - $Edges = 3n(n+1)/2$
- **Move Invariants:** Adjacency checking, duplicate edge detection, out-of-range bounds, turn order.
- **Triangle Closure:** Upright and inverted closures, simultaneous double triangle closures, single and double point awards.
- **Turn Mechanics:** Extra turn awarded when $\ge 1$ triangle completed; turn passed when 0 completed.
- **Random Match Simulator (Property-Based):** 100+ matches played with seeded PRNG; invariants checked after each transition.
- **Exhaustive State Search:** Complete state-space traversal on $n=2$ (9 edges, $2^9 = 512$ reachable edge subsets).

### Suite B: Serialization & Codecs
- JSON round-trip for states, moves, and results.
- Invariant integrity after deserialization.
- Backward compatibility verification for ruleset version `1.0.0`.

### Suite C: Serverpod Database & Endpoints
- Match creation with room code generation.
- Participant pairing and matchmaking queue.
- Atomicity of move submission within PostgreSQL transactions.
- Idempotency and duplicate submission handling.

### Suite D: Real-Time Streaming & Reconnection
- Dual client connection via WebSockets.
- Verified broadcast delivery: Both clients receive confirmed move events with identical version numbers.
- Simulated disconnection: Reconnection retrieves authoritative snapshot and resumes without state divergence.

### Suite E: Flutter UI Widget Tests (`one_v_one_flutter/test`)
- Home screen navigation to Catalogue, Lobby, and Leaderboards.
- Interactive board rendering: Canvas paint coordinates, tap detection on edge hit-boxes.
- Score badge and turn indicators.
- Victory/Draw modal presentation.

### Suite F: Security & Abuse Prevention
- Rejection of moves from non-participants.
- Rejection of out-of-turn moves.
- Prevention of client-side score forgery (server re-calculates all scores).
- Room code collision and brute-force mitigation.

### Suite G: Concurrency & Daily Job Idempotency
- Simultaneous concurrent move submissions to the same match.
- Daily scheduled job idempotency: Repeated execution produces identical leaderboard aggregates.
