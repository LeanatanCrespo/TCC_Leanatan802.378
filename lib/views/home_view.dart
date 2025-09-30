import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import 'perfil_view.dart';
import 'receita_view.dart';
import 'despesa_view.dart';
import 'lembretes_view.dart';
import 'pesquisa_view.dart';
import 'relatorio_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _paginaAtual = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Eventos do calendário (datas com receitas/despesas)
  Map<DateTime, List<Map<String, dynamic>>> eventos = {};

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    Map<DateTime, List<Map<String, dynamic>>> tempEventos = {};

    // Buscar Receitas
    final receitasSnapshot =
        await FirebaseFirestore.instance.collection('receitas').get();
    for (var doc in receitasSnapshot.docs) {
      final data = (doc['data'] as Timestamp).toDate();
      final dia = DateTime(data.year, data.month, data.day);

      tempEventos[dia] ??= [];
      tempEventos[dia]!.add({'tipo': 'receita', 'valor': doc['valor']});
    }

    // Buscar Despesas
    final despesasSnapshot =
        await FirebaseFirestore.instance.collection('despesas').get();
    for (var doc in despesasSnapshot.docs) {
      final data = (doc['data'] as Timestamp).toDate();
      final dia = DateTime(data.year, data.month, data.day);

      tempEventos[dia] ??= [];
      tempEventos[dia]!.add({'tipo': 'despesa', 'valor': doc['valor']});
    }

    setState(() {
      eventos = tempEventos;
    });
  }

  List<Map<String, dynamic>> _getEventosDoDia(DateTime day) {
    return eventos[DateTime(day.year, day.month, day.day)] ?? [];
  }

  final List<Widget> _telas = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Atualiza a lista de telas incluindo o calendário na Home
    _telas.clear();
    _telas.addAll([
      _buildCalendario(), // Home com calendário
      const ReceitasView(),
      const DespesasView(),
      const LembretesView(),
      const PerfilView(),
      const PesquisaView(),
      const RelatorioView(),
    ]);
  }

  Widget _buildCalendario() {
    return Column(
      children: [
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
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedDay != null) ...[
          Text(
            "Eventos em ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}:",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._getEventosDoDia(_selectedDay!).map((evento) {
            return ListTile(
              leading: Icon(
                evento['tipo'] == 'receita'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color:
                    evento['tipo'] == 'receita' ? Colors.blue : Colors.red,
              ),
              title: Text(
                "${evento['tipo'].toString().toUpperCase()} - R\$ ${evento['valor']}",
              ),
            );
          }),
        ],
      ],
    );
  }

  void _selecionarPagina(int index) {
    setState(() {
      _paginaAtual = index;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciador Financeiro')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => _selecionarPagina(0),
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Receitas'),
              onTap: () => _selecionarPagina(1),
            ),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('Despesas'),
              onTap: () => _selecionarPagina(2),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Lembretes'),
              onTap: () => _selecionarPagina(3),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () => _selecionarPagina(4),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Pesquisar'),
              onTap: () => _selecionarPagina(5),
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Relatório'),
              onTap: () => _selecionarPagina(6),
            ),
          ],
        ),
      ),
      body: _telas[_paginaAtual],
    );
  }
}
