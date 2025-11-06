class Tipo {
  final String id;
  final String usuarioId;
  final String nome;
  final DateTime dataCriacao;

  Tipo({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nome': nome,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Tipo.fromMap(Map<String, dynamic> map) {
    return Tipo(
      id: map['id'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      nome: map['nome'] ?? '',
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  Tipo copyWith({
    String? id,
    String? usuarioId,
    String? nome,
    DateTime? dataCriacao,
  }) {
    return Tipo(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}