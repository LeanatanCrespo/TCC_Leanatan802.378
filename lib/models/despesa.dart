class Despesa {
  final String id;
  final String usuarioId;
  final String nome;
  final double valor;
  final String periodo;
  final String prioridade;
  final String tipo;
  final DateTime dataCriacao;

  Despesa({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.valor,
    required this.periodo,
    required this.prioridade,
    required this.tipo,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nome': nome,
      'valor': valor,
      'periodo': periodo,
      'prioridade': prioridade,
      'tipo': tipo,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Despesa.fromMap(Map<String, dynamic> map) {
    return Despesa(
      id: map['id'],
      usuarioId: map['usuarioId'],
      nome: map['nome'],
      valor: (map['valor'] as num).toDouble(),
      periodo: map['periodo'],
      prioridade: map['prioridade'],
      tipo: map['tipo'],
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }
}
