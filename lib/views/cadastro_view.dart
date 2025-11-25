import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _authService = AuthService();

  bool _carregando = false;
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _aceitouTermos = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  String? _validarConfirmacaoSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }

    if (value != _senhaController.text) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceitouTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Você precisa aceitar os termos de uso'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      await _authService.cadastro(
        _emailController.text.trim(),
        _senhaController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Aguardar um pouco para mostrar o feedback
        await Future.delayed(const Duration(milliseconds: 800));

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        String mensagem = e.toString();

        // Tratar erros específicos
        if (mensagem.contains('email-already-in-use')) {
          mensagem = 'Este email já está em uso';
        } else if (mensagem.contains('invalid-email')) {
          mensagem = 'Email inválido';
        } else if (mensagem.contains('weak-password')) {
          mensagem = 'Senha muito fraca. Use no mínimo 6 caracteres';
        } else if (mensagem.contains('network-request-failed')) {
          mensagem = 'Erro de conexão. Verifique sua internet';
        } else {
          mensagem = 'Erro ao criar conta. Tente novamente';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $mensagem'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ícone
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  'Bem-vindo!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crie sua conta para começar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    hintText: 'seu.email@exemplo.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_carregando,
                  validator: Validators.validarEmail,
                ),
                const SizedBox(height: 16),

                // Campo Senha
                TextFormField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha *',
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _senhaVisivel
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _senhaVisivel = !_senhaVisivel);
                      },
                    ),
                    border: const OutlineInputBorder(),
                    helperText: 'Use maiúsculas, minúsculas e números',
                    helperMaxLines: 2,
                  ),
                  obscureText: !_senhaVisivel,
                  textInputAction: TextInputAction.next,
                  enabled: !_carregando,
                  validator: (value) => Validators.validarSenha(
                    value,
                    minLength: 6,
                    verificarComplexidade: false,
                  ),
                ),
                const SizedBox(height: 16),

                // Confirmar Senha
                TextFormField(
                  controller: _confirmarSenhaController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha *',
                    hintText: 'Digite a senha novamente',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmarSenhaVisivel
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() =>
                            _confirmarSenhaVisivel = !_confirmarSenhaVisivel);
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: !_confirmarSenhaVisivel,
                  textInputAction: TextInputAction.done,
                  enabled: !_carregando,
                  onFieldSubmitted: (_) => _cadastrar(),
                  validator: _validarConfirmacaoSenha,
                ),
                const SizedBox(height: 16),

                // Força da senha
                if (_senhaController.text.isNotEmpty) ...[
                  _buildForcaSenha(),
                  const SizedBox(height: 16),
                ],

                // Checkbox Termos
                CheckboxListTile(
                  value: _aceitouTermos,
                  onChanged: _carregando
                      ? null
                      : (value) {
                          setState(() => _aceitouTermos = value ?? false);
                        },
                  title: const Text(
                    'Li e aceito os termos de uso',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Botão Cadastrar
                ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Criar Conta',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),

                // Link para login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem uma conta? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: _carregando ? null : () => Navigator.pop(context),
                      child: const Text('Fazer login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForcaSenha() {
    final senha = _senhaController.text;
    int forca = 0;
    Color cor = Colors.red;
    String texto = 'Fraca';

    // Calcular força
    if (senha.length >= 6) forca++;
    if (senha.length >= 8) forca++;
    if (senha.contains(RegExp(r'[A-Z]'))) forca++;
    if (senha.contains(RegExp(r'[a-z]'))) forca++;
    if (senha.contains(RegExp(r'[0-9]'))) forca++;
    if (senha.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) forca++;

    // Determinar cor e texto
    if (forca <= 2) {
      cor = Colors.red;
      texto = 'Fraca';
    } else if (forca <= 4) {
      cor = Colors.orange;
      texto = 'Média';
    } else {
      cor = Colors.green;
      texto = 'Forte';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Força da senha: $texto',
          style: TextStyle(
            color: cor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: forca / 6,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(cor),
        ),
      ],
    );
  }
}