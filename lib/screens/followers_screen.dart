import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
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
  String? userName;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchFollowedStores();
    _fetchFollowersStores();
  }

  Future<void> _fetchUserDetails() async {
    const secureStorage = FlutterSecureStorage();
    try {
      final userJson = await secureStorage.read(key: 'user');
      if (userJson != null) {
        final userDetails = jsonDecode(userJson) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            userName = userDetails['name'];
          });
        }
      } else {
        throw Exception(
            'Nenhum dado do usuário encontrado no armazenamento seguro');
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          userName = 'Usuário';
        });
      }
    }
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
    // Nova função para carregar seguidores
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

  Future<void> _unfollowStore(String storeId) async {
    if (mounted) {
      setState(() {
        followingStores =
            followingStores?.where((store) => store['id'] != storeId).toList();
      });
    }

    try {
      await followService.unfollowStore(storeId);
    } catch (e) {
      print('Failed to unfollow store: $e');
      if (mounted) {
        setState(() {
          followingStores = followingStores?.map((store) {
            if (store['id'] == storeId) {
              store['isFollowing'] =
                  true; // Reverte a interface caso ocorra um erro
            }
            return store;
          }).toList();
        });
      }
    }
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
            : ListView.builder(
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  final store = stores[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: store['profile_picture'] != null
                          ? NetworkImage(store['profile_picture'])
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      store['company_name'],
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        _unfollowStore(store['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
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
                  );
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
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/default_avatar.png'),
            ),
            const SizedBox(width: 10),
            Text(
              userName ?? 'Usuário',
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
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
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'seguindo',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ),
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
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'seguidores',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ),
                        _buildIndicator(currentIndex == 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1.0,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
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
