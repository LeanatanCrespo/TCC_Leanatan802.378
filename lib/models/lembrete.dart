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
}
