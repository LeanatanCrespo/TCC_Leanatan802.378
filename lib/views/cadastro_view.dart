import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();

  bool _carregando = false;

  void _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      try {
        await _authService.cadastro(
          _emailController.text.trim(),
          _senhaController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        if (!mounted) return;
      } finally {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Digite seu email' : null,
              ),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Digite sua senha' : null,
              ),
              const SizedBox(height: 16),
              _carregando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _cadastrar, child: const Text('Cadastrar')),
            ],
          ),
        ),
      ),
    );
  }
}
