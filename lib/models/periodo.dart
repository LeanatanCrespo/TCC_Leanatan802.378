class Periodo {
  final String id;
  final String usuarioId;
  final String nome;
  final int quantidade; // Ex: 3, 5, 7
  final String unidade; // 'dias', 'meses', 'anos'
  final DateTime dataCriacao;

  Periodo({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.dataCriacao,
  });

  // Calcula a próxima data baseada na data fornecida
  DateTime calcularProximaData(DateTime dataBase) {
    switch (unidade) {
      case 'dias':
        return dataBase.add(Duration(days: quantidade));
      case 'meses':
        return DateTime(
          dataBase.year,
          dataBase.month + quantidade,
          dataBase.day,
        );
      case 'anos':
        return DateTime(
          dataBase.year + quantidade,
          dataBase.month,
          dataBase.day,
        );
      default:
        return dataBase;
    }
  }

  // Gera todas as datas de recorrência dentro de um intervalo
  List<DateTime> gerarDatasRecorrentes(DateTime dataInicial, DateTime dataFinal) {
    List<DateTime> datas = [];
    DateTime dataAtual = dataInicial;

    while (dataAtual.isBefore(dataFinal) || dataAtual.isAtSameMomentAs(dataFinal)) {
      datas.add(dataAtual);
      dataAtual = calcularProximaData(dataAtual);
    }

    return datas;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Periodo.fromMap(Map<String, dynamic> map) {
    return Periodo(
      id: map['id'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      nome: map['nome'] ?? '',
      quantidade: map['quantidade'] ?? 0,
      unidade: map['unidade'] ?? 'dias',
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  Periodo copyWith({
    String? id,
    String? usuarioId,
    String? nome,
    int? quantidade,
    String? unidade,
    DateTime? dataCriacao,
  }) {
    return Periodo(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      unidade: unidade ?? this.unidade,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  String get descricao => 'A cada $quantidade $unidade';
}