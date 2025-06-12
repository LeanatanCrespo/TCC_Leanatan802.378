import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcc2025_leanatan/models/receita.dart';
import 'package:tcc2025_leanatan/firebase_options.dart'; // certifique-se que existe

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  test('Salvar e recuperar Receita no Firestore', () async {
    final firestore = FirebaseFirestore.instance;

    final receita = Receita(
      id: 'test_id_123',
      usuarioId: 'user_test',
      nome: 'Salário',
      valor: 3000.0,
      periodo: 'Mensal',
      prioridade: 'Alta',
      tipo: 'Fixa',
      dataCriacao: DateTime.now(),
    );

    // Salvar
    await firestore.collection('receitas').doc(receita.id).set(receita.toMap());

    // Recuperar
    final snapshot = await firestore.collection('receitas').doc(receita.id).get();
    final data = snapshot.data();

    expect(data, isNotNull);
    expect(data!['nome'], equals('Salário'));
    expect(data['valor'], equals(3000.0));

    // Limpar
    await firestore.collection('receitas').doc(receita.id).delete();
  });
}
