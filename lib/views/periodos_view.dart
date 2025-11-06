import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../controllers/periodo_controller.dart';
import '../models/periodo.dart';

class PeriodosView extends StatefulWidget {
  const PeriodosView({Key? key}) : super(key: key);

  @override
  State<PeriodosView> createState() => _PeriodosViewState();
}

class _PeriodosViewState extends State<PeriodosView> {
  final PeriodoController _controller = PeriodoController();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  String _unidadeSelecionada = 'dias';
  bool _isLoading = false;
  Periodo? _periodoEditando;

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  void _limparFormulario() {
    _nomeController.clear();
    _quantidadeController.clear();
    setState(() {
      _periodoEditando = null;
      _unidadeSelecionada = 'dias';
    });
  }

  void _editarPeriodo(Periodo periodo) {
    setState(() {
      _periodoEditando = periodo;
      _nomeController.text = periodo.nome;
      _quantidadeController.text = periodo.quantidade.toString();
      _unidadeSelecionada = periodo.unidade;
    });
  }

  Future<void> _salvarPeriodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final quantidade = int.parse(_quantidadeController.text.trim());

      if (_periodoEditando == null) {
        // Criar novo
        final periodo = Periodo(
          id: const Uuid().v4(),
          usuarioId: '',
          nome: _nomeController.text.trim(),
          quantidade: quantidade,
          unidade: _unidadeSelecionada,
          dataCriacao: DateTime.now(),
        );
        await _controller.adicionarPeriodo(periodo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Período criado com sucesso!')),
          );
        }
      } else {
        // Atualizar existente
        final periodoAtualizado = _periodoEditando!.copyWith(
          nome: _nomeController.text.trim(),
          quantidade: quantidade,
          unidade: _unidadeSelecionada,
        );
        await _controller.atualizarPeriodo(periodoAtualizado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Período atualizado com sucesso!')),
          );
        }
      }
      _limparFormulario();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmarExclusao(Periodo periodo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Período'),
        content: Text('Deseja excluir o período "${periodo.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _controller.deletarPeriodo(periodo.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Período excluído com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Períodos'),
      ),
      body: Column(
        children: [
          // Formulário
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _periodoEditando == null
                          ? 'Novo Período'
                          : 'Editar Período',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Período',
                        hintText: 'Ex: Quinzenal, Trimestral',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite o nome do período';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _quantidadeController,
                            decoration: const InputDecoration(
                              labelText: 'Quantidade',
                              hintText: '3, 5, 7...',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Digite a quantidade';
                              }
                              final numero = int.tryParse(value.trim());
                              if (numero == null || numero <= 0) {
                                return 'Digite um número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _unidadeSelecionada,
                            decoration: const InputDecoration(
                              labelText: 'Unidade',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'dias',
                                child: Text('Dias'),
                              ),
                              DropdownMenuItem(
                                value: 'meses',
                                child: Text('Meses'),
                              ),
                              DropdownMenuItem(
                                value: 'anos',
                                child: Text('Anos'),
                              ),
                            ],
                            onChanged: (valor) {
                              setState(() => _unidadeSelecionada = valor!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Exemplo: A cada ${_quantidadeController.text.isEmpty ? "X" : _quantidadeController.text} $_unidadeSelecionada',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(_periodoEditando == null
                                ? Icons.add
                                : Icons.save),
                            label: Text(_periodoEditando == null
                                ? 'Criar Período'
                                : 'Salvar'),
                            onPressed: _isLoading ? null : _salvarPeriodo,
                          ),
                        ),
                        if (_periodoEditando != null) ...[
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _limparFormulario,
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de períodos
          Expanded(
            child: StreamBuilder<List<Periodo>>(
              stream: _controller.listarPeriodos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final periodos = snapshot.data ?? [];

                if (periodos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum período cadastrado.\nCrie períodos personalizados para recorrência.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: periodos.length,
                  itemBuilder: (context, index) {
                    final periodo = periodos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.repeat),
                        ),
                        title: Text(periodo.nome),
                        subtitle: Text(periodo.descricao),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editarPeriodo(periodo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarExclusao(periodo),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}