BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "daily_leaderboard" (
    "id" bigserial PRIMARY KEY,
    "dateString" text NOT NULL,
    "playerId" text NOT NULL,
    "displayName" text NOT NULL,
    "wins" bigint NOT NULL,
    "losses" bigint NOT NULL,
    "draws" bigint NOT NULL,
    "trianglesCaptured" bigint NOT NULL,
    "rank" bigint NOT NULL,
    "winRate" double precision NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "daily_leaderboard_date_idx" ON "daily_leaderboard" USING btree ("dateString");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "game_match" (
    "id" bigserial PRIMARY KEY,
    "matchId" text NOT NULL,
    "gameType" text NOT NULL,
    "rulesetVersion" text NOT NULL,
    "boardSize" bigint NOT NULL,
    "roomCode" text,
    "isPublic" boolean NOT NULL,
    "status" text NOT NULL,
    "player1Id" text NOT NULL,
    "player2Id" text,
    "activePlayerId" text NOT NULL,
    "player1Score" bigint NOT NULL,
    "player2Score" bigint NOT NULL,
    "stateVersion" bigint NOT NULL,
    "winnerId" text,
    "isDraw" boolean NOT NULL,
    "stateJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "completedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "game_match_id_idx" ON "game_match" USING btree ("matchId");
CREATE INDEX "game_match_room_idx" ON "game_match" USING btree ("roomCode");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "match_move_record" (
    "id" bigserial PRIMARY KEY,
    "matchId" text NOT NULL,
    "moveIndex" bigint NOT NULL,
    "playerId" text NOT NULL,
    "node1R" bigint NOT NULL,
    "node1C" bigint NOT NULL,
    "node2R" bigint NOT NULL,
    "node2C" bigint NOT NULL,
    "edgeId" text NOT NULL,
    "claimedTrianglesJson" text NOT NULL,
    "extraTurn" boolean NOT NULL,
    "stateVersion" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "match_move_match_idx" ON "match_move_record" USING btree ("matchId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "player_profile" (
    "id" bigserial PRIMARY KEY,
    "playerId" text NOT NULL,
    "displayName" text NOT NULL,
    "avatarSeed" text NOT NULL,
    "totalMatches" bigint NOT NULL,
    "wins" bigint NOT NULL,
    "losses" bigint NOT NULL,
    "draws" bigint NOT NULL,
    "trianglesCaptured" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "lastActiveAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "player_profile_id_idx" ON "player_profile" USING btree ("playerId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "scheduled_job_log" (
    "id" bigserial PRIMARY KEY,
    "jobName" text NOT NULL,
    "executedAt" timestamp without time zone NOT NULL,
    "targetDate" text NOT NULL,
    "staleLobbiesCleaned" bigint NOT NULL,
    "abandonedMatchesProcessed" bigint NOT NULL,
    "leaderboardsAggregated" bigint NOT NULL,
    "success" boolean NOT NULL,
    "errorDetails" text
);


--
-- MIGRATION VERSION FOR one_v_one
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('one_v_one', '20261011073859553', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261011073859553', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
