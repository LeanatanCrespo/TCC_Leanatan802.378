import 'package:flutter_test/flutter_test.dart';
import 'package:tcc2025_leanatan/models/despesa.dart';

void main() {
  group('Despesa Model', () {
    final dataBase = DateTime(2025, 1, 15);
    final dataCriacao = DateTime(2025, 1, 1);

    test('deve criar uma despesa com todos os campos', () {
      final despesa = Despesa(
        id: '123',
        usuarioId: 'user123',
        nome: 'Aluguel',
        valor: 1500.0,
        prioridade: 10,
        data: dataBase,
        tiposIds: ['tipo1', 'tipo2'],
        periodoId: 'periodo1',
        dataCriacao: dataCriacao,
      );

      expect(despesa.id, equals('123'));
      expect(despesa.usuarioId, equals('user123'));
      expect(despesa.nome, equals('Aluguel'));
      expect(despesa.valor, equals(1500.0));
      expect(despesa.prioridade, equals(10));
      expect(despesa.data, equals(dataBase));
      expect(despesa.tiposIds, equals(['tipo1', 'tipo2']));
      expect(despesa.periodoId, equals('periodo1'));
      expect(despesa.dataCriacao, equals(dataCriacao));
    });

    test('deve criar uma despesa sem período', () {
      final despesa = Despesa(
        id: '123',
        usuarioId: 'user123',
        nome: 'Aluguel',
        valor: 1500.0,
        prioridade: 10,
        data: dataBase,
        tiposIds: [],
        dataCriacao: dataCriacao,
      );

      expect(despesa.periodoId, isNull);
    });

    test('toMap deve converter para Map corretamente', () {
      final despesa = Despesa(
        id: '123',
        usuarioId: 'user123',
        nome: 'Aluguel',
        valor: 1500.0,
        prioridade: 10,
        data: dataBase,
        tiposIds: ['tipo1'],
        periodoId: 'periodo1',
        dataCriacao: dataCriacao,
      );

      final map = despesa.toMap();

      expect(map['id'], equals('123'));
      expect(map['usuarioId'], equals('user123'));
      expect(map['nome'], equals('Aluguel'));
      expect(map['valor'], equals(1500.0));
      expect(map['prioridade'], equals(10));
      expect(map['data'], equals(dataBase.toIso8601String()));
      expect(map['tiposIds'], equals(['tipo1']));
      expect(map['periodoId'], equals('periodo1'));
      expect(map['dataCriacao'], equals(dataCriacao.toIso8601String()));
    });

    test('fromMap deve criar Despesa a partir de Map', () {
      final map = {
        'id': '123',
        'usuarioId': 'user123',
        'nome': 'Aluguel',
        'valor': 1500.0,
        'prioridade': 10,
        'data': dataBase.toIso8601String(),
        'tiposIds': ['tipo1'],
        'periodoId': 'periodo1',
        'dataCriacao': dataCriacao.toIso8601String(),
      };

      final despesa = Despesa.fromMap(map);

      expect(despesa.id, equals('123'));
      expect(despesa.usuarioId, equals('user123'));
      expect(despesa.nome, equals('Aluguel'));
      expect(despesa.valor, equals(1500.0));
      expect(despesa.prioridade, equals(10));
      expect(despesa.data, equals(dataBase));
      expect(despesa.tiposIds, equals(['tipo1']));
      expect(despesa.periodoId, equals('periodo1'));
      expect(despesa.dataCriacao, equals(dataCriacao));
    });

    test('fromMap deve lidar com valor inteiro', () {
      final map = {
        'id': '123',
        'usuarioId': 'user123',
        'nome': 'Aluguel',
        'valor': 1500, // Inteiro
        'prioridade': 10,
        'data': dataBase.toIso8601String(),
        'tiposIds': [],
        'dataCriacao': dataCriacao.toIso8601String(),
      };

      final despesa = Despesa.fromMap(map);
      expect(despesa.valor, equals(1500.0));
    });

    test('fromMap deve lidar com campos vazios', () {
      final map = {
        'id': '',
        'usuarioId': '',
        'nome': '',
        'valor': 0,
        'prioridade': 0,
        'data': dataBase.toIso8601String(),
        'tiposIds': [],
        'dataCriacao': dataCriacao.toIso8601String(),
      };

      final despesa = Despesa.fromMap(map);

      expect(despesa.id, equals(''));
      expect(despesa.usuarioId, equals(''));
      expect(despesa.nome, equals(''));
      expect(despesa.valor, equals(0.0));
      expect(despesa.prioridade, equals(0));
      expect(despesa.tiposIds, isEmpty);
      expect(despesa.periodoId, isNull);
    });

    test('copyWith deve criar cópia com campos modificados', () {
      final original = Despesa(
        id: '123',
        usuarioId: 'user123',
        nome: 'Aluguel',
        valor: 1500.0,
        prioridade: 10,
        data: dataBase,
        tiposIds: ['tipo1'],
        periodoId: 'periodo1',
        dataCriacao: dataCriacao,
      );

      final copia = original.copyWith(
        nome: 'Aluguel Atualizado',
        valor: 1600.0,
      );

      expect(copia.id, equals('123')); // Não modificado
      expect(copia.nome, equals('Aluguel Atualizado')); // Modificado
      expect(copia.valor, equals(1600.0)); // Modificado
      expect(copia.prioridade, equals(10)); // Não modificado
    });

    test('copyWith sem parâmetros deve criar cópia idêntica', () {
      final original = Despesa(
        id: '123',
        usuarioId: 'user123',
        nome: 'Aluguel',
        valor: 1500.0,
        prioridade: 10,
        data: dataBase,
        tiposIds: ['tipo1'],
        dataCriacao: dataCriacao,
      );

      final copia = original.copyWith();

      expect(copia.id, equals(original.id));
      expect(copia.usuarioId, equals(original.usuarioId));
      expect(copia.nome, equals(original.nome));
      expect(copia.valor, equals(original.valor));
      expect(copia.prioridade, equals(original.prioridade));
      expect(copia.data, equals(original.data));
      expect(copia.tiposIds, equals(original.tiposIds));
      expect(copia.periodoId, equals(original.periodoId));
      expect(copia.dataCriacao, equals(original.dataCriacao));
    });

    test('toMap e fromMap devem ser reversíveis', () {
      final original = Despesa(
        id: '123',
        usuarioId: 'user123',
        nome: 'Aluguel',
        valor: 1500.0,
        prioridade: 10,
        data: dataBase,
        tiposIds: ['tipo1', 'tipo2'],
        periodoId: 'periodo1',
        dataCriacao: dataCriacao,
      );

      final map = original.toMap();
      final recuperada = Despesa.fromMap(map);

      expect(recuperada.id, equals(original.id));
      expect(recuperada.usuarioId, equals(original.usuarioId));
      expect(recuperada.nome, equals(original.nome));
      expect(recuperada.valor, equals(original.valor));
      expect(recuperada.prioridade, equals(original.prioridade));
      expect(recuperada.data, equals(original.data));
      expect(recuperada.tiposIds, equals(original.tiposIds));
      expect(recuperada.periodoId, equals(original.periodoId));
      expect(recuperada.dataCriacao, equals(original.dataCriacao));
    });
  });
}