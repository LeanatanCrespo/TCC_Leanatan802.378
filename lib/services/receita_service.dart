import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receita.dart';

class ReceitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('receitas'); 

  Future<void> adicionarReceita(Receita receita) async { 
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    final data = receita.toMap()..['usuarioId'] = uid;
    await _ref(uid).doc(receita.id).set(data);
  }

  Stream<List<Receita>> listarReceitas() { 
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Receita>>.empty();
    }
    return _ref(uid)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Receita.fromMap(d.data())).toList()); 
  }

  Future<void> atualizarReceita(Receita receita) async { 
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');

    final data = receita.toMap()..['usuarioId'] = uid;
    await _ref(uid).doc(receita.id).update(data);
  }

  Future<void> deletarReceita(String id) async { 
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    await _ref(uid).doc(id).delete();
  }
}