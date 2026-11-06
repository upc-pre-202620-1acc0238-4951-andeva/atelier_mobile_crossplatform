enum WeekDay {
  monday('MONDAY'),
  tuesday('TUESDAY'),
  wednesday('WEDNESDAY'),
  thursday('THURSDAY'),
  friday('FRIDAY'),
  saturday('SATURDAY'),
  sunday('SUNDAY');

  final String apiName;

  const WeekDay(this.apiName);

  /// `null` si el backend envía un valor nuevo.
  static WeekDay? fromApi(String value) {
    for (final day in values) {
      if (day.apiName == value) return day;
    }
    return null;
  }
}
