import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/receita_controller.dart';
import '../controllers/despesa_controller.dart';
import '../controllers/tipo_controller.dart';
import '../controllers/periodo_controller.dart';
import '../models/receita.dart';
import '../models/despesa.dart';
import '../models/tipo.dart';
import '../models/periodo.dart';

import 'perfil_view.dart';
import 'receita_form_view.dart';
import 'despesa_form_view.dart';
import 'lembretes_view.dart';
import 'pesquisa_view.dart';
import 'relatorio_view.dart';
import 'tipos_view.dart';
import 'periodos_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ReceitaController _receitaController = ReceitaController();
  final DespesaController _despesaController = DespesaController();
  final TipoController _tipoController = TipoController();
  final PeriodoController _periodoController = PeriodoController();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<dynamic>> _eventos = {};
  List<Receita> _todasReceitas = [];
  List<Despesa> _todasDespesas = [];
  Map<String, Tipo> _tiposCache = {};
  Map<String, Periodo> _periodosCache = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _carregarDados();
  }

  void _carregarDados() {
    // Escuta mudanças em receitas
    _receitaController.listarReceitas().listen((receitas) {
      setState(() => _todasReceitas = receitas);
      _processarEventos();
    });

    // Escuta mudanças em despesas
    _despesaController.listarDespesas().listen((despesas) {
      setState(() => _todasDespesas = despesas);
      _processarEventos();
    });

    // Carrega tipos para cache
    _tipoController.listarTipos().listen((tipos) {
      setState(() {
        _tiposCache = {for (var t in tipos) t.id: t};
      });
    });

    // Carrega períodos para cache
    _periodoController.listarPeriodos().listen((periodos) {
      setState(() {
        _periodosCache = {for (var p in periodos) p.id: p};
      });
      _processarEventos();
    });
  }

  void _processarEventos() {
    Map<DateTime, List<dynamic>> tempEventos = {};

    // Processar receitas
    for (var receita in _todasReceitas) {
      _adicionarEvento(tempEventos, receita.data, receita);

      // Se tem período, adicionar recorrências
      if (receita.periodoId != null) {
        final periodo = _periodosCache[receita.periodoId];
        if (periodo != null) {
          final dataFinal = DateTime.now().add(const Duration(days: 365));
          final datasRecorrentes =
              periodo.gerarDatasRecorrentes(receita.data, dataFinal);
          for (var data in datasRecorrentes) {
            if (!isSameDay(data, receita.data)) {
              _adicionarEvento(tempEventos, data, receita);
            }
          }
        }
      }
    }

    // Processar despesas
    for (var despesa in _todasDespesas) {
      _adicionarEvento(tempEventos, despesa.data, despesa);

      // Se tem período, adicionar recorrências
      if (despesa.periodoId != null) {
        final periodo = _periodosCache[despesa.periodoId];
        if (periodo != null) {
          final dataFinal = DateTime.now().add(const Duration(days: 365));
          final datasRecorrentes =
              periodo.gerarDatasRecorrentes(despesa.data, dataFinal);
          for (var data in datasRecorrentes) {
            if (!isSameDay(data, despesa.data)) {
              _adicionarEvento(tempEventos, data, despesa);
            }
          }
        }
      }
    }

    setState(() => _eventos = tempEventos);
  }

  void _adicionarEvento(Map<DateTime, List<dynamic>> eventos, DateTime data,
      dynamic item) {
    final dia = DateTime(data.year, data.month, data.day);
    eventos[dia] ??= [];
    eventos[dia]!.add(item);
  }

  List<dynamic> _getEventosDoDia(DateTime day) {
    final dia = DateTime(day.year, day.month, day.day);
    return _eventos[dia] ?? [];
  }

  void _editarItem(dynamic item) {
    if (item is Receita) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceitaFormView(receitaParaEditar: item),
        ),
      );
    } else if (item is Despesa) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DespesaFormView(despesaParaEditar: item),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventosDoDia = _selectedDay != null
        ? _getEventosDoDia(_selectedDay!)
        : <dynamic>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciador Financeiro'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: const Text('Nova Receita'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReceitaFormView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.red),
              title: const Text('Nova Despesa'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DespesaFormView()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.label),
              title: const Text('Gerenciar Tipos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TiposView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Gerenciar Períodos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PeriodosView()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Lembretes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LembretesView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Pesquisar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PesquisaView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Relatórios'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RelatorioView()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PerfilView()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Calendário
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventosDoDia,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox();

                final temReceita =
                    events.any((e) => e is Receita);
                final temDespesa =
                    events.any((e) => e is Despesa);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (temReceita)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (temDespesa)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const Divider(),

          // Lista de eventos do dia
          Expanded(
            child: eventosDoDia.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum evento neste dia',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: eventosDoDia.length,
                    itemBuilder: (context, index) {
                      final item = eventosDoDia[index];
                      final isReceita = item is Receita;
                      final nome = isReceita
                          ? (item as Receita).nome
                          : (item as Despesa).nome;
                      final valor = isReceita
                          ? (item as Receita).valor
                          : (item as Despesa).valor;
                      final prioridade = isReceita
                          ? (item as Receita).prioridade
                          : (item as Despesa).prioridade;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isReceita ? Colors.green : Colors.red,
                            child: Icon(
                              isReceita
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(nome),
                          subtitle: Text(
                            'R\$ ${valor.toStringAsFixed(2)} • Prioridade: $prioridade',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editarItem(item),
                          ),
                          onTap: () => _editarItem(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}