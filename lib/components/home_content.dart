import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/auth_service.dart';
import 'dart:convert';
import 'package:meachou/services/stores_service.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:intl/intl.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic> stores = [];
  List<dynamic> events = [];
  bool isLoadingStores = true;
  bool isLoadingEvents = true;
  String? userStoreId;
  final AuthService authService = AuthService();
  final StoreService storeService = StoreService();
  final Map<String, ConfettiController> _confettiControllers = {};

  @override
  void initState() {
    super.initState();
    fetchUserStoreId();
    fetchStores();
    fetchEvents(page: 1, limit: 10);
  }

  @override
  void dispose() {
    _confettiControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> fetchUserStoreId() async {
    final token = await authService.getAccessToken();
    final response = await http.get(
      Uri.parse(ApiConstants.storeDetailsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userStoreId = json.decode(response.body)['id'];
      });
    } else {
      _showErrorToast('Erro ao carregar ID da loja do usuário.');
    }
  }

  Future<void> fetchStores() async {
    final token = await authService.getAccessToken();
    final response = await storeService.getStores(
      page: 1,
      limit: 10,
      businessSector: 'Tecnologia da Informação',
      city: 'São Paulo',
    );

    if (response.statusCode == 200) {
      setState(() {
        stores = json.decode(response.body)['data'];
        isLoadingStores = false;
        _initializeConfettiControllers();
      });
    } else {
      setState(() {
        isLoadingStores = false;
      });
      _showErrorToast('Erro ao carregar as lojas.');
    }
  }

  Future<void> fetchEvents({required int page, required int limit}) async {
    final token = await authService.getAccessToken();
    final response = await http.get(
      Uri.parse(ApiConstants.eventsEndpoint
          .replaceFirst('{page}', '$page')
          .replaceFirst('{limit}', '$limit')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        events = json.decode(response.body)['data'];
        isLoadingEvents = false;
      });
    } else {
      setState(() {
        isLoadingEvents = false;
      });
      _showErrorToast('Erro ao carregar os eventos.');
    }
  }

  void _initializeConfettiControllers() {
    for (var store in stores) {
      _confettiControllers[store['id']] =
          ConfettiController(duration: const Duration(milliseconds: 50));
    }
  }

  Future<void> followStore(String storeId) async {
    if (_isOwnStore(storeId)) return;

    final token = await authService.getAccessToken();
    final endpoint =
        ApiConstants.followStoreEndpoint.replaceFirst(':storeId', storeId);

    // Update the UI immediately
    setState(() {
      _updateStoreFollowStatus(storeId, true);
      _confettiControllers[storeId]?.play();
    });

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Revert the UI if the request fails
    if (response.statusCode != 201) {
      setState(() {
        _updateStoreFollowStatus(storeId, false);
      });
      _showErrorToast('Erro ao seguir a loja.');
    }
  }

  Future<void> unfollowStore(String storeId) async {
    if (_isOwnStore(storeId)) return;

    final token = await authService.getAccessToken();
    final endpoint =
        ApiConstants.unfollowStoreEndpoint.replaceFirst(':storeId', storeId);

    // Update the UI immediately
    setState(() {
      _updateStoreFollowStatus(storeId, false);
    });

    final response = await http.delete(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Revert the UI if the request fails
    if (response.statusCode != 200) {
      setState(() {
        _updateStoreFollowStatus(storeId, true);
      });
      _showErrorToast('Erro ao deixar de seguir a loja.');
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  bool _isOwnStore(String storeId) {
    if (storeId == userStoreId) {
      _showErrorToast("Você não pode seguir sua própria loja.");
      return true;
    }
    return false;
  }

  void _updateStoreFollowStatus(String storeId, bool isFollowed) {
    stores = stores.map((store) {
      if (store['id'] == storeId) {
        store['isFollowed'] = isFollowed;
      }
      return store;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _buildSearchInput(),
          const SizedBox(height: 20),
          isLoadingEvents
              ? _buildEventCarouselSkeleton()
              : _buildEventCarousel(),
          const SizedBox(height: 20),
          isLoadingStores ? _buildLoadingSkeletons() : _buildStoreList(),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar lojas...',
        hintStyle:
            TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildEventCarousel() {
    return CarouselSlider.builder(
      itemCount: events.length,
      itemBuilder: (context, index, realIdx) {
        final event = events[index];
        final startDate = DateFormat('dd-MM-yyyy').parse(event['start_date']);
        final endDate = DateFormat('dd-MM-yyyy').parse(event['end_date']);
        final dateRange =
            '${DateFormat('dd MMM').format(startDate)} - ${DateFormat('dd MMM').format(endDate)}';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(event['image']),
                fit: BoxFit.cover,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      dateRange,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        enableInfiniteScroll: events.length > 2,
      ),
    );
  }

  Widget _buildEventCarouselSkeleton() {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: SkeletonAnimation(
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[300],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lojas cadastradas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            final isOwnStore = store['id'] == userStoreId;
            return Stack(
              children: [
                _buildStoreCard(store, isOwnStore),
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

  Widget _buildStoreCard(Map<String, dynamic> store, bool isOwnStore) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: store['profile_picture'] != null
              ? Image.network(store['profile_picture'])
              : Image.network(
                  'https://www.logodesignlove.com/wp-content/uploads/2023/10/playstation-logo-01.jpeg'),
        ),
        title: Text(
          store['company_name'],
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store['address']['region'] ?? 'Região não especificada',
                style: TextStyle(fontSize: 14)),
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
              if (_confettiControllers[store['id']] != null)
                ConfettiWidget(
                  confettiController: _confettiControllers[store['id']]!,
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

  Widget _buildLoadingSkeletons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(5, (index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: ListTile(
            leading: SkeletonAnimation(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[300],
                ),
              ),
            ),
            title: SkeletonAnimation(
              child: Container(
                width: double.infinity,
                height: 10,
                color: Colors.grey[300],
              ),
            ),
            subtitle: SkeletonAnimation(
              child: Container(
                width: double.infinity,
                height: 10,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 5),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConfettiWidget(String storeId) {
    return ConfettiWidget(
      confettiController: _confettiControllers[storeId]!,
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
