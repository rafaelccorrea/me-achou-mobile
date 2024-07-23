import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchAndFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final int? rankingMin;
  final int? rankingMax;
  final List<int> rankingOptions;
  final VoidCallback onFilterApplied;
  final VoidCallback onClearFilters;
  final VoidCallback onShowRankingFilterDialog;
  final bool isSearching;

  SearchAndFilterWidget({
    super.key,
    required this.searchController,
    required this.rankingMin,
    required this.rankingMax,
    required this.rankingOptions,
    required this.onFilterApplied,
    required this.onClearFilters,
    required this.onShowRankingFilterDialog,
    required this.isSearching,
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
                  labelText: 'Buscar por Nome da Empresa',
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
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_alt),
                    color: Colors.blueGrey,
                    onPressed: onShowRankingFilterDialog,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (rankingMin != null || rankingMax != null)
              Expanded(
                child: Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    if (rankingMin != null)
                      Chip(
                        label: Text('Min: $rankingMin'),
                        backgroundColor: Colors.blueAccent,
                        labelStyle: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (rankingMax != null)
                      Chip(
                        label: Text('Max: $rankingMax'),
                        backgroundColor: Colors.blueAccent,
                        labelStyle: GoogleFonts.lato(
                          textStyle: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (rankingMin != null || rankingMax != null)
              TextButton(
                onPressed: onClearFilters,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  textStyle: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                child: const Text('Limpar Filtros'),
              ),
          ],
        ),
      ],
    );
  }
}
