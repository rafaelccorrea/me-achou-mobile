import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'store_card.dart';

class StoreList extends StatelessWidget {
  final List<dynamic> stores;
  final String? userStoreId;
  final Function followStore;
  final Function unfollowStore;
  final Map<String, ConfettiController> confettiControllers;

  StoreList({
    required this.stores,
    required this.userStoreId,
    required this.followStore,
    required this.unfollowStore,
    required this.confettiControllers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stores.isNotEmpty)
          const Text(
            'Lojas',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (stores.isNotEmpty) const SizedBox(height: 10),
        if (stores.isEmpty)
          Center(
            child: Column(
              children: [
                const Text(
                  'Nenhuma loja encontrada',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/no_stores.png',
                  width: 200,
                  height: 200,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              final isOwnStore = store['id'] == userStoreId;
              return Stack(
                children: [
                  StoreCard(
                    store: store,
                    isOwnStore: isOwnStore,
                    followStore: followStore,
                    unfollowStore: unfollowStore,
                    confettiControllers: confettiControllers,
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _buildConfettiWidget(store['id']),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildConfettiWidget(String storeId) {
    return ConfettiWidget(
      confettiController: confettiControllers[storeId]!,
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
    );
  }
}
