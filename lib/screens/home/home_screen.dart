import 'package:flutter/material.dart';
import 'package:meachou/components/placeholder_widget.dart';
import 'package:provider/provider.dart';
import 'package:meachou/providers/app_drawer_provider.dart';
import 'package:meachou/components/custom_app_bar.dart';
import 'package:meachou/components/custom_bottom_navigation_bar.dart';
import 'package:meachou/components/home_content.dart';
import 'package:meachou/widgets/custom_drawer.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeContent(),
    PlaceholderWidget('Publicações'),
    PlaceholderWidget('Seguindo'),
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
    final AuthService authService = Provider.of<AuthService>(context);

    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getUser(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Carregando...'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          authService.logout();

          WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Erro'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data!;
        final avatar = user['avatar'];
        final name = user['name'];

        return Scaffold(
          appBar: const CustomAppBar(),
          endDrawer: CustomDrawer(
            isOpen: appDrawerProvider.isOpen,
            toggleDrawer: () => appDrawerProvider.toggleDrawer(),
            userName: name,
            userAvatarUrl: avatar,
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
