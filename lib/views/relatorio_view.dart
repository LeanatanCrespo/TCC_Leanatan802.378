import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/relatorio.dart';
import '../services/relatorio_service.dart';
import '../utils/pdf_helper.dart';
import 'grafico_view.dart';

class RelatorioView extends StatefulWidget {
  const RelatorioView({super.key});

  @override
  State<RelatorioView> createState() => _RelatorioViewState();
}

class _RelatorioViewState extends State<RelatorioView> {
  final RelatorioService _service = RelatorioService();
  Relatorio? _relatorio;
  bool _isLoading = false;
  String _tipoRelatorio = 'mensal';

  final _anoController = TextEditingController();
  final _mesController = TextEditingController();
  DateTime? _dataInicio;
  DateTime? _dataFim;

  @override
  void initState() {
    super.initState();
    // Preencher com mês/ano atual
    final agora = DateTime.now();
    _mesController.text = agora.month.toString();
    _anoController.text = agora.year.toString();
  }

  @override
  void dispose() {
    _anoController.dispose();
    _mesController.dispose();
    super.dispose();
  }

  Future<void> _gerarRelatorio() async {
    setState(() => _isLoading = true);

    try {
      Relatorio relatorio;

      if (_tipoRelatorio == 'mensal') {
        final mes = int.tryParse(_mesController.text.trim());
        final ano = int.tryParse(_anoController.text.trim());

        if (mes == null || ano == null || mes < 1 || mes > 12) {
          throw Exception('Mês e ano inválidos');
        }

        debugPrint('📊 Gerando relatório mensal: $mes/$ano');
        relatorio = await _service.gerarRelatorioMensal(mes, ano);
      } else if (_tipoRelatorio == 'anual') {
        final ano = int.tryParse(_anoController.text.trim());

        if (ano == null) {
          throw Exception('Ano inválido');
        }

        debugPrint('📊 Gerando relatório anual: $ano');
        relatorio = await _service.gerarRelatorioAnual(ano);
      } else {
        if (_dataInicio == null || _dataFim == null) {
          throw Exception('Selecione as datas de início e fim');
        }

        debugPrint('📊 Gerando relatório personalizado: $_dataInicio - $_dataFim');
        relatorio = await _service.gerarRelatorioPorPeriodo(_dataInicio!, _dataFim!);
      }

      debugPrint('✅ Relatório gerado: ${relatorio.receitas.length} receitas, ${relatorio.despesas.length} despesas');

      setState(() {
        _relatorio = relatorio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data inicial',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );
    if (data != null && mounted) {
      setState(() => _dataInicio = data);
    }
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataFim ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data final',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );
    if (data != null && mounted) {
      setState(() => _dataFim = data);
    }
  }

  void _abrirGrafico() {
    if (_relatorio == null) return;

    final tipoAgrupamento = _service.determinarTipoAgrupamento(
      _relatorio!.primeiraData,
      _relatorio!.ultimaData,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GraficoView(
          relatorio: _relatorio!,
          tipoAgrupamento: tipoAgrupamento,
        ),
      ),
    );
  }

  // ✅ CORREÇÃO: Geração de PDF melhorada
  Future<void> _gerarPDF() async {
    if (_relatorio == null) return;

    setState(() => _isLoading = true);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Text(
                'Relatório Financeiro',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Período
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Período do Relatório',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      '${_formatarData(_relatorio!.primeiraData)} até ${_formatarData(_relatorio!.ultimaData)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Resumo
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: _relatorio!.valorFinal >= 0
                      ? PdfColors.green50
                      : PdfColors.red50,
                  border: pw.Border.all(
                    color: _relatorio!.valorFinal >= 0
                        ? PdfColors.green
                        : PdfColors.red,
                  ),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Receitas:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'R\$ ${_relatorio!.receitas.fold(0.0, (sum, r) => sum + r.valor).toStringAsFixed(2)}',
                          style: const pw.TextStyle(color: PdfColors.green),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Total Despesas:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          'R\$ ${_relatorio!.despesas.fold(0.0, (sum, d) => sum + d.valor).toStringAsFixed(2)}',
                          style: const pw.TextStyle(color: PdfColors.red),
                        ),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Saldo Final:',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'R\$ ${_relatorio!.valorFinal.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _relatorio!.valorFinal >= 0
                                ? PdfColors.green
                                : PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Receitas
              pw.Text(
                'Receitas (${_relatorio!.receitas.length})',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (_relatorio!.receitas.isEmpty)
                pw.Text('Nenhuma receita no período', style: const pw.TextStyle(color: PdfColors.grey))
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Data', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Nome', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ..._relatorio!.receitas.take(20).map((r) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(_formatarData(r.data), style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(r.nome, style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'R\$ ${r.valor.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.green),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              pw.SizedBox(height: 20),

              // Despesas
              pw.Text(
                'Despesas (${_relatorio!.despesas.length})',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (_relatorio!.despesas.isEmpty)
                pw.Text('Nenhuma despesa no período', style: const pw.TextStyle(color: PdfColors.grey))
              else
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Data', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Nome', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ..._relatorio!.despesas.take(20).map((d) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(_formatarData(d.data), style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(d.nome, style: const pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            'R\$ ${d.valor.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.red),
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
            ],
          ),
        ),
      );

      // ✅ CORREÇÃO: Salvar PDF com path_provider
      try {
        final Directory? directory = await getDownloadsDirectory() ?? 
                                     await getApplicationDocumentsDirectory();
        
        if (directory == null) {
          throw Exception('Não foi possível acessar o diretório de downloads');
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'relatorio_$timestamp.pdf';
        final file = File('${directory.path}/$fileName');
        
        await file.writeAsBytes(await pdf.save());

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ PDF salvo com sucesso!\n📁 ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      } catch (e) {
        throw Exception('Erro ao salvar PDF: $e');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao gerar PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          if (_relatorio != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _gerarRelatorio,
              tooltip: 'Atualizar relatório',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Gerando relatório...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seletor de tipo de relatório
                  const Text(
                    'Tipo de Relatório',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'mensal', label: Text('Mensal')),
                      ButtonSegment(value: 'anual', label: Text('Anual')),
                      ButtonSegment(value: 'personalizado', label: Text('Personalizado')),
                    ],
                    selected: {_tipoRelatorio},
                    onSelectionChanged: (value) {
                      setState(() {
                        _tipoRelatorio = value.first;
                        _relatorio = null; // Limpar relatório anterior
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campos conforme tipo
                  if (_tipoRelatorio == 'mensal') ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _mesController,
                            decoration: const InputDecoration(
                              labelText: 'Mês (1-12)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_month),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _anoController,
                            decoration: const InputDecoration(
                              labelText: 'Ano',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ] else if (_tipoRelatorio == 'anual') ...[
                    TextField(
                      controller: _anoController,
                      decoration: const InputDecoration(
                        labelText: 'Ano',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: _selecionarDataInicio,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _dataInicio == null
                            ? 'Selecionar Data Início'
                            : 'Início: ${_formatarData(_dataInicio!)}',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _selecionarDataFim,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _dataFim == null
                            ? 'Selecionar Data Fim'
                            : 'Fim: ${_formatarData(_dataFim!)}',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Botão Gerar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.summarize),
                      label: const Text('Gerar Relatório'),
                      onPressed: _gerarRelatorio,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  // Relatório gerado
                  if (_relatorio != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Cabeçalho do relatório
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Período',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatarData(_relatorio!.primeiraData)} até ${_formatarData(_relatorio!.ultimaData)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Resumo
                    Card(
                      color: _relatorio!.valorFinal >= 0
                          ? Colors.green[50]
                          : Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Receitas:'),
                                Text(
                                  'R\$ ${_relatorio!.receitas.fold(0.0, (sum, r) => sum + r.valor).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Despesas:'),
                                Text(
                                  'R\$ ${_relatorio!.despesas.fold(0.0, (sum, d) => sum + d.valor).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Saldo Final:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'R\$ ${_relatorio!.valorFinal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _relatorio!.valorFinal >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.pie_chart),
                            label: const Text('Ver Gráfico'),
                            onPressed: _abrirGrafico,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Gerar PDF'),
                            onPressed: _gerarPDF,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Listas expandidas
                    ExpansionTile(
                      title: Text(
                        'Receitas (${_relatorio!.receitas.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      initiallyExpanded: _relatorio!.receitas.isNotEmpty,
                      children: [
                        if (_relatorio!.receitas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Nenhuma receita no período'),
                          )
                        else
                          ..._relatorio!.receitas.take(10).map((r) => ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.arrow_upward, color: Colors.white),
                                ),
                                title: Text(r.nome),
                                subtitle: Text(_formatarData(r.data)),
                                trailing: Text(
                                  'R\$ ${r.valor.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                        if (_relatorio!.receitas.length > 10)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '+ ${_relatorio!.receitas.length - 10} receitas...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ExpansionTile(
                      title: Text(
                        'Despesas (${_relatorio!.despesas.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      initiallyExpanded: _relatorio!.despesas.isNotEmpty,
                      children: [
                        if (_relatorio!.despesas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Nenhuma despesa no período'),
                          )
                        else
                          ..._relatorio!.despesas.take(10).map((d) => ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.arrow_downward, color: Colors.white),
                                ),
                                title: Text(d.nome),
                                subtitle: Text(_formatarData(d.data)),
                                trailing: Text(
                                  'R\$ ${d.valor.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )),
                        if (_relatorio!.despesas.length > 10)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '+ ${_relatorio!.despesas.length - 10} despesas...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}