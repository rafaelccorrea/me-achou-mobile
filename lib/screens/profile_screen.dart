import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                      color: Colors.white, // Fundo branco para o card
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
                              value: '6',
                              label: 'Avaliações',
                            ),
                            _buildDivider(),
                            _buildProfileStat(
                              icon: FontAwesomeIcons.thumbsUp,
                              value: '203',
                              label: 'Curtidas',
                            ),
                            _buildDivider(),
                            _buildProfileStat(
                              icon: FontAwesomeIcons.comment,
                              value: '24',
                              label: 'Comentários',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.white, // Fundo branco para o card
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
                          'Magalu',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              FontAwesomeIcons.checkCircle,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ativado',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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
                  _buildOption(FontAwesomeIcons.award, 'Recompensas Microsoft'),
                  _buildOption(FontAwesomeIcons.users, 'Comunidade'),
                  _buildOption(FontAwesomeIcons.cog, 'Configurações'),
                  _buildOption(FontAwesomeIcons.star, 'Interesses'),
                  _buildOption(FontAwesomeIcons.history, 'Histórico'),
                  _buildOption(FontAwesomeIcons.bookmark, 'Favoritos e Salvos'),
                  const SizedBox(height: 24),
                  _buildDeleteAccountButton(),
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

  Widget _buildOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        title,
        style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
      ),
      onTap: () {
        // Ação de navegação
      },
    );
  }

  Widget _buildDeleteAccountButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.redAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      onPressed: () {
        // Lógica para deletar a conta
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.trash, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(
            'Deletar Conta',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
