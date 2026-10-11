# Game Rules Specification: Triangle Tactics

**Game Identifier:** `triangle_tactics`  
**Ruleset Version:** `1.0.0`  
**Game Family:** Deterministic Turn-Based Territory Strategy

---

## 1. Overview & Vision
*Triangle Tactics* is a digital tactical territory capture game played on a regular triangular lattice of pegs (nodes). Players take turns stretching a connection (edge) between two adjacent pegs. Whenever an edge completes one or more elementary triangular cells (faces), the player who drew the closing edge claims ownership of those triangles, gains one point per triangle claimed, and receives an extra turn.

The game ends when all available edges on the board have been placed. The player with the most claimed triangles wins. If scores are equal, the match is a draw.

---

## 2. Board Geometry & Coordinate System

### 2.1 Triangular Lattice Definition
A board of size $n$ represents an equilateral triangular grid with side length $n$ elementary units.

- **Nodes (Pegs):** Arranged in rows $r \in [0, n]$. Row $r$ contains $r + 1$ nodes indexed by column $c \in [0, r]$.
  $$\text{Total Nodes} = \sum_{r=0}^{n} (r + 1) = \frac{(n + 1)(n + 2)}{2}$$
  - Each node is uniquely identified by its coordinate `(r, c)` or canonical ID `node_r_c`.

- **Elementary Triangular Faces:**
  - **Upright Triangles ($\Delta$):** Top vertex at `(r, c)`, bottom-left at `(r+1, c)`, bottom-right at `(r+1, c+1)`.
    Count: $\frac{n(n+1)}{2}$.
  - **Inverted Triangles ($\nabla$):** Top-left vertex at `(r, c)`, top-right at `(r, c+1)`, bottom vertex at `(r+1, c+1)`.
    Count: $\frac{n(n-1)}{2}$.
  - **Total Elementary Triangles:**
    $$\text{Total Triangles} = \frac{n(n+1)}{2} + \frac{n(n-1)}{2} = n^2$$

- **Edges:**
  Connections exist strictly between adjacent nodes. In a triangular lattice, each node has up to 6 neighbors:
  1. **Horizontal Edges:** `(r, c)` to `(r, c+1)` for $c < r$. Count: $\sum_{r=1}^{n} r = \frac{n(n+1)}{2}$.
  2. **Down-Right Edges:** `(r, c)` to `(r+1, c+1)` for $r < n$. Count: $\frac{n(n+1)}{2}$.
  3. **Down-Left Edges:** `(r, c)` to `(r+1, c)` for $r < n$. Count: $\frac{n(n+1)}{2}$.
  - **Total Edges:**
    $$\text{Total Edges} = 3 \times \frac{n(n+1)}{2} = \frac{3n(n+1)}{2}$$

### 2.2 Canonical ID Normalization
- Nodes in an edge are canonically ordered: $u < v$ by row, then by column:
  `edge_id = "edge_${u.r}_${u.c}_${v.r}_${v.c}"`
- A triangle face is canonically identified by its orientation and top/top-left coordinate:
  `tri_up_r_c` or `tri_down_r_c`.
- Each triangle has exactly 3 boundary edges.

### 2.3 Supported Board Sizes
| Size ($n$) | Nodes | Edges | Triangles | Typical Use Case |
|---|---|---|---|---|
| $n = 2$ | 6 | 9 | 4 | Exhaustive state space verification & rapid unit testing |
| $n = 3$ | 10 | 18 | 9 | Quick casual matches & integration test suites |
| $n = 4$ | 15 | 30 | 16 | Standard competitive mobile match (Default) |
| $n = 5$ | 21 | 45 | 25 | Extended tactical match |

---

## 3. Match Rules & Mechanics

### 3.1 Participants & Initialization
- Exactly two players participate: **Player 1** (Teal `#00E5FF`) and **Player 2** (Amber `#FFAB00`).
- The server determines player identities and the starting player (default: Player 1).
- Initial scores: Player 1 = 0, Player 2 = 0.
- All edges begin unplaced; all triangles begin unclaimed.

### 3.2 Turn Action
A turn action consists of placing a single unplaced edge between two adjacent nodes:
$$\text{Move}(u, v) \quad \text{where } u, v \in \text{Nodes}, \text{Adjacent}(u, v), \text{Edge}(u, v) \notin \text{OccupiedEdges}$$

### 3.3 Triangle Completion & Scoring
Upon placing a valid edge $e$:
1. Determine all elementary triangles that contain $e$ as a boundary edge (at most 2 triangles).
2. For each such triangle $T$:
   - Check if all three boundary edges of $T$ are now occupied.
   - If yes and $T$ was not previously claimed, award $T$ to the acting player.
   - Increment the acting player's score by 1 point.
3. **Turn Progression:**
   - If **at least one** triangle was claimed during this move, the acting player **earns an extra turn** and retains active status.
   - If **zero** triangles were claimed, the turn passes to the opponent.

### 3.4 Terminal State & Victory Conditions
- The match terminates immediately when all $\frac{3n(n+1)}{2}$ edges are occupied.
- Since every triangle is bounded by 3 edges, at terminal state all $n^2$ triangles will be claimed:
  $$\text{Player1Score} + \text{Player2Score} = n^2$$
- **Winner:** Player with highest score.
- **Draw:** If $\text{Player1Score} == \text{Player2Score}$ (e.g., $8 - 8$ on an $n=4$ board).

---

## 4. Move Validation & Rejection Invariants

An action must be strictly validated before any state mutation. Any rejection leaves the entire state untouched.

### Rejection Conditions:
1. **Wrong Player:** The acting player ID does not match `activePlayerId`.
2. **Terminal Match:** Attempting a move after the match has reached terminal state.
3. **Invalid Nodes:** Either node coordinate is outside the board bounds.
4. **Non-Adjacent Nodes:** Nodes are not immediate grid neighbors.
5. **Duplicate Edge:** An edge between the two nodes is already occupied.
6. **Self-Loop:** Attempting to connect a node to itself.

---

## 5. Concrete Move Sequence Examples

### Example 1: Quiet Edge Placement (Turn Passes)
- Board: $n = 3$.
- State: Move 1 by Player 1.
- Move: Connect `(0, 0)` to `(1, 0)` (Down-Left edge).
- Evaluation: Adjacent triangle `tri_up_0_0` now has 1/3 edges. No triangles completed.
- Result: Score: P1=0, P2=0. Next player: **Player 2**.

### Example 2: Triangle Completion (Extra Turn Awarded)
- State: Edges `(0,0)-(1,0)` and `(0,0)-(1,1)` are already placed.
- Active player: Player 2.
- Move: Connect `(1,0)` to `(1,1)` (Horizontal bottom edge of `tri_up_0_0`).
- Evaluation: `tri_up_0_0` has 3/3 edges completed! Awarded to Player 2.
- Result: Score: P1=0, P2=1. P2 takes an **extra turn**. Next player: **Player 2**.

### Example 3: Double Triangle Completion (2 Points + Extra Turn)
- State: An upright triangle and an inverted triangle share a common internal edge $e$. Both triangles have their other two boundary edges already drawn.
- Active player: Player 1.
- Move: Place the shared edge $e$.
- Evaluation: Both triangles complete simultaneously.
- Result: Player 1 scores +2 points. Next player: **Player 1**.

---

## 6. Ruleset Versioning Policy
- The engine tags every game instance with `rulesetVersion: 1.0.0`.
- Any semantic variation (e.g., handicap starts, different scoring weights, hexagonal or truncated boards) requires a bump to a new ruleset version (e.g., `2.0.0`) with backwards-compatible replay support for historical `1.0.0` matches.
