import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifications = _getDummyNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          FontAwesomeIcons.bell,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Notificações',
                          style: GoogleFonts.lato(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: notifications.isEmpty
                        ? [
                            SvgPicture.asset(
                              'assets/no_notifications.svg',
                              height: 200,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Nenhuma notificação',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ]
                        : notifications
                            .map((notification) =>
                                _buildNotificationItem(notification))
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, String> notification) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          FontAwesomeIcons.bell,
          color: Colors.blueAccent,
        ),
        title: Text(
          notification['title']!,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          notification['body']!,
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        trailing: Text(
          notification['time']!,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getDummyNotifications() {
    return [
      {
        'title': 'Nova mensagem',
        'body': 'Você recebeu uma nova mensagem de João.',
        'time': '2h atrás'
      },
      {
        'title': 'Promoção',
        'body': 'Aproveite a promoção de 50% de desconto.',
        'time': '4h atrás'
      },
      {
        'title': 'Atualização',
        'body': 'O aplicativo foi atualizado para a versão 2.0.',
        'time': '1 dia atrás'
      },
      {
        'title': 'Atualização',
        'body': 'O aplicativo foi atualizado para a versão 1.9.',
        'time': '1 dia atrás'
      },
      {
        'title': 'Atualização',
        'body': 'O aplicativo foi atualizado para a versão 1.8.',
        'time': '1 dia atrás'
      },
      {
        'title': 'Atualização',
        'body': 'O aplicativo foi atualizado para a versão 1.7.',
        'time': '1 dia atrás'
      },
      {
        'title': 'Atualização',
        'body': 'O aplicativo foi atualizado para a versão 1.6.',
        'time': '1 dia atrás'
      },
    ];
  }
}
