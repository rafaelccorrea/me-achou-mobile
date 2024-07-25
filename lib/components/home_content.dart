import 'dart:async';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:meachou/components/home/event_carousel.dart';
import 'package:meachou/components/home/loading_skeletons.dart';
import 'package:meachou/components/home/store_list.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/services/follow_store.dart';
import 'package:meachou/services/stores_service.dart';
import 'package:meachou/services/event_service.dart';
import 'package:async/async.dart';

class HomeContent extends StatefulWidget {
  final Map<String, dynamic>? filters;

  const HomeContent({Key? key, this.filters}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with AutomaticKeepAliveClientMixin<HomeContent> {
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

  CancelableOperation<void>? _fetchUserStoreIdOperation;
  CancelableOperation<void>? _fetchStoresOperation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    applyFilters(widget.filters);
  }

  @override
  void dispose() {
    _confettiControllers.forEach((key, controller) => controller.dispose());
    _scrollController.dispose();
    _fetchUserStoreIdOperation?.cancel();
    _fetchStoresOperation?.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMoreStores) {
      loadMoreStores();
    }
  }

  Future<void> fetchUserStoreId() async {
    if (!mounted) return;

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
    if (!mounted) return;

    setState(() {
      _currentFilters = filters ?? {};
      currentCity = _currentFilters['city'] ?? 'Marília';
    });

    _fetchStoresOperation =
        CancelableOperation.fromFuture(fetchStores(filters: _currentFilters));
    fetchEvents(filters: _currentFilters, page: 1, limit: 10);
  }

  Future<void> fetchStores(
      {Map<String, dynamic>? filters, int retries = 3}) async {
    if (!mounted) return;

    setState(() {
      isLoadingStores = true;
      currentPage = 1;
    });

    for (int attempt = 0; attempt < retries; attempt++) {
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
          return; // Successful response, exit the loop
        } else if (response?.statusCode == 404) {
          if (mounted) {
            setState(() {
              stores = [];
              isLoadingStores = false;
            });
          }
          return; // No stores found, exit the loop
        } else {
          throw Exception('Failed to load stores');
        }
      } catch (e) {
        if (attempt == retries - 1) {
          if (mounted) {
            setState(() {
              isLoadingStores = false;
            });
          }
          if (e is TimeoutException) {
            _showErrorToast(
                'Erro ao carregar as lojas após várias tentativas.');
          }
        }
      }
    }
  }

  Future<void> loadMoreStores({int retries = 3}) async {
    if (!mounted) return;

    setState(() {
      isLoadingMoreStores = true;
    });

    for (int attempt = 0; attempt < retries; attempt++) {
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
          return; // Successful response, exit the loop
        } else if (response?.statusCode == 404) {
          if (mounted) {
            setState(() {
              isLoadingMoreStores = false;
            });
          }
          return; // No more stores found, exit the loop
        } else {
          throw Exception('Failed to load more stores');
        }
      } catch (e) {
        if (attempt == retries - 1) {
          if (mounted) {
            setState(() {
              isLoadingMoreStores = false;
            });
          }
          if (e is TimeoutException) {
            _showErrorToast(
                'Erro ao carregar mais lojas após várias tentativas.');
          }
        }
      }
    }
  }

  Future<void> fetchEvents(
      {Map<String, dynamic>? filters,
      required int page,
      required int limit,
      int retries = 3}) async {
    if (!mounted) return;

    setState(() {
      isLoadingEvents = true;
    });

    for (int attempt = 0; attempt < retries; attempt++) {
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
          return; // Successful response, exit the loop
        } else if (response?.statusCode == 404) {
          if (mounted) {
            setState(() {
              events = [];
              isLoadingEvents = false;
            });
          }
          return; // No events found, exit the loop
        } else {
          throw Exception('Failed to load events');
        }
      } catch (e) {
        if (attempt == retries - 1) {
          if (mounted) {
            setState(() {
              isLoadingEvents = false;
            });
          }
          if (e is TimeoutException) {
            _showErrorToast('Erro ao carregar eventos após várias tentativas.');
          }
        }
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

    setState(() {
      _updateStoreFollowStatus(storeId, true);
      _confettiControllers[storeId]?.play();
    });

    try {
      await followsService.followStore(storeId);
    } catch (e) {
      setState(() {
        _updateStoreFollowStatus(storeId, false);
      });
      _showErrorToast('Erro ao seguir a loja.');
    }
  }

  Future<void> unfollowStore(String storeId) async {
    if (_isOwnStore(storeId)) return;

    setState(() {
      _updateStoreFollowStatus(storeId, false);
    });

    try {
      await followsService.unfollowStore(storeId);
    } catch (e) {
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
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin

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
            if (isLoadingEvents || isLoadingStores)
              LoadingSkeletons()
            else ...[
              if (events.isNotEmpty) EventCarousel(events: events),
              const SizedBox(height: 20),
              StoreList(
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
