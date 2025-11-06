class Despesa {
  final String id;
  final String usuarioId;
  final String nome;
  final double valor;
  final int prioridade;
  final DateTime data;
  final List<String> tiposIds;
  final String? periodoId;
  final DateTime dataCriacao;

  Despesa({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.valor,
    required this.prioridade,
    required this.data,
    required this.tiposIds,
    this.periodoId,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nome': nome,
      'valor': valor,
      'prioridade': prioridade,
      'data': data.toIso8601String(),
      'tiposIds': tiposIds,
      'periodoId': periodoId,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Despesa.fromMap(Map<String, dynamic> map) {
    return Despesa(
      id: map['id'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      nome: map['nome'] ?? '',
      valor: (map['valor'] as num).toDouble(),
      prioridade: map['prioridade'] ?? 0,
      data: DateTime.parse(map['data']),
      tiposIds: List<String>.from(map['tiposIds'] ?? []),
      periodoId: map['periodoId'],
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  Despesa copyWith({
    String? id,
    String? usuarioId,
    String? nome,
    double? valor,
    int? prioridade,
    DateTime? data,
    List<String>? tiposIds,
    String? periodoId,
    DateTime? dataCriacao,
  }) {
    return Despesa(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      valor: valor ?? this.valor,
      prioridade: prioridade ?? this.prioridade,
      data: data ?? this.data,
      tiposIds: tiposIds ?? this.tiposIds,
      periodoId: periodoId ?? this.periodoId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}