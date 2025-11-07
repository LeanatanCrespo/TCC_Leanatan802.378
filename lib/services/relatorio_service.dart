import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/despesa.dart';
import '../models/receita.dart';
import '../models/relatorio.dart';
import 'package:uuid/uuid.dart';

class RelatorioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // 📹 Gerar relatório mensal
  Future<Relatorio> gerarRelatorioMensal(int mes, int ano) async {
    if (uid == null) throw Exception('Usuário não autenticado');

    final primeiraData = DateTime(ano, mes, 1);
    final ultimaData = DateTime(ano, mes + 1, 0, 23, 59, 59);

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

  // 📹 Gerar relatório anual
  Future<Relatorio> gerarRelatorioAnual(int ano) async {
    if (uid == null) throw Exception('Usuário não autenticado');

    final primeiraData = DateTime(ano, 1, 1);
    final ultimaData = DateTime(ano, 12, 31, 23, 59, 59);

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

  // 📹 Gerar relatório entre datas
  Future<Relatorio> gerarRelatorioPorPeriodo(DateTime inicio, DateTime fim) async {
    if (uid == null) throw Exception('Usuário não autenticado');

    // Ajustar para pegar o dia inteiro
    final primeiraData = DateTime(inicio.year, inicio.month, inicio.day);
    final ultimaData = DateTime(fim.year, fim.month, fim.day, 23, 59, 59);

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

  // Buscar receitas por período
  Future<List<Receita>> _buscarReceitas(DateTime inicio, DateTime fim) async {
    if (uid == null) return [];

    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('receitas')
          .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('data', isLessThanOrEqualTo: fim.toIso8601String())
          .orderBy('data')
          .get();

      return snapshot.docs
          .map((doc) => Receita.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar receitas: $e');
      return [];
    }
  }

  // Buscar despesas por período
  Future<List<Despesa>> _buscarDespesas(DateTime inicio, DateTime fim) async {
    if (uid == null) return [];

    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('despesas')
          .where('data', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('data', isLessThanOrEqualTo: fim.toIso8601String())
          .orderBy('data')
          .get();

      return snapshot.docs
          .map((doc) => Despesa.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar despesas: $e');
      return [];
    }
  }

  // 📊 Gerar dados para gráfico mensal (por semana)
  Map<String, Map<String, double>> gerarDadosGraficoMensal(Relatorio relatorio) {
    Map<String, Map<String, double>> dadosPorSemana = {};

    // Agrupar por semana
    for (var receita in relatorio.receitas) {
      final semana = 'Semana ${_calcularSemanaDoMes(receita.data)}';
      dadosPorSemana[semana] ??= {'receitas': 0.0, 'despesas': 0.0};
      dadosPorSemana[semana]!['receitas'] = 
          (dadosPorSemana[semana]!['receitas'] ?? 0.0) + receita.valor;
    }

    for (var despesa in relatorio.despesas) {
      final semana = 'Semana ${_calcularSemanaDoMes(despesa.data)}';
      dadosPorSemana[semana] ??= {'receitas': 0.0, 'despesas': 0.0};
      dadosPorSemana[semana]!['despesas'] = 
          (dadosPorSemana[semana]!['despesas'] ?? 0.0) + despesa.valor;
    }

    return dadosPorSemana;
  }

  // 📊 Gerar dados para gráfico anual (por mês)
  Map<String, Map<String, double>> gerarDadosGraficoAnual(Relatorio relatorio) {
    Map<String, Map<String, double>> dadosPorMes = {};

    const meses = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    // Inicializar todos os meses com zero
    for (var mes in meses) {
      dadosPorMes[mes] = {'receitas': 0.0, 'despesas': 0.0};
    }

    // Agrupar por mês
    for (var receita in relatorio.receitas) {
      final mes = meses[receita.data.month - 1];
      dadosPorMes[mes]!['receitas'] = 
          (dadosPorMes[mes]!['receitas'] ?? 0.0) + receita.valor;
    }

    for (var despesa in relatorio.despesas) {
      final mes = meses[despesa.data.month - 1];
      dadosPorMes[mes]!['despesas'] = 
          (dadosPorMes[mes]!['despesas'] ?? 0.0) + despesa.valor;
    }

    return dadosPorMes;
  }

  // 📊 Gerar dados para gráfico de período longo (por ano)
  Map<String, Map<String, double>> gerarDadosGraficoPorAno(Relatorio relatorio) {
    Map<String, Map<String, double>> dadosPorAno = {};

    for (var receita in relatorio.receitas) {
      final ano = receita.data.year.toString();
      dadosPorAno[ano] ??= {'receitas': 0.0, 'despesas': 0.0};
      dadosPorAno[ano]!['receitas'] = 
          (dadosPorAno[ano]!['receitas'] ?? 0.0) + receita.valor;
    }

    for (var despesa in relatorio.despesas) {
      final ano = despesa.data.year.toString();
      dadosPorAno[ano] ??= {'receitas': 0.0, 'despesas': 0.0};
      dadosPorAno[ano]!['despesas'] = 
          (dadosPorAno[ano]!['despesas'] ?? 0.0) + despesa.valor;
    }

    return dadosPorAno;
  }

  // Calcular em qual semana do mês está a data
  int _calcularSemanaDoMes(DateTime data) {
    return ((data.day - 1) ~/ 7) + 1;
  }

  // 📊 Determinar tipo de agrupamento baseado no período
  String determinarTipoAgrupamento(DateTime inicio, DateTime fim) {
    final diferenca = fim.difference(inicio).inDays;

    if (diferenca <= 31) {
      return 'semanal'; // Mensal ou menos
    } else if (diferenca <= 365) {
      return 'mensal'; // Anual
    } else {
      return 'anual'; // Mais de um ano
    }
  }

  // 🔢 Calcular totais por tipo
  Map<String, double> calcularTotaisPorTipo(Relatorio relatorio, List<String> tiposIds) {
    Map<String, double> totais = {};

    for (var tipoId in tiposIds) {
      double total = 0.0;
      
      // Somar receitas com este tipo
      for (var receita in relatorio.receitas) {
        if (receita.tiposIds.contains(tipoId)) {
          total += receita.valor;
        }
      }

      // Subtrair despesas com este tipo
      for (var despesa in relatorio.despesas) {
        if (despesa.tiposIds.contains(tipoId)) {
          total -= despesa.valor;
        }
      }

      totais[tipoId] = total;
    }

    return totais;
  }

  // 🔢 Calcular média diária
  double calcularMediaDiaria(Relatorio relatorio) {
    final dias = relatorio.ultimaData.difference(relatorio.primeiraData).inDays + 1;
    if (dias == 0) return 0.0;
    return relatorio.valorFinal / dias;
  }

  // 🔢 Encontrar maiores receitas e despesas
  List<Receita> maioresReceitas(Relatorio relatorio, {int limite = 5}) {
    final lista = List<Receita>.from(relatorio.receitas);
    lista.sort((a, b) => b.valor.compareTo(a.valor));
    return lista.take(limite).toList();
  }

  List<Despesa> maioresDespesas(Relatorio relatorio, {int limite = 5}) {
    final lista = List<Despesa>.from(relatorio.despesas);
    lista.sort((a, b) => b.valor.compareTo(a.valor));
    return lista.take(limite).toList();
  }
}