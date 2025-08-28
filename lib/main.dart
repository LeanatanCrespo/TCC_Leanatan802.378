import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tcc2025_leanatan/firebase_options.dart';
import 'package:tcc2025_leanatan/views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCC 2025',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginView(), // 👈 Tela inicial
    );
  }
}

