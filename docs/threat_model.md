# Threat Model & Security Posture: 1v1 Platform

## 1. System Asset Classification
1. **Match Integrity:** Game scores, player turns, winner declarations.
2. **Player Identity:** User tokens, player profiles, win-loss records.
3. **Session Privacy:** Private room access, match communication channels.
4. **Availability:** Database connection pools, WebSocket stream capacity.

---

## 2. Threat Analysis & Mitigations

| Threat ID | Threat Vector | Impact | Engineering Mitigation |
|---|---|---|---|
| **TH-01** | **Client Score Forgery** | Attacker tampers with client memory or payload to submit fabricated score | **Server Authoritative Engine:** Move payloads only contain `(node1, node2)`. The server calculates all triangle closures and score increments using `game_core`. Client-provided scores are never accepted. |
| **TH-02** | **Out-of-Turn / Double Move** | Player submits multiple moves before opponent acts | **Strict State Locking & Versioning:** Every move requires `clientStateVersion == match.stateVersion` and `playerId == match.activePlayerId`. Checked within PostgreSQL transaction. |
| **TH-03** | **Non-Participant Move Injection** | Attacker observes public match ID and submits moves for Player 2 | **Participant Authorization:** Server verifies JWT/session token and enforces `playerId IN (player1Id, player2Id)`. |
| **TH-04** | **Replay Attacks** | Re-sending previously captured legal move request | **State Version Monotonic Increment:** Replaying move with stale version $V$ fails optimistic concurrency check. |
| **TH-05** | **Private Room Guessing / Enumeration** | Brute-forcing 6-character room codes | High-entropy alphanumeric room codes with rate limiting on failed join attempts. |
| **TH-06** | **Denial of Service via Stale Lobbies** | Spanning thousands of unjoined lobbies | Automatic cleanup via daily scheduled job (and expiration timers). |
| **TH-07** | **Stream Eavesdropping** | Subscribing to matches of other players | Serverpod channel authorization checks match participation before attaching stream listener. |
