import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tcc2025_leanatan/models/despesa.dart';
import 'package:tcc2025_leanatan/services/despesa_service.dart';

// Mock do FirebaseAuth para simular um usuário logado
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('DespesaService Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late DespesaService service;
    late User mockUser;
    const uid = 'test_uid';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
      mockUser = MockUser(uid: uid);
      when(auth.currentUser).thenReturn(mockUser);
      
      service = DespesaService();
    });

    final despesa1 = Despesa(
      id: 'd1',
      usuarioId: uid,
      nome: 'Aluguel',
      valor: 1500.0,
      prioridade: 5,
      data: DateTime(2023, 10, 15),
      tiposIds: ['t1'],
      dataCriacao: DateTime.now(),
    );

    test('adicionarDespesa deve adicionar uma nova despesa', () async {
      await service.adicionarDespesa(despesa1);

      final doc = await firestore.collection('usuarios').doc(uid).collection('despesas').doc('d1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['nome'], 'Aluguel');
    });

    test('listarDespesasPorPeriodo deve retornar despesas no intervalo', () async {
      // Adicionar despesas
      await firestore.collection('usuarios').doc(uid).collection('despesas').doc('d2').set(despesa1.copyWith(id: 'd2', data: DateTime(2023, 11, 1)).toMap());
      await firestore.collection('usuarios').doc(uid).collection('despesas').doc('d3').set(despesa1.copyWith(id: 'd3', data: DateTime(2023, 12, 1)).toMap());

      final inicio = DateTime(2023, 10, 1);
      final fim = DateTime(2023, 11, 30);

      final despesas = await service.listarDespesasPorPeriodo(inicio, fim);

      expect(despesas.length, 2);
      expect(despesas.any((d) => d.id == 'd1'), isTrue);
      expect(despesas.any((d) => d.id == 'd2'), isTrue);
      expect(despesas.any((d) => d.id == 'd3'), isFalse);
    });

    test('calcularTotalDespesasPorPeriodo deve calcular o total corretamente', () async {
      // Adicionar despesas
      await firestore.collection('usuarios').doc(uid).collection('despesas').doc('d4').set(despesa1.copyWith(id: 'd4', valor: 100.0, data: DateTime(2023, 10, 1)).toMap());
      await firestore.collection('usuarios').doc(uid).collection('despesas').doc('d5').set(despesa1.copyWith(id: 'd5', valor: 200.0, data: DateTime(2023, 10, 31)).toMap());

      final inicio = DateTime(2023, 10, 1);
      final fim = DateTime(2023, 10, 31);

      final total = await service.calcularTotalDespesasPorPeriodo(inicio, fim);

      // O total deve ser 100.0 + 200.0 = 300.0
      expect(total, 300.0);
    });
  });
}
