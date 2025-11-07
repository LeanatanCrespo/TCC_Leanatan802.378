import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/relatorio.dart';
import '../models/receita.dart';
import '../models/despesa.dart';

class GraficoView extends StatelessWidget {
  final Relatorio relatorio;
  final bool anual;

  const GraficoView({
    super.key,
    required this.relatorio,
    this.anual = false, required String tipoAgrupamento,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(anual ? "Gráfico Anual" : "Gráfico Mensal")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: anual ? _buildGraficoAnual() : _buildGraficoMensal(),
      ),
    );
  }

  /// 🔹 Gráfico de Pizza para relatório mensal
  Widget _buildGraficoMensal() {
    final totalReceitas =
        relatorio.receitas.fold(0.0, (sum, r) => sum + r.valor);
    final totalDespesas =
        relatorio.despesas.fold(0.0, (sum, d) => sum + d.valor);

    return Column(
      children: [
        const Text(
          "Receitas x Despesas",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: totalReceitas,
                  color: Colors.green,
                  title: "Receitas\nR\$ ${totalReceitas.toStringAsFixed(2)}",
                  radius: 80,
                  titleStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  value: totalDespesas,
                  color: Colors.red,
                  title: "Despesas\nR\$ ${totalDespesas.toStringAsFixed(2)}",
                  radius: 80,
                  titleStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 🔹 Gráfico de Barras para relatório anual
  Widget _buildGraficoAnual() {
    // Agrupa receitas e despesas por mês
    Map<int, double> receitasMes = {};
    Map<int, double> despesasMes = {};

    for (var r in relatorio.receitas) {
      final mes = r.data.month;
      receitasMes[mes] = (receitasMes[mes] ?? 0) + r.valor;
    }

    for (var d in relatorio.despesas) {
      final mes = d.data.month;
      despesasMes[mes] = (despesasMes[mes] ?? 0) + d.valor;
    }

    return Column(
      children: [
        const Text(
          "Receitas x Despesas por Mês",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: [
                ...receitasMes.values,
                ...despesasMes.values,
              ].fold<double>(0, (max, v) => v > max ? v : max) *
                  1.2, // margem 20%
              barGroups: List.generate(12, (i) {
                final mes = i + 1;
                final receita = receitasMes[mes] ?? 0;
                final despesa = despesasMes[mes] ?? 0;

                return BarChartGroupData(
                  x: mes,
                  barRods: [
                    BarChartRodData(
                      toY: receita,
                      color: Colors.green,
                      width: 12,
                    ),
                    BarChartRodData(
                      toY: despesa,
                      color: Colors.red,
                      width: 12,
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value < 1 || value > 12) return const SizedBox();
                      return Text(
                        _mesNome(value.toInt()),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _mesNome(int mes) {
    const nomes = [
      "Jan", "Fev", "Mar", "Abr", "Mai", "Jun",
      "Jul", "Ago", "Set", "Out", "Nov", "Dez"
    ];
    return nomes[mes - 1];
  }
}