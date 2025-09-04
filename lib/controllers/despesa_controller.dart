import '../models/despesa.dart';
import '../services/despesa_service.dart';

class DespesaController {
  final DespesaService _service = DespesaService();

  Future<void> adicionarDespesa(Despesa despesa) => _service.adicionarDespesa(despesa);

  Stream<List<Despesa>> listarDespesas() => _service.listarDespesas();

  Future<void> atualizarDespesa(Despesa despesa) => _service.atualizarDespesa(despesa);

  Future<void> deletarDespesa(String id) => _service.deletarDespesa(id);
}
