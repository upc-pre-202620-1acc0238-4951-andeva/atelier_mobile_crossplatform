class VerifyEmailRequestDto {
  final String email;
  final String token;

  const VerifyEmailRequestDto({required this.email, required this.token});

  Map<String, dynamic> toJson() => {'email': email, 'token': token};
}
