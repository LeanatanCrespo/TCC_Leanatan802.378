import 'package:flutter_test/flutter_test.dart';
import 'package:tcc2025_leanatan/models/receita.dart';

void main() {
  group('Receita', () {
    final receita = Receita(
      id: 'r001',
      usuarioId: 'u123',
      nome: 'Salário',
      valor: 2500.00,
      periodo: 'Mensal',
      prioridade: 'Alta',
      tipo: 'Fixa',
      dataCriacao: DateTime.parse('2024-06-01T12:00:00'),
    );

    test('construtor e atributos', () {
      expect(receita.id, 'r001');
      expect(receita.usuarioId, 'u123');
      expect(receita.nome, 'Salário');
      expect(receita.valor, 2500.00);
      expect(receita.periodo, 'Mensal');
      expect(receita.prioridade, 'Alta');
      expect(receita.tipo, 'Fixa');
      expect(receita.dataCriacao, DateTime.parse('2024-06-01T12:00:00'));
    });

    test('conversão para Map', () {
      final map = receita.toMap();
      expect(map['id'], 'r001');
      expect(map['usuarioId'], 'u123');
      expect(map['nome'], 'Salário');
      expect(map['valor'], 2500.00);
      expect(map['periodo'], 'Mensal');
      expect(map['prioridade'], 'Alta');
      expect(map['tipo'], 'Fixa');
      expect(map['dataCriacao'], '2024-06-01T12:00:00.000');
    });

    test('criação a partir de Map', () {
      final map = {
        'id': 'r002',
        'usuarioId': 'u456',
        'nome': 'Freelance',
        'valor': 1200.50,
        'periodo': 'Semanal',
        'prioridade': 'Média',
        'tipo': 'Variável',
        'dataCriacao': '2024-06-10T08:30:00.000',
      };

      final novaReceita = Receita.fromMap(map);
      expect(novaReceita.id, 'r002');
      expect(novaReceita.usuarioId, 'u456');
      expect(novaReceita.nome, 'Freelance');
      expect(novaReceita.valor, 1200.50);
      expect(novaReceita.periodo, 'Semanal');
      expect(novaReceita.prioridade, 'Média');
      expect(novaReceita.tipo, 'Variável');
      expect(novaReceita.dataCriacao, DateTime.parse('2024-06-10T08:30:00.000'));
    });
  });
}
