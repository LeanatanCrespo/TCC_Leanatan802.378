class Lembrete {
  final String id;
  final String usuarioId;
  final String referenciaId;
  final String tipoReferencia;
  final DateTime dataLembrete;
  final bool recorrente;
  final bool ativo;

  Lembrete({
    required this.id,
    required this.usuarioId,
    required this.referenciaId,
    required this.tipoReferencia,
    required this.dataLembrete,
    required this.recorrente,
    required this.ativo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'referenciaId': referenciaId,
      'tipoReferencia': tipoReferencia,
      'dataLembrete': dataLembrete.toIso8601String(),
      'recorrente': recorrente,
      'ativo': ativo,
    };
  }

  factory Lembrete.fromMap(Map<String, dynamic> map) {
    return Lembrete(
      id: map['id'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      referenciaId: map['referenciaId'] ?? '',
      tipoReferencia: map['tipoReferencia'] ?? '',
      dataLembrete: DateTime.parse(map['dataLembrete']),
      recorrente: map['recorrente'] ?? false,
      ativo: map['ativo'] ?? true,
    );
  }
}
