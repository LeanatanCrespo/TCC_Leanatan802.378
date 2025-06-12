import 'package:flutter_test/flutter_test.dart';
import 'package:tcc2025_leanatan/models/despesa.dart';

void main() {
  group('Despesa', () {
    final despesa = Despesa(
      id: 'd001',
      usuarioId: 'u321',
      nome: 'Aluguel',
      valor: 1500.00,
      periodo: 'Mensal',
      prioridade: 'Alta',
      tipo: 'Fixa',
      dataCriacao: DateTime.parse('2024-06-01T10:00:00'),
    );

    test('construtor e atributos', () {
      expect(despesa.id, 'd001');
      expect(despesa.usuarioId, 'u321');
      expect(despesa.nome, 'Aluguel');
      expect(despesa.valor, 1500.00);
      expect(despesa.periodo, 'Mensal');
      expect(despesa.prioridade, 'Alta');
      expect(despesa.tipo, 'Fixa');
      expect(despesa.dataCriacao, DateTime.parse('2024-06-01T10:00:00'));
    });

    test('conversão para Map', () {
      final map = despesa.toMap();
      expect(map['id'], 'd001');
      expect(map['usuarioId'], 'u321');
      expect(map['nome'], 'Aluguel');
      expect(map['valor'], 1500.00);
      expect(map['periodo'], 'Mensal');
      expect(map['prioridade'], 'Alta');
      expect(map['tipo'], 'Fixa');
      expect(map['dataCriacao'], '2024-06-01T10:00:00.000');
    });

    test('criação a partir de Map', () {
      final map = {
        'id': 'd002',
        'usuarioId': 'u654',
        'nome': 'Internet',
        'valor': 120.75,
        'periodo': 'Mensal',
        'prioridade': 'Média',
        'tipo': 'Fixa',
        'dataCriacao': '2024-06-05T08:00:00.000',
      };

      final novaDespesa = Despesa.fromMap(map);
      expect(novaDespesa.id, 'd002');
      expect(novaDespesa.usuarioId, 'u654');
      expect(novaDespesa.nome, 'Internet');
      expect(novaDespesa.valor, 120.75);
      expect(novaDespesa.periodo, 'Mensal');
      expect(novaDespesa.prioridade, 'Média');
      expect(novaDespesa.tipo, 'Fixa');
      expect(novaDespesa.dataCriacao, DateTime.parse('2024-06-05T08:00:00.000'));
    });
  });
}
