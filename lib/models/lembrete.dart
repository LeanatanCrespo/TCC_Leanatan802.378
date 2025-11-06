class Lembrete {
  final String id;
  final String usuarioId;
  final String referenciaId; // ID da receita ou despesa
  final String tipoReferencia; // 'receita' ou 'despesa'
  final int diasAntes; // Quantos dias antes notificar
  final bool notificarNoDia; // Se notifica no dia também
  final bool ativo; // Se o lembrete está ativo
  final bool concluido; // Se foi marcado como concluído
  final DateTime dataCriacao;

  Lembrete({
    required this.id,
    required this.usuarioId,
    required this.referenciaId,
    required this.tipoReferencia,
    required this.diasAntes,
    required this.notificarNoDia,
    required this.ativo,
    required this.concluido,
    required this.dataCriacao,
  });

  // Calcula quando o lembrete deve ser disparado
  DateTime calcularDataNotificacao(DateTime dataReferencia) {
    if (diasAntes == 0) {
      return dataReferencia;
    }
    return dataReferencia.subtract(Duration(days: diasAntes));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'referenciaId': referenciaId,
      'tipoReferencia': tipoReferencia,
      'diasAntes': diasAntes,
      'notificarNoDia': notificarNoDia,
      'ativo': ativo,
      'concluido': concluido,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Lembrete.fromMap(Map<String, dynamic> map) {
    return Lembrete(
      id: map['id'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      referenciaId: map['referenciaId'] ?? '',
      tipoReferencia: map['tipoReferencia'] ?? '',
      diasAntes: map['diasAntes'] ?? 0,
      notificarNoDia: map['notificarNoDia'] ?? true,
      ativo: map['ativo'] ?? true,
      concluido: map['concluido'] ?? false,
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  Lembrete copyWith({
    String? id,
    String? usuarioId,
    String? referenciaId,
    String? tipoReferencia,
    int? diasAntes,
    bool? notificarNoDia,
    bool? ativo,
    bool? concluido,
    DateTime? dataCriacao,
  }) {
    return Lembrete(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      referenciaId: referenciaId ?? this.referenciaId,
      tipoReferencia: tipoReferencia ?? this.tipoReferencia,
      diasAntes: diasAntes ?? this.diasAntes,
      notificarNoDia: notificarNoDia ?? this.notificarNoDia,
      ativo: ativo ?? this.ativo,
      concluido: concluido ?? this.concluido,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  String get descricao {
    if (diasAntes == 0) {
      return 'Notificar no dia';
    } else if (diasAntes == 1) {
      return 'Notificar 1 dia antes';
    } else {
      return 'Notificar $diasAntes dias antes';
    }
  }
}