import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc2025_leanatan/models/receita.dart';
import 'package:tcc2025_leanatan/firebase_options.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  test('Salvar e recuperar Receita no Firestore', () async {
    final firestore = FirebaseFirestore.instance;

    final receita = Receita(
      id: 'test_id_123',
      usuarioId: 'user_test',
      nome: 'Salário',
      valor: 3000.0,
      prioridade: 3, // Obrigatório agora
      data: DateTime.now(), // Campo atualizado
      tiposIds: ['tipo_teste'], // Campo novo
      periodoId: null, // Campo novo (opcional)
      dataCriacao: DateTime.now(),
    );

    // Salvar
    await firestore
        .collection('usuarios')
        .doc('user_test')
        .collection('receitas')
        .doc(receita.id)
        .set(receita.toMap());

    // Recuperar
    final snapshot = await firestore
        .collection('usuarios')
        .doc('user_test')
        .collection('receitas')
        .doc(receita.id)
        .get();
    
    final data = snapshot.data();

    expect(data, isNotNull);
    expect(data!['nome'], equals('Salário'));
    expect(data['valor'], equals(3000.0));
    expect(data['prioridade'], equals(3));

    // Limpar
    await firestore
        .collection('usuarios')
        .doc('user_test')
        .collection('receitas')
        .doc(receita.id)
        .delete();
  });

  test('Testar estrutura hierárquica do Firestore', () async {
    final firestore = FirebaseFirestore.instance;
    final usuarioId = 'test_user_hierarchy';

    // Criar receita
    final receita = Receita(
      id: 'receita_test',
      usuarioId: usuarioId,
      nome: 'Teste Hierarquia',
      valor: 100.0,
      prioridade: 1,
      data: DateTime.now(),
      tiposIds: [],
      periodoId: null,
      dataCriacao: DateTime.now(),
    );

    // Salvar na estrutura correta: usuarios/{uid}/receitas/{id}
    await firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('receitas')
        .doc(receita.id)
        .set(receita.toMap());

    // Verificar se foi salvo corretamente
    final doc = await firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('receitas')
        .doc(receita.id)
        .get();

    expect(doc.exists, true);
    expect(doc.data()!['nome'], equals('Teste Hierarquia'));

    // Limpar
    await firestore
        .collection('usuarios')
        .doc(usuarioId)
        .collection('receitas')
        .doc(receita.id)
        .delete();
  });
}