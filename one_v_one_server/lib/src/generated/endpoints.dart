/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:one_v_one_server/src/generated/future_calls.dart' as _ich94d5a;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/admin_endpoint.dart' as _i5t1w2d2;
import '../endpoints/leaderboard_endpoint.dart' as _iy80ldha;
import '../endpoints/match_endpoint.dart' as _iznotijq;
import '../endpoints/player_endpoint.dart' as _ip5fnzx4;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
export 'future_calls.dart' show ServerpodFutureCallsGetter;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'admin': _i5t1w2d2.AdminEndpoint()
        ..initialize(
          server,
          'admin',
          null,
        ),
      'leaderboard': _iy80ldha.LeaderboardEndpoint()
        ..initialize(
          server,
          'leaderboard',
          null,
        ),
      'match': _iznotijq.MatchEndpoint()
        ..initialize(
          server,
          'match',
          null,
        ),
      'player': _ip5fnzx4.PlayerEndpoint()
        ..initialize(
          server,
          'player',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['admin'] = _is.EndpointConnector(
      name: 'admin',
      endpoint: endpoints['admin']!,
      methodConnectors: {
        'triggerDailyMaintenance': _is.MethodConnector(
          name: 'triggerDailyMaintenance',
          params: {
            'targetDate': _is.ParameterDescription(
              name: 'targetDate',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .triggerDailyMaintenance(
                    session,
                    targetDate: params['targetDate'],
                  ),
        ),
        'clearCaches': _is.MethodConnector(
          name: 'clearCaches',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .clearCaches(session),
        ),
        'getDashboardData': _is.MethodConnector(
          name: 'getDashboardData',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .getDashboardData(session),
        ),
        'getGameTypeStatsJson': _is.MethodConnector(
          name: 'getGameTypeStatsJson',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .getGameTypeStatsJson(session),
        ),
      },
    );
    connectors['leaderboard'] = _is.EndpointConnector(
      name: 'leaderboard',
      endpoint: endpoints['leaderboard']!,
      methodConnectors: {
        'getDailyLeaderboard': _is.MethodConnector(
          name: 'getDailyLeaderboard',
          params: {
            'dateString': _is.ParameterDescription(
              name: 'dateString',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['leaderboard'] as _iy80ldha.LeaderboardEndpoint)
                      .getDailyLeaderboard(
                        session,
                        dateString: params['dateString'],
                        limit: params['limit'],
                      ),
        ),
        'getAllTimeLeaderboard': _is.MethodConnector(
          name: 'getAllTimeLeaderboard',
          params: {
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['leaderboard'] as _iy80ldha.LeaderboardEndpoint)
                      .getAllTimeLeaderboard(
                        session,
                        limit: params['limit'],
                      ),
        ),
        'getGameLeaderboard': _is.MethodConnector(
          name: 'getGameLeaderboard',
          params: {
            'gameType': _is.ParameterDescription(
              name: 'gameType',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['leaderboard'] as _iy80ldha.LeaderboardEndpoint)
                      .getGameLeaderboard(
                        session,
                        gameType: params['gameType'],
                        limit: params['limit'],
                      ),
        ),
      },
    );
    connectors['match'] = _is.EndpointConnector(
      name: 'match',
      endpoint: endpoints['match']!,
      methodConnectors: {
        'createMatch': _is.MethodConnector(
          name: 'createMatch',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'gameType': _is.ParameterDescription(
              name: 'gameType',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'boardSize': _is.ParameterDescription(
              name: 'boardSize',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'isPublic': _is.ParameterDescription(
              name: 'isPublic',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).createMatch(
                    session,
                    playerId: params['playerId'],
                    gameType: params['gameType'],
                    boardSize: params['boardSize'],
                    isPublic: params['isPublic'],
                  ),
        ),
        'joinMatch': _is.MethodConnector(
          name: 'joinMatch',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'roomCode': _is.ParameterDescription(
              name: 'roomCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).joinMatch(
                    session,
                    playerId: params['playerId'],
                    roomCode: params['roomCode'],
                  ),
        ),
        'findMatch': _is.MethodConnector(
          name: 'findMatch',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'gameType': _is.ParameterDescription(
              name: 'gameType',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'boardSize': _is.ParameterDescription(
              name: 'boardSize',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).findMatch(
                    session,
                    playerId: params['playerId'],
                    gameType: params['gameType'],
                    boardSize: params['boardSize'],
                  ),
        ),
        'getMatch': _is.MethodConnector(
          name: 'getMatch',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).getMatch(
                    session,
                    params['matchId'],
                  ),
        ),
        'submitMove': _is.MethodConnector(
          name: 'submitMove',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'node1R': _is.ParameterDescription(
              name: 'node1R',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'node1C': _is.ParameterDescription(
              name: 'node1C',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'node2R': _is.ParameterDescription(
              name: 'node2R',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'node2C': _is.ParameterDescription(
              name: 'node2C',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'clientStateVersion': _is.ParameterDescription(
              name: 'clientStateVersion',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).submitMove(
                    session,
                    matchId: params['matchId'],
                    playerId: params['playerId'],
                    node1R: params['node1R'],
                    node1C: params['node1C'],
                    node2R: params['node2R'],
                    node2C: params['node2C'],
                    clientStateVersion: params['clientStateVersion'],
                  ),
        ),
        'resign': _is.MethodConnector(
          name: 'resign',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['match'] as _iznotijq.MatchEndpoint).resign(
                session,
                matchId: params['matchId'],
                playerId: params['playerId'],
              ),
        ),
        'getMatchHistory': _is.MethodConnector(
          name: 'getMatchHistory',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['match'] as _iznotijq.MatchEndpoint)
                  .getMatchHistory(
                    session,
                    playerId: params['playerId'],
                    limit: params['limit'],
                  ),
        ),
        'getMoves': _is.MethodConnector(
          name: 'getMoves',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).getMoves(
                    session,
                    params['matchId'],
                  ),
        ),
        'streamMatchEvents': _is.MethodStreamConnector(
          name: 'streamMatchEvents',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['match'] as _iznotijq.MatchEndpoint)
                  .streamMatchEvents(
                    session,
                    params['matchId'],
                  ),
        ),
      },
    );
    connectors['player'] = _is.EndpointConnector(
      name: 'player',
      endpoint: endpoints['player']!,
      methodConnectors: {
        'getOrCreateProfile': _is.MethodConnector(
          name: 'getOrCreateProfile',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'displayName': _is.ParameterDescription(
              name: 'displayName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'avatarSeed': _is.ParameterDescription(
              name: 'avatarSeed',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['player'] as _ip5fnzx4.PlayerEndpoint)
                  .getOrCreateProfile(
                    session,
                    playerId: params['playerId'],
                    displayName: params['displayName'],
                    avatarSeed: params['avatarSeed'],
                  ),
        ),
        'updateProfile': _is.MethodConnector(
          name: 'updateProfile',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'displayName': _is.ParameterDescription(
              name: 'displayName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'avatarSeed': _is.ParameterDescription(
              name: 'avatarSeed',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['player'] as _ip5fnzx4.PlayerEndpoint)
                  .updateProfile(
                    session,
                    playerId: params['playerId'],
                    displayName: params['displayName'],
                    avatarSeed: params['avatarSeed'],
                  ),
        ),
        'getProfile': _is.MethodConnector(
          name: 'getProfile',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['player'] as _ip5fnzx4.PlayerEndpoint).getProfile(
                    session,
                    params['playerId'],
                  ),
        ),
        'getAvatarUploadDescription': _is.MethodConnector(
          name: 'getAvatarUploadDescription',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['player'] as _ip5fnzx4.PlayerEndpoint)
                  .getAvatarUploadDescription(
                    session,
                    playerId: params['playerId'],
                  ),
        ),
        'verifyAvatarUpload': _is.MethodConnector(
          name: 'verifyAvatarUpload',
          params: {
            'playerId': _is.ParameterDescription(
              name: 'playerId',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['player'] as _ip5fnzx4.PlayerEndpoint)
                  .verifyAvatarUpload(
                    session,
                    playerId: params['playerId'],
                  ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }

  @override
  _is.FutureCallDispatch? get futureCalls {
    return _ich94d5a.FutureCalls();
  }
}
