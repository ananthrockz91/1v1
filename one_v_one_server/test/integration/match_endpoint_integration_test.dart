import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Suite C & F: Match Endpoint Integration & Security', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'creates private match with unique room code and initial state',
      () async {
        final match = await endpoints.match.createMatch(
          sessionBuilder,
          playerId: 'alice_123',
          boardSize: 3,
          isPublic: false,
        );

        expect(match.matchId, startsWith('match_'));
        expect(match.roomCode, isNotNull);
        expect(match.roomCode!.length, equals(6));
        expect(match.status, equals('waiting'));
        expect(match.player1Id, equals('alice_123'));
        expect(match.player2Id, isNull);
        expect(match.stateVersion, equals(0));
      },
    );

    test('joins private room by room code and starts match', () async {
      final match = await endpoints.match.createMatch(
        sessionBuilder,
        playerId: 'alice_1',
        boardSize: 3,
        isPublic: false,
      );

      final joined = await endpoints.match.joinMatch(
        sessionBuilder,
        playerId: 'bob_2',
        roomCode: match.roomCode!,
      );

      expect(joined.status, equals('in_progress'));
      expect(joined.player1Id, equals('alice_1'));
      expect(joined.player2Id, equals('bob_2'));
      expect(joined.activePlayerId, equals('alice_1'));
    });

    test('prevents player from joining their own room', () async {
      final match = await endpoints.match.createMatch(
        sessionBuilder,
        playerId: 'alice_self',
        boardSize: 3,
        isPublic: false,
      );

      await expectLater(
        () => endpoints.match.joinMatch(
          sessionBuilder,
          playerId: 'alice_self',
          roomCode: match.roomCode!,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'public matchmaking pairs two players waiting for the same size',
      () async {
        final p1Match = await endpoints.match.findMatch(
          sessionBuilder,
          playerId: 'queue_p1',
          boardSize: 3,
        );
        expect(p1Match.status, equals('waiting'));

        final p2Match = await endpoints.match.findMatch(
          sessionBuilder,
          playerId: 'queue_p2',
          boardSize: 3,
        );
        expect(p2Match.matchId, equals(p1Match.matchId));
        expect(p2Match.status, equals('in_progress'));
        expect(p2Match.player1Id, equals('queue_p1'));
        expect(p2Match.player2Id, equals('queue_p2'));
      },
    );

    test(
      'transactional move submission updates state and logs auditable move record',
      () async {
        final match = await endpoints.match.createMatch(
          sessionBuilder,
          playerId: 'p1_act',
          boardSize: 3,
          isPublic: false,
        );

        await endpoints.match.joinMatch(
          sessionBuilder,
          playerId: 'p2_act',
          roomCode: match.roomCode!,
        );

        // p1 plays 4-peg straight band (0,0) to (3,0)
        final afterMove1 = await endpoints.match.submitMove(
          sessionBuilder,
          matchId: match.matchId,
          playerId: 'p1_act',
          node1R: 0,
          node1C: 0,
          node2R: 3,
          node2C: 0,
          clientStateVersion: 0,
        );

        expect(afterMove1.stateVersion, equals(1));
        expect(afterMove1.activePlayerId, equals('p2_act'));

        // Check move audit record in database
        final moves = await endpoints.match.getMoves(
          sessionBuilder,
          match.matchId,
        );
        expect(moves.length, equals(1));
        expect(moves.first.playerId, equals('p1_act'));
        expect(moves.first.edgeId, equals('band_0_0_3_0'));
        expect(moves.first.stateVersion, equals(1));
      },
    );

    test('Suite F: rejects out-of-turn and non-participant moves', () async {
      final match = await endpoints.match.createMatch(
        sessionBuilder,
        playerId: 'sec_p1',
        boardSize: 3,
        isPublic: false,
      );

      await endpoints.match.joinMatch(
        sessionBuilder,
        playerId: 'sec_p2',
        roomCode: match.roomCode!,
      );

      // sec_p2 tries to move out of turn
      await expectLater(
        () => endpoints.match.submitMove(
          sessionBuilder,
          matchId: match.matchId,
          playerId: 'sec_p2',
          node1R: 0,
          node1C: 0,
          node2R: 1,
          node2C: 0,
          clientStateVersion: 0,
        ),
        throwsA(isA<StateError>()),
      );

      // Malicious third party tries to move
      await expectLater(
        () => endpoints.match.submitMove(
          sessionBuilder,
          matchId: match.matchId,
          playerId: 'hacker_eve',
          node1R: 0,
          node1C: 0,
          node2R: 1,
          node2C: 0,
          clientStateVersion: 0,
        ),
        throwsA(isA<StateError>()),
      );

      // Stale state version (e.g. client is at version 5 while match is at 0)
      await expectLater(
        () => endpoints.match.submitMove(
          sessionBuilder,
          matchId: match.matchId,
          playerId: 'sec_p1',
          node1R: 0,
          node1C: 0,
          node2R: 1,
          node2C: 0,
          clientStateVersion: 5,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'player resignation cleanly finishes match with opponent winning',
      () async {
        final match = await endpoints.match.createMatch(
          sessionBuilder,
          playerId: 'resigner',
          boardSize: 3,
          isPublic: false,
        );

        await endpoints.match.joinMatch(
          sessionBuilder,
          playerId: 'victor',
          roomCode: match.roomCode!,
        );

        final completed = await endpoints.match.resign(
          sessionBuilder,
          matchId: match.matchId,
          playerId: 'resigner',
        );

        expect(completed.status, equals('completed'));
        expect(completed.winnerId, equals('victor'));
        expect(completed.completedAt, isNotNull);
      },
    );
  });
}
