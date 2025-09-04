import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/despesa.dart';

class DespesaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('despesas');

  Future<void> adicionarDespesa(Despesa despesa) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    final data = despesa.toMap()..['usuarioId'] = uid;
    await _ref(uid).doc(despesa.id).set(data);
  }

  Stream<List<Despesa>> listarDespesas() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Despesa>>.empty();
    }
    return _ref(uid)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Despesa.fromMap(d.data())).toList());
  }

  Future<void> atualizarDespesa(Despesa despesa) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    final data = despesa.toMap()..['usuarioId'] = uid;
    await _ref(uid).doc(despesa.id).update(data);
  }

  Future<void> deletarDespesa(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    await _ref(uid).doc(id).delete();
  }
}