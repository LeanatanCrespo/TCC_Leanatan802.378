import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/despesa_controller.dart';
import '../controllers/receita_controller.dart';
import '../models/despesa.dart';
import '../models/receita.dart';

class PesquisaView extends StatefulWidget {
  const PesquisaView({Key? key}) : super(key: key);

  @override
  State<PesquisaView> createState() => _PesquisaViewState();
}

class _PesquisaViewState extends State<PesquisaView> {
  final DespesaController _despesaController = DespesaController();
  final ReceitaController _receitaController = ReceitaController();

  final TextEditingController _searchController = TextEditingController();

  String filtroTipoLancamento = 'Todos'; // Todos | Despesa | Receita
  String filtroTipo = ''; // Tipo digitado
  String filtroPrioridade = ''; // Prioridade digitada
  DateTime? filtroDataInicio; // Data inicial opcional
  DateTime? filtroDataFim;    // Data final opcional

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: filtroDataInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() => filtroDataInicio = data);
    }
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate: filtroDataFim ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() => filtroDataFim = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar Lançamentos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de busca
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar por nome ou valor',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),

            // Filtros
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filtroTipoLancamento,
                    decoration: const InputDecoration(labelText: 'Lançamento'),
                    items: const [
                      DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'Despesa', child: Text('Despesa')),
                      DropdownMenuItem(value: 'Receita', child: Text('Receita')),
                    ],
                    onChanged: (val) {
                      setState(() => filtroTipoLancamento = val ?? 'Todos');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Tipo (filtro)'),
                    onChanged: (val) => setState(() => filtroTipo = val.trim().toLowerCase()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Prioridade (filtro)'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => filtroPrioridade = val.trim()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filtros de Data
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selecionarDataInicio,
                    icon: const Icon(Icons.date_range),
                    label: Text(filtroDataInicio == null
                        ? "Data Início"
                        : "${filtroDataInicio!.day}/${filtroDataInicio!.month}/${filtroDataInicio!.year}"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selecionarDataFim,
                    icon: const Icon(Icons.date_range),
                    label: Text(filtroDataFim == null
                        ? "Data Fim"
                        : "${filtroDataFim!.day}/${filtroDataFim!.month}/${filtroDataFim!.year}"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista combinada
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: _combineStreams(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final dados = snapshot.data ?? [];

                  if (dados.isEmpty) {
                    return const Center(child: Text('Nenhum lançamento encontrado.'));
                  }

                  return ListView.builder(
                    itemCount: dados.length,
                    itemBuilder: (context, index) {
                      final item = dados[index];
                      final bool isDespesa = item is Despesa;

                      final nome = item.nome as String;
                      final valor = item.valor as double;
                      final tipo = (item.tipo ?? '') as String;
                      final prioridade = (item.prioridade ?? '') as String;
                      final data = item.dataCriacao as DateTime;

                      final dataFmt =
                          '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';

                      return ListTile(
                        leading: Icon(
                          isDespesa ? Icons.remove_circle : Icons.add_circle,
                          color: isDespesa ? Colors.red : Colors.green,
                        ),
                        title: Text('$nome — R\$ ${valor.toStringAsFixed(2)}'),
                        subtitle: Text(
                          '${isDespesa ? "Despesa" : "Receita"}'
                          '${tipo.isNotEmpty ? " • Tipo: $tipo" : ""}'
                          '${prioridade.isNotEmpty ? " • Prioridade: $prioridade" : ""}\n'
                          'Criado em: $dataFmt',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Combina os streams de despesas e receitas e aplica filtros.
  Stream<List<dynamic>> _combineStreams() {
    final despesasStream = _despesaController.listarDespesas();
    final receitasStream = _receitaController.listarReceitas();

    final controller = StreamController<List<dynamic>>();

    List<Despesa> latestDespesas = [];
    List<Receita> latestReceitas = [];

    late final StreamSubscription<List<Despesa>> subD;
    late final StreamSubscription<List<Receita>> subR;

    void emitCombined() {
      List<dynamic> todos = [];

      if (filtroTipoLancamento == 'Todos' || filtroTipoLancamento == 'Despesa') {
        todos.addAll(latestDespesas);
      }
      if (filtroTipoLancamento == 'Todos' || filtroTipoLancamento == 'Receita') {
        todos.addAll(latestReceitas);
      }

      final pesquisa = _searchController.text.trim().toLowerCase();

      todos = todos.where((item) {
        final nome = (item.nome as String).toLowerCase();
        final valor = item.valor.toString();
        final tipo = ((item.tipo ?? '') as String).toLowerCase();
        final prioridade = (item.prioridade ?? '').toString();
        final data = item.dataCriacao as DateTime;

        final matchPesquisa =
            pesquisa.isEmpty || nome.contains(pesquisa) || valor.contains(pesquisa);

        final matchTipo = filtroTipo.isEmpty || tipo.contains(filtroTipo);

        final matchPrioridade = filtroPrioridade.isEmpty || prioridade == filtroPrioridade;

        final matchData = (filtroDataInicio == null || data.isAfter(filtroDataInicio!) || data.isAtSameMomentAs(filtroDataInicio!)) &&
                          (filtroDataFim == null || data.isBefore(filtroDataFim!) || data.isAtSameMomentAs(filtroDataFim!));

        return matchPesquisa && matchTipo && matchPrioridade && matchData;
      }).toList();

      todos.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));

      if (!controller.isClosed) {
        controller.add(todos);
      }
    }

    subD = despesasStream.listen((d) {
      latestDespesas = d;
      emitCombined();
    }, onError: (e, s) {
      if (!controller.isClosed) controller.addError(e, s);
    });

    subR = receitasStream.listen((r) {
      latestReceitas = r;
      emitCombined();
    }, onError: (e, s) {
      if (!controller.isClosed) controller.addError(e, s);
    });

    controller.onCancel = () async {
      await subD.cancel();
      await subR.cancel();
      if (!controller.isClosed) await controller.close();
    };

    return controller.stream;
  }
}
