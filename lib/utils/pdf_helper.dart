import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfHelper {
  /// Salva PDF de forma multiplataforma
  static Future<String> salvarPdf(pw.Document pdf, String nomeArquivo) async {
    try {
      // Gerar bytes do PDF
      final pdfBytes = await pdf.save();
      
      if (kIsWeb) {
        // ✅ CORREÇÃO: Para Web, apenas retornar mensagem
        // O download web será tratado diretamente na view
        throw UnsupportedError('Use salvarPdfWeb para plataforma web');
      } else {
        // Mobile/Desktop: Salvar no sistema de arquivos
        return await _salvarPdfNativo(pdfBytes, nomeArquivo);
      }
    } catch (e) {
      throw Exception('Erro ao salvar PDF: $e');
    }
  }

  static Future<String> _salvarPdfNativo(List<int> pdfBytes, String nomeArquivo) async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      // Android: Tentar Downloads primeiro, depois External Storage
      try {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      // iOS: Application Documents
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop: Downloads ou Documents
      try {
        directory = await getDownloadsDirectory();
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }
    }

    if (directory == null) {
      throw Exception('Não foi possível acessar o diretório de armazenamento');
    }

    // Criar arquivo
    final filePath = '${directory.path}/$nomeArquivo';
    final file = File(filePath);
    
    // Garantir que o diretório existe
    await file.parent.create(recursive: true);
    
    // Escrever bytes
    await file.writeAsBytes(pdfBytes);

    debugPrint('✅ PDF salvo: $filePath');
    return filePath;
  }

  /// Gera nome de arquivo com timestamp
  static String gerarNomeArquivo(String prefixo) {
    final timestamp = DateTime.now();
    final data = '${timestamp.year}'
        '${timestamp.month.toString().padLeft(2, '0')}'
        '${timestamp.day.toString().padLeft(2, '0')}';
    final hora = '${timestamp.hour.toString().padLeft(2, '0')}'
        '${timestamp.minute.toString().padLeft(2, '0')}';
    return '${prefixo}_${data}_$hora.pdf';
  }
  
  /// Obter bytes do PDF (para web ou compartilhamento)
  static Future<Uint8List> obterBytes(pw.Document pdf) async {
    return await pdf.save();
  }
}