import 'package:flutter/material.dart';
import 'package:tcc2025_leanatan/views/perfil_view.dart';
import 'receita_view.dart';
import 'despesa_view.dart';
import 'lembretes_view.dart';
import 'pesquisa_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _paginaAtual = 0;

  final List<Widget> _telas = [
    const Center(child: Text('Home')), // Pode exibir resumo de saldo
    const ReceitasView(),
    const DespesasView(),
    const LembretesView(),
    const PerfilView(),
    const PesquisaView(),
  ];

  void _selecionarPagina(int index) {
    setState(() {
      _paginaAtual = index;
      Navigator.pop(context); // Fecha o Drawer ao selecionar
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
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
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
              leading: const Icon(Icons.circle),
              title: const Text('Pesquisar'),
              onTap: () => _selecionarPagina(5),
            ),
          ],
        ),
      ),
      body: _telas[_paginaAtual],
    );
  }
}