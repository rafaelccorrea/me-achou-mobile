import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meachou/services/follow_store.dart';
import 'package:meachou/components/loading/loading_dots.dart';

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
  int totalFollowing = 0;
  int totalFollowers = 0;
  int currentIndex = 1;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _fetchFollowedStores();
    _fetchFollowersStores();
  }

  Future<void> _fetchFollowedStores() async {
    try {
      final response = await followService.getFollowedStores(1, 10);
      if (mounted) {
        setState(() {
          followingStores = List<Map<String, dynamic>>.from(response['data']);
          totalFollowing = response['total'];
          isLoadingFollowing = false;
        });
      }
    } catch (e) {
      print('Falha ao carregar as lojas seguidas: $e');
      if (mounted) {
        setState(() {
          isLoadingFollowing = false;
        });
      }
    }
  }

  Future<void> _fetchFollowersStores() async {
    try {
      // final response = await followService.getFollowersStores(1, 10); // Supondo que essa função exista
      if (mounted) {
        setState(() {
          // followersStores = List<Map<String, dynamic>>.from(response['data']);
          // totalFollowers = response['total'];
          isLoadingFollowers = false;
        });
      }
    } catch (e) {
      print('Falha ao carregar as lojas seguidoras: $e');
      if (mounted) {
        setState(() {
          isLoadingFollowers = false;
        });
      }
    }
  }

  Future<void> _unfollowStore(String storeId, int index) async {
    final removedStore = followingStores?.removeAt(index);
    if (removedStore != null) {
      setState(() {
        totalFollowing--;
      });
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildStoreTile(removedStore, index, animation),
      );
    }

    try {
      await followService.unfollowStore(storeId);
    } catch (e) {
      print('Falha ao deixar de seguir a loja: $e');
      if (mounted && removedStore != null) {
        followingStores?.insert(index, removedStore);
        setState(() {
          totalFollowing++;
        });
        _listKey.currentState?.insertItem(index);
      }
    }
  }

  Widget _buildStoreTile(Map<String, dynamic> store, int index,
      [Animation<double>? animation]) {
    return SizeTransition(
      sizeFactor: animation ?? const AlwaysStoppedAnimation(1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
        leading: Container(
          padding: const EdgeInsets.all(3.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Color(0xFF2196F3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CircleAvatar(
            radius: 23,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 21,
              backgroundImage: store['profile_picture'] != null
                  ? NetworkImage(store['profile_picture'])
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
            ),
          ),
        ),
        title: Text(
          store['company_name'],
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        subtitle: Text(
          store['description'] ?? '',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        trailing: TextButton(
          onPressed: () {
            _unfollowStore(store['id'], index);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Remover',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreList(List<Map<String, dynamic>>? stores, bool isLoading) {
    if (isLoading) {
      return const Center(child: LoadingDots());
    } else if (stores == null) {
      return const Center(
        child: Text(
          'Erro ao carregar dados',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    } else {
      return AnimatedList(
        key: _listKey,
        initialItemCount: stores.length,
        itemBuilder: (context, index, animation) {
          final store = stores[index];
          return _buildStoreTile(store, index, animation);
        },
      );
    }
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 4.0,
      width: isActive ? 24.0 : 0.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingFollowing || isLoadingFollowers) {
      return const Scaffold(
        body: Center(
          child: LoadingDots(),
        ),
      );
    }

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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = 1;
                              });
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
                                _buildIndicator(currentIndex == 1),
                              ],
                            ),
                          ),
                          _buildDivider(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = 0;
                              });
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
                                _buildIndicator(currentIndex == 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: IndexedStack(
                index: currentIndex,
                children: [
                  _buildStoreList(followersStores, isLoadingFollowers),
                  _buildStoreList(followingStores, isLoadingFollowing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      child: const VerticalDivider(
        color: Colors.grey,
        thickness: 1,
      ),
    );
  }
}
