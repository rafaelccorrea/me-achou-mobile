import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 80,
            height: 180,
            child: store['profile_picture'] != null
                ? Image.network(
                    store['profile_picture'],
                    width: 80,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    'https://www.logodesignlove.com/wp-content/uploads/2023/10/playstation-logo-01.jpeg',
                    width: 80,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(
          store['company_name'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store['address']['region'] ?? 'Região não especificada',
                style: const TextStyle(fontSize: 14)),
            _buildStarRating(store['ranking']),
            const SizedBox(height: 4),
            Text(
              '(${store['reviewCount']} avaliações)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: GestureDetector(
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
                  blastDirectionality:
                      BlastDirectionality.explosive, // Explosive effect
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
                  particleDrag: 0.05, // Control the speed of the particles
                  child: const Icon(
                    Icons.star,
                    color: Colors.transparent,
                    size: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(int ranking) {
    return Row(
      children: List.generate(7, (index) {
        return Icon(
          index < ranking ? Icons.star : Icons.star_border,
          color: Colors.yellow,
          size: 16,
        );
      }),
    );
  }
}
