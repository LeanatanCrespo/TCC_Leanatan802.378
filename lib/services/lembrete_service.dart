import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lembrete.dart';

class LembreteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _lembretesRef =>
      _firestore.collection('usuarios').doc(uid).collection('lembretes');

  // Create
  Future<void> adicionarLembrete(Lembrete lembrete) async {
    await _lembretesRef.doc(lembrete.id).set(lembrete.toMap());
  }

  // Read all (Stream)
  Stream<List<Lembrete>> listarLembretes() {
    return _lembretesRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Lembrete.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  // Update
  Future<void> atualizarLembrete(Lembrete lembrete) async {
    await _lembretesRef.doc(lembrete.id).update(lembrete.toMap());
  }

  // Delete
  Future<void> deletarLembrete(String id) async {
    await _lembretesRef.doc(id).delete();
  }
}
