import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/lembrete.dart';

class LembreteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('lembretes');

  // Create
  Future<void> adicionarLembrete(Lembrete lembrete) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      // Criar lembrete com usuarioId correto
      final lembreteComUid = lembrete.copyWith(usuarioId: uid);
      await _ref(uid).doc(lembreteComUid.id).set(lembreteComUid.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao adicionar lembrete: $e');
    }
  }

  // Read all (Stream)
  Stream<List<Lembrete>> listarLembretes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Lembrete>>.empty();
    }

    return _ref(uid)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) => Lembrete.fromMap(doc.data()))
                .toList();
          } catch (e) {
            debugPrint('Erro ao listar lembretes: $e');
            return <Lembrete>[];
          }
        });
  }

  // Listar lembretes ativos
  Stream<List<Lembrete>> listarLembretesAtivos() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Lembrete>>.empty();
    }

    return _ref(uid)
        .where('ativo', isEqualTo: true)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Lembrete.fromMap(doc.data())).toList());
  }

  // Listar lembretes pendentes (ativos e não concluídos)
  Stream<List<Lembrete>> listarLembretesPendentes() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Lembrete>>.empty();
    }

    return _ref(uid)
        .where('ativo', isEqualTo: true)
        .where('concluido', isEqualTo: false)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Lembrete.fromMap(doc.data())).toList());
  }

  // Listar lembretes de uma receita/despesa específica
  Stream<List<Lembrete>> listarLembretesPorReferencia(String referenciaId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Lembrete>>.empty();
    }

    return _ref(uid)
        .where('referenciaId', isEqualTo: referenciaId)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Lembrete.fromMap(doc.data())).toList());
  }

  // Buscar um lembrete específico
  Future<Lembrete?> buscarLembretePorId(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _ref(uid).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Lembrete.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar lembrete: $e');
      return null;
    }
  }

  // Update
  Future<void> atualizarLembrete(Lembrete lembrete) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      // Garantir que o usuarioId está correto
      final lembreteComUid = lembrete.copyWith(usuarioId: uid);
      await _ref(uid).doc(lembreteComUid.id).update(lembreteComUid.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao atualizar lembrete: $e');
    }
  }

  // Marcar como concluído
  Future<void> marcarComoConcluido(String id, bool concluido) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      await _ref(uid).doc(id).update({'concluido': concluido});
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  // Ativar/Desativar lembrete
  Future<void> toggleAtivo(String id, bool ativo) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      await _ref(uid).doc(id).update({'ativo': ativo});
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  // Delete
  Future<void> deletarLembrete(String id) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');
      await _ref(uid).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao deletar lembrete: $e');
    }
  }

  // Deletar todos os lembretes de uma receita/despesa
  Future<void> deletarLembretesPorReferencia(String referenciaId) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final snapshot = await _ref(uid)
          .where('referenciaId', isEqualTo: referenciaId)
          .get();

      // Deletar em lote
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao deletar lembretes: $e');
    }
  }

  // Estatísticas
  Future<int> contarLembretes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final snapshot = await _ref(uid).get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Erro ao contar lembretes: $e');
      return 0;
    }
  }

  Future<int> contarLembretesAtivos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final snapshot = await _ref(uid).where('ativo', isEqualTo: true).get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Erro ao contar lembretes ativos: $e');
      return 0;
    }
  }

  Future<int> contarLembretesPendentes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final snapshot = await _ref(uid)
          .where('ativo', isEqualTo: true)
          .where('concluido', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Erro ao contar lembretes pendentes: $e');
      return 0;
    }
  }
}