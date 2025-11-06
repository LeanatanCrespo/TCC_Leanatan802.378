import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../controllers/tipo_controller.dart';
import '../models/tipo.dart';

class TiposView extends StatefulWidget {
  const TiposView({Key? key}) : super(key: key);

  @override
  State<TiposView> createState() => _TiposViewState();
}

class _TiposViewState extends State<TiposView> {
  final TipoController _controller = TipoController();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  bool _isLoading = false;
  Tipo? _tipoEditando;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _limparFormulario() {
    _nomeController.clear();
    setState(() => _tipoEditando = null);
  }

  void _editarTipo(Tipo tipo) {
    setState(() {
      _tipoEditando = tipo;
      _nomeController.text = tipo.nome;
    });
  }

  Future<void> _salvarTipo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_tipoEditando == null) {
        // Criar novo
        final tipo = Tipo(
          id: const Uuid().v4(),
          usuarioId: '',
          nome: _nomeController.text.trim(),
          dataCriacao: DateTime.now(),
        );
        await _controller.adicionarTipo(tipo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tipo criado com sucesso!')),
          );
        }
      } else {
        // Atualizar existente
        final tipoAtualizado = _tipoEditando!.copyWith(
          nome: _nomeController.text.trim(),
        );
        await _controller.atualizarTipo(tipoAtualizado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tipo atualizado com sucesso!')),
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

  Future<void> _confirmarExclusao(Tipo tipo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Tipo'),
        content: Text('Deseja excluir o tipo "${tipo.nome}"?'),
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
        await _controller.deletarTipo(tipo.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tipo excluído com sucesso!')),
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
        title: const Text('Gerenciar Tipos/Tags'),
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
                      _tipoEditando == null ? 'Novo Tipo' : 'Editar Tipo',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do Tipo',
                        hintText: 'Ex: Alimentação, Transporte, Salário',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite o nome do tipo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(_tipoEditando == null
                                ? Icons.add
                                : Icons.save),
                            label: Text(_tipoEditando == null
                                ? 'Criar Tipo'
                                : 'Salvar'),
                            onPressed: _isLoading ? null : _salvarTipo,
                          ),
                        ),
                        if (_tipoEditando != null) ...[
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

          // Lista de tipos
          Expanded(
            child: StreamBuilder<List<Tipo>>(
              stream: _controller.listarTipos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tipos = snapshot.data ?? [];

                if (tipos.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum tipo cadastrado.\nCrie um tipo para categorizar suas receitas e despesas.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: tipos.length,
                  itemBuilder: (context, index) {
                    final tipo = tipos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(tipo.nome[0].toUpperCase()),
                        ),
                        title: Text(tipo.nome),
                        subtitle: Text(
                          'Criado em: ${tipo.dataCriacao.day}/${tipo.dataCriacao.month}/${tipo.dataCriacao.year}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editarTipo(tipo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmarExclusao(tipo),
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