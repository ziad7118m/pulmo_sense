class SessionTokens {
  final String accessToken;
  final String refreshToken;

  const SessionTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  bool get hasAccessToken => accessToken.trim().isNotEmpty;
  bool get hasRefreshToken => refreshToken.trim().isNotEmpty;
  bool get isComplete => hasAccessToken && hasRefreshToken;

  SessionTokens copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return SessionTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
