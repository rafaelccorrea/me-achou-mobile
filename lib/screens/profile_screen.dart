import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'settings_screen.dart'; // Adicionar a importação da nova tela

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    const secureStorage = FlutterSecureStorage();
    try {
      final userJson = await secureStorage.read(key: 'user');
      if (userJson != null) {
        final userDetails = jsonDecode(userJson) as Map<String, dynamic>;
        setState(() {
          user = userDetails;
          isLoading = false;
        });
      } else {
        throw Exception(
            'Nenhum dado do usuário encontrado no armazenamento seguro');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Falha ao carregar os detalhes do usuário';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(errorMessage)),
      );
    }

    if (user == null || user!['name'] == null || user!['email'] == null) {
      return const Scaffold(
        body: Center(child: Text('Dados do usuário incompletos')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user!['avatar'] != null
                          ? NetworkImage(user!['avatar'])
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user!['name'] ?? 'Nome não disponível',
                      style: GoogleFonts.lato(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user!['email'] ?? 'Email não disponível',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProfileStat(
                              icon: FontAwesomeIcons.star,
                              value: user!['reviews'].toString(),
                              label: 'Avaliações',
                            ),
                            _buildDivider(),
                            _buildProfileStat(
                              icon: FontAwesomeIcons.thumbsUp,
                              value: user!['likes'].toString(),
                              label: 'Curtidas',
                            ),
                            _buildDivider(),
                            _buildProfileStat(
                              icon: FontAwesomeIcons.comment,
                              value: user!['comments'].toString(),
                              label: 'Comentários',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (user!['store'] != null)
                      Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            FontAwesomeIcons.store,
                            color: Colors.blueAccent,
                          ),
                          title: Text(
                            user!['store']['company_name'],
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user!['store']['subscription'] != null &&
                                        user!['store']['subscription']
                                                ['status'] ==
                                            'ACTIVE'
                                    ? FontAwesomeIcons.checkCircle
                                    : FontAwesomeIcons.timesCircle,
                                color: user!['store']['subscription'] != null &&
                                        user!['store']['subscription']
                                                ['status'] ==
                                            'ACTIVE'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user!['store']['subscription'] != null &&
                                        user!['store']['subscription']
                                                ['status'] ==
                                            'ACTIVE'
                                    ? 'Ativado'
                                    : 'Inativo',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      user!['store']['subscription'] != null &&
                                              user!['store']['subscription']
                                                      ['status'] ==
                                                  'ACTIVE'
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  _buildOption(FontAwesomeIcons.bell, 'Notificações'),
                  _buildOption(FontAwesomeIcons.history, 'Histórico'),
                  _buildOption(FontAwesomeIcons.cog, 'Configurações', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(
      {required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      child: const VerticalDivider(
        color: Colors.grey,
        thickness: 1,
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
      ),
      onTap: onTap ?? () {},
    );
  }
}
