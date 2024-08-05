import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreProfileHeader extends StatelessWidget {
  final Map<String, dynamic> store;
  final Function(String) onTapProfilePicture;

  const StoreProfileHeader({
    Key? key,
    required this.store,
    required this.onTapProfilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              store['company_name'] ?? 'Nome não disponível',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: ProfileHeader(
                store: store,
                onTap: onTapProfilePicture,
              ),
            ),
          ),
          Stats(
            publicationCount: store['publicationCount'],
            reviewCount: store['reviewCount'],
            followerCount: store['followerCount'],
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> store;
  final Function(String) onTap;

  const ProfileHeader({
    Key? key,
    required this.store,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () =>
              onTap(store['profile_picture'] ?? 'assets/default_avatar.png'),
          child: ClipOval(
            child: ProfilePicture(store: store),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store['company_name'] ?? 'Nome não disponível',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                store['business_sector'] ?? 'Setor não disponível',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              StarRating(ranking: store['ranking']?.toDouble() ?? 0.0),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfilePicture extends StatelessWidget {
  final Map<String, dynamic> store;

  const ProfilePicture({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return store['profile_picture'] != null
        ? Image.network(
            store['profile_picture'],
            fit: BoxFit.cover,
            width: 100.0,
            height: 100.0,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    color: Colors.grey[300],
                  ),
                );
              }
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, size: 50, color: Colors.white);
            },
          )
        : const Icon(Icons.person, size: 50, color: Colors.white);
  }
}

class StarRating extends StatelessWidget {
  final double ranking;

  const StarRating({Key? key, required this.ranking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class Stats extends StatelessWidget {
  final int publicationCount;
  final int reviewCount;
  final int followerCount;

  const Stats({
    Key? key,
    required this.publicationCount,
    required this.reviewCount,
    required this.followerCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StatItem(label: 'Publicações', count: publicationCount),
            StatItem(label: 'Avaliações', count: reviewCount),
            StatItem(label: 'Seguidores', count: followerCount),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final int count;

  const StatItem({Key? key, required this.label, required this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: count),
          duration: const Duration(seconds: 2),
          builder: (BuildContext context, int value, Widget? child) {
            return Text(
              value.toString(),
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class BusinessInfoCard extends StatelessWidget {
  final Map<String, dynamic> store;

  const BusinessInfoCard({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                width: double.infinity,
                child: Text(
                  store['about']?.isNotEmpty == true
                      ? store['about']
                      : 'O lojista não forneceu mais detalhes...',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactInfoCard extends StatelessWidget {
  final Map<String, dynamic> store;
  final Function(String) onTap;

  const ContactInfoCard({
    Key? key,
    required this.store,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              'Informações de Contato',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            children: [
              if (store['contact_phone']?.isNotEmpty == true)
                ProfileDetail(
                  icon: FontAwesomeIcons.phone,
                  value: store['contact_phone']!,
                  onTap: () => onTap(
                      'tel:${_cleanPhoneNumber(store['contact_phone']!)}'),
                ),
              if (store['whatsapp_phone']?.isNotEmpty == true)
                ProfileDetail(
                  icon: FontAwesomeIcons.whatsapp,
                  value: store['whatsapp_phone']!,
                  onTap: () => onTap(
                      'https://wa.me/${_cleanPhoneNumber(store['whatsapp_phone']!)}?text=Olá'),
                ),
              if (store['website']?.isNotEmpty == true)
                ProfileDetail(
                  icon: FontAwesomeIcons.link,
                  value: store['website']!,
                  onTap: () => onTap(_formatURL(store['website']!)),
                ),
              if (store['email']?.isNotEmpty == true)
                ProfileDetail(
                  icon: FontAwesomeIcons.envelope,
                  value: store['email']!,
                  onTap: () => onTap('mailto:${store['email']}'),
                ),
            ],
          ),
        ),
      ),
    );
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

class SocialNetworksCard extends StatelessWidget {
  final Map<String, dynamic> store;
  final Function(String) onTap;

  const SocialNetworksCard({
    Key? key,
    required this.store,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socialNetworks = store['social_networks'] as List<dynamic>?;

    if (socialNetworks == null || socialNetworks.isEmpty) {
      return const SizedBox.shrink();
    }

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
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              'Redes Sociais',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            children: socialNetworks
                .map((network) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14.4, vertical: 7.2),
                      child: SocialNetworkLink(
                          url: _cleanURL(network['url']), onTap: onTap),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  String _cleanURL(String url) {
    return url.replaceAll(RegExp(r'[\"\r\n]'), '').trim();
  }
}

class SocialNetworkLink extends StatelessWidget {
  final String url;
  final Function(String) onTap;

  const SocialNetworkLink({
    Key? key,
    required this.url,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      onTap: () => onTap(url),
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
}

class WorkingHoursAndServicesCard extends StatelessWidget {
  final Map<String, dynamic> store;

  const WorkingHoursAndServicesCard({Key? key, required this.store})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      store['working_hours'] ?? 'Horário não disponível',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              ServiceDetail(
                icon: FontAwesomeIcons.truck,
                label: 'Delivery',
                value:
                    store['delivery'] == true ? 'Disponível' : 'Indisponível',
                available: store['delivery'] == true,
              ),
              ServiceDetail(
                icon: FontAwesomeIcons.home,
                label: 'Atendimento em Casa',
                value: store['in_home_service'] == true
                    ? 'Disponível'
                    : 'Indisponível',
                available: store['in_home_service'] == true,
              ),
              if (store['service_values'] != null &&
                  store['service_values'] != 'NaN')
                ServiceDetail(
                  icon: FontAwesomeIcons.dollarSign,
                  label: 'Valor do Serviço',
                  value: 'R\$ ${store['service_values']}',
                  available: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool available;

  const ServiceDetail({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.available = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class PhotosSection extends StatelessWidget {
  final Map<String, dynamic> store;
  final Function(String) onTap;

  const PhotosSection({
    Key? key,
    required this.store,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (store['photos'] == null || store['photos'].isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> photoWidgets = store['photos'].map<Widget>((photo) {
      return GestureDetector(
        onTap: () => onTap(photo['url']),
        child: Container(
          padding: const EdgeInsets.all(1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photo['url'],
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white,
                    ),
                  );
                }
              },
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
}

class ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String value;
  final Function()? onTap;

  const ProfileDetail({
    Key? key,
    required this.icon,
    required this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class AddressSection extends StatelessWidget {
  final Map<String, dynamic> address;

  const AddressSection({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Endereço',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(FontAwesomeIcons.mapMarkerAlt,
                  color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                '${address['street']}, ${address['address_number']}',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 28), // To align with the first row
              Text(
                '${address['region']}, ${address['city']} - ${address['state']}',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 28), // To align with the first row
              Text(
                '${address['postal_code']}',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
