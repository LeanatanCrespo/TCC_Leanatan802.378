import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../controllers/despesa_controller.dart';
import '../models/despesa.dart';

class DespesasView extends StatefulWidget {
  const DespesasView({Key? key}) : super(key: key);

  @override
  State<DespesasView> createState() => _DespesasViewState();
}

class _DespesasViewState extends State<DespesasView> {
  final DespesaController _controller = DespesaController();

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _tipoController = TextEditingController();
  final _prioridadeController = TextEditingController();
  final _periodoController = TextEditingController();

  void _adicionarDespesa() {
    if (_formKey.currentState!.validate()) {
      final despesa = Despesa(
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

      _controller.adicionarDespesa(despesa).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Despesa adicionada com sucesso!')),
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
                            value!.isEmpty ? 'Digite o nome da despesa' : null,
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
                  decoration: const InputDecoration(labelText: 'Tipo (ex: Transporte, Alimentação)'),
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
                  onPressed: _adicionarDespesa,
                  label: const Text('Adicionar Despesa'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Despesa>>(
            stream: _controller.listarDespesas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final despesas = snapshot.data ?? [];
              if (despesas.isEmpty) {
                return const Center(child: Text('Nenhuma despesa cadastrada.'));
              }
              return ListView.builder(
                itemCount: despesas.length,
                itemBuilder: (context, index) {
                  final d = despesas[index];
                  return ListTile(
                    title: Text(d.nome),
                    subtitle: Text(
                      'R\$ ${d.valor.toStringAsFixed(2)}'
                      '${d.tipo != null ? " | Tipo: ${d.tipo}" : ""}'
                      '${d.prioridade != null ? " | Prioridade: ${d.prioridade}" : ""}'
                      '${d.periodo != null ? " | Período: ${d.periodo}" : ""}'
                      '\nCriado em: ${d.dataCriacao.day}/${d.dataCriacao.month}/${d.dataCriacao.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _controller.deletarDespesa(d.id),
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