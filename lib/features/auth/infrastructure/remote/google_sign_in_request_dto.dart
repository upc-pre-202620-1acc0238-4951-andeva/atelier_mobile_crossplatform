class GoogleSignInRequestDto {
  final String idToken;

  const GoogleSignInRequestDto({required this.idToken});

  Map<String, dynamic> toJson() => {'idToken': idToken};
}
