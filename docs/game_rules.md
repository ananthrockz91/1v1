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
- The engine tags every game instance with its canonical identifier and `rulesetVersion` (`triangle_tactics: 1.0.0`, `connect_four: 1.1.0`, `reversi: 1.0.0`).
- Any semantic variation requires a bump to a new ruleset version with backwards-compatible replay support for historical matches.

---

## 7. Game Rules Specification: Gravity Drop Duel (Connect Four)

**Game Identifier:** `connect_four`  
**Ruleset Version:** `1.1.0`  
**Game Family:** Vertical Falling Disc Alignment Strategy

### 7.1 Board Geometry & Grid Configurations
Played on a vertically standing grid of $C$ columns and $R$ rows. Cells are indexed as $(r, c)$ where row $0$ is the top row and row $R - 1$ is the bottom row resting on the base.

The platform provides 3 selectable grid presets:
1. **Classic Duel:** $7 \text{ columns} \times 6 \text{ rows}$, Target run length $K = 4$. Total cells = 42.
2. **Tactical Duel:** $8 \text{ columns} \times 7 \text{ rows}$, Target run length $K = 4$. Total cells = 56.
3. **Grand Duel:** $9 \text{ columns} \times 8 \text{ rows}$, Target run length $K = 5$. Total cells = 72.

### 7.2 Core Gravity Drop Action
- **Turn Action:** A player selects an index $c \in [0, C-1]$.
- **Gravity Invariant:** The placed disc falls into the lowest unoccupied row in column $c$:
  $$r^* = \max \{ r \in [0, R-1] \mid \text{Grid}[r][c] = \text{Empty} \}$$
  If no such row exists ($\text{Grid}[0][c] \neq \text{Empty}$), the column is full and the move is rejected as illegal.
- Upon placement, $\text{Grid}[r^*][c] \leftarrow \text{ActivePlayerDisc}$.

### 7.3 Win Condition & Vector Win Scanning
Following disc placement at $(r^*, c)$, the engine tests for victory by evaluating 4 directional vectors $D = \{ (0, 1), (1, 0), (1, 1), (-1, 1) \}$:
1. **Horizontal:** $\vec{d} = (0, 1)$
2. **Vertical:** $\vec{d} = (1, 0)$
3. **Diagonal Down-Right:** $\vec{d} = (1, 1)$
4. **Diagonal Up-Right:** $\vec{d} = (-1, 1)$

For each vector $(dr, dc)$, the engine counts continuous matching tokens bidirectionally from $(r^*, c)$:
$$\text{ChainLength} = 1 + \text{RayCount}(dr, dc) + \text{RayCount}(-dr, -dc)$$
If $\text{ChainLength} \ge K$, the acting player wins immediately.

### 7.4 Terminal States & Draws
- **Victory:** Any valid line of $K$ contiguous friendly discs is formed.
- **Draw:** All $C \times R$ cells are filled with zero winning lines.
- **Turn Alternation:** Unless terminal, turns alternate strictly between Player 1 and Player 2.

### 7.5 Solo AI Engine (Minimax Lookahead)
The solo offline bot utilizes a 2-ply Minimax lookahead evaluation:
- **Instant Win / Block Priority:** Evaluates immediate winning moves ($+10,000$ points) and opponent immediate winning threats ($-9,000$ points).
- **Positional Heuristic:** Awards higher weights to center columns $(\lfloor C/2 \rfloor)$ due to maximal geometric line participation.
- **Run Potential:** Scores unblocked 2-in-a-row and 3-in-a-row alignments with open endpoints.

---

## 8. Game Rules Specification: Reversi (Othello Duel)

**Game Identifier:** `reversi`  
**Ruleset Version:** `1.0.0`  
**Game Family:** Flanking & Reversal Strategy

### 8.1 Board Geometry & Initial Setup
Played on an $8 \times 8$ grid ($R = 8, C = 8$, 64 total squares).
- **Initial State:** The center 4 squares are initialized with alternating discs:
  - $(3, 3) = \text{Player 2}$ (Dark)
  - $(3, 4) = \text{Player 1}$ (Light)
  - $(4, 3) = \text{Player 1}$ (Light)
  - $(4, 4) = \text{Player 2}$ (Dark)
- All remaining 60 squares begin empty.

### 8.2 Legal Move Condition (Flanking Invariant)
A move to square $(r, c)$ is legal if and only if:
1. $\text{Grid}[r][c] == \text{Empty}$.
2. In at least one of the 8 cardinal directions $\vec{d} = (dr, dc) \in \{-1, 0, 1\}^2 \setminus \{(0, 0)\}$, there exists a non-empty contiguous sequence of opponent discs terminated by a friendly disc:
   $$\exists k \ge 2 \text{ s.t. } \forall i \in [1, k-1]: \text{Grid}[r + i \cdot dr][c + i \cdot dc] = \text{Opponent} \quad \land \quad \text{Grid}[r + k \cdot dr][c + k \cdot dc] = \text{ActingPlayer}$$

### 8.3 Flanking & Disk Flipping Action
When a legal move is placed at $(r, c)$:
1. $\text{Grid}[r][c] \leftarrow \text{ActingPlayer}$.
2. In every direction $\vec{d}$ satisfying the flanking condition, all trapped opponent discs between $(r, c)$ and the terminating friendly disc are flipped to $\text{ActingPlayer}$.

### 8.4 Turn Progression & Automatic Passing
- After disc placement and flipping, the engine computes the set of legal moves for the opponent.
- If the opponent has **$\ge 1$ legal moves**, turn passes to the opponent.
- If the opponent has **$0$ legal moves**, but the acting player has $\ge 1$ legal moves, the opponent's turn is **automatically passed**, and the acting player plays again.
- If **both players have $0$ legal moves** (or the board is completely filled with 64 discs), the match terminates immediately.

### 8.5 Victory & Scoring
- **Score:** Total count of occupied discs: $S_1 = |\text{Player 1 Discs}|$, $S_2 = |\text{Player 2 Discs}|$.
- **Winner:** Player with the higher disc count at terminal state.
- **Draw:** $S_1 = S_2 = 32$.

### 8.6 Solo AI Engine (Positional Heuristic Matrix)
The solo bot uses an 8×8 positional weighting matrix factoring static board topology:
- **Corners** $(0,0), (0,7), (7,0), (7,7)$: $+100$ points (permanent, unflappable anchor tiles).
- **Corner Danger Zones (C-squares & X-squares):** $-20$ points (giving opponent access to corners).
- **Edges:** $+10$ points (defensible boundary lines).
- **Mobility Differential:** Maximizes friendly legal moves while restricting opponent options.

