import 'package:firebase_auth/firebase_auth.dart';

Future<void> loginUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('Usuário logado!');
  } catch (e) {
    print('Erro no login: $e');
  }
}
