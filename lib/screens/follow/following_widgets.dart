import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/services/follow_store.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FollowsService followsService = FollowsService();

Future<void> unfollowStore(String storeId) async {
  try {
    await followsService.unfollowStore(storeId);
    Fluttertoast.showToast(
      msg: 'Deixou de seguir a loja com sucesso.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: 'Erro ao deixar de seguir a loja.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}

Widget buildStoreTile(Map<String, dynamic> store, int index,
    [Animation<double>? animation,
    Future<void> Function(String, int)? onUnfollow]) {
  return SizeTransition(
    sizeFactor: animation ?? const AlwaysStoppedAnimation(1),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
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
          store['company_name'] ?? 'No Name',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        trailing: TextButton(
          onPressed: () {
            if (onUnfollow != null) {
              onUnfollow(store['id'], index);
            } else {
              unfollowStore(store['id']);
            }
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.blueGrey.withOpacity(0.1),
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
    ),
  );
}

Widget buildStoreList(
    List<Map<String, dynamic>>? stores,
    bool isLoading,
    GlobalKey<AnimatedListState> listKey,
    Future<void> Function(String, int)? onUnfollow,
    bool isSearching) {
  if (isLoading) {
    return const Center(child: LoadingDots());
  } else if (stores == null || stores.isEmpty) {
    return const Center(
      child: Text(
        'Nenhuma loja encontrada',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  } else {
    return AnimatedList(
      key: listKey,
      initialItemCount: stores.length,
      itemBuilder: (context, index, animation) {
        final store = stores[index];
        return buildStoreTile(store, index, animation, onUnfollow);
      },
    );
  }
}

Widget buildRankingCategory(String title, List<int> options, int? selectedValue,
    ValueChanged<int?> onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8.0),
      Wrap(
        spacing: 8.0,
        children: options.map((option) {
          final isSelected = selectedValue == option;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ChoiceChip(
              label: Text(option.toString()),
              selected: isSelected,
              onSelected: (selected) {
                onChanged(selected ? option : null);
              },
              selectedColor: Colors.blueAccent.shade100,
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black87),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

Widget buildIndicator(bool isActive) {
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

Widget buildDivider() {
  return Container(
    height: 50,
    child: const VerticalDivider(
      color: Colors.grey,
      thickness: 1,
    ),
  );
}
