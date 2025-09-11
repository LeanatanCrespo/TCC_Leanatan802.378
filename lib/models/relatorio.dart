import 'package:uuid/uuid.dart';
import 'despesa.dart';
import 'receita.dart';

class Relatorio {
  final String id;
  final DateTime primeiraData;
  final DateTime ultimaData;
  final List<Receita> receitas;
  final List<Despesa> despesas;
  final double valorFinal;

  Relatorio({
    required this.id,
    required this.primeiraData,
    required this.ultimaData,
    required this.receitas,
    required this.despesas,
  }) : valorFinal = _calcularValorFinal(receitas, despesas);

  //alcula o saldo
  static double _calcularValorFinal(List<Receita> receitas, List<Despesa> despesas) {
    final totalReceitas = receitas.fold(0.0, (sum, r) => sum + r.valor);
    final totalDespesas = despesas.fold(0.0, (sum, d) => sum + d.valor);
    return totalReceitas - totalDespesas;
  }

  //Exporta para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'primeiraData': primeiraData.toIso8601String(),
      'ultimaData': ultimaData.toIso8601String(),
      'receitas': receitas.map((r) => r.toMap()).toList(),
      'despesas': despesas.map((d) => d.toMap()).toList(),
      'valorFinal': valorFinal,
    };
  }

  factory Relatorio.fromMap(Map<String, dynamic> map) {
    return Relatorio(
      id: map['id'] ?? const Uuid().v4(),
      primeiraData: DateTime.parse(map['primeiraData']),
      ultimaData: DateTime.parse(map['ultimaData']),
      receitas: (map['receitas'] as List)
          .map((r) => Receita.fromMap(r as Map<String, dynamic>))
          .toList(),
      despesas: (map['despesas'] as List)
          .map((d) => Despesa.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
