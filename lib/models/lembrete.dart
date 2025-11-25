import 'package:cloud_firestore/cloud_firestore.dart';

class Lembrete {
  final String id;
  final String usuarioId;
  final String referenciaId;
  final String tipoReferencia;
  final int diasAntes;
  final bool notificarNoDia;
  final bool ativo;
  final bool concluido;
  final DateTime dataCriacao;
  
  // ✅ NOVO: Horário da notificação
  final int horario; // Hora do dia (0-23)
  final int minuto; // Minuto (0-59)

  Lembrete({
    required this.id,
    required this.usuarioId,
    required this.referenciaId,
    required this.tipoReferencia,
    required this.diasAntes,
    required this.notificarNoDia,
    required this.ativo,
    required this.concluido,
    required this.dataCriacao,
    this.horario = 9, // Padrão: 9h da manhã
    this.minuto = 0, // Padrão: 00 minutos
  });

  /// Calcula quando o lembrete deve ser disparado (com hora)
  DateTime calcularDataHoraNotificacao(DateTime dataReferencia) {
    DateTime dataNotificacao;
    
    if (diasAntes == 0) {
      dataNotificacao = dataReferencia;
    } else {
      dataNotificacao = dataReferencia.subtract(Duration(days: diasAntes));
    }

    // ✅ Aplicar horário configurado
    return DateTime(
      dataNotificacao.year,
      dataNotificacao.month,
      dataNotificacao.day,
      horario,
      minuto,
    );
  }

  /// Verifica se o lembrete deve ser disparado agora
  bool deveDispararAgora(DateTime dataReferencia) {
    if (!ativo || concluido) return false;

    final dataHoraNotificacao = calcularDataHoraNotificacao(dataReferencia);
    final agora = DateTime.now();

    // Verifica se está dentro de uma janela de 5 minutos
    final diferenca = agora.difference(dataHoraNotificacao).inMinutes.abs();
    return diferenca <= 5;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'referenciaId': referenciaId,
      'tipoReferencia': tipoReferencia,
      'diasAntes': diasAntes,
      'notificarNoDia': notificarNoDia,
      'ativo': ativo,
      'concluido': concluido,
      'dataCriacao': dataCriacao.toIso8601String(),
      'horario': horario, // ✅ NOVO
      'minuto': minuto, // ✅ NOVO
    };
  }

  factory Lembrete.fromMap(Map<String, dynamic> map) {
    return Lembrete(
      id: map['id'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      referenciaId: map['referenciaId'] ?? '',
      tipoReferencia: map['tipoReferencia'] ?? '',
      diasAntes: map['diasAntes'] ?? 0,
      notificarNoDia: map['notificarNoDia'] ?? true,
      ativo: map['ativo'] ?? true,
      concluido: map['concluido'] ?? false,
      dataCriacao: DateTime.parse(map['dataCriacao']),
      horario: map['horario'] ?? 9, // ✅ NOVO com padrão
      minuto: map['minuto'] ?? 0, // ✅ NOVO com padrão
    );
  }

  Lembrete copyWith({
    String? id,
    String? usuarioId,
    String? referenciaId,
    String? tipoReferencia,
    int? diasAntes,
    bool? notificarNoDia,
    bool? ativo,
    bool? concluido,
    DateTime? dataCriacao,
    int? horario,
    int? minuto,
  }) {
    return Lembrete(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      referenciaId: referenciaId ?? this.referenciaId,
      tipoReferencia: tipoReferencia ?? this.tipoReferencia,
      diasAntes: diasAntes ?? this.diasAntes,
      notificarNoDia: notificarNoDia ?? this.notificarNoDia,
      ativo: ativo ?? this.ativo,
      concluido: concluido ?? this.concluido,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      horario: horario ?? this.horario,
      minuto: minuto ?? this.minuto,
    );
  }

  String get descricao {
    final horarioFormatado = '${horario.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';
    
    if (diasAntes == 0) {
      return 'No dia às $horarioFormatado';
    } else if (diasAntes == 1) {
      return '1 dia antes às $horarioFormatado';
    } else {
      return '$diasAntes dias antes às $horarioFormatado';
    }
  }
}