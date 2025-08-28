import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../controllers/lembrete_controller.dart';
import '../models/lembrete.dart';

class LembretesView extends StatefulWidget {
  const LembretesView({Key? key}) : super(key: key);

  @override
  State<LembretesView> createState() => _LembretesViewState();
}

class _LembretesViewState extends State<LembretesView> {
  final LembreteController _controller = LembreteController();

  final _formKey = GlobalKey<FormState>();

  void _adicionarLembrete() {
    if (_formKey.currentState!.validate()) {
      final lembrete = Lembrete(
        id: const Uuid().v4(),
        usuarioId: '',
        referenciaId: '',
        tipoReferencia: 'Geral',
        dataLembrete: DateTime.now(),
        recorrente: false,
        ativo: true,
      );

      _controller.adicionarLembrete(lembrete).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lembrete adicionado com sucesso!')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _adicionarLembrete,
          child: const Text('Adicionar Lembrete'),
        ),
        Expanded(
          child: StreamBuilder<List<Lembrete>>(
            stream: _controller.listarLembretes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final lembretes = snapshot.data ?? [];
              if (lembretes.isEmpty) {
                return const Center(child: Text('Nenhum lembrete.'));
              }
              return ListView.builder(
                itemCount: lembretes.length,
                itemBuilder: (context, index) {
                  final l = lembretes[index];
                  return ListTile(
                    title: Text('Lembrete ${l.id.substring(0, 6)}'),
                    subtitle: Text('Ativo: ${l.ativo}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _controller.deletarLembrete(l.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
