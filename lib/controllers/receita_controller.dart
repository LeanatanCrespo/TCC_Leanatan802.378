import '../models/receita.dart';
import '../services/receita_service.dart';

class ReceitaController {
  final ReceitaService _service = ReceitaService();

  Future<void> adicionarReceita(Receita receita) => _service.adicionarReceita(receita);

  Stream<List<Receita>> listarReceitas() => _service.listarReceitas();

  Future<void> atualizarReceita(Receita receita) => _service.atualizarReceita(receita);

  Future<void> deletarReceita(String id) => _service.deletarReceita(id);
}