import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/periodo.dart';

class PeriodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('periodos');

  Future<void> adicionarPeriodo(Periodo periodo) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    final data = periodo.toMap()..['usuarioId'] = uid;
    await _ref(uid).doc(periodo.id).set(data);
  }

  Stream<List<Periodo>> listarPeriodos() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Periodo>>.empty();
    }
    return _ref(uid)
        .orderBy('nome')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Periodo.fromMap(d.data())).toList());
  }

  Future<void> atualizarPeriodo(Periodo periodo) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    final data = periodo.toMap()..['usuarioId'] = uid;
    await _ref(uid).doc(periodo.id).update(data);
  }

  Future<void> deletarPeriodo(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    await _ref(uid).doc(id).delete();
  }

  // Busca um período específico por ID
  Future<Periodo?> buscarPeriodoPorId(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _ref(uid).doc(id).get();
    if (doc.exists) {
      return Periodo.fromMap(doc.data()!);
    }
    return null;
  }
}