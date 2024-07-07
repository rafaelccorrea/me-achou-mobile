import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meachou/components/home/event_carousel.dart';
import 'package:meachou/components/home/loading_skeletons.dart';
import 'package:meachou/components/home/store_list.dart';
import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/services/stores_service.dart';
import 'package:meachou/services/event_service.dart';

class HomeContent extends StatefulWidget {
  final Map<String, dynamic>? filters;

  const HomeContent({Key? key, this.filters}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic> stores = [];
  List<dynamic> events = [];
  bool isLoadingStores = true;
  bool isLoadingEvents = true;
  String? userStoreId;
  String currentCity = 'Marília'; // Cidade padrão
  final AuthService authService = AuthService();
  final StoreService storeService = StoreService();
  final EventService eventService = EventService();
  final Map<String, ConfettiController> _confettiControllers = {};
  Map<String, dynamic> _currentFilters = {}; // Armazenar filtros aplicados

  @override
  void initState() {
    super.initState();
    fetchUserStoreId();
    applyFilters(widget.filters);
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

  Future<void> applyFilters(Map<String, dynamic>? filters) async {
    setState(() {
      _currentFilters = filters ?? {};
    });
    String? city = _currentFilters['city'];
    setState(() {
      currentCity = city ?? 'Marília';
    });
    fetchStores(filters: _currentFilters);
    fetchEvents(filters: _currentFilters, page: 1, limit: 10);
  }

  Future<void> fetchStores({Map<String, dynamic>? filters}) async {
    setState(() {
      isLoadingStores = true;
    });

    final token = await authService.getAccessToken();
    final response = await storeService.getStores(
      page: 1,
      limit: 10,
      businessSector: filters?['business_sector'] ?? '',
      city: currentCity,
      region: filters?['region'],
      rankingMin: filters?['ranking_min'],
      rankingMax: filters?['ranking_max'],
      delivery: filters?['delivery'] == false ? null : filters?['delivery'],
      inHomeService: filters?['in_home_service'] == false
          ? null
          : filters?['in_home_service'],
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

  Future<void> fetchEvents(
      {Map<String, dynamic>? filters,
      required int page,
      required int limit}) async {
    setState(() {
      isLoadingEvents = true;
    });

    final token = await authService.getAccessToken();
    final response = await eventService.getEvents(
      page: page,
      limit: limit,
      city: currentCity,
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
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                Spacer(),
                Text(
                  'Cidade: $currentCity',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoadingEvents)
              LoadingSkeletons()
            else if (events.isEmpty)
              isLoadingStores
                  ? LoadingSkeletons()
                  : StoreList(
                      stores: stores,
                      userStoreId: userStoreId,
                      followStore: followStore,
                      unfollowStore: unfollowStore,
                      confettiControllers: _confettiControllers,
                    )
            else ...[
              EventCarousel(events: events),
              const SizedBox(height: 20),
              isLoadingStores
                  ? LoadingSkeletons()
                  : StoreList(
                      stores: stores,
                      userStoreId: userStoreId,
                      followStore: followStore,
                      unfollowStore: unfollowStore,
                      confettiControllers: _confettiControllers,
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
