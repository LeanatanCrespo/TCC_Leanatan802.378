import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/despesa.dart';
import '../models/receita.dart';
import '../models/periodo.dart';
import '../models/relatorio.dart';
import 'package:uuid/uuid.dart';

class RelatorioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // 📊 Gerar relatório mensal
  Future<Relatorio> gerarRelatorioMensal(int mes, int ano) async {
    if (uid == null) throw Exception('Usuário não autenticado');

    final primeiraData = DateTime(ano, mes, 1);
    final ultimaData = DateTime(ano, mes + 1, 0, 23, 59, 59);

    final receitas = await _buscarReceitasComRecorrencia(primeiraData, ultimaData);
    final despesas = await _buscarDespesasComRecorrencia(primeiraData, ultimaData);

    return Relatorio(
      id: const Uuid().v4(),
      primeiraData: primeiraData,
      ultimaData: ultimaData,
      receitas: receitas,
      despesas: despesas,
    );
  }

  // 📊 Gerar relatório anual
  Future<Relatorio> gerarRelatorioAnual(int ano) async {
    if (uid == null) throw Exception('Usuário não autenticado');

    final primeiraData = DateTime(ano, 1, 1);
    final ultimaData = DateTime(ano, 12, 31, 23, 59, 59);

    final receitas = await _buscarReceitasComRecorrencia(primeiraData, ultimaData);
    final despesas = await _buscarDespesasComRecorrencia(primeiraData, ultimaData);

    return Relatorio(
      id: const Uuid().v4(),
      primeiraData: primeiraData,
      ultimaData: ultimaData,
      receitas: receitas,
      despesas: despesas,
    );
  }

  // 📊 Gerar relatório entre datas
  Future<Relatorio> gerarRelatorioPorPeriodo(DateTime inicio, DateTime fim) async {
    if (uid == null) throw Exception('Usuário não autenticado');

    final primeiraData = DateTime(inicio.year, inicio.month, inicio.day);
    final ultimaData = DateTime(fim.year, fim.month, fim.day, 23, 59, 59);

    final receitas = await _buscarReceitasComRecorrencia(primeiraData, ultimaData);
    final despesas = await _buscarDespesasComRecorrencia(primeiraData, ultimaData);

    return Relatorio(
      id: const Uuid().v4(),
      primeiraData: primeiraData,
      ultimaData: ultimaData,
      receitas: receitas,
      despesas: despesas,
    );
  }

  // ✅ CORREÇÃO: Buscar receitas COM recorrência expandida
  Future<List<Receita>> _buscarReceitasComRecorrencia(
    DateTime inicio,
    DateTime fim,
  ) async {
    if (uid == null) return [];

    try {
      // Buscar todas as receitas (não apenas do período)
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('receitas')
          .orderBy('data')
          .get();

      final receitasBase = snapshot.docs
          .map((doc) => Receita.fromMap(doc.data()))
          .toList();

      // Buscar todos os períodos
      final periodosSnapshot = await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('periodos')
          .get();

      final periodos = {
        for (var doc in periodosSnapshot.docs)
          doc.id: Periodo.fromMap(doc.data())
      };

      List<Receita> receitasExpandidas = [];

      for (var receita in receitasBase) {
        // Adicionar receita original se estiver no período
        if (_dataNoIntervalo(receita.data, inicio, fim)) {
          receitasExpandidas.add(receita);
        }

        // ✅ Se tem período, gerar recorrências
        if (receita.periodoId != null && periodos.containsKey(receita.periodoId)) {
          final periodo = periodos[receita.periodoId]!;
          
          // Gerar datas recorrentes
          final datasRecorrentes = periodo.gerarDatasRecorrentes(
            receita.data,
            fim,
          );

          // Adicionar cada recorrência que esteja no intervalo
          for (var dataRecorrente in datasRecorrentes) {
            // Pular a data original (já foi adicionada)
            if (_mesmaData(dataRecorrente, receita.data)) continue;

            // Adicionar apenas se estiver no intervalo do relatório
            if (_dataNoIntervalo(dataRecorrente, inicio, fim)) {
              receitasExpandidas.add(
                receita.copyWith(
                  id: '${receita.id}_${dataRecorrente.millisecondsSinceEpoch}',
                  data: dataRecorrente,
                ),
              );
            }
          }
        }
      }

      // Ordenar por data
      receitasExpandidas.sort((a, b) => a.data.compareTo(b.data));

      debugPrint('📊 Receitas expandidas: ${receitasExpandidas.length}');
      return receitasExpandidas;
    } catch (e) {
      debugPrint('❌ Erro ao buscar receitas: $e');
      return [];
    }
  }

  // ✅ CORREÇÃO: Buscar despesas COM recorrência expandida
  Future<List<Despesa>> _buscarDespesasComRecorrencia(
    DateTime inicio,
    DateTime fim,
  ) async {
    if (uid == null) return [];

    try {
      // Buscar todas as despesas (não apenas do período)
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('despesas')
          .orderBy('data')
          .get();

      final despesasBase = snapshot.docs
          .map((doc) => Despesa.fromMap(doc.data()))
          .toList();

      // Buscar todos os períodos
      final periodosSnapshot = await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('periodos')
          .get();

      final periodos = {
        for (var doc in periodosSnapshot.docs)
          doc.id: Periodo.fromMap(doc.data())
      };

      List<Despesa> despesasExpandidas = [];

      for (var despesa in despesasBase) {
        // Adicionar despesa original se estiver no período
        if (_dataNoIntervalo(despesa.data, inicio, fim)) {
          despesasExpandidas.add(despesa);
        }

        // ✅ Se tem período, gerar recorrências
        if (despesa.periodoId != null && periodos.containsKey(despesa.periodoId)) {
          final periodo = periodos[despesa.periodoId]!;
          
          // Gerar datas recorrentes
          final datasRecorrentes = periodo.gerarDatasRecorrentes(
            despesa.data,
            fim,
          );

          // Adicionar cada recorrência que esteja no intervalo
          for (var dataRecorrente in datasRecorrentes) {
            // Pular a data original (já foi adicionada)
            if (_mesmaData(dataRecorrente, despesa.data)) continue;

            // Adicionar apenas se estiver no intervalo do relatório
            if (_dataNoIntervalo(dataRecorrente, inicio, fim)) {
              despesasExpandidas.add(
                despesa.copyWith(
                  id: '${despesa.id}_${dataRecorrente.millisecondsSinceEpoch}',
                  data: dataRecorrente,
                ),
              );
            }
          }
        }
      }

      // Ordenar por data
      despesasExpandidas.sort((a, b) => a.data.compareTo(b.data));

      debugPrint('📊 Despesas expandidas: ${despesasExpandidas.length}');
      return despesasExpandidas;
    } catch (e) {
      debugPrint('❌ Erro ao buscar despesas: $e');
      return [];
    }
  }

  // Helper: Verificar se data está no intervalo
  bool _dataNoIntervalo(DateTime data, DateTime inicio, DateTime fim) {
    final dataComparar = DateTime(data.year, data.month, data.day);
    final inicioComparar = DateTime(inicio.year, inicio.month, inicio.day);
    final fimComparar = DateTime(fim.year, fim.month, fim.day);

    return (dataComparar.isAfter(inicioComparar) || dataComparar.isAtSameMomentAs(inicioComparar)) &&
           (dataComparar.isBefore(fimComparar) || dataComparar.isAtSameMomentAs(fimComparar));
  }

  // Helper: Verificar se são a mesma data (ignorando hora)
  bool _mesmaData(DateTime data1, DateTime data2) {
    return data1.year == data2.year &&
           data1.month == data2.month &&
           data1.day == data2.day;
  }

  // 📊 Gerar dados para gráfico mensal (por semana)
  Map<String, Map<String, double>> gerarDadosGraficoMensal(Relatorio relatorio) {
    Map<String, Map<String, double>> dadosPorSemana = {};

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

  int _calcularSemanaDoMes(DateTime data) {
    return ((data.day - 1) ~/ 7) + 1;
  }

  String determinarTipoAgrupamento(DateTime inicio, DateTime fim) {
    final diferenca = fim.difference(inicio).inDays;

    if (diferenca <= 31) {
      return 'semanal';
    } else if (diferenca <= 365) {
      return 'mensal';
    } else {
      return 'anual';
    }
  }

  Map<String, double> calcularTotaisPorTipo(Relatorio relatorio, List<String> tiposIds) {
    Map<String, double> totais = {};

    for (var tipoId in tiposIds) {
      double total = 0.0;
      
      for (var receita in relatorio.receitas) {
        if (receita.tiposIds.contains(tipoId)) {
          total += receita.valor;
        }
      }

      for (var despesa in relatorio.despesas) {
        if (despesa.tiposIds.contains(tipoId)) {
          total -= despesa.valor;
        }
      }

      totais[tipoId] = total;
    }

    return totais;
  }

  double calcularMediaDiaria(Relatorio relatorio) {
    final dias = relatorio.ultimaData.difference(relatorio.primeiraData).inDays + 1;
    if (dias == 0) return 0.0;
    return relatorio.valorFinal / dias;
  }

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