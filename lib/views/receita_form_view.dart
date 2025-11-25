import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/receita_controller.dart';
import '../controllers/tipo_controller.dart';
import '../controllers/periodo_controller.dart';
import '../models/receita.dart';
import '../models/tipo.dart';
import '../models/periodo.dart';
import '../utils/validators.dart';

class ReceitaFormView extends StatefulWidget {
  final Receita? receitaParaEditar;

  const ReceitaFormView({super.key, this.receitaParaEditar});

  @override
  State<ReceitaFormView> createState() => _ReceitaFormViewState();
}

class _ReceitaFormViewState extends State<ReceitaFormView> {
  final ReceitaController _receitaController = ReceitaController();
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
    
    if (widget.receitaParaEditar != null) {
      final receita = widget.receitaParaEditar!;
      _nomeController.text = receita.nome;
      _valorController.text = receita.valor.toStringAsFixed(2).replaceAll('.', ',');
      _prioridadeController.text = receita.prioridade.toString();
      _dataSelecionada = receita.data;
      _tiposSelecionados = List.from(receita.tiposIds);
      _periodoSelecionado = receita.periodoId;
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
      helpText: 'Selecione a data da receita',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
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

  Future<void> _salvarReceita() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ CRÍTICO: Validar usuário autenticado
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado. Faça login novamente.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ Usar helper para parsing seguro
      final valor = Validators.parseValor(_valorController.text);
      final prioridade = Validators.parseInt(_prioridadeController.text);

      // ✅ Validação extra
      if (valor <= 0) {
        throw Exception('O valor deve ser maior que zero');
      }
      if (prioridade < 1 || prioridade > 10) {
        throw Exception('A prioridade deve estar entre 1 e 10');
      }

      if (widget.receitaParaEditar == null) {
        // Criar nova receita
        final receita = Receita(
          id: const Uuid().v4(),
          usuarioId: uid, // ✅ CORRIGIDO: uid real
          nome: _nomeController.text.trim(),
          valor: valor,
          prioridade: prioridade,
          data: _dataSelecionada,
          tiposIds: _tiposSelecionados,
          periodoId: _periodoSelecionado,
          dataCriacao: DateTime.now(),
        );

        await _receitaController.adicionarReceita(receita);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Receita criada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Atualizar receita existente
        final receitaAtualizada = widget.receitaParaEditar!.copyWith(
          nome: _nomeController.text.trim(),
          valor: valor,
          prioridade: prioridade,
          data: _dataSelecionada,
          tiposIds: _tiposSelecionados,
          periodoId: _periodoSelecionado,
        );

        await _receitaController.atualizarReceita(receitaAtualizada);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Receita atualizada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        }
      }
    } on FormatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Formato inválido: ${e.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: ${e.toString()}'),
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
        title: const Text('Excluir Receita'),
        content: const Text(
          'Tem certeza que deseja excluir esta receita?\n\nEsta ação não pode ser desfeita.',
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

    if (confirmar == true && widget.receitaParaEditar != null) {
      setState(() => _isLoading = true);
      try {
        await _receitaController.deletarReceita(widget.receitaParaEditar!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Receita excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erro ao excluir: ${e.toString()}'),
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
        title: Text(widget.receitaParaEditar == null
            ? 'Nova Receita'
            : 'Editar Receita'),
        actions: [
          if (widget.receitaParaEditar != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _confirmarExclusao,
              tooltip: 'Excluir receita',
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
                labelText: 'Nome da Receita *',
                hintText: 'Ex: Salário, Freelance',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isLoading,
              validator: (value) => Validators.validarTextoObrigatorio(
                value,
                mensagem: 'Digite o nome da receita',
                minLength: 3,
              ),
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
                    enabled: !_isLoading,
                    validator: (value) => Validators.validarValor(
                      value,
                      minValue: 0.01,
                    ),
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
                      helperText: '1=baixa, 10=alta',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isLoading,
                    validator: Validators.validarPrioridade,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Data
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: const Text('Data da Receita'),
                subtitle: Text(
                  '${_dataSelecionada.day.toString().padLeft(2, '0')}/'
                  '${_dataSelecionada.month.toString().padLeft(2, '0')}/'
                  '${_dataSelecionada.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                    selectedColor: Colors.green[100],
                    checkmarkColor: Colors.green[800],
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
                hint: const Text('Nenhum (receita única)'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Nenhum (receita única)'),
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
                  : Icon(widget.receitaParaEditar == null
                      ? Icons.add
                      : Icons.save),
              label: Text(
                widget.receitaParaEditar == null
                    ? 'Criar Receita'
                    : 'Salvar Alterações',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : _salvarReceita,
            ),

            // Info de ajuda
            if (!_isLoading) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dica: Você pode usar vírgula ou ponto no valor',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}