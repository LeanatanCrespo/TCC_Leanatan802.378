import '../models/lembrete.dart';
import '../services/lembrete_service.dart';

class LembreteController {
  final LembreteService _service = LembreteService();

  // CRUD
  Future<void> adicionarLembrete(Lembrete lembrete) => _service.adicionarLembrete(lembrete);

  Stream<List<Lembrete>> listarLembretes() => _service.listarLembretes();

  Future<void> atualizarLembrete(Lembrete lembrete) => _service.atualizarLembrete(lembrete);

  Future<void> deletarLembrete(String id) => _service.deletarLembrete(id);
}
