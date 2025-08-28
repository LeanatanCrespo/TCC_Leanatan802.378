import '../models/usuario.dart';
import '../services/auth_service.dart';

class UsuarioController {
  final AuthService _authService = AuthService();

  // Recupera usuário logado
  Future<String?> getUsuarioId() async {
    return await _authService.getUsuarioId();
  }

  // Retorna o usuário atual do Firebase
  Usuario? get usuarioAtual {
    final user = _authService.usuarioAtual;
    if (user == null) return null;
    return Usuario(id: user.uid, nome: user.displayName ?? '', email: user.email ?? '');
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
  }
}
