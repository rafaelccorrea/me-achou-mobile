import 'package:flutter/material.dart';
import 'package:meachou/services/follow_store.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'dart:async';

class FollowersWidget extends StatefulWidget {
  final TextEditingController searchController;
  final ValueChanged<int> onTotalFollowersChanged;

  const FollowersWidget({
    Key? key,
    required this.searchController,
    required this.onTotalFollowersChanged,
  }) : super(key: key);

  @override
  _FollowersWidgetState createState() => _FollowersWidgetState();
}

class _FollowersWidgetState extends State<FollowersWidget> {
  final FollowsService followService = FollowsService();
  List<Map<String, dynamic>>? followersStores;
  bool isLoadingFollowers = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchFollowersStores();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {
      isLoadingFollowers = true;
    });
    _debounce = Timer(const Duration(milliseconds: 500), _fetchFollowersStores);
  }

  Future<void> _fetchFollowersStores() async {
    try {
      final response = await followService.getFollowersStores(
        page: 1,
        limit: 10,
        name: widget.searchController.text.isEmpty
            ? null
            : widget.searchController.text,
      );
      if (mounted) {
        setState(() {
          followersStores = List<Map<String, dynamic>>.from(response['data']);
          isLoadingFollowers = false;
        });
        widget.onTotalFollowersChanged(response['total']);
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

  @override
  Widget build(BuildContext context) {
    if (isLoadingFollowers) {
      return const Center(
        child: LoadingDots(),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: followersStores?.length ?? 0,
            itemBuilder: (context, index) {
              final store = followersStores![index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 2.0),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundImage: store['avatar'] != null
                                ? NetworkImage(store['avatar'])
                                : null,
                            radius: 30,
                            child: store['avatar'] == null
                                ? Text(
                                    store['name'][0],
                                    style: const TextStyle(fontSize: 24),
                                  )
                                : null,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            store['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
