import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../controllers/lembrete_controller.dart';
import '../controllers/receita_controller.dart';
import '../controllers/despesa_controller.dart';
import '../models/lembrete.dart';
import '../models/receita.dart';
import '../models/despesa.dart';

class LembretesView extends StatefulWidget {
  const LembretesView({super.key});

  @override
  State<LembretesView> createState() => _LembretesViewState();
}

class _LembretesViewState extends State<LembretesView> {
  final LembreteController _lembreteController = LembreteController();
  final ReceitaController _receitaController = ReceitaController();
  final DespesaController _despesaController = DespesaController();

  List<Receita> _todasReceitas = [];
  List<Despesa> _todasDespesas = [];
  final Map<String, dynamic> _referenciasCache = {};

  @override
  void initState() {
    super.initState();
    _carregarReferencias();
  }

  void _carregarReferencias() {
    _receitaController.listarReceitas().listen((receitas) {
      if (mounted) {
        setState(() {
          _todasReceitas = receitas;
          for (var r in receitas) {
            _referenciasCache[r.id] = {'tipo': 'receita', 'item': r};
          }
        });
      }
    });

    _despesaController.listarDespesas().listen((despesas) {
      if (mounted) {
        setState(() {
          _todasDespesas = despesas;
          for (var d in despesas) {
            _referenciasCache[d.id] = {'tipo': 'despesa', 'item': d};
          }
        });
      }
    });
  }

  void _abrirFormularioLembrete({Lembrete? lembreteParaEditar}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FormularioLembrete(
        lembreteParaEditar: lembreteParaEditar,
        todasReceitas: _todasReceitas,
        todasDespesas: _todasDespesas,
        onSalvar: (lembrete) async {
          try {
            if (lembreteParaEditar == null) {
              await _lembreteController.adicionarLembrete(lembrete);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Lembrete criado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } else {
              await _lembreteController.atualizarLembrete(lembrete);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Lembrete atualizado!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
            Navigator.pop(context);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Erro: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _toggleAtivo(Lembrete lembrete) async {
    try {
      final lembreteAtualizado = lembrete.copyWith(ativo: !lembrete.ativo);
      await _lembreteController.atualizarLembrete(lembreteAtualizado);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Future<void> _toggleConcluido(Lembrete lembrete) async {
    try {
      final lembreteAtualizado = lembrete.copyWith(concluido: !lembrete.concluido);
      await _lembreteController.atualizarLembrete(lembreteAtualizado);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Future<void> _confirmarExclusao(Lembrete lembrete) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Lembrete'),
        content: const Text('Deseja excluir este lembrete?'),
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

    if (confirmar == true) {
      try {
        await _lembreteController.deletarLembrete(lembrete.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Lembrete excluído!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  String _getNomeReferencia(String referenciaId) {
    final ref = _referenciasCache[referenciaId];
    if (ref != null) {
      if (ref['tipo'] == 'receita') {
        return (ref['item'] as Receita).nome;
      } else {
        return (ref['item'] as Despesa).nome;
      }
    }
    return 'Item não encontrado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lembretes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormularioLembrete(),
        icon: const Icon(Icons.add),
        label: const Text('Novo Lembrete'),
      ),
      body: StreamBuilder<List<Lembrete>>(
        stream: _lembreteController.listarLembretes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lembretes = snapshot.data ?? [];

          if (lembretes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum lembrete cadastrado',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie lembretes para suas receitas e despesas',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: lembretes.length,
            itemBuilder: (context, index) {
              final lembrete = lembretes[index];
              final nomeReferencia = _getNomeReferencia(lembrete.referenciaId);
              final isReceita = lembrete.tipoReferencia == 'receita';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isReceita ? Colors.green : Colors.red,
                    child: Icon(
                      isReceita ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(nomeReferencia),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lembrete.descricao),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (lembrete.notificarNoDia)
                            Chip(
                              label: const Text('No dia', style: TextStyle(fontSize: 10)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            ),
                          const SizedBox(width: 4),
                          Chip(
                            label: Text(
                              lembrete.concluido ? 'Concluído' : 'Pendente',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: lembrete.concluido ? Colors.green[100] : Colors.orange[100],
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: lembrete.ativo,
                        onChanged: (_) => _toggleAtivo(lembrete),
                        activeThumbColor: Colors.green,
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'editar') {
                            _abrirFormularioLembrete(lembreteParaEditar: lembrete);
                          } else if (value == 'concluir') {
                            _toggleConcluido(lembrete);
                          } else if (value == 'excluir') {
                            _confirmarExclusao(lembrete);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'concluir',
                            child: Row(
                              children: [
                                Icon(lembrete.concluido ? Icons.undo : Icons.check),
                                const SizedBox(width: 8),
                                Text(lembrete.concluido ? 'Desfazer' : 'Concluir'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'excluir',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ✅ Formulário de Lembrete com Horário
class _FormularioLembrete extends StatefulWidget {
  final Lembrete? lembreteParaEditar;
  final List<Receita> todasReceitas;
  final List<Despesa> todasDespesas;
  final Function(Lembrete) onSalvar;

  const _FormularioLembrete({
    this.lembreteParaEditar,
    required this.todasReceitas,
    required this.todasDespesas,
    required this.onSalvar,
  });

  @override
  State<_FormularioLembrete> createState() => _FormularioLembreteState();
}

class _FormularioLembreteState extends State<_FormularioLembrete> {
  final _formKey = GlobalKey<FormState>();
  String? _referenciaIdSelecionada;
  String _tipoReferenciaSelecionado = 'receita';
  int _diasAntes = 1;
  bool _notificarNoDia = true;
  int _horario = 9;
  int _minuto = 0;

  @override
  void initState() {
    super.initState();
    if (widget.lembreteParaEditar != null) {
      final lembrete = widget.lembreteParaEditar!;
      _referenciaIdSelecionada = lembrete.referenciaId;
      _tipoReferenciaSelecionado = lembrete.tipoReferencia;
      _diasAntes = lembrete.diasAntes;
      _notificarNoDia = lembrete.notificarNoDia;
      _horario = lembrete.horario;
      _minuto = lembrete.minuto;
    }
  }

  Future<void> _selecionarHorario() async {
    final TimeOfDay? horarioSelecionado = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _horario, minute: _minuto),
      helpText: 'Selecione o horário',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (horarioSelecionado != null) {
      setState(() {
        _horario = horarioSelecionado.hour;
        _minuto = horarioSelecionado.minute;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final itensDisponiveis = _tipoReferenciaSelecionado == 'receita'
        ? widget.todasReceitas
        : widget.todasDespesas;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.lembreteParaEditar == null ? 'Novo Lembrete' : 'Editar Lembrete',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'receita',
                    label: Text('Receita'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: 'despesa',
                    label: Text('Despesa'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_tipoReferenciaSelecionado},
                onSelectionChanged: (value) {
                  setState(() {
                    _tipoReferenciaSelecionado = value.first;
                    _referenciaIdSelecionada = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _referenciaIdSelecionada,
                decoration: InputDecoration(
                  labelText: 'Selecione ${_tipoReferenciaSelecionado == "receita" ? "uma receita" : "uma despesa"}',
                  border: const OutlineInputBorder(),
                ),
                items: itensDisponiveis.map((item) {
                  final id = _tipoReferenciaSelecionado == 'receita'
                      ? (item as Receita).id
                      : (item as Despesa).id;
                  final nome = _tipoReferenciaSelecionado == 'receita'
                      ? (item as Receita).nome
                      : (item as Despesa).nome;
                  return DropdownMenuItem(value: id, child: Text(nome));
                }).toList(),
                onChanged: (value) {
                  setState(() => _referenciaIdSelecionada = value);
                },
                validator: (value) => value == null ? 'Selecione um item' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _diasAntes.toString(),
                decoration: const InputDecoration(
                  labelText: 'Notificar quantos dias antes?',
                  border: OutlineInputBorder(),
                  helperText: '0 = notificar apenas no dia',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final dias = int.tryParse(value);
                  if (dias != null) _diasAntes = dias;
                },
                validator: (value) {
                  final dias = int.tryParse(value ?? '');
                  if (dias == null || dias < 0) return 'Digite um número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.blue),
                  title: const Text('Horário da notificação'),
                  subtitle: Text(
                    '${_horario.toString().padLeft(2, '0')}:${_minuto.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: _selecionarHorario,
                ),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('Notificar também no dia'),
                value: _notificarNoDia,
                onChanged: (value) => setState(() => _notificarNoDia = value),
              ),
              const SizedBox(height: 8),

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
                        _diasAntes == 0
                            ? 'Será notificado no dia às ${_horario.toString().padLeft(2, '0')}:${_minuto.toString().padLeft(2, '0')}'
                            : 'Será notificado $_diasAntes dia${_diasAntes > 1 ? 's' : ''} antes às ${_horario.toString().padLeft(2, '0')}:${_minuto.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Lembrete'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final lembrete = Lembrete(
                        id: widget.lembreteParaEditar?.id ?? const Uuid().v4(),
                        usuarioId: widget.lembreteParaEditar?.usuarioId ?? '',
                        referenciaId: _referenciaIdSelecionada!,
                        tipoReferencia: _tipoReferenciaSelecionado,
                        diasAntes: _diasAntes,
                        notificarNoDia: _notificarNoDia,
                        ativo: widget.lembreteParaEditar?.ativo ?? true,
                        concluido: widget.lembreteParaEditar?.concluido ?? false,
                        dataCriacao: widget.lembreteParaEditar?.dataCriacao ?? DateTime.now(),
                        horario: _horario,
                        minuto: _minuto,
                      );
                      widget.onSalvar(lembrete);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}