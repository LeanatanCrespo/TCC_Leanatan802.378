import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/despesa.dart';

class DespesaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _firestore.collection('usuarios').doc(uid).collection('despesas');

  Future<void> adicionarDespesa(Despesa despesa) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final data = despesa.toMap()..['usuarioId'] = uid;
      await _ref(uid).doc(despesa.id).set(data);
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao adicionar despesa: $e');
    }
  }

  Stream<List<Despesa>> listarDespesas() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Despesa>>.empty();
    }
    
    return _ref(uid)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) {
          try {
            return snap.docs
                .map((d) => Despesa.fromMap(d.data()))
                .toList();
          } catch (e) {
            debugPrint('Erro ao listar despesas: $e');
            return <Despesa>[];
          }
        });
  }

  // Listar despesas de um mês específico
  Stream<List<Despesa>> listarDespesasPorMes(int mes, int ano) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Despesa>>.empty();
    }

    final primeiraData = DateTime(ano, mes, 1);
    final ultimaData = DateTime(ano, mes + 1, 0);

    return _ref(uid)
        .where('data', isGreaterThanOrEqualTo: primeiraData.toIso8601String())
        .where('data', isLessThanOrEqualTo: ultimaData.toIso8601String())
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Despesa.fromMap(d.data())).toList());
  }

  // Listar despesas por período
  Future<List<Despesa>> listarDespesasPorPeriodo(DateTime inicio, DateTime fim) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snapshot = await _ref(uid)
          .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('data', isLessThanOrEqualTo: fim.toIso8601String())
          .orderBy('data', descending: true)
          .get();

      return snapshot.docs.map((d) => Despesa.fromMap(d.data())).toList();
    } catch (e) {
      debugPrint('Erro ao buscar despesas por período: $e');
      return [];
    }
  }

  // Buscar despesas por tipo
  Stream<List<Despesa>> listarDespesasPorTipo(String tipoId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Despesa>>.empty();
    }

    return _ref(uid)
        .where('tiposIds', arrayContains: tipoId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Despesa.fromMap(d.data())).toList());
  }

  // Buscar despesas por período de recorrência
  Stream<List<Despesa>> listarDespesasComPeriodoRecorrencia(String periodoId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Despesa>>.empty();
    }

    return _ref(uid)
        .where('periodoId', isEqualTo: periodoId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Despesa.fromMap(d.data())).toList());
  }

  // Buscar despesas por prioridade
  Stream<List<Despesa>> listarDespesasPorPrioridade(int prioridade) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream<List<Despesa>>.empty();
    }

    return _ref(uid)
        .where('prioridade', isEqualTo: prioridade)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Despesa.fromMap(d.data())).toList());
  }

  // Buscar uma despesa específica por ID
  Future<Despesa?> buscarDespesaPorId(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      final doc = await _ref(uid).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Despesa.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar despesa: $e');
      return null;
    }
  }

  Future<void> atualizarDespesa(Despesa despesa) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');

      final data = despesa.toMap()..['usuarioId'] = uid;
      await _ref(uid).doc(despesa.id).update(data);
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao atualizar despesa: $e');
    }
  }

  Future<void> deletarDespesa(String id) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Usuário não autenticado');
      await _ref(uid).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Erro no Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao deletar despesa: $e');
    }
  }

  // Estatísticas
  Future<double> calcularTotalDespesas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0.0;

    try {
      final snapshot = await _ref(uid).get();
      double total = 0.0;
      for (var doc in snapshot.docs) {
        final despesa = Despesa.fromMap(doc.data());
        total += despesa.valor;
      }
      return total;
    } catch (e) {
      debugPrint('Erro ao calcular total: $e');
      return 0.0;
    }
  }

  Future<double> calcularTotalDespesasPorPeriodo(DateTime inicio, DateTime fim) async {
    final despesas = await listarDespesasPorPeriodo(inicio, fim);
    double total = 0.0;
    for (var d in despesas) {
      total += d.valor;
    }
    return total;
  }

  Future<int> contarDespesas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final snapshot = await _ref(uid).get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Erro ao contar despesas: $e');
      return 0;
    }
  }
}