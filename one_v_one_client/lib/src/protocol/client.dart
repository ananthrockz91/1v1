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
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:one_v_one_client/src/protocol/admin_dashboard_data.dart'
    as _iaj3aai6;
import 'package:one_v_one_client/src/protocol/daily_leaderboard.dart'
    as _iqbb7t4g;
import 'package:one_v_one_client/src/protocol/game_match.dart' as _i5zwpjwi;
import 'package:one_v_one_client/src/protocol/greetings/greeting.dart'
    as _icy54go6;
import 'package:one_v_one_client/src/protocol/match_event.dart' as _ifuc2njp;
import 'package:one_v_one_client/src/protocol/match_move_record.dart'
    as _i7uf79mb;
import 'package:one_v_one_client/src/protocol/player_profile.dart' as _i380unr6;
import 'package:one_v_one_client/src/protocol/scheduled_job_log.dart'
    as _imhi8npt;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointAdmin extends _isc.EndpointRef {
  EndpointAdmin(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'admin';

  /// Development/demo manual trigger to run the daily maintenance process
  /// on demand without waiting for 1:00 AM IST.
  _ida.Future<_imhi8npt.ScheduledJobLog> triggerDailyMaintenance({
    String? targetDate,
  }) => caller.callServerEndpoint<_imhi8npt.ScheduledJobLog>(
    'admin',
    'triggerDailyMaintenance',
    {'targetDate': targetDate},
  );

  /// Clears in-memory caches across leaderboards and profiles.
  _ida.Future<bool> clearCaches() => caller.callServerEndpoint<bool>(
    'admin',
    'clearCaches',
    {},
  );

  /// Comprehensive real-time backend overview aggregating Serverpod runtime metrics,
  /// PostgreSQL table counts, in-memory cache statistics, and recent activity records.
  _ida.Future<_iaj3aai6.AdminDashboardData> getDashboardData() =>
      caller.callServerEndpoint<_iaj3aai6.AdminDashboardData>(
        'admin',
        'getDashboardData',
        {},
      );

  /// Returns real-time breakdown of matches by gameType (triangle_tactics, connect_four, reversi)
  /// including waiting, in-progress, completed, and total counts.
  _ida.Future<String> getGameTypeStatsJson() =>
      caller.callServerEndpoint<String>(
        'admin',
        'getGameTypeStatsJson',
        {},
      );
}

/// {@category Endpoint}
class EndpointLeaderboard extends _isc.EndpointRef {
  EndpointLeaderboard(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'leaderboard';

  /// Fetch daily leaderboard for a specific date (defaults to today).
  /// Uses Serverpod in-memory local caching (5-minute TTL) with group invalidation.
  _ida.Future<List<_iqbb7t4g.DailyLeaderboard>> getDailyLeaderboard({
    String? dateString,
    required int limit,
  }) => caller.callServerEndpoint<List<_iqbb7t4g.DailyLeaderboard>>(
    'leaderboard',
    'getDailyLeaderboard',
    {
      'dateString': dateString,
      'limit': limit,
    },
  );

  /// Fetch all-time leaderboard from player profiles.
  /// Uses Serverpod in-memory local caching (2-minute TTL).
  _ida.Future<List<_i380unr6.PlayerProfile>> getAllTimeLeaderboard({
    required int limit,
  }) => caller.callServerEndpoint<List<_i380unr6.PlayerProfile>>(
    'leaderboard',
    'getAllTimeLeaderboard',
    {'limit': limit},
  );

  /// Fetch leaderboard filtered by gameType ('all', 'triangle_tactics', 'connect_four', 'reversi').
  /// Computes game-specific wins and standings from completed matches.
  _ida.Future<List<_i380unr6.PlayerProfile>> getGameLeaderboard({
    required String gameType,
    required int limit,
  }) => caller.callServerEndpoint<List<_i380unr6.PlayerProfile>>(
    'leaderboard',
    'getGameLeaderboard',
    {
      'gameType': gameType,
      'limit': limit,
    },
  );
}

/// {@category Endpoint}
class EndpointMatch extends _isc.EndpointRef {
  EndpointMatch(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'match';

  /// Create a new match (private or public).
  _ida.Future<_i5zwpjwi.GameMatch> createMatch({
    required String playerId,
    String? gameType,
    required int boardSize,
    required bool isPublic,
  }) => caller.callServerEndpoint<_i5zwpjwi.GameMatch>(
    'match',
    'createMatch',
    {
      'playerId': playerId,
      'gameType': gameType,
      'boardSize': boardSize,
      'isPublic': isPublic,
    },
  );

  /// Join a private room with a 6-character room code.
  _ida.Future<_i5zwpjwi.GameMatch> joinMatch({
    required String playerId,
    required String roomCode,
  }) => caller.callServerEndpoint<_i5zwpjwi.GameMatch>(
    'match',
    'joinMatch',
    {
      'playerId': playerId,
      'roomCode': roomCode,
    },
  );

  /// Matchmake with an available player.
  _ida.Future<_i5zwpjwi.GameMatch> findMatch({
    required String playerId,
    String? gameType,
    required int boardSize,
  }) => caller.callServerEndpoint<_i5zwpjwi.GameMatch>(
    'match',
    'findMatch',
    {
      'playerId': playerId,
      'gameType': gameType,
      'boardSize': boardSize,
    },
  );

  /// Fetch authoritative match snapshot.
  _ida.Future<_i5zwpjwi.GameMatch?> getMatch(String matchId) =>
      caller.callServerEndpoint<_i5zwpjwi.GameMatch?>(
        'match',
        'getMatch',
        {'matchId': matchId},
      );

  /// Submit an edge connection move.
  _ida.Future<_i5zwpjwi.GameMatch> submitMove({
    required String matchId,
    required String playerId,
    required int node1R,
    required int node1C,
    required int node2R,
    required int node2C,
    required int clientStateVersion,
  }) => caller.callServerEndpoint<_i5zwpjwi.GameMatch>(
    'match',
    'submitMove',
    {
      'matchId': matchId,
      'playerId': playerId,
      'node1R': node1R,
      'node1C': node1C,
      'node2R': node2R,
      'node2C': node2C,
      'clientStateVersion': clientStateVersion,
    },
  );

  /// Resign from an active match.
  _ida.Future<_i5zwpjwi.GameMatch> resign({
    required String matchId,
    required String playerId,
  }) => caller.callServerEndpoint<_i5zwpjwi.GameMatch>(
    'match',
    'resign',
    {
      'matchId': matchId,
      'playerId': playerId,
    },
  );

  /// Retrieve match history for a player or platform.
  _ida.Future<List<_i5zwpjwi.GameMatch>> getMatchHistory({
    String? playerId,
    required int limit,
  }) => caller.callServerEndpoint<List<_i5zwpjwi.GameMatch>>(
    'match',
    'getMatchHistory',
    {
      'playerId': playerId,
      'limit': limit,
    },
  );

  /// Retrieve all moves for a match for auditable replay.
  _ida.Future<List<_i7uf79mb.MatchMoveRecord>> getMoves(String matchId) =>
      caller.callServerEndpoint<List<_i7uf79mb.MatchMoveRecord>>(
        'match',
        'getMoves',
        {'matchId': matchId},
      );

  /// Real-time stream of authoritative match events.
  _ida.Stream<_ifuc2njp.MatchEvent> streamMatchEvents(String matchId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_ifuc2njp.MatchEvent>,
        _ifuc2njp.MatchEvent
      >(
        'match',
        'streamMatchEvents',
        {'matchId': matchId},
        {},
      );
}

/// {@category Endpoint}
class EndpointPlayer extends _isc.EndpointRef {
  EndpointPlayer(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'player';

  /// Fetches an existing player profile or creates one if it doesn't exist.
  _ida.Future<_i380unr6.PlayerProfile> getOrCreateProfile({
    required String playerId,
    String? displayName,
    String? avatarSeed,
  }) => caller.callServerEndpoint<_i380unr6.PlayerProfile>(
    'player',
    'getOrCreateProfile',
    {
      'playerId': playerId,
      'displayName': displayName,
      'avatarSeed': avatarSeed,
    },
  );

  /// Updates player profile (displayName and avatarSeed) and refreshes cache.
  _ida.Future<_i380unr6.PlayerProfile> updateProfile({
    required String playerId,
    String? displayName,
    String? avatarSeed,
  }) => caller.callServerEndpoint<_i380unr6.PlayerProfile>(
    'player',
    'updateProfile',
    {
      'playerId': playerId,
      'displayName': displayName,
      'avatarSeed': avatarSeed,
    },
  );

  /// Fetches a player profile using fast local in-memory caching.
  _ida.Future<_i380unr6.PlayerProfile?> getProfile(String playerId) =>
      caller.callServerEndpoint<_i380unr6.PlayerProfile?>(
        'player',
        'getProfile',
        {'playerId': playerId},
      );

  /// Generates a Serverpod Cloud Storage direct upload description for avatar photos.
  _ida.Future<String?> getAvatarUploadDescription({required String playerId}) =>
      caller.callServerEndpoint<String?>(
        'player',
        'getAvatarUploadDescription',
        {'playerId': playerId},
      );

  /// Verifies an uploaded avatar file in Cloud Storage, persists its public URL, and invalidates cache.
  _ida.Future<_i380unr6.PlayerProfile?> verifyAvatarUpload({
    required String playerId,
  }) => caller.callServerEndpoint<_i380unr6.PlayerProfile?>(
    'player',
    'verifyAvatarUpload',
    {'playerId': playerId},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_icy54go6.Greeting> hello(String name) =>
      caller.callServerEndpoint<_icy54go6.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    admin = EndpointAdmin(this);
    leaderboard = EndpointLeaderboard(this);
    match = EndpointMatch(this);
    player = EndpointPlayer(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAdmin admin;

  late final EndpointLeaderboard leaderboard;

  late final EndpointMatch match;

  late final EndpointPlayer player;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'admin': admin,
    'leaderboard': leaderboard,
    'match': match,
    'player': player,
    'greeting': greeting,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
