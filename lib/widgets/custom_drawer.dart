import 'package:flutter/material.dart';
import 'package:meachou/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:meachou/services/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  final bool isOpen;
  final VoidCallback toggleDrawer;
  final String userName;
  final String? userAvatarUrl;

  const CustomDrawer({
    required this.isOpen,
    required this.toggleDrawer,
    required this.userName,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    AuthService authService = Provider.of<AuthService>(context, listen: false);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fechar o drawer
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10), // Add top padding
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: userAvatarUrl != null
                        ? NetworkImage(userAvatarUrl!)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8), // Add bottom padding
                ],
              ),
            ),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                'Home',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // Add other drawer items here
            const Spacer(),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await authService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
