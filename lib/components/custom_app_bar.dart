import 'package:flutter/material.dart';
import 'package:meachou/components/store_filter.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function(Map<String, dynamic>) onFilter;
  final Function onClearFilters;
  final Map<String, dynamic>
      initialFilters; // Adicionando campo para filtros iniciais

  const CustomAppBar({
    Key? key,
    required this.onFilter,
    required this.onClearFilters,
    required this.initialFilters, // Adicionando campo para filtros iniciais
  }) : super(key: key);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 150); // Adjust height as needed
}

class _CustomAppBarState extends State<CustomAppBar> {
  late Map<String, dynamic> _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = Map<String, dynamic>.from(
        widget.initialFilters); // Inicializa com os filtros iniciais
  }

  void _handleFilter(Map<String, dynamic> filters) {
    setState(() {
      _currentFilters = filters;
    });
    widget.onFilter(filters);
  }

  void _handleClearFilters() {
    setState(() {
      _currentFilters = {};
    });
    widget.onClearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.3)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Vamos encontrar o que procura?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Busque por lojas...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.black54),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        builder: (context) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: StoreFilterForm(
                            onFilter: _handleFilter,
                            onClearFilters: _handleClearFilters,
                            initialFilters: _currentFilters,
                          ),
                        ),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.white54,
          height: 1.0,
        ),
      ),
    );
  }
}
