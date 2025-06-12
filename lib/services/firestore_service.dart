import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> salvarReceita(String titulo, double valor) async {
    if (uid == null) return;

    await _firestore.collection('usuarios').doc(uid).collection('receitas').add({
      'titulo': titulo,
      'valor': valor,
      'data': Timestamp.now(),
    });
  }

  Future<void> salvarDespesa(String titulo, double valor) async {
    if (uid == null) return;

    await _firestore.collection('usuarios').doc(uid).collection('despesas').add({
      'titulo': titulo,
      'valor': valor,
      'data': Timestamp.now(),
    });
  }
}
