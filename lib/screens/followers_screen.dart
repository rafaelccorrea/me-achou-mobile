import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meachou/services/follow_store.dart';
import 'package:meachou/components/loading/loading_dots.dart';

class FollowersScreen extends StatefulWidget {
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with SingleTickerProviderStateMixin {
  final FollowsService followService = FollowsService();
  List<Map<String, dynamic>>? followingStores;
  List<Map<String, dynamic>>? followersStores;
  bool isLoadingFollowing = true;
  bool isLoadingFollowers = true;
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
      final stores = await followService.getFollowedStores(1, 10);
      if (mounted) {
        setState(() {
          followingStores = stores;
          isLoadingFollowing = false;
        });
      }
    } catch (e) {
      print('Failed to load followed stores: $e');
      if (mounted) {
        setState(() {
          isLoadingFollowing = false;
        });
      }
    }
  }

  Future<void> _fetchFollowersStores() async {
    try {
      // final stores = await followService.getFollowersStores(1, 10); // Supondo que essa função exista
      if (mounted) {
        setState(() {
          // followersStores = stores;
          isLoadingFollowers = false;
        });
      }
    } catch (e) {
      print('Failed to load followers stores: $e');
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
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildStoreTile(removedStore, index, animation),
      );
    }

    try {
      await followService.unfollowStore(storeId);
    } catch (e) {
      print('Failed to unfollow store: $e');
      if (mounted && removedStore != null) {
        followingStores?.insert(index, removedStore);
        _listKey.currentState?.insertItem(index);
      }
    }
  }

  Widget _buildStoreTile(Map<String, dynamic> store, int index,
      [Animation<double>? animation]) {
    return SizeTransition(
      sizeFactor: animation ?? AlwaysStoppedAnimation(1),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: store['profile_picture'] != null
              ? NetworkImage(store['profile_picture'])
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
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
        trailing: ElevatedButton(
          onPressed: () {
            _unfollowStore(store['id'], index);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
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
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreList(List<Map<String, dynamic>>? stores, bool isLoading) {
    return isLoading
        ? const Center(child: LoadingDots())
        : stores == null
            ? const Center(
                child: Text(
                  'Erro ao carregar dados',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
            : AnimatedList(
                key: _listKey,
                initialItemCount: stores.length,
                itemBuilder: (context, index, animation) {
                  final store = stores[index];
                  return _buildStoreTile(store, index, animation);
                },
              );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 4.0,
      width: isActive ? 24.0 : 0.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          currentIndex = 1;
                        });
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          '417',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'seguindo',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildIndicator(currentIndex == 1),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          currentIndex = 0;
                        });
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          '211',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'seguidores',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildIndicator(currentIndex == 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: [
                  _buildStoreList(followersStores, isLoadingFollowers),
                  _buildStoreList(followingStores, isLoadingFollowing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
