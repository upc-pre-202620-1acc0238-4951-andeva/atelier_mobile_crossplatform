class ResendVerificationRequestDto {
  final String email;

  const ResendVerificationRequestDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}
