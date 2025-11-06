import '../models/periodo.dart';
import '../services/periodo_service.dart';

class PeriodoController {
  final PeriodoService _service = PeriodoService();

  Future<void> adicionarPeriodo(Periodo periodo) =>
      _service.adicionarPeriodo(periodo);

  Stream<List<Periodo>> listarPeriodos() => _service.listarPeriodos();

  Future<void> atualizarPeriodo(Periodo periodo) =>
      _service.atualizarPeriodo(periodo);

  Future<void> deletarPeriodo(String id) => _service.deletarPeriodo(id);

  Future<Periodo?> buscarPeriodoPorId(String id) =>
      _service.buscarPeriodoPorId(id);
}