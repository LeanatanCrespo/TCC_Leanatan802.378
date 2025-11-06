import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tipo.dart';

class TipoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('tipos');

  Future<void> adicionarTipo(Tipo tipo) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    final data = tipo.toMap()..['usuarioId'] = uid;
    await _ref(uid).doc(tipo.id).set(data);
  }

  Stream<List<Tipo>> listarTipos() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Tipo>>.empty();
    }
    return _ref(uid)
        .orderBy('nome')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Tipo.fromMap(d.data())).toList());
  }

  Future<void> atualizarTipo(Tipo tipo) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    final data = tipo.toMap()..['usuarioId'] = uid;
    await _ref(uid).doc(tipo.id).update(data);
  }

  Future<void> deletarTipo(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    await _ref(uid).doc(id).delete();
  }

  // Busca múltiplos tipos por IDs
  Future<List<Tipo>> buscarTiposPorIds(List<String> ids) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    if (ids.isEmpty) return [];

    List<Tipo> tipos = [];
    for (String id in ids) {
      final doc = await _ref(uid).doc(id).get();
      if (doc.exists) {
        tipos.add(Tipo.fromMap(doc.data()!));
      }
    }
    return tipos;
  }
}