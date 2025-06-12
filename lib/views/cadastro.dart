import 'package:firebase_auth/firebase_auth.dart';

Future<void> registerUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('Usuário registrado com sucesso!');
  } catch (e) {
    print('Erro no cadastro: $e');
  }
}
