import 'package:flutter/material.dart';
import 'package:meachou/components/placeholder_widget.dart';
import 'package:provider/provider.dart';
import 'package:meachou/providers/app_drawer_provider.dart';
import 'package:meachou/components/custom_app_bar.dart';
import 'package:meachou/components/custom_bottom_navigation_bar.dart';
import 'package:meachou/components/home_content.dart';
import 'package:meachou/widgets/custom_drawer.dart';
import 'package:meachou/services/auth_service.dart'; // Importe o serviço de autenticação

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    PlaceholderWidget('Publicações'),
    PlaceholderWidget('Favoritos'),
    PlaceholderWidget('Avaliações'),
    PlaceholderWidget('Perfil'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appDrawerProvider = Provider.of<AppDrawerProvider>(context);
    final AuthService authService = Provider.of<AuthService>(
        context); // Use o Provider para obter o serviço AuthService

    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getUser(), // Chame o método para obter o usuário
      builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Carregando...'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Erro'),
            ),
            body: Center(
              child: Text('Ocorreu um erro ao carregar os dados do usuário.'),
            ),
          );
        }

        final user = snapshot.data!;
        final avatar = user['avatar'];
        final name = user['name'];

        return Scaffold(
          appBar: CustomAppBar(
            name, // Passa o nome do usuário
            avatar, // Passa a URL do avatar do usuário
          ),
          drawer: CustomDrawer(
            isOpen: appDrawerProvider.isOpen,
            toggleDrawer: () => appDrawerProvider.toggleDrawer(),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        );
      },
    );
  }
}
