import 'package:test/test.dart';
import 'package:tcc2025_leanatan/models/receita.dart';

void main() {
  test('Criar Receita', () {
    final receita = Receita(
      id: '1',
      usuarioId: 'user123',
      nome: 'Salário',
      valor: 5000.0,
      prioridade: 5,
      data: DateTime(2024, 1, 5),
      tiposIds: ['tipo_trabalho'],
      periodoId: 'periodo_mensal',
      dataCriacao: DateTime.now(),
    );

    expect(receita.nome, equals('Salário'));
    expect(receita.valor, equals(5000.0));
    expect(receita.prioridade, equals(5));
    expect(receita.data.day, equals(5));
    expect(receita.tiposIds.length, equals(1));
    expect(receita.periodoId, equals('periodo_mensal'));
  });

  test('Converter Receita para Map', () {
    final receita = Receita(
      id: '2',
      usuarioId: 'user456',
      nome: 'Freelance',
      valor: 1500.0,
      prioridade: 3,
      data: DateTime(2024, 2, 15),
      tiposIds: ['tipo_extra'],
      periodoId: null,
      dataCriacao: DateTime.now(),
    );

    final map = receita.toMap();

    expect(map['nome'], equals('Freelance'));
    expect(map['valor'], equals(1500.0));
    expect(map['prioridade'], equals(3));
    expect(map['tiposIds'], isA<List>());
    expect(map['periodoId'], isNull);
  });

  test('Criar Receita a partir de Map', () {
    final map = {
      'id': '3',
      'usuarioId': 'user789',
      'nome': 'Investimento',
      valor: 500.0,
      'prioridade': 2,
      'data': DateTime(2024, 3, 10).toIso8601String(),
      'tiposIds': ['tipo_rendimento'],
      'periodoId': 'periodo_anual',
      'dataCriacao': DateTime.now().toIso8601String(),
    };

    final receita = Receita.fromMap(map);

    expect(receita.nome, equals('Investimento'));
    expect(receita.valor, equals(500.0));
    expect(receita.prioridade, equals(2));
    expect(receita.tiposIds.contains('tipo_rendimento'), isTrue);
    expect(receita.periodoId, equals('periodo_anual'));
  });

  test('Receita sem período (opcional)', () {
    final receita = Receita(
      id: '4',
      usuarioId: 'user111',
      nome: 'Venda única',
      valor: 300.0,
      prioridade: 1,
      data: DateTime(2024, 4, 25),
      tiposIds: [],
      periodoId: null,
      dataCriacao: DateTime.now(),
    );

    expect(receita.periodoId, isNull);
    expect(receita.tiposIds.isEmpty, isTrue);
  });

  test('Receita com múltiplos tipos', () {
    final receita = Receita(
      id: '5',
      usuarioId: 'user222',
      nome: 'Projeto',
      valor: 8000.0,
      prioridade: 4,
      data: DateTime(2024, 5, 20),
      tiposIds: ['tipo_trabalho', 'tipo_extra', 'tipo_bonus'],
      periodoId: null,
      dataCriacao: DateTime.now(),
    );

    expect(receita.tiposIds.length, equals(3));
    expect(receita.tiposIds.contains('tipo_trabalho'), isTrue);
    expect(receita.tiposIds.contains('tipo_bonus'), isTrue);
  });
}