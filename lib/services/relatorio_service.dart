import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/despesa.dart';
import '../models/receita.dart';
import '../models/relatorio.dart';
import 'package:uuid/uuid.dart';

class RelatorioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // 🔹 Gerar relatório mensal
  Future<Relatorio> gerarRelatorioMensal(int mes, int ano) async {
    final primeiraData = DateTime(ano, mes, 1);
    final ultimaData = DateTime(ano, mes + 1, 0);

    final receitas = await _buscarReceitas(primeiraData, ultimaData);
    final despesas = await _buscarDespesas(primeiraData, ultimaData);

    return Relatorio(
      id: const Uuid().v4(),
      primeiraData: primeiraData,
      ultimaData: ultimaData,
      receitas: receitas,
      despesas: despesas,
    );
  }

  // 🔹 Gerar relatório anual
  Future<Relatorio> gerarRelatorioAnual(int ano) async {
    final primeiraData = DateTime(ano, 1, 1);
    final ultimaData = DateTime(ano, 12, 31);

    final receitas = await _buscarReceitas(primeiraData, ultimaData);
    final despesas = await _buscarDespesas(primeiraData, ultimaData);

    return Relatorio(
      id: const Uuid().v4(),
      primeiraData: primeiraData,
      ultimaData: ultimaData,
      receitas: receitas,
      despesas: despesas,
    );
  }

  //receitas
  Future<List<Receita>> _buscarReceitas(DateTime inicio, DateTime fim) async {
    final snapshot = await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('receitas')
        .where('dataCriacao', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('dataCriacao', isLessThanOrEqualTo: fim.toIso8601String())
        .get();

    return snapshot.docs
        .map((doc) => Receita.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  //despesas
  Future<List<Despesa>> _buscarDespesas(DateTime inicio, DateTime fim) async {
    final snapshot = await _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('despesas')
        .where('dataCriacao', isGreaterThanOrEqualTo: inicio.toIso8601String())
        .where('dataCriacao', isLessThanOrEqualTo: fim.toIso8601String())
        .get();

    return snapshot.docs
        .map((doc) => Despesa.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
