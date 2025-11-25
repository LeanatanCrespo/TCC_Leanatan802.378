import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tcc2025_leanatan/models/receita.dart';
import 'package:tcc2025_leanatan/services/receita_service.dart';

// Mock do FirebaseAuth para simular um usuário logado
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('ReceitaService Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late ReceitaService service;
    late User mockUser;
    const uid = 'test_uid';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
      mockUser = MockUser(uid: uid);
      when(auth.currentUser).thenReturn(mockUser);
      
      service = ReceitaService();
    });

    final receita1 = Receita(
      id: 'r1',
      usuarioId: uid,
      nome: 'Salário',
      valor: 5000.0,
      prioridade: 1,
      data: DateTime(2023, 10, 15),
      tiposIds: ['t1'],
      dataCriacao: DateTime.now(),
    );

    test('adicionarReceita deve adicionar uma nova receita', () async {
      await service.adicionarReceita(receita1);

      final doc = await firestore.collection('usuarios').doc(uid).collection('receitas').doc('r1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['nome'], 'Salário');
    });

    test('listarReceitasPorPeriodo deve retornar receitas no intervalo', () async {
      // Adicionar receitas
      await firestore.collection('usuarios').doc(uid).collection('receitas').doc('r2').set(receita1.copyWith(id: 'r2', data: DateTime(2023, 11, 1)).toMap());
      await firestore.collection('usuarios').doc(uid).collection('receitas').doc('r3').set(receita1.copyWith(id: 'r3', data: DateTime(2023, 12, 1)).toMap());

      final inicio = DateTime(2023, 10, 1);
      final fim = DateTime(2023, 11, 30);

      final receitas = await service.listarReceitasPorPeriodo(inicio, fim);

      expect(receitas.length, 2);
      expect(receitas.any((r) => r.id == 'r1'), isTrue);
      expect(receitas.any((r) => r.id == 'r2'), isTrue);
      expect(receitas.any((r) => r.id == 'r3'), isFalse);
    });

    test('calcularTotalReceitasPorPeriodo deve calcular o total corretamente', () async {
      // Adicionar receitas
      await firestore.collection('usuarios').doc(uid).collection('receitas').doc('r4').set(receita1.copyWith(id: 'r4', valor: 1000.0, data: DateTime(2023, 10, 1)).toMap());
      await firestore.collection('usuarios').doc(uid).collection('receitas').doc('r5').set(receita1.copyWith(id: 'r5', valor: 2000.0, data: DateTime(2023, 10, 31)).toMap());

      final inicio = DateTime(2023, 10, 1);
      final fim = DateTime(2023, 10, 31);

      final total = await service.calcularTotalReceitasPorPeriodo(inicio, fim);

      // O total deve ser 1000.0 + 2000.0 = 3000.0
      expect(total, 3000.0);
    });
  });
}
