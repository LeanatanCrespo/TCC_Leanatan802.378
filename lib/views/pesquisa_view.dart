import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../controllers/despesa_controller.dart';
import '../controllers/receita_controller.dart';
import '../controllers/tipo_controller.dart';
import '../models/despesa.dart';
import '../models/receita.dart';
import '../models/tipo.dart';

class PesquisaView extends StatefulWidget {
  const PesquisaView({super.key});

  @override
  State<PesquisaView> createState() => _PesquisaViewState();
}

class _PesquisaViewState extends State<PesquisaView> {
  final DespesaController _despesaController = DespesaController();
  final ReceitaController _receitaController = ReceitaController();
  final TipoController _tipoController = TipoController();

  final TextEditingController _searchController = TextEditingController();

  // Filtros
  String _filtroTipoLancamento = 'Todos'; // Todos | Despesa | Receita
  List<String> _tiposSelecionados = [];
  int? _prioridadeMin;
  int? _prioridadeMax;
  double? _valorMin;
  double? _valorMax;
  DateTime? _filtroDataInicio;
  DateTime? _filtroDataFim;

  // Ordenação
  String _ordenacao = 'data_desc'; // data_desc, data_asc, valor_desc, valor_asc, nome_asc, nome_desc, prioridade_desc, prioridade_asc

  List<Tipo> _todosOsTipos = [];

  @override
  void initState() {
    super.initState();
    _carregarTipos();
  }

  void _carregarTipos() {
    _tipoController.listarTipos().listen((tipos) {
      setState(() => _todosOsTipos = tipos);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataInicio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _filtroDataInicio ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() => _filtroDataInicio = data);
    }
  }

  Future<void> _selecionarDataFim() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _filtroDataFim ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() => _filtroDataFim = data);
    }
  }

  void _limparFiltros() {
    setState(() {
      _searchController.clear();
      _filtroTipoLancamento = 'Todos';
      _tiposSelecionados.clear();
      _prioridadeMin = null;
      _prioridadeMax = null;
      _valorMin = null;
      _valorMax = null;
      _filtroDataInicio = null;
      _filtroDataFim = null;
      _ordenacao = 'data_desc';
    });
  }

  void _mostrarFiltrosAvancados() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _FiltrosAvancados(
          todosOsTipos: _todosOsTipos,
          tiposSelecionados: _tiposSelecionados,
          prioridadeMin: _prioridadeMin,
          prioridadeMax: _prioridadeMax,
          valorMin: _valorMin,
          valorMax: _valorMax,
          onAplicar: (tipos, priMin, priMax, valMin, valMax) {
            setState(() {
              _tiposSelecionados = tipos;
              _prioridadeMin = priMin;
              _prioridadeMax = priMax;
              _valorMin = valMin;
              _valorMax = valMax;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            onPressed: _limparFiltros,
            tooltip: 'Limpar filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                hintText: 'Digite para buscar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchController.clear());
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Chips de filtros ativos
          if (_tiposSelecionados.isNotEmpty ||
              _prioridadeMin != null ||
              _valorMin != null ||
              _filtroDataInicio != null)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_tiposSelecionados.isNotEmpty)
                    Chip(
                      label: Text('${_tiposSelecionados.length} tipos'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => setState(() => _tiposSelecionados.clear()),
                    ),
                  if (_prioridadeMin != null || _prioridadeMax != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(
                          'Prioridade: ${_prioridadeMin ?? 0}-${_prioridadeMax ?? '∞'}',
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() {
                          _prioridadeMin = null;
                          _prioridadeMax = null;
                        }),
                      ),
                    ),
                  if (_valorMin != null || _valorMax != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(
                          'Valor: R\$ ${_valorMin?.toStringAsFixed(0) ?? 0}-${_valorMax?.toStringAsFixed(0) ?? '∞'}',
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() {
                          _valorMin = null;
                          _valorMax = null;
                        }),
                      ),
                    ),
                  if (_filtroDataInicio != null || _filtroDataFim != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(
                          'Período: ${_filtroDataInicio != null ? '${_filtroDataInicio!.day}/${_filtroDataInicio!.month}' : '...'} - ${_filtroDataFim != null ? '${_filtroDataFim!.day}/${_filtroDataFim!.month}' : '...'}',
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() {
                          _filtroDataInicio = null;
                          _filtroDataFim = null;
                        }),
                      ),
                    ),
                ],
              ),
            ),

          // Filtros rápidos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Tipo de lançamento
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Todos', label: Text('Todos')),
                      ButtonSegment(value: 'Receita', label: Text('Receitas')),
                      ButtonSegment(value: 'Despesa', label: Text('Despesas')),
                    ],
                    selected: {_filtroTipoLancamento},
                    onSelectionChanged: (value) {
                      setState(() => _filtroTipoLancamento = value.first);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Botão filtros avançados
                IconButton(
                  icon: Badge(
                    isLabelVisible: _tiposSelecionados.isNotEmpty ||
                        _prioridadeMin != null ||
                        _valorMin != null,
                    child: const Icon(Icons.tune),
                  ),
                  onPressed: _mostrarFiltrosAvancados,
                  tooltip: 'Filtros avançados',
                ),
              ],
            ),
          ),

          // Período e Ordenação
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selecionarDataInicio,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _filtroDataInicio == null
                          ? 'Data Início'
                          : '${_filtroDataInicio!.day}/${_filtroDataInicio!.month}/${_filtroDataInicio!.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selecionarDataFim,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _filtroDataFim == null
                          ? 'Data Fim'
                          : '${_filtroDataFim!.day}/${_filtroDataFim!.month}/${_filtroDataFim!.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  tooltip: 'Ordenar',
                  onSelected: (value) => setState(() => _ordenacao = value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'data_desc', child: Text('Data (mais recente)')),
                    const PopupMenuItem(value: 'data_asc', child: Text('Data (mais antiga)')),
                    const PopupMenuItem(value: 'valor_desc', child: Text('Valor (maior)')),
                    const PopupMenuItem(value: 'valor_asc', child: Text('Valor (menor)')),
                    const PopupMenuItem(value: 'nome_asc', child: Text('Nome (A-Z)')),
                    const PopupMenuItem(value: 'nome_desc', child: Text('Nome (Z-A)')),
                    const PopupMenuItem(value: 'prioridade_desc', child: Text('Prioridade (maior)')),
                    const PopupMenuItem(value: 'prioridade_asc', child: Text('Prioridade (menor)')),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Lista de resultados
          Expanded(
            child: StreamBuilder<List<dynamic>>(
              stream: _combineStreams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var dados = snapshot.data ?? [];

                // Aplicar filtros
                dados = _aplicarFiltros(dados);

                // Aplicar ordenação
                dados = _aplicarOrdenacao(dados);

                if (dados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum resultado encontrado',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: dados.length,
                  itemBuilder: (context, index) {
                    final item = dados[index];
                    final isDespesa = item is Despesa;
                    final nome = isDespesa ? item.nome : (item as Receita).nome;
                    final valor = isDespesa ? item.valor : (item as Receita).valor;
                    final prioridade = isDespesa ? item.prioridade : (item as Receita).prioridade;
                    final data = isDespesa ? item.data : (item as Receita).data;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDespesa ? Colors.red : Colors.green,
                          child: Icon(
                            isDespesa ? Icons.arrow_downward : Icons.arrow_upward,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(nome),
                        subtitle: Text(
                          '${isDespesa ? 'Despesa' : 'Receita'} • Prioridade: $prioridade\n'
                          '${data.day}/${data.month}/${data.year}',
                        ),
                        trailing: Text(
                          'R\$ ${valor.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDespesa ? Colors.red : Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<dynamic>> _combineStreams() {
    final despesasStream = _despesaController.listarDespesas();
    final receitasStream = _receitaController.listarReceitas();

    return Rx.combineLatest2<List<Despesa>, List<Receita>, List<dynamic>>(
      despesasStream,
      receitasStream,
      (despesas, receitas) {
        List<dynamic> todos = [];
        if (_filtroTipoLancamento == 'Todos' || _filtroTipoLancamento == 'Despesa') {
          todos.addAll(despesas);
        }
        if (_filtroTipoLancamento == 'Todos' || _filtroTipoLancamento == 'Receita') {
          todos.addAll(receitas);
        }
        return todos;
      },
    );
  }

  List<dynamic> _aplicarFiltros(List<dynamic> dados) {
    return dados.where((item) {
      final nome = item is Despesa ? item.nome : (item as Receita).nome;
      final valor = item is Despesa ? item.valor : (item as Receita).valor;
      final prioridade = item is Despesa ? item.prioridade : (item as Receita).prioridade;
      final data = item is Despesa ? item.data : (item as Receita).data;
      final tiposIds = item is Despesa ? item.tiposIds : (item as Receita).tiposIds;

      // Filtro por nome
      final pesquisa = _searchController.text.trim().toLowerCase();
      if (pesquisa.isNotEmpty && !nome.toLowerCase().contains(pesquisa)) {
        return false;
      }

      // Filtro por tipos
      if (_tiposSelecionados.isNotEmpty) {
        final temTipoSelecionado = _tiposSelecionados.any((t) => tiposIds.contains(t));
        if (!temTipoSelecionado) return false;
      }

      // Filtro por prioridade
      if (_prioridadeMin != null && prioridade < _prioridadeMin!) return false;
      if (_prioridadeMax != null && prioridade > _prioridadeMax!) return false;

      // Filtro por valor
      if (_valorMin != null && valor < _valorMin!) return false;
      if (_valorMax != null && valor > _valorMax!) return false;

      // Filtro por data
      if (_filtroDataInicio != null && data.isBefore(_filtroDataInicio!)) return false;
      if (_filtroDataFim != null && data.isAfter(_filtroDataFim!)) return false;

      return true;
    }).toList();
  }

  List<dynamic> _aplicarOrdenacao(List<dynamic> dados) {
    dados.sort((a, b) {
      switch (_ordenacao) {
        case 'data_desc':
          final dataA = a is Despesa ? a.data : (a as Receita).data;
          final dataB = b is Despesa ? b.data : (b as Receita).data;
          return dataB.compareTo(dataA);
        case 'data_asc':
          final dataA = a is Despesa ? a.data : (a as Receita).data;
          final dataB = b is Despesa ? b.data : (b as Receita).data;
          return dataA.compareTo(dataB);
        case 'valor_desc':
          final valorA = a is Despesa ? a.valor : (a as Receita).valor;
          final valorB = b is Despesa ? b.valor : (b as Receita).valor;
          return valorB.compareTo(valorA);
        case 'valor_asc':
          final valorA = a is Despesa ? a.valor : (a as Receita).valor;
          final valorB = b is Despesa ? b.valor : (b as Receita).valor;
          return valorA.compareTo(valorB);
        case 'nome_asc':
          final nomeA = a is Despesa ? a.nome : (a as Receita).nome;
          final nomeB = b is Despesa ? b.nome : (b as Receita).nome;
          return nomeA.compareTo(nomeB);
        case 'nome_desc':
          final nomeA = a is Despesa ? a.nome : (a as Receita).nome;
          final nomeB = b is Despesa ? b.nome : (b as Receita).nome;
          return nomeB.compareTo(nomeA);
        case 'prioridade_desc':
          final prioA = a is Despesa ? a.prioridade : (a as Receita).prioridade;
          final prioB = b is Despesa ? b.prioridade : (b as Receita).prioridade;
          return prioB.compareTo(prioA);
        case 'prioridade_asc':
          final prioA = a is Despesa ? a.prioridade : (a as Receita).prioridade;
          final prioB = b is Despesa ? b.prioridade : (b as Receita).prioridade;
          return prioA.compareTo(prioB);
        default:
          return 0;
      }
    });
    return dados;
  }
}

// Widget de Filtros Avançados
class _FiltrosAvancados extends StatefulWidget {
  final List<Tipo> todosOsTipos;
  final List<String> tiposSelecionados;
  final int? prioridadeMin;
  final int? prioridadeMax;
  final double? valorMin;
  final double? valorMax;
  final Function(List<String>, int?, int?, double?, double?) onAplicar;

  const _FiltrosAvancados({
    required this.todosOsTipos,
    required this.tiposSelecionados,
    required this.prioridadeMin,
    required this.prioridadeMax,
    required this.valorMin,
    required this.valorMax,
    required this.onAplicar,
  });

  @override
  State<_FiltrosAvancados> createState() => _FiltrosAvancadosState();
}

class _FiltrosAvancadosState extends State<_FiltrosAvancados> {
  late List<String> _tiposSelecionados;
  final _prioridadeMinController = TextEditingController();
  final _prioridadeMaxController = TextEditingController();
  final _valorMinController = TextEditingController();
  final _valorMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tiposSelecionados = List.from(widget.tiposSelecionados);
    _prioridadeMinController.text = widget.prioridadeMin?.toString() ?? '';
    _prioridadeMaxController.text = widget.prioridadeMax?.toString() ?? '';
    _valorMinController.text = widget.valorMin?.toString() ?? '';
    _valorMaxController.text = widget.valorMax?.toString() ?? '';
  }

  @override
  void dispose() {
    _prioridadeMinController.dispose();
    _prioridadeMaxController.dispose();
    _valorMinController.dispose();
    _valorMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros Avançados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                // Tipos
                const Text('Tipos', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (widget.todosOsTipos.isEmpty)
                  const Text('Nenhum tipo cadastrado', style: TextStyle(color: Colors.grey))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.todosOsTipos.map((tipo) {
                      final selecionado = _tiposSelecionados.contains(tipo.id);
                      return FilterChip(
                        label: Text(tipo.nome),
                        selected: selecionado,
                        onSelected: (_) {
                          setState(() {
                            if (selecionado) {
                              _tiposSelecionados.remove(tipo.id);
                            } else {
                              _tiposSelecionados.add(tipo.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),

                // Prioridade
                const Text('Prioridade', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _prioridadeMinController,
                        decoration: const InputDecoration(
                          labelText: 'Mínima',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _prioridadeMaxController,
                        decoration: const InputDecoration(
                          labelText: 'Máxima',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Valor
                const Text('Valor (R\$)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _valorMinController,
                        decoration: const InputDecoration(
                          labelText: 'Mínimo',
                          border: OutlineInputBorder(),
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _valorMaxController,
                        decoration: const InputDecoration(
                          labelText: 'Máximo',
                          border: OutlineInputBorder(),
                          prefixText: 'R\$ ',
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onAplicar(
                  _tiposSelecionados,
                  int.tryParse(_prioridadeMinController.text),
                  int.tryParse(_prioridadeMaxController.text),
                  double.tryParse(_valorMinController.text),
                  double.tryParse(_valorMaxController.text),
                );
              },
              child: const Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }
}