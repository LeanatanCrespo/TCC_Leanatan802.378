import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/despesa.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DespesaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _despesasRef =>
      _firestore.collection('usuarios').doc(uid).collection('despesas');

  // Create
  Future<void> adicionarDespesa(Despesa despesa) async {
    await _despesasRef.doc(despesa.id).set(despesa.toMap());
  }

  // Read all (Stream)
  Stream<List<Despesa>> listarDespesas() {
    return _despesasRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Despesa.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Update
  Future<void> atualizarDespesa(Despesa despesa) async {
    await _despesasRef.doc(despesa.id).update(despesa.toMap());
  }

  // Delete
  Future<void> deletarDespesa(String id) async {
    await _despesasRef.doc(id).delete();
  }
}
