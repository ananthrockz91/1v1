# Production Release Checklist: 1v1 Platform

## Pre-Release Verification Gates

- [ ] **1. Clean Workspace & Formatting:**
  - `dart format --output=none --set-exit-if-changed .` passes cleanly across all packages.
  - Zero warnings or errors in `dart analyze` across client, server, and core packages.
- [ ] **2. Pure Game Core (Suite A & B):**
  - All unit tests for board geometry, node coordinate math, edge adjacency, triangle closures pass.
  - 100+ seeded random matches complete with zero invariant violations.
  - Exhaustive state space search on small board ($n=2$) executes with 100% invariant preservation.
  - State serialization and deserialization round-trip maintains exact state equality.
- [ ] **3. Serverpod Authoritative Backend (Suite C & F):**
  - Database migrations applied cleanly to PostgreSQL.
  - Transactional move processing verified: concurrent attempts reject out-of-turn or duplicate moves without data corruption.
  - Participant authorization verified: non-participants cannot submit moves or query private streams.
- [ ] **4. Real-time Multiplayer & Recovery (Suite D):**
  - Two independent client sessions successfully complete full match via streaming.
  - Disconnect / reconnect scenario restores state accurately without progress loss.
- [ ] **5. Scheduled Processing (Suite G):**
  - Daily job runs cleanly, aggregates stats, cleans stale lobbies, records audit log.
  - Idempotency verified: re-running for the same date does not duplicate statistics.
- [ ] **6. Flutter Client Presentation (Suite E):**
  - Interactive board widgets render correctly on mobile dimensions.
  - Touch interaction registers correct node pairs.
  - Riverpod state providers update immediately upon receiving stream events.
- [ ] **7. Automated Release Gate:**
  - Single release command `dart run tool/release_check.dart` exits with code `0`.
