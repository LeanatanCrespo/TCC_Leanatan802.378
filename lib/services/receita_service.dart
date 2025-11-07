import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/receita.dart';

class ReceitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('receitas'); 

  Future<void> adicionarReceita(Receita receita) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final data = receita.toMap()..['usuarioId'] = uid;
      await _ref(uid).doc(receita.id).set(data);
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao adicionar receita: $e');
    }
  }

  Stream<List<Receita>> listarReceitas() { 
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Receita>>.empty();
    }
    
    return _ref(uid)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) {
          try {
            return snap.docs
                .map((d) => Receita.fromMap(d.data()))
                .toList();
          } catch (e) {
            debugPrint('Erro ao listar receitas: $e');
            return <Receita>[];
          }
        });
  }

  // Listar receitas de um mês específico
  Stream<List<Receita>> listarReceitasPorMes(int mes, int ano) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Receita>>.empty();
    }

    final primeiraData = DateTime(ano, mes, 1);
    final ultimaData = DateTime(ano, mes + 1, 0);

    return _ref(uid)
        .where('data', isGreaterThanOrEqualTo: primeiraData.toIso8601String())
        .where('data', isLessThanOrEqualTo: ultimaData.toIso8601String())
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Receita.fromMap(d.data())).toList());
  }

  // Listar receitas por período
  Future<List<Receita>> listarReceitasPorPeriodo(DateTime inicio, DateTime fim) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snapshot = await _ref(uid)
          .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('data', isLessThanOrEqualTo: fim.toIso8601String())
          .orderBy('data', descending: true)
          .get();

      return snapshot.docs.map((d) => Receita.fromMap(d.data())).toList();
    } catch (e) {
      debugPrint('Erro ao buscar receitas por período: $e');
      return [];
    }
  }

  // Buscar receitas por tipo
  Stream<List<Receita>> listarReceitasPorTipo(String tipoId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Receita>>.empty();
    }

    return _ref(uid)
        .where('tiposIds', arrayContains: tipoId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Receita.fromMap(d.data())).toList());
  }

  // Buscar receitas por período de recorrência
  Stream<List<Receita>> listarReceitasPorPeriodoRecorrencia(String periodoId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Receita>>.empty();
    }

    return _ref(uid)
        .where('periodoId', isEqualTo: periodoId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Receita.fromMap(d.data())).toList());
  }

  // Buscar receitas por prioridade
  Stream<List<Receita>> listarReceitasPorPrioridade(int prioridade) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Receita>>.empty();
    }

    return _ref(uid)
        .where('prioridade', isEqualTo: prioridade)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Receita.fromMap(d.data())).toList());
  }

  // Buscar uma receita específica por ID
  Future<Receita?> buscarReceitaPorId(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _ref(uid).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Receita.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar receita: $e');
      return null;
    }
  }

  Future<void> atualizarReceita(Receita receita) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final data = receita.toMap()..['usuarioId'] = uid;
      await _ref(uid).doc(receita.id).update(data);
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao atualizar receita: $e');
    }
  }

  Future<void> deletarReceita(String id) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');
      await _ref(uid).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao deletar receita: $e');
    }
  }

  // Estatísticas
  Future<double> calcularTotalReceitas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0.0;

    try {
      final snapshot = await _ref(uid).get();
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final receita = Receita.fromMap(doc.data());
        total += receita.valor;
      }
      return total;
    } catch (e) {
      debugPrint('Erro ao calcular total: $e');
      return 0.0;
    }
  }

  Future<double> calcularTotalReceitasPorPeriodo(DateTime inicio, DateTime fim) async {
    final receitas = await listarReceitasPorPeriodo(inicio, fim);
    double total = 0.0;
    for (var r in receitas) {
      total += r.valor;
    }
    return total;
  }

  Future<int> contarReceitas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final snapshot = await _ref(uid).get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Erro ao contar receitas: $e');
      return 0;
    }
  }
}