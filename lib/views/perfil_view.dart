import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({Key? key}) : super(key: key);

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir conta"),
        content: const Text(
            "Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _excluirUsuario();
    }
  }

  Future<void> _excluirUsuario() async {
    try {
      if (user != null) {
        // 🔹 Exclui dados no Firestore, se você estiver salvando perfil
        await _db.collection("usuarios").doc(user!.uid).delete();

        // 🔹 Exclui o usuário do Firebase Auth
        await user!.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Usuário excluído com sucesso.")),
          );
          Navigator.of(context).pushReplacementNamed("/login"); // redireciona
        }
      }
    } on FirebaseAuthException catch (e) {
      // 🔹 Caso precise de reautenticação
      if (e.code == "requires-recent-login") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Faça login novamente antes de excluir a conta.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao excluir conta: ${e.message}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) ...[
              Text("Email: ${user!.email ?? 'Não informado'}"),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.delete_forever),
                onPressed: _confirmarExclusao,
                label: const Text("Excluir Conta"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
