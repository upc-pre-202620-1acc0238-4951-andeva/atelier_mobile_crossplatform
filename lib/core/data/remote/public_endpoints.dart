/// Rutas que no llevan `Authorization` (docs/api/README.md §4).
class PublicEndpoints {
  static bool isPublic(String method, Uri url) {
    final path = url.path;
    return path.contains('/api/v1/auth/') ||
        path.endsWith('/api/v1/invitations/validate') ||
        path.endsWith('/api/v1/invitations/accept') ||
        (method == 'GET' && path.endsWith('/api/v1/billing/plans'));
  }
}
