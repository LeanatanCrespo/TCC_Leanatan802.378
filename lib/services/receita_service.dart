import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/receita.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _receitasRef =>
      _firestore.collection('usuarios').doc(uid).collection('receitas');

  // Create
  Future<void> adicionarReceita(Receita receita) async {
    await _receitasRef.doc(receita.id).set(receita.toMap());
  }

  // Read all (Stream)
  Stream<List<Receita>> listarReceitas() {
    return _receitasRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Receita.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Update
  Future<void> atualizarReceita(Receita receita) async {
    await _receitasRef.doc(receita.id).update(receita.toMap());
  }

  // Delete
  Future<void> deletarReceita(String id) async {
    await _receitasRef.doc(id).delete();
  }
}
