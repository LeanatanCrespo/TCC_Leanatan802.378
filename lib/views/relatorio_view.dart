import 'package:flutter/material.dart';
import '../models/relatorio.dart';
import '../services/relatorio_service.dart';
import 'grafico_view.dart'; 

class RelatorioView extends StatefulWidget {
  const RelatorioView({Key? key}) : super(key: key);

  @override
  State<RelatorioView> createState() => _RelatorioViewState();
}

class _RelatorioViewState extends State<RelatorioView> {
  final RelatorioService _service = RelatorioService();
  Relatorio? _relatorio;

  final _anoController = TextEditingController();
  final _mesController = TextEditingController();

  void _gerarMensal() async {
    final mes = int.tryParse(_mesController.text.trim());
    final ano = int.tryParse(_anoController.text.trim());
    if (mes != null && ano != null) {
      final rel = await _service.gerarRelatorioMensal(mes, ano);
      setState(() => _relatorio = rel);
    }
  }

  void _gerarAnual() async {
    final ano = int.tryParse(_anoController.text.trim());
    if (ano != null) {
      final rel = await _service.gerarRelatorioAnual(ano);
      setState(() => _relatorio = rel);
    }
  }

  void _abrirGrafico(bool anual) {
    if (_relatorio != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GraficoView(
            relatorio: _relatorio!,
            anual: anual,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Relatórios")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _mesController,
              decoration: const InputDecoration(labelText: "Mês (1-12)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _anoController,
              decoration: const InputDecoration(labelText: "Ano"),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _gerarMensal,
                  child: const Text("Gerar Mensal"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _gerarAnual,
                  child: const Text("Gerar Anual"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_relatorio != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Período: ${_relatorio!.primeiraData} - ${_relatorio!.ultimaData}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("Receitas:"),
                    Expanded(
                      child: ListView(
                        children: [
                          ..._relatorio!.receitas.map(
                            (r) => Text(" - ${r.nome}: R\$ ${r.valor}"),
                          ),
                          const SizedBox(height: 10),
                          Text("Despesas:"),
                          ..._relatorio!.despesas.map(
                            (d) => Text(" - ${d.nome}: R\$ ${d.valor}"),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "💰 Valor Final: R\$ ${_relatorio!.valorFinal.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Botão para gráfico
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // verifica se foi gerado anual ou mensal
                          final anual = _mesController.text.trim().isEmpty;
                          _abrirGrafico(anual);
                        },
                        icon: const Icon(Icons.pie_chart),
                        label: const Text("Ver Gráfico"),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
