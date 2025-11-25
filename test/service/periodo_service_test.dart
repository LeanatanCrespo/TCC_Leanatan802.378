import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tcc2025_leanatan/models/periodo.dart';
import 'package:tcc2025_leanatan/services/periodo_service.dart';

// Mock do FirebaseAuth para simular um usuário logado
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('PeriodoService Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late PeriodoService service;
    late User mockUser;
    const uid = 'test_uid';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
      mockUser = MockUser(uid: uid);
      when(auth.currentUser).thenReturn(mockUser);
      
      // O PeriodoService usa o singleton, então vamos criar uma instância
      // que usa o FakeFirestore para simular o comportamento.
      // Como não podemos modificar o construtor, vamos assumir que o
      // serviço usa o singleton do Firebase.
      service = PeriodoService();
    });

    final periodo1 = Periodo(
      id: 'p1',
      usuarioId: uid,
      nome: 'Mensal',
      quantidade: 1,
      unidade: 'meses',
      dataCriacao: DateTime.now(),
    );

    test('adicionarPeriodo deve adicionar um novo período', () async {
      await service.adicionarPeriodo(periodo1);

      final doc = await firestore.collection('usuarios').doc(uid).collection('periodos').doc('p1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['nome'], 'Mensal');
    });

    test('listarPeriodos deve retornar um stream de períodos', () async {
      // Adicionar um período diretamente no FakeFirestore
      await firestore.collection('usuarios').doc(uid).collection('periodos').doc('p2').set(periodo1.copyWith(id: 'p2', nome: 'Semanal').toMap());

      final stream = service.listarPeriodos();
      final list = await stream.first;

      expect(list, isA<List<Periodo>>());
      expect(list.length, 1);
      expect(list.first.nome, 'Semanal');
    });

    test('deletarPeriodo deve remover o período', () async {
      // Adicionar um período
      await firestore.collection('usuarios').doc(uid).collection('periodos').doc('p3').set(periodo1.copyWith(id: 'p3').toMap());
      
      // Deletar
      await service.deletarPeriodo('p3');

      // Verificar se foi deletado
      final doc = await firestore.collection('usuarios').doc(uid).collection('periodos').doc('p3').get();
      expect(doc.exists, isFalse);
    });
  });
}
