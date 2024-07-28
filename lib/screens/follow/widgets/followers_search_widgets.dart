import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FollowersSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final bool isSearching;
  final VoidCallback onSearch;

  const FollowersSearchWidget({
    super.key,
    required this.searchController,
    required this.isSearching,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar por Nome do Seguidor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2.0,
                    ),
                  ),
                  labelStyle: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.blueGrey,
                    onPressed: () {
                      searchController.clear();
                      onSearch();
                    },
                  ),
                ),
                onChanged: (value) {
                  onSearch();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
