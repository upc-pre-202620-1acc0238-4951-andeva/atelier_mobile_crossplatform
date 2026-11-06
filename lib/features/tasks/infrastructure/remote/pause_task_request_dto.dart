class PauseTaskRequestDto {
  final String reason;

  const PauseTaskRequestDto({required this.reason});

  Map<String, dynamic> toJson() => {'reason': reason};
}
