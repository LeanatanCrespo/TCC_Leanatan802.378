import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tcc2025_leanatan/models/tipo.dart';
import 'package:tcc2025_leanatan/services/tipo_service.dart';

// Mock do FirebaseAuth para simular um usuário logado
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('TipoService Tests', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late TipoService service;
    late User mockUser;
    const uid = 'test_uid';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
      mockUser = MockUser(uid: uid);
      when(auth.currentUser).thenReturn(mockUser);
      
      // O TipoService usa o singleton, então vamos criar uma instância
      // que usa o FakeFirestore para simular o comportamento.
      service = TipoService();
    });

    final tipo1 = Tipo(
      id: 't1',
      usuarioId: uid,
      nome: 'Alimentação',
      dataCriacao: DateTime.now(),
    );

    test('adicionarTipo deve adicionar um novo tipo', () async {
      await service.adicionarTipo(tipo1);

      final doc = await firestore.collection('usuarios').doc(uid).collection('tipos').doc('t1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['nome'], 'Alimentação');
    });

    test('listarTipos deve retornar um stream de tipos', () async {
      // Adicionar um tipo diretamente no FakeFirestore
      await firestore.collection('usuarios').doc(uid).collection('tipos').doc('t2').set(tipo1.copyWith(id: 't2', nome: 'Transporte').toMap());

      final stream = service.listarTipos();
      final list = await stream.first;

      expect(list, isA<List<Tipo>>());
      expect(list.length, 1);
      expect(list.first.nome, 'Transporte');
    });

    test('deletarTipo deve remover o tipo', () async {
      // Adicionar um tipo
      await firestore.collection('usuarios').doc(uid).collection('tipos').doc('t3').set(tipo1.copyWith(id: 't3').toMap());
      
      // Deletar
      await service.deletarTipo('t3');

      // Verificar se foi deletado
      final doc = await firestore.collection('usuarios').doc(uid).collection('tipos').doc('t3').get();
      expect(doc.exists, isFalse);
    });
  });
}
