import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meachou/providers/app_drawer_provider.dart';

class CustomDrawer extends StatelessWidget {
  final bool isOpen;
  final VoidCallback toggleDrawer;

  const CustomDrawer({
    required this.isOpen,
    required this.toggleDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              // Lógica de logout aqui, usando o provider se necessário
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
