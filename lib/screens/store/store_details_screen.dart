import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meachou/services/stores_service.dart';

class StoreProfileScreen extends StatefulWidget {
  final String storeId;

  const StoreProfileScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  _StoreProfileScreenState createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  Map<String, dynamic>? store;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchStoreDetails();
  }

  Future<void> _fetchStoreDetails() async {
    try {
      final storeDetails = await StoreService().getStoreDetails(widget.storeId);
      setState(() {
        store = storeDetails;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Falha ao carregar os detalhes da loja';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5),
        body: Stack(
          children: [
            const Center(
              child: LoadingDots(),
            ),
            Center(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(errorMessage)),
      );
    }

    if (store == null) {
      return const Scaffold(
        body: Center(child: Text('Dados da loja incompletos')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildBusinessInfo(),
            const SizedBox(height: 16),
            _buildExpandableContactInfo(context),
            const SizedBox(height: 16),
            _buildSocialNetworksSection(context),
            const SizedBox(height: 16),
            _buildWorkingHoursAndServicesSection(context),
            const SizedBox(height: 16),
            _buildPhotosSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              store!['company_name'] ?? 'Nome não disponível',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildProfileHeader(),
          ),
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _showImageDialog(
                store!['profile_picture'] ?? 'assets/default_avatar.png');
          },
          child: CircleAvatar(
            radius: 50,
            backgroundImage: store!['profile_picture'] != null
                ? NetworkImage(store!['profile_picture'])
                : const AssetImage('assets/default_avatar.png')
                    as ImageProvider,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store!['company_name'] ?? 'Nome não disponível',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                store!['business_sector'] ?? 'Setor não disponível',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              _buildStarRating(store!['ranking']?.toDouble() ?? 0.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(double ranking) {
    int fullStars = ranking.floor();
    bool hasHalfStar = (ranking - fullStars) >= 0.5;

    return Row(
      children: List.generate(7, (index) {
        if (index < fullStars) {
          return const Icon(
            Icons.star,
            color: Colors.yellow,
            size: 20,
          );
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(
            Icons.star_half,
            color: Colors.yellow,
            size: 20,
          );
        } else {
          return const Icon(
            Icons.star_border,
            color: Colors.yellow,
            size: 20,
          );
        }
      }),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Publicações', '120'),
          _buildStatItem('Avaliações', '4.5K'),
          _buildStatItem('Seguidores', '2.3K'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: GoogleFonts.lato(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildBusinessInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sobre a Empresa',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                store!['about'] ?? 'O lojista não forneceu mais detalhes...',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableContactInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              'Informações de Contato',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            children: [
              _buildProfileDetail(
                icon: FontAwesomeIcons.phone,
                value: store!['contact_phone'] ?? 'Não disponível',
                onTap: () => _launchURL(
                    'tel:${_cleanPhoneNumber(store!['contact_phone'])}'),
              ),
              _buildProfileDetail(
                icon: FontAwesomeIcons.whatsapp,
                value: store!['whatsapp_phone'] ?? 'Não disponível',
                onTap: () => _launchURL(
                    'https://wa.me/${_cleanPhoneNumber(store!['whatsapp_phone'])}?text=Olá'),
              ),
              _buildProfileDetail(
                icon: FontAwesomeIcons.link,
                value: store!['website'] ?? 'Não disponível',
                onTap: () => _launchURL(_formatURL(store!['website'])),
              ),
              _buildProfileDetail(
                icon: FontAwesomeIcons.envelope,
                value: store!['email'] ?? 'Não disponível',
                onTap: () => _launchURL('mailto:${store!['email']}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialNetworksSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              'Redes Sociais',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            children: (store!['social_networks'] as List<dynamic>)
                .map((network) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.4, vertical: 7.2),
                      child: _buildSocialNetworkLink(_cleanURL(network['url'])),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialNetworkLink(String url) {
    IconData icon;
    if (url.contains('facebook')) {
      icon = FontAwesomeIcons.facebook;
    } else if (url.contains('linkedin')) {
      icon = FontAwesomeIcons.linkedin;
    } else if (url.contains('instagram')) {
      icon = FontAwesomeIcons.instagram;
    } else if (url.contains('twitter')) {
      icon = FontAwesomeIcons.twitter;
    } else {
      icon = FontAwesomeIcons.globe;
    }

    return InkWell(
      onTap: () => _launchURL(url),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              url,
              style: GoogleFonts.lato(
                fontSize: 14.4,
                color: Colors.blueAccent,
                decoration: TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursAndServicesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              'Horário e Serviços',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horário de Funcionamento',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      store!['working_hours'] ?? 'Horário não disponível',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              _buildServiceDetail(
                icon: FontAwesomeIcons.truck,
                label: 'Delivery',
                value:
                    store!['delivery'] == true ? 'Disponível' : 'Indisponível',
                available: store!['delivery'] == true,
              ),
              _buildServiceDetail(
                icon: FontAwesomeIcons.home,
                label: 'Atendimento em Casa',
                value: store!['in_home_service'] == true
                    ? 'Disponível'
                    : 'Indisponível',
                available: store!['in_home_service'] == true,
              ),
              _buildServiceDetail(
                icon: FontAwesomeIcons.dollarSign,
                label: 'Valor do Serviço',
                value: 'R\$ ${store!['service_values']}',
                available: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDetail({
    required IconData icon,
    required String label,
    required String value,
    bool available = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: available ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              available ? Icons.check : Icons.close,
              color: Colors.white,
              size: 7,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              color: available ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    if (store!['photos'] == null || store!['photos'].isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> photoWidgets = store!['photos'].map<Widget>((photo) {
      return GestureDetector(
        onTap: () {
          _showImageDialog(photo['url']);
        },
        child: Container(
          padding: const EdgeInsets.all(1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photo['url'],
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fotos',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: photoWidgets,
          ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetail({
    required IconData icon,
    required String value,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7.2, horizontal: 14.4),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 18),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 12.6,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 9),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.blueAccent, size: 14.4),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir URL: $e')),
      );
    }
  }

  String _cleanURL(String url) {
    return url.replaceAll(RegExp(r'[\"\r\n]'), '').trim();
  }

  String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'\s+'), '');
  }

  String _formatURL(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'http://$url';
    }
    return url;
  }
}
