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
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop(); // Fechar o drawer
                  },
                ),
              ),
            ),
            Container(
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
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8), // Add bottom padding
                ],
              ),
            ),
            Divider(color: Colors.grey[300], thickness: 0.5),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.person,
                      text: 'Meu Perfil',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.star_rate,
                      text: 'Avaliações',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.article,
                      text: 'Publicações',
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.group,
                      text: 'Seguindo',
                    ),
                    _buildExpansionTileWithoutBorder(
                      context,
                      icon: Icons.store,
                      text: 'Minha Loja',
                      children: [
                        _buildDrawerSubItem(
                          context,
                          icon: Icons.person_outline,
                          text: 'Perfil',
                        ),
                        _buildDrawerSubItem(
                          context,
                          icon: Icons.article_outlined,
                          text: 'Publicações',
                        ),
                        _buildDrawerSubItem(
                          context,
                          icon: Icons.subscriptions,
                          text: 'Assinatura',
                        ),
                        _buildDrawerSubItem(
                          context,
                          icon: Icons.rate_review,
                          text: 'Avaliações',
                        ),
                        _buildDrawerSubItem(
                          context,
                          icon: Icons.campaign,
                          text: 'Campanhas',
                        ),
                        _buildDrawerSubItem(
                          context,
                          icon: Icons.event,
                          text: 'Eventos',
                        ),
                        _buildDrawerSubItem(
                          context,
                          icon: Icons.payment,
                          text: 'Cobranças',
                        ),
                        _buildDrawerSubItem(
                          context,
                          icon: Icons.receipt,
                          text: 'Faturas',
                        ),
                      ],
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.event_available,
                      text: 'Eventos',
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.grey[300], thickness: 0.5),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.black),
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

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String text}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: TextStyle(color: Colors.black),
        ),
        onTap: () {
          // Navegar para a tela correspondente
        },
      ),
    );
  }

  Widget _buildDrawerSubItem(BuildContext context,
      {required IconData icon, required String text}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: TextStyle(color: Colors.black),
        ),
        onTap: () {
          // Navegar para a tela correspondente
        },
      ),
    );
  }

  Widget _buildExpansionTileWithoutBorder(BuildContext context,
      {required IconData icon,
      required String text,
      required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: TextStyle(color: Colors.black),
        ),
        childrenPadding: const EdgeInsets.only(left: 16.0),
        children: children,
      ),
    );
  }
}
