class Usuario {
  final String id;
  final String nome;
  final String email;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
