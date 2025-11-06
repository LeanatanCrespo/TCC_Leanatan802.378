import '../models/tipo.dart';
import '../services/tipo_service.dart';

class TipoController {
  final TipoService _service = TipoService();

  Future<void> adicionarTipo(Tipo tipo) => _service.adicionarTipo(tipo);

  Stream<List<Tipo>> listarTipos() => _service.listarTipos();

  Future<void> atualizarTipo(Tipo tipo) => _service.atualizarTipo(tipo);

  Future<void> deletarTipo(String id) => _service.deletarTipo(id);

  Future<List<Tipo>> buscarTiposPorIds(List<String> ids) =>
      _service.buscarTiposPorIds(ids);
}