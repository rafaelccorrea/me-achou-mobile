import 'package:flutter/material.dart';
import 'package:meachou/components/placeholder_widget.dart';
import 'package:meachou/providers/app_drawer_provider.dart';
import 'package:meachou/screens/followers_screen.dart';
import 'package:meachou/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:meachou/components/custom_app_bar.dart';
import 'package:meachou/components/custom_bottom_navigation_bar.dart';
import 'package:meachou/components/home_content.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  Map<String, dynamic>? _filters;

  final List<Widget> _pages = [
    HomeContent(),
    PlaceholderWidget('Publicações'),
    FollowersScreen(),
    PlaceholderWidget('Avaliações'),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<DrawerProvider>(context, listen: false).scaffoldKey =
        _scaffoldKey;
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      _scaffoldKey.currentState?.openDrawer();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FollowersScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onFilter(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
      _pages[0] = HomeContent(filters: _filters);
    });
    print('Filters applied: $filters');
  }

  void _onClearFilters() {
    setState(() {
      _filters = null;
      _pages[0] = HomeContent(filters: _filters);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          key: _scaffoldKey,
          appBar: _selectedIndex == 0
              ? CustomAppBar(
                  onFilter: _onFilter,
                  onClearFilters: _onClearFilters,
                  initialFilters: _filters ?? {},
                )
              : null,
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
          drawer: CustomDrawer(
            isOpen: _scaffoldKey.currentState?.isDrawerOpen ?? false,
            toggleDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            userName: name,
            userAvatarUrl: avatar,
          ),
        );
      },
    );
  }
}
