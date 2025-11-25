import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/despesa_controller.dart';
import '../controllers/tipo_controller.dart';
import '../controllers/periodo_controller.dart';
import '../models/despesa.dart';
import '../models/tipo.dart';
import '../models/periodo.dart';

class DespesaFormView extends StatefulWidget {
  final Despesa? despesaParaEditar;

  const DespesaFormView({super.key, this.despesaParaEditar});

  @override
  State<DespesaFormView> createState() => _DespesaFormViewState();
}

class _DespesaFormViewState extends State<DespesaFormView> {
  final DespesaController _despesaController = DespesaController();
  final TipoController _tipoController = TipoController();
  final PeriodoController _periodoController = PeriodoController();

  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _prioridadeController = TextEditingController();

  DateTime _dataSelecionada = DateTime.now();
  List<String> _tiposSelecionados = [];
  String? _periodoSelecionado;

  List<Tipo> _todosOsTipos = [];
  List<Periodo> _todosOsPeriodos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
    
    if (widget.despesaParaEditar != null) {
      final despesa = widget.despesaParaEditar!;
      _nomeController.text = despesa.nome;
      _valorController.text = despesa.valor.toString();
      _prioridadeController.text = despesa.prioridade.toString();
      _dataSelecionada = despesa.data;
      _tiposSelecionados = List.from(despesa.tiposIds);
      _periodoSelecionado = despesa.periodoId;
    }
  }

  void _carregarDados() {
    _tipoController.listarTipos().listen((tipos) {
      if (mounted) setState(() => _todosOsTipos = tipos);
    });

    _periodoController.listarPeriodos().listen((periodos) {
      if (mounted) setState(() => _todosOsPeriodos = periodos);
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _prioridadeController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null && mounted) {
      setState(() => _dataSelecionada = data);
    }
  }

  void _toggleTipo(String tipoId) {
    setState(() {
      if (_tiposSelecionados.contains(tipoId)) {
        _tiposSelecionados.remove(tipoId);
      } else {
        _tiposSelecionados.add(tipoId);
      }
    });
  }

  Future<void> _salvarDespesa() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ CORREÇÃO: Validar usuário autenticado ANTES de processar
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado. Faça login novamente.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ CORREÇÃO: Substituir vírgula por ponto para parsing correto
      final valorText = _valorController.text.trim().replaceAll(',', '.');
      final valor = double.parse(valorText);
      final prioridade = int.parse(_prioridadeController.text.trim());

      // ✅ VALIDAÇÃO EXTRA: Garantir valores válidos
      if (valor <= 0) {
        throw Exception('O valor deve ser maior que zero');
      }
      if (prioridade <= 0) {
        throw Exception('A prioridade deve ser maior que zero');
      }

      if (widget.despesaParaEditar == null) {
        // Criar nova despesa
        final despesa = Despesa(
          id: const Uuid().v4(),
          usuarioId: uid, // ✅ CORREÇÃO: Usar uid real
          nome: _nomeController.text.trim(),
          valor: valor,
          prioridade: prioridade,
          data: _dataSelecionada,
          tiposIds: _tiposSelecionados,
          periodoId: _periodoSelecionado,
          dataCriacao: DateTime.now(),
        );

        await _despesaController.adicionarDespesa(despesa);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Despesa criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Atualizar despesa existente
        final despesaAtualizada = widget.despesaParaEditar!.copyWith(
          nome: _nomeController.text.trim(),
          valor: valor,
          prioridade: prioridade,
          data: _dataSelecionada,
          tiposIds: _tiposSelecionados,
          periodoId: _periodoSelecionado,
        );

        await _despesaController.atualizarDespesa(despesaAtualizada);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Despesa atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } on FormatException catch (e) {
      // ✅ MELHORIA: Tratamento específico para erro de formato
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Formato inválido: ${e.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // ✅ MELHORIA: Tratamento de erros melhorado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar despesa: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Despesa'),
        content: const Text(
          'Tem certeza que deseja excluir esta despesa?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true && widget.despesaParaEditar != null) {
      setState(() => _isLoading = true);
      try {
        await _despesaController.deletarDespesa(widget.despesaParaEditar!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Despesa excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.despesaParaEditar == null
            ? 'Nova Despesa'
            : 'Editar Despesa'),
        actions: [
          if (widget.despesaParaEditar != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _confirmarExclusao,
              tooltip: 'Excluir despesa',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nome
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da Despesa *',
                hintText: 'Ex: Aluguel, Alimentação',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite o nome da despesa';
                }
                if (value.trim().length < 3) {
                  return 'Nome muito curto (mínimo 3 caracteres)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Valor e Prioridade
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valorController,
                    decoration: const InputDecoration(
                      labelText: 'Valor *',
                      hintText: '0,00',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                      prefixText: 'R\$ ',
                      helperText: 'Use vírgula ou ponto',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite o valor';
                      }
                      // ✅ MELHORIA: Aceitar vírgula e ponto
                      final valorText = value.trim().replaceAll(',', '.');
                      final valor = double.tryParse(valorText);
                      if (valor == null) {
                        return 'Valor inválido';
                      }
                      if (valor <= 0) {
                        return 'Valor deve ser maior que zero';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _prioridadeController,
                    decoration: const InputDecoration(
                      labelText: 'Prioridade *',
                      hintText: '1-10',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.priority_high),
                      helperText: '1 = baixa, 10 = alta',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite a prioridade';
                      }
                      final prioridade = int.tryParse(value.trim());
                      if (prioridade == null) {
                        return 'Número inválido';
                      }
                      if (prioridade < 1 || prioridade > 10) {
                        return 'Entre 1 e 10';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data da Despesa'),
                subtitle: Text(
                  '${_dataSelecionada.day.toString().padLeft(2, '0')}/'
                  '${_dataSelecionada.month.toString().padLeft(2, '0')}/'
                  '${_dataSelecionada.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.edit),
                onTap: _isLoading ? null : _selecionarData,
              ),
            ),
            const SizedBox(height: 16),

            // Tipos
            const Text(
              'Tipos/Tags (opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_todosOsTipos.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.label_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum tipo cadastrado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crie tipos em "Gerenciar Tipos"',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _todosOsTipos.map((tipo) {
                  final selecionado = _tiposSelecionados.contains(tipo.id);
                  return FilterChip(
                    label: Text(tipo.nome),
                    selected: selecionado,
                    onSelected: _isLoading ? null : (_) => _toggleTipo(tipo.id),
                    selectedColor: Colors.red[100],
                    checkmarkColor: Colors.red[800],
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Período
            const Text(
              'Recorrência (opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_todosOsPeriodos.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.repeat_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum período cadastrado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crie períodos em "Gerenciar Períodos"',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: _periodoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Selecione um período',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat),
                ),
                hint: const Text('Nenhum (despesa única)'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Nenhum (despesa única)'),
                  ),
                  ..._todosOsPeriodos.map((periodo) {
                    return DropdownMenuItem<String>(
                      value: periodo.id,
                      child: Text('${periodo.nome} - ${periodo.descricao}'),
                    );
                  }),
                ],
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _periodoSelecionado = value);
                      },
              ),
            const SizedBox(height: 24),

            // Botão Salvar
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(widget.despesaParaEditar == null
                      ? Icons.add
                      : Icons.save),
              label: Text(
                widget.despesaParaEditar == null
                    ? 'Criar Despesa'
                    : 'Salvar Alterações',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _salvarDespesa,
            ),
          ],
        ),
      ),
    );
  }
}