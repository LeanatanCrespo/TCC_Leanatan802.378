import 'package:test/test.dart';
import 'package:tcc2025_leanatan/models/despesa.dart';

void main() {
  test('Criar Despesa', () {
    final despesa = Despesa(
      id: '1',
      usuarioId: 'user123',
      nome: 'Aluguel',
      valor: 1200.0,
      prioridade: 5,
      data: DateTime(2024, 1, 15),
      tiposIds: ['tipo_moradia'],
      periodoId: 'periodo_mensal',
      dataCriacao: DateTime.now(),
    );

    expect(despesa.nome, equals('Aluguel'));
    expect(despesa.valor, equals(1200.0));
    expect(despesa.prioridade, equals(5));
    expect(despesa.data.day, equals(15));
    expect(despesa.tiposIds.length, equals(1));
    expect(despesa.periodoId, equals('periodo_mensal'));
  });

  test('Converter Despesa para Map', () {
    final despesa = Despesa(
      id: '2',
      usuarioId: 'user456',
      nome: 'Supermercado',
      valor: 500.0,
      prioridade: 3,
      data: DateTime(2024, 2, 10),
      tiposIds: ['tipo_alimentacao'],
      periodoId: null,
      dataCriacao: DateTime.now(),
    );

    final map = despesa.toMap();

    expect(map['nome'], equals('Supermercado'));
    expect(map['valor'], equals(500.0));
    expect(map['prioridade'], equals(3));
    expect(map['tiposIds'], isA<List>());
    expect(map['periodoId'], isNull);
  });

  test('Criar Despesa a partir de Map', () {
    final map = {
      'id': '3',
      'usuarioId': 'user789',
      'nome': 'Internet',
      'valor': 100.0,
      'prioridade': 2,
      'data': DateTime(2024, 3, 5).toIso8601String(),
      'tiposIds': ['tipo_servicos'],
      'periodoId': 'periodo_mensal',
      'dataCriacao': DateTime.now().toIso8601String(),
    };

    final despesa = Despesa.fromMap(map);

    expect(despesa.nome, equals('Internet'));
    expect(despesa.valor, equals(100.0));
    expect(despesa.prioridade, equals(2));
    expect(despesa.tiposIds.contains('tipo_servicos'), isTrue);
    expect(despesa.periodoId, equals('periodo_mensal'));
  });

  test('Despesa sem período (opcional)', () {
    final despesa = Despesa(
      id: '4',
      usuarioId: 'user111',
      nome: 'Compra única',
      valor: 50.0,
      prioridade: 1,
      data: DateTime(2024, 4, 20),
      tiposIds: [],
      periodoId: null,
      dataCriacao: DateTime.now(),
    );

    expect(despesa.periodoId, isNull);
    expect(despesa.tiposIds.isEmpty, isTrue);
  });

  test('Despesa com múltiplos tipos', () {
    final despesa = Despesa(
      id: '5',
      usuarioId: 'user222',
      nome: 'Viagem',
      valor: 2000.0,
      prioridade: 4,
      data: DateTime(2024, 5, 15),
      tiposIds: ['tipo_transporte', 'tipo_lazer', 'tipo_alimentacao'],
      periodoId: null,
      dataCriacao: DateTime.now(),
    );

    expect(despesa.tiposIds.length, equals(3));
    expect(despesa.tiposIds.contains('tipo_transporte'), isTrue);
    expect(despesa.tiposIds.contains('tipo_lazer'), isTrue);
  });
}