import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../controllers/receita_controller.dart';
import '../models/receita.dart';

class ReceitasView extends StatefulWidget {
  const ReceitasView({Key? key}) : super(key: key);

  @override
  State<ReceitasView> createState() => _ReceitasViewState();
}

class _ReceitasViewState extends State<ReceitasView> {
  final ReceitaController _controller = ReceitaController();

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _tipoController = TextEditingController();
  final _prioridadeController = TextEditingController();
  final _periodoController = TextEditingController();

  void _adicionarReceita() {
    if (_formKey.currentState!.validate()) {
      final receita = Receita(
        id: const Uuid().v4(),
        usuarioId: '',
        nome: _nomeController.text.trim(),
        valor: double.parse(_valorController.text.trim()),
        tipo: _tipoController.text.trim().isEmpty ? null : _tipoController.text.trim(),
        prioridade: _prioridadeController.text.trim().isEmpty
            ? null
            : int.tryParse(_prioridadeController.text.trim()),
        periodo: _periodoController.text.trim().isEmpty ? null : _periodoController.text.trim(),
        dataCriacao: DateTime.now(),
      );

      _controller.adicionarReceita(receita).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receita adicionada com sucesso!')),
        );
        _nomeController.clear();
        _valorController.clear();
        _tipoController.clear();
        _prioridadeController.clear();
        _periodoController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (value) =>
                            value!.isEmpty ? 'Digite o nome da receita' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _valorController,
                        decoration: const InputDecoration(labelText: 'Valor'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Digite o valor' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tipoController,
                  decoration: const InputDecoration(labelText: 'Tipo (ex: Salário, Freelance)'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _prioridadeController,
                  decoration: const InputDecoration(labelText: 'Prioridade (número opcional)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _periodoController,
                  decoration: const InputDecoration(
                    labelText: 'Período (diário, semanal, mensal, anual ou data específica)',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  onPressed: _adicionarReceita,
                  label: const Text('Adicionar Receita'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Receita>>(
            stream: _controller.listarReceitas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final receitas = snapshot.data ?? [];
              if (receitas.isEmpty) {
                return const Center(child: Text('Nenhuma receita cadastrada.'));
              }
              return ListView.builder(
                itemCount: receitas.length,
                itemBuilder: (context, index) {
                  final r = receitas[index];
                  return ListTile(
                    title: Text(r.nome),
                    subtitle: Text(
                      'R\$ ${r.valor.toStringAsFixed(2)}'
                      '${r.tipo != null ? " | Tipo: ${r.tipo}" : ""}'
                      '${r.prioridade != null ? " | Prioridade: ${r.prioridade}" : ""}'
                      '${r.periodo != null ? " | Período: ${r.periodo}" : ""}'
                      '\nCriado em: ${r.dataCriacao.day}/${r.dataCriacao.month}/${r.dataCriacao.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _controller.deletarReceita(r.id),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}