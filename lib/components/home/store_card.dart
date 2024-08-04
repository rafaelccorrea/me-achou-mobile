import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:meachou/screens/store/store_details_screen.dart';
import 'package:shimmer/shimmer.dart';

class StoreCard extends StatelessWidget {
  final Map<String, dynamic> store;
  final bool isOwnStore;
  final Function followStore;
  final Function unfollowStore;
  final Map<String, ConfettiController> confettiControllers;

  StoreCard({
    required this.store,
    required this.isOwnStore,
    required this.followStore,
    required this.unfollowStore,
    required this.confettiControllers,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreProfileScreen(storeId: store['id']),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: store['profile_picture'] != null
                    ? Image.network(
                        store['profile_picture'],
                        fit: BoxFit.cover,
                        width: 68.0,
                        height: 68.0,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 68.0,
                                height: 68.0,
                                color: Colors.grey[300],
                              ),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person,
                              size: 34, color: Colors.white);
                        },
                      )
                    : const Icon(Icons.person, size: 34, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store['company_name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRegion(store['address']['region']) ??
                        'Região não especificada',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStarRating(store['ranking'].toDouble()),
                  const SizedBox(
                      height: 4), // Add space between stars and review count
                  Text(
                    '(${store['reviewCount']} avaliações)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                if (store['isFollowed'] == true) {
                  unfollowStore(store['id']);
                } else {
                  followStore(store['id']);
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    store['isFollowed'] == true || isOwnStore
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: store['isFollowed'] == true || isOwnStore
                        ? Colors.red
                        : null,
                  ),
                  if (confettiControllers[store['id']] != null)
                    ConfettiWidget(
                      confettiController: confettiControllers[store['id']]!,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.1,
                      numberOfParticles: 10,
                      maxBlastForce: 20,
                      minBlastForce: 5,
                      gravity: 0.1,
                      colors: const [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.blue,
                        Colors.green
                      ],
                      shouldLoop: false,
                      particleDrag: 0.05,
                      child: const Icon(
                        Icons.star,
                        color: Colors.transparent,
                        size: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _formatRegion(String? region) {
    if (region == null) return null;
    List<String> parts = region.split('_');
    return parts
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _buildStarRating(double ranking) {
    int fullStars = ranking.floor();
    bool hasHalfStar = (ranking - fullStars) >= 0.5;

    return Row(
      children: List.generate(7, (index) {
        // Adjusted to 7 stars
        if (index < fullStars) {
          return const Icon(
            Icons.star,
            color: Colors.yellow,
            size: 16,
          );
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(
            Icons.star_half,
            color: Colors.yellow,
            size: 16,
          );
        } else {
          return const Icon(
            Icons.star_border,
            color: Colors.yellow,
            size: 16,
          );
        }
      }),
    );
  }
}
