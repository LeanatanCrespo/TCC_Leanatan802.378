import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Login
  Future<User?> login(String email, String senha) async {
    try {
      final credenciais = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      // Salvar UID seguro
      await _secureStorage.write(key: 'usuarioId', value: credenciais.user?.uid);
      return credenciais.user;
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  // Cadastro
  Future<User?> cadastro(String email, String senha) async {
    try {
      final credenciais = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      // Salvar UID seguro
      await _secureStorage.write(key: 'usuarioId', value: credenciais.user?.uid);
      return credenciais.user;
    } catch (e) {
      throw Exception('Erro ao fazer cadastro: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _secureStorage.delete(key: 'usuarioId');
  }

  // Verificar usuário logado
  User? get usuarioAtual => _firebaseAuth.currentUser;

  // Recuperar UID armazenado
  Future<String?> getUsuarioId() async {
    return await _secureStorage.read(key: 'usuarioId');
  }
}