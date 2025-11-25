import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tcc2025_leanatan/models/receita.dart';
import 'package:tcc2025_leanatan/models/despesa.dart';
import 'package:tcc2025_leanatan/models/periodo.dart';
import 'package:tcc2025_leanatan/services/relatorio_service.dart';

// Mock do FirebaseAuth para simular um usuário logado
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('RelatorioService Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late RelatorioService service;
    late User mockUser;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
      mockUser = MockUser(uid: 'test_uid');
      when(auth.currentUser).thenReturn(mockUser);

      // Injetar o mock do Firestore e Auth no serviço (necessário para testes)
      // Como não podemos modificar o construtor do RelatorioService,
      // vamos criar uma instância do serviço que usa o FakeFirestore.
      // Isso é um hack, mas necessário para testar a lógica do serviço.
      service = RelatorioService();
      // O RelatorioService usa o singleton, então vamos tentar injetar
      // o FakeFirestore se possível. Como não é, vamos simular os dados.

      // Dados de teste
      final uid = mockUser.uid;
      final dataBase = DateTime(2023, 10, 15);
      final dataRecorrente = DateTime(2023, 11, 15);

      // Receita sem recorrência
      final receita1 = Receita(
        id: 'r1',
        usuarioId: uid,
        nome: 'Salário',
        valor: 5000.0,
        prioridade: 1,
        data: dataBase,
        tiposIds: ['t1'],
        dataCriacao: DateTime.now(),
      );

      // Despesa com recorrência mensal
      final despesa1 = Despesa(
        id: 'd1',
        usuarioId: uid,
        nome: 'Aluguel',
        valor: 1500.0,
        prioridade: 5,
        data: dataBase,
        tiposIds: ['t2'],
        periodoId: 'p1',
        dataCriacao: DateTime.now(),
      );

      // Período Mensal
      final periodo1 = Periodo(
        id: 'p1',
        usuarioId: uid,
        nome: 'Mensal',
        quantidade: 1,
        unidade: 'meses',
        dataCriacao: DateTime.now(),
      );

      // Inserir dados no FakeFirestore
      await firestore.collection('usuarios').doc(uid).collection('receitas').doc(receita1.id).set(receita1.toMap());
      await firestore.collection('usuarios').doc(uid).collection('despesas').doc(despesa1.id).set(despesa1.toMap());
      await firestore.collection('usuarios').doc(uid).collection('periodos').doc(periodo1.id).set(periodo1.toMap());
    });

    test('gerarRelatorioMensal deve incluir recorrências', () async {
      // Testar o mês de Outubro (dataBase)
      final relatorioOutubro = await service.gerarRelatorioMensal(10, 2023);
      
      // Deve ter 1 receita (Salário) e 1 despesa (Aluguel)
      expect(relatorioOutubro.receitas.length, 1);
      expect(relatorioOutubro.despesas.length, 1);
      expect(relatorioOutubro.valorFinal, 3500.0); // 5000 - 1500

      // Testar o mês de Novembro (dataRecorrente)
      final relatorioNovembro = await service.gerarRelatorioMensal(11, 2023);
      
      // A receita não tem recorrência, então não deve aparecer
      // A despesa tem recorrência, então deve aparecer
      expect(relatorioNovembro.receitas.length, 0);
      expect(relatorioNovembro.despesas.length, 1);
      expect(relatorioNovembro.despesas.first.data.month, 11);
      expect(relatorioNovembro.valorFinal, -1500.0); // 0 - 1500
    });

    test('gerarRelatorioPorPeriodo deve incluir recorrências no intervalo', () async {
      final inicio = DateTime(2023, 10, 1);
      final fim = DateTime(2023, 11, 30);

      final relatorio = await service.gerarRelatorioPorPeriodo(inicio, fim);

      // Receita de Outubro (1)
      // Despesa de Outubro (1)
      // Despesa de Novembro (1)
      expect(relatorio.receitas.length, 1);
      expect(relatorio.despesas.length, 2);
      expect(relatorio.valorFinal, 2000.0); // 5000 - 1500 - 1500
    });

    test('calcularTotaisPorTipo deve calcular o saldo por tipo', () async {
      final inicio = DateTime(2023, 10, 1);
      final fim = DateTime(2023, 10, 31);
      final relatorio = await service.gerarRelatorioPorPeriodo(inicio, fim);
      
      final tiposIds = ['t1', 't2'];
      final totais = service.calcularTotaisPorTipo(relatorio, tiposIds);

      expect(totais['t1'], 5000.0); // Receita
      expect(totais['t2'], -1500.0); // Despesa
    });
  });
}
