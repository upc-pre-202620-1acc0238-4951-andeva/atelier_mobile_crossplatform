/// Emite cuando cualquiera cambia, una vez que ambos tienen valor. Sin `rxdart` (05 §2).
Stream<R> combineLatest2<A, B, R>(
  Stream<A> first,
  Stream<B> second,
  R Function(A, B) combine,
) {
  return Stream.multi((controller) {
    late A a;
    late B b;
    var hasA = false;
    var hasB = false;
    void emit() {
      if (hasA && hasB) controller.add(combine(a, b));
    }

    final subscriptions = [
      first.listen((value) {
        a = value;
        hasA = true;
        emit();
      }, onError: controller.addError),
      second.listen((value) {
        b = value;
        hasB = true;
        emit();
      }, onError: controller.addError),
    ];
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
  });
}
