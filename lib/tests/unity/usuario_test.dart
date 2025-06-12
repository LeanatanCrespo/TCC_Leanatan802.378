import 'package:flutter_test/flutter_test.dart';
import 'package:tcc2025_leanatan/models/usuario.dart';

void main() {
  group('Usuario', () {
    test('construtor e atributos', () {
      final usuario = Usuario(id: '123', nome: 'João', email: 'teste@email.com');
      expect(usuario.id, '123');
      expect(usuario.nome, 'João');
      expect(usuario.email, 'teste@email.com');
    });

    test('conversão para Map', () {
      final usuario = Usuario(id: '123', nome: 'João', email: 'teste@email.com');
      final map = usuario.toMap();
      expect(map['id'], '123');
      expect(map['nome'], 'João');
      expect(map['email'], 'teste@email.com');
    });

    test('criação a partir de Map', () {
      final map = {'id': '456', 'nome': 'Maria', 'email': 'maria@email.com'};
      final usuario = Usuario.fromMap(map);
      expect(usuario.id, '456');
      expect(usuario.nome, 'Maria');
      expect(usuario.email, 'maria@email.com');
    });
  });
}
