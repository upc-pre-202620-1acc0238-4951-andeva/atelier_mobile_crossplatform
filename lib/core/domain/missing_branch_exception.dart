/// La sesión no tiene sede y la acción la necesita (agenda, órdenes o mecánicos de la sede).
class MissingBranchException implements Exception {
  const MissingBranchException();

  @override
  String toString() => 'Session without branch';
}
