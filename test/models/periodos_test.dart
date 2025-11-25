import 'package:flutter_test/flutter_test.dart';
import 'package:tcc2025_leanatan/models/periodo.dart';

void main() {
  group('Periodo Model', () {
    final dataCriacao = DateTime(2025, 1, 1);

    test('deve criar período com todos os campos', () {
      final periodo = Periodo(
        id: '123',
        usuarioId: 'user123',
        nome: 'Mensal',
        quantidade: 1,
        unidade: 'meses',
        dataCriacao: dataCriacao,
      );

      expect(periodo.id, equals('123'));
      expect(periodo.usuarioId, equals('user123'));
      expect(periodo.nome, equals('Mensal'));
      expect(periodo.quantidade, equals(1));
      expect(periodo.unidade, equals('meses'));
      expect(periodo.dataCriacao, equals(dataCriacao));
    });

    test('descricao deve formatar corretamente', () {
      final periodo1 = Periodo(
        id: '1',
        usuarioId: 'user',
        nome: 'Mensal',
        quantidade: 1,
        unidade: 'meses',
        dataCriacao: dataCriacao,
      );

      final periodo2 = Periodo(
        id: '2',
        usuarioId: 'user',
        nome: 'Trimestral',
        quantidade: 3,
        unidade: 'meses',
        dataCriacao: dataCriacao,
      );

      expect(periodo1.descricao, equals('A cada 1 meses'));
      expect(periodo2.descricao, equals('A cada 3 meses'));
    });

    group('calcularProximaData', () {
      test('deve calcular próxima data em dias', () {
        final periodo = Periodo(
          id: '1',
          usuarioId: 'user',
          nome: 'Semanal',
          quantidade: 7,
          unidade: 'dias',
          dataCriacao: dataCriacao,
        );

        final dataBase = DateTime(2025, 1, 15);
        final proximaData = periodo.calcularProximaData(dataBase);

        expect(proximaData, equals(DateTime(2025, 1, 22)));
      });

      test('deve calcular próxima data em meses', () {
        final periodo = Periodo(
          id: '1',
          usuarioId: 'user',
          nome: 'Mensal',
          quantidade: 1,
          unidade: 'meses',
          dataCriacao: dataCriacao,
        );

        final dataBase = DateTime(2025, 1, 15);
        final proximaData = periodo.calcularProximaData(dataBase);

        expect(proximaData, equals(DateTime(2025, 2, 15)));
      });

      test('deve calcular próxima data em anos', () {
        final periodo = Periodo(
          id: '1',
          usuarioId: 'user',
          nome: 'Anual',
          quantidade: 1,
          unidade: 'anos',
          dataCriacao: dataCriacao,
        );

        final dataBase = DateTime(2025, 1, 15);
        final proximaData = periodo.calcularProximaData(dataBase);

        expect(proximaData, equals(DateTime(2026, 1, 15)));
      });

      test('deve retornar mesma data para unidade desconhecida', () {
        final periodo = Periodo(
          id: '1',
          usuarioId: 'user',
          nome: 'Teste',
          quantidade: 1,
          unidade: 'desconhecido',
          dataCriacao: dataCriacao,
        );

        final dataBase = DateTime(2025, 1, 15);
        final proximaData = periodo.calcularProximaData(dataBase);

        expect(proximaData, equals(dataBase));
      });
    });

    group('gerarDatasRecorrentes', () {
      test('deve gerar datas recorrentes em dias', () {
        final periodo = Periodo(
          id: '1',
          usuarioId: 'user',
          nome: 'A cada 7 dias',
          quantidade: 7,
          unidade: 'dias',
          dataCriacao: dataCriacao,
        );

        final dataInicial = DateTime(2025, 1, 1);
        final dataFinal = DateTime(2025, 1, 31);
        final datas = periodo.gerarDatasRecorrentes(dataInicial, dataFinal);

        expect(datas.length, equals(5)); // 1, 8, 15, 22, 29
        expect(datas[0], equals(DateTime(2025, 1, 1)));
        expect(datas[1], equals(DateTime(2025, 1, 8)));
        expect(datas[2], equals(DateTime(2025, 1, 15)));
        expect(datas[3], equals(DateTime(2025, 1, 22)));
        expect(datas[4], equals(DateTime(2025, 1, 29)));
      });

      test('deve gerar datas recorrentes em meses', () {
        final periodo = Periodo(
          id: '1',
          usuarioId: 'user',
          nome: 'Mensal',
          quantidade: 1,
          unidade: 'meses',
          dataCriacao: dataCriacao,
        );

        final dataInicial = DateTime(2025, 1, 15);
        final dataFinal = DateTime(2025, 4, 15);
        final datas = periodo.gerarDatasRecorrentes(dataInicial, dataFinal);

        expect(datas.length, equals(4)); // Jan, Fev, Mar, Abr
        expect(datas[0], equals(DateTime(2025, 1, 15)));
        expect(datas[1], equals(DateTime(2025, 2, 15)));
        expect(datas[2], equals(DateTime(2025, 3, 15)));
        expect(datas[3], equals(DateTime(2025, 4, 15)));
      });

      test('deve gerar lista vazia quando data inicial > data final', () {
        final periodo = Periodo(
          id: '1',
          usuarioId: 'user',
          nome: 'Mensal',
          quantidade: 1,
          unidade: 'meses',
          dataCriacao: dataCriacao,
        );

        final dataInicial = DateTime(2025, 12, 1);
        final dataFinal = DateTime(2025, 1, 1);
        final datas = periodo.gerarDatasRecorrentes(dataInicial, dataFinal);

        expect(datas, isEmpty);
      });

      test('deve incluir data inicial e final quando coincidem', () {
        final periodo = Periodo(
          id: '1',
          usuarioId: 'user',
          nome: 'Único',
          quantidade: 1,
          unidade: 'meses',
          dataCriacao: dataCriacao,
        );

        final data = DateTime(2025, 1, 15);
        final datas = periodo.gerarDatasRecorrentes(data, data);

        expect(datas.length, equals(1));
        expect(datas[0], equals(data));
      });
    });

    test('toMap deve converter para Map corretamente', () {
      final periodo = Periodo(
        id: '123',
        usuarioId: 'user123',
        nome: 'Mensal',
        quantidade: 1,
        unidade: 'meses',
        dataCriacao: dataCriacao,
      );

      final map = periodo.toMap();

      expect(map['id'], equals('123'));
      expect(map['usuarioId'], equals('user123'));
      expect(map['nome'], equals('Mensal'));
      expect(map['quantidade'], equals(1));
      expect(map['unidade'], equals('meses'));
      expect(map['dataCriacao'], equals(dataCriacao.toIso8601String()));
    });

    test('fromMap deve criar Periodo a partir de Map', () {
      final map = {
        'id': '123',
        'usuarioId': 'user123',
        'nome': 'Mensal',
        'quantidade': 1,
        'unidade': 'meses',
        'dataCriacao': dataCriacao.toIso8601String(),
      };

      final periodo = Periodo.fromMap(map);

      expect(periodo.id, equals('123'));
      expect(periodo.usuarioId, equals('user123'));
      expect(periodo.nome, equals('Mensal'));
      expect(periodo.quantidade, equals(1));
      expect(periodo.unidade, equals('meses'));
      expect(periodo.dataCriacao, equals(dataCriacao));
    });

    test('copyWith deve criar cópia com campos modificados', () {
      final original = Periodo(
        id: '123',
        usuarioId: 'user123',
        nome: 'Mensal',
        quantidade: 1,
        unidade: 'meses',
        dataCriacao: dataCriacao,
      );

      final copia = original.copyWith(
        nome: 'Trimestral',
        quantidade: 3,
      );

      expect(copia.id, equals('123'));
      expect(copia.nome, equals('Trimestral'));
      expect(copia.quantidade, equals(3));
      expect(copia.unidade, equals('meses'));
    });

    test('toMap e fromMap devem ser reversíveis', () {
      final original = Periodo(
        id: '123',
        usuarioId: 'user123',
        nome: 'Mensal',
        quantidade: 1,
        unidade: 'meses',
        dataCriacao: dataCriacao,
      );

      final map = original.toMap();
      final recuperado = Periodo.fromMap(map);

      expect(recuperado.id, equals(original.id));
      expect(recuperado.usuarioId, equals(original.usuarioId));
      expect(recuperado.nome, equals(original.nome));
      expect(recuperado.quantidade, equals(original.quantidade));
      expect(recuperado.unidade, equals(original.unidade));
      expect(recuperado.dataCriacao, equals(original.dataCriacao));
    });
  });
}