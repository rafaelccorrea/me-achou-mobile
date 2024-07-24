import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meachou/screens/follow/followers_search_widgets.dart';
import 'package:meachou/services/follow_store.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/screens/follow/following_widgets.dart';
import 'package:meachou/screens/follow/search_and_filter_widget.dart';
import 'package:meachou/screens/follow/followers_widget.dart';
import 'dart:async';

class FollowersScreen extends StatefulWidget {
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final FollowsService followService = FollowsService();
  List<Map<String, dynamic>>? followingStores;
  List<Map<String, dynamic>>? followersStores;
  bool isLoadingFollowing = true;
  bool isLoadingFollowers = true;
  bool isSearching = false;
  int totalFollowing = 0;
  int totalFollowers = 0;
  int currentIndex = 1;
  final GlobalKey<AnimatedListState> _followingListKey =
      GlobalKey<AnimatedListState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _followersSearchController =
      TextEditingController();
  int? rankingMin;
  int? rankingMax;
  Timer? _debounce;
  final List<int> _rankingOptions = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _fetchFollowedStores();
    _searchController.addListener(_onSearchChanged);
    _followersSearchController.addListener(_onFollowersSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _followersSearchController.removeListener(_onFollowersSearchChanged);
    _followersSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {
      isSearching = true;
    });
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchFollowedStores();
    });
  }

  void _onFollowersSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {
      isSearching = true;
    });
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchFollowersStores();
    });
  }

  Future<void> _fetchFollowedStores({bool clearFilters = false}) async {
    setState(() {
      isLoadingFollowing = true;
    });
    try {
      final response = await followService.getFollowingStores(
        page: 1,
        limit: 10,
        companyName: clearFilters
            ? null
            : _searchController.text.isEmpty
                ? null
                : _searchController.text,
        rankingMin: clearFilters ? null : rankingMin,
        rankingMax: clearFilters ? null : rankingMax,
      );
      if (mounted) {
        setState(() {
          followingStores = List<Map<String, dynamic>>.from(response['data']);
          totalFollowing = response['total'];
          isLoadingFollowing = false;
          isSearching = false;
        });
      }
    } catch (e) {
      print('Falha ao carregar as lojas seguidas: $e');
      if (mounted) {
        setState(() {
          isLoadingFollowing = false;
          isSearching = false;
        });
      }
    }
  }

  Future<void> _fetchFollowersStores({bool clearFilters = false}) async {
    setState(() {
      isLoadingFollowers = true;
    });
    try {
      final response = await followService.getFollowersStores(
        page: 1,
        limit: 10,
        name: clearFilters
            ? null
            : _followersSearchController.text.isEmpty
                ? null
                : _followersSearchController.text,
      );
      if (mounted) {
        setState(() {
          followersStores = List<Map<String, dynamic>>.from(response['data']);
          totalFollowers = response['total'];
          isLoadingFollowers = false;
          isSearching = false;
        });
      }
    } catch (e) {
      print('Falha ao carregar as lojas seguidoras: $e');
      if (mounted) {
        setState(() {
          isLoadingFollowers = false;
          isSearching = false;
        });
      }
    }
  }

  void _showRankingFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<int> maxOptions = _rankingOptions;
            if (rankingMin != null) {
              maxOptions = _rankingOptions
                  .where((option) => option >= rankingMin!)
                  .toList();
            }
            return AlertDialog(
              title: const Text('Filtrar por Classificação'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildRankingCategory(
                    'Classificação Mínima',
                    _rankingOptions,
                    rankingMin,
                    (value) {
                      setState(() {
                        rankingMin = value;
                        if (value == 7) {
                          rankingMax = 7;
                        } else if (rankingMax != null && rankingMax! < value!) {
                          rankingMax = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  buildRankingCategory(
                    'Classificação Máxima',
                    maxOptions,
                    rankingMax,
                    (value) {
                      setState(() {
                        rankingMax = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Limpar Filtros'),
                  onPressed: () {
                    setState(() {
                      rankingMin = null;
                      rankingMax = null;
                    });
                    Navigator.of(context).pop();
                    _fetchFollowedStores(clearFilters: true);
                  },
                ),
                TextButton(
                  child: const Text('Aplicar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _fetchFollowedStores();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearRankingFilters() {
    setState(() {
      rankingMin = null;
      rankingMax = null;
    });
    _fetchFollowedStores(clearFilters: true);
  }

  void _clearSearchFields() {
    _searchController.clear();
    _followersSearchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 60.0, bottom: 20.0, left: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                currentIndex = 1;
                                _fetchFollowersStores(clearFilters: true);
                                _clearSearchFields();
                              });
                              _fetchFollowedStores();
                            },
                            child: Column(
                              children: [
                                Text(
                                  '$totalFollowing',
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Seguindo',
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: currentIndex == 1
                                          ? Colors.blueAccent
                                          : Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                buildIndicator(currentIndex == 1),
                              ],
                            ),
                          ),
                          buildDivider(),
                          InkWell(
                            onTap: () {
                              setState(() {
                                currentIndex = 0;
                                _fetchFollowedStores(clearFilters: true);
                                _clearSearchFields();
                              });
                              _fetchFollowersStores();
                            },
                            child: Column(
                              children: [
                                Text(
                                  '$totalFollowers',
                                  style: GoogleFonts.lato(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Seguidores',
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: currentIndex == 0
                                          ? Colors.blueAccent
                                          : Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                buildIndicator(currentIndex == 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (currentIndex == 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SearchAndFilterWidget(
                        searchController: _searchController,
                        rankingMin: rankingMin,
                        rankingMax: rankingMax,
                        rankingOptions: _rankingOptions,
                        onFilterApplied: _fetchFollowedStores,
                        onClearFilters: _clearRankingFilters,
                        onShowRankingFilterDialog: _showRankingFilterDialog,
                        isSearching: isSearching,
                      ),
                    ),
                  if (currentIndex == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FollowersSearchWidget(
                        searchController: _followersSearchController,
                        isSearching: isSearching,
                        onSearch: _onFollowersSearchChanged,
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: currentIndex.clamp(0, 1),
              children: [
                FollowersWidget(
                  searchController: _followersSearchController,
                  onTotalFollowersChanged: (total) {
                    setState(() {
                      totalFollowers = total;
                    });
                  },
                ),
                buildFollowingList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFollowingList() {
    if (isLoadingFollowing) {
      return const Center(
        child: LoadingDots(),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: AnimatedList(
            key: _followingListKey,
            initialItemCount: followingStores?.length ?? 0,
            itemBuilder: (context, index, animation) {
              final store = followingStores![index];
              return buildStoreTile(store, index, animation);
            },
          ),
        ),
      ],
    );
  }

  Widget buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey,
    );
  }

  Widget buildIndicator(bool isActive) {
    return isActive
        ? Container(
            margin: const EdgeInsets.only(top: 8.0),
            height: 2,
            width: 24,
            color: Colors.blueAccent,
          )
        : Container();
  }
}
