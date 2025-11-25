import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/receita_service.dart';
import '../services/despesa_service.dart';
import '../services/lembrete_service.dart';
import '../services/auth_service.dart';
import 'login_view.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final ReceitaService _receitaService = ReceitaService();
  final DespesaService _despesaService = DespesaService();
  final LembreteService _lembreteService = LembreteService();

  User? get user => _auth.currentUser;

  bool _isLoadingStats = true;
  Map<String, dynamic> _estatisticas = {};

  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  // ✅ CORREÇÃO: Saldo acumulado até hoje
  Future<void> _carregarEstatisticas() async {
    setState(() => _isLoadingStats = true);

    try {
      final agora = DateTime.now();
      final inicioDosTempos = DateTime(2000, 1, 1);
      final fimDeHoje = DateTime(agora.year, agora.month, agora.day, 23, 59, 59);

      // ✅ Buscar TODAS as receitas e despesas até hoje
      final todasReceitas = await _receitaService.listarReceitasPorPeriodo(
        inicioDosTempos,
        fimDeHoje,
      );
      
      final todasDespesas = await _despesaService.listarDespesasPorPeriodo(
        inicioDosTempos,
        fimDeHoje,
      );

      // Calcular totais
      final totalReceitas = todasReceitas.fold(0.0, (sum, r) => sum + r.valor);
      final totalDespesas = todasDespesas.fold(0.0, (sum, d) => sum + d.valor);

      // ✅ Saldo acumulado até hoje
      final saldoAcumulado = totalReceitas - totalDespesas;

      // Receitas e despesas apenas de hoje
      final hoje = DateTime(agora.year, agora.month, agora.day);
      final receitasHoje = todasReceitas.where((r) {
        final dataR = DateTime(r.data.year, r.data.month, r.data.day);
        return dataR.isAtSameMomentAs(hoje);
      }).length;

      final despesasHoje = todasDespesas.where((d) {
        final dataD = DateTime(d.data.year, d.data.month, d.data.day);
        return dataD.isAtSameMomentAs(hoje);
      }).length;

      // Lembretes
      final quantidadeLembretes = await _lembreteService.contarLembretes();
      final lembretesAtivos = await _lembreteService.contarLembretesAtivos();
      final lembretesPendentes = await _lembreteService.contarLembretesPendentes();

      setState(() {
        _estatisticas = {
          'saldoAcumulado': saldoAcumulado, // ✅ Saldo até hoje
          'totalReceitas': totalReceitas,
          'totalDespesas': totalDespesas,
          'quantidadeReceitas': todasReceitas.length,
          'quantidadeDespesas': todasDespesas.length,
          'receitasHoje': receitasHoje,
          'despesasHoje': despesasHoje,
          'quantidadeLembretes': quantidadeLembretes,
          'lembretesAtivos': lembretesAtivos,
          'lembretesPendentes': lembretesPendentes,
        };
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar estatísticas: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _authService.logout();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao sair: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmarExclusao() async {
    final senha = await showDialog<String>(
      context: context,
      builder: (context) {
        final senhaController = TextEditingController();
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Esta ação é IRREVERSÍVEL!\n\nTodos os seus dados serão permanentemente excluídos.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text('Digite sua senha para confirmar:'),
              const SizedBox(height: 8),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, senhaController.text),
              child: const Text('EXCLUIR CONTA'),
            ),
          ],
        );
      },
    );

    if (senha != null && senha.isNotEmpty) {
      await _excluirConta(senha);
    }
  }

  Future<void> _excluirConta(String senha) async {
    try {
      if (user == null) return;

      final email = user!.email;
      if (email == null) throw Exception('Email não encontrado');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: senha,
      );

      await user!.reauthenticateWithCredential(credential);
      await user!.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta excluída com sucesso')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Erro ao excluir conta';
      if (e.code == 'wrong-password') {
        mensagem = 'Senha incorreta';
      } else if (e.code == 'requires-recent-login') {
        mensagem = 'Faça login novamente antes de excluir a conta';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Widget _buildStatCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
    String? subtitulo,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: cor.withOpacity(0.1),
                  child: Icon(icone, color: cor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        valor,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cor,
                        ),
                      ),
                      if (subtitulo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitulo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    final dataHoje = '${agora.day}/${agora.month}/${agora.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarEstatisticas,
            tooltip: 'Atualizar estatísticas',
          ),
        ],
      ),
      body: _isLoadingStats
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _carregarEstatisticas,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Informações do Usuário (SEM foto)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Conta',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? 'Não identificado',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ Saldo Acumulado até Hoje (DESTAQUE)
                  const Text(
                    'Saldo Acumulado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    elevation: 4,
                    color: (_estatisticas['saldoAcumulado'] ?? 0) >= 0
                        ? Colors.green[50]
                        : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Até hoje ($dataHoje)',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'R\$ ${(_estatisticas['saldoAcumulado'] ?? 0.0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: (_estatisticas['saldoAcumulado'] ?? 0) >= 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (_estatisticas['saldoAcumulado'] ?? 0) >= 0
                                ? '✅ Positivo'
                                : '⚠️ Negativo',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Estatísticas do Dia
                  const Text(
                    'Hoje',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          titulo: 'Receitas',
                          valor: '${_estatisticas['receitasHoje'] ?? 0}',
                          icone: Icons.arrow_upward,
                          cor: Colors.green,
                          subtitulo: 'Hoje',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          titulo: 'Despesas',
                          valor: '${_estatisticas['despesasHoje'] ?? 0}',
                          icone: Icons.arrow_downward,
                          cor: Colors.red,
                          subtitulo: 'Hoje',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Total Geral
                  const Text(
                    'Total Geral',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          titulo: 'Total Receitas',
                          valor: 'R\$ ${(_estatisticas['totalReceitas'] ?? 0.0).toStringAsFixed(2)}',
                          icone: Icons.trending_up,
                          cor: Colors.green,
                          subtitulo: '${_estatisticas['quantidadeReceitas'] ?? 0} registros',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          titulo: 'Total Despesas',
                          valor: 'R\$ ${(_estatisticas['totalDespesas'] ?? 0.0).toStringAsFixed(2)}',
                          icone: Icons.trending_down,
                          cor: Colors.red,
                          subtitulo: '${_estatisticas['quantidadeDespesas'] ?? 0} registros',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Lembretes
                  const Text(
                    'Lembretes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          titulo: 'Total',
                          valor: '${_estatisticas['quantidadeLembretes'] ?? 0}',
                          icone: Icons.notifications,
                          cor: Colors.blue,
                          subtitulo: 'Criados',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          titulo: 'Ativos',
                          valor: '${_estatisticas['lembretesAtivos'] ?? 0}',
                          icone: Icons.notifications_active,
                          cor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildStatCard(
                    titulo: 'Lembretes Pendentes',
                    valor: '${_estatisticas['lembretesPendentes'] ?? 0}',
                    icone: Icons.pending_actions,
                    cor: Colors.deepOrange,
                    subtitulo: 'Aguardando ação',
                  ),
                  const SizedBox(height: 24),

                  // Ações
                  const Text(
                    'Ações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Sair da Conta'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _logout,
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Excluir Conta'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: _confirmarExclusao,
                  ),
                ],
              ),
            ),
    );
  }
}