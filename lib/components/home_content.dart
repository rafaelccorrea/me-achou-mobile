import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meachou/components/home/event_carousel.dart';
import 'package:meachou/components/home/loading_skeletons.dart';
import 'package:meachou/components/home/store_list.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/services/follow_store.dart';
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
  bool isLoadingMoreStores = false;
  String? userStoreId;
  String currentCity = 'Marília';
  final AuthService authService = AuthService();
  final StoreService storeService = StoreService();
  final EventService eventService = EventService();
  final FollowsService followsService = FollowsService();
  final Map<String, ConfettiController> _confettiControllers = {};
  Map<String, dynamic> _currentFilters = {};
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchUserStoreId();
    applyFilters(widget.filters);
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isBottom = _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent;
        if (isBottom && !isLoadingMoreStores) {
          loadMoreStores();
        }
      }
    });
  }

  @override
  void dispose() {
    _confettiControllers.forEach((key, controller) => controller.dispose());
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchUserStoreId() async {
    try {
      final response = await storeService
          .getStoreDetails()
          .timeout(const Duration(seconds: 10));

      if (response is Map<String, dynamic> && response.containsKey('id')) {
        if (mounted) {
          setState(() {
            userStoreId = response['id'];
          });
        }
      } else {
        throw Exception('Failed to load user store ID');
      }
    } catch (e) {
      _showErrorToast('Erro ao carregar ID da loja do usuário.');
    }
  }

  Future<void> applyFilters(Map<String, dynamic>? filters) async {
    if (mounted) {
      setState(() {
        _currentFilters = filters ?? {};
      });
      String? city = _currentFilters['city'];
      setState(() {
        currentCity = city ?? 'Marília';
      });
    }
    fetchStores(filters: _currentFilters);
    fetchEvents(filters: _currentFilters, page: 1, limit: 10);
  }

  Future<void> fetchStores({Map<String, dynamic>? filters}) async {
    if (mounted) {
      setState(() {
        isLoadingStores = true;
        currentPage = 1;
      });
    }

    try {
      final response = await storeService
          .getStores(
            page: 1,
            limit: 10,
            businessSector: filters?['business_sector'] ?? '',
            city: currentCity,
            region: filters?['region'],
            rankingMin: filters?['ranking_min'],
            rankingMax: filters?['ranking_max'],
            delivery:
                filters?['delivery'] == false ? null : filters?['delivery'],
            inHomeService: filters?['in_home_service'] == false
                ? null
                : filters?['in_home_service'],
          )
          .timeout(const Duration(seconds: 10));

      if (response?.statusCode == 200) {
        if (mounted) {
          setState(() {
            stores = json.decode(response!.body)['data'];
            isLoadingStores = false;
            _initializeConfettiControllers();
          });
        }
      } else {
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingStores = false;
        });
      }
      _showErrorToast('Erro ao carregar as lojas.');
    }
  }

  Future<void> loadMoreStores() async {
    if (mounted) {
      setState(() {
        isLoadingMoreStores = true;
      });
    }

    try {
      final response = await storeService
          .getStores(
            page: currentPage + 1,
            limit: 10,
            businessSector: _currentFilters['business_sector'] ?? '',
            city: currentCity,
            region: _currentFilters['region'],
            rankingMin: _currentFilters['ranking_min'],
            rankingMax: _currentFilters['ranking_max'],
            delivery: _currentFilters['delivery'] == false
                ? null
                : _currentFilters['delivery'],
            inHomeService: _currentFilters['in_home_service'] == false
                ? null
                : _currentFilters['in_home_service'],
          )
          .timeout(const Duration(seconds: 10));

      if (response?.statusCode == 200) {
        final newStores = json.decode(response!.body)['data'];
        if (mounted) {
          setState(() {
            stores.addAll(newStores);
            currentPage += 1;
            isLoadingMoreStores = false;
          });
        }
      } else {
        throw Exception('Failed to load more stores');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMoreStores = false;
        });
      }
      _showErrorToast('Erro ao carregar mais lojas.');
    }
  }

  Future<void> fetchEvents(
      {Map<String, dynamic>? filters,
      required int page,
      required int limit}) async {
    if (mounted) {
      setState(() {
        isLoadingEvents = true;
      });
    }

    try {
      final response = await eventService
          .getEvents(
            page: page,
            limit: limit,
            city: currentCity,
          )
          .timeout(const Duration(seconds: 10));

      if (response?.statusCode == 200) {
        if (mounted) {
          setState(() {
            events = json.decode(response!.body)['data'];
            isLoadingEvents = false;
          });
        }
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingEvents = false;
        });
      }
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

    // Atualiza o estado instantaneamente
    setState(() {
      _updateStoreFollowStatus(storeId, true);
      _confettiControllers[storeId]?.play();
    });

    try {
      await followsService.followStore(storeId);
    } catch (e) {
      // Reverte o estado se a API falhar
      setState(() {
        _updateStoreFollowStatus(storeId, false);
      });
      _showErrorToast('Erro ao seguir a loja.');
    }
  }

  Future<void> unfollowStore(String storeId) async {
    if (_isOwnStore(storeId)) return;

    // Atualiza o estado instantaneamente
    setState(() {
      _updateStoreFollowStatus(storeId, false);
    });

    try {
      await followsService.unfollowStore(storeId);
    } catch (e) {
      // Reverte o estado se a API falhar
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
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                const Spacer(),
                Text(
                  'Cidade: $currentCity',
                  style: const TextStyle(
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
            if (isLoadingMoreStores) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(child: LoadingDots()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
