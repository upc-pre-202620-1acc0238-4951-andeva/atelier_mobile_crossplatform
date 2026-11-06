class SignInRequestDto {
  final String email;
  final String password;

  const SignInRequestDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
