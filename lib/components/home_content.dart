import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meachou/constants/api_constants.dart';
import 'package:meachou/services/auth_service.dart';
import 'dart:convert';
import 'package:meachou/services/stores_service.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic> stores = [];
  bool isLoading = true;
  Map<String, bool> followingStatus = {};
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  Future<void> fetchStores() async {
    final storeService = StoreService();
    final String? token = await authService.getAccessToken();
    final response = await storeService.getStores(
      page: 1,
      limit: 10,
      businessSector: 'Tecnologia da Informação',
      city: 'São Paulo',
    );

    if (response.statusCode == 200) {
      setState(() {
        stores = json.decode(response.body)['data'];
        for (var store in stores) {
          followingStatus[store['id']] =
              false; // Inicializar o status de "seguindo" como falso
        }
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> followStore(String storeId) async {
    final String? token = await authService.getAccessToken();
    final response = await http.post(
      Uri.parse(
          ApiConstants.followStoreEndpoint.replaceFirst(':storeId', storeId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print(response.statusCode);
    if (response.statusCode == 201) {
      setState(() {
        followingStatus[storeId] = true;
      });
    } else {
      // Handle error
    }
  }

  Future<void> unfollowStore(String storeId) async {
    final String? token = await authService.getAccessToken();
    final response = await http.delete(
      Uri.parse(
          ApiConstants.unfollowStoreEndpoint.replaceFirst(':storeId', storeId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        followingStatus[storeId] = false;
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _buildSearchInput(),
          const SizedBox(height: 20),
          _buildEventCarousel(),
          const SizedBox(height: 20),
          isLoading ? const CircularProgressIndicator() : _buildStoreList(),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar lojas...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildEventCarousel() {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Número de eventos
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                        'https://img.freepik.com/fotos-gratis/publico-animado-assistindo-fogos-de-artificio-de-confete-e-se-divertindo-no-festival-de-musica-a-noite-copiar-espaco_637285-559.jpg?w=996&t=st=1719423582~exp=1719424182~hmac=85917cec18454b63a27e62c53fd20c2720dc5527cbee93d4c21d0ed0d6fa091d',
                        fit: BoxFit.cover), // Imagem do evento
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Evento $index',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lojas cadastradas',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stores.length, // Número de lojas
          itemBuilder: (context, index) {
            final store = stores[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: store['profile_picture'] != null
                      ? Image.network(store['profile_picture'])
                      : Image.network(
                          'https://www.logodesignlove.com/wp-content/uploads/2023/10/playstation-logo-01.jpeg'), // Placeholder image
                ),
                title: Text(store['company_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store['address']['region'] ??
                        'Região não especificada'),
                    Row(
                      children: [
                        for (var i = 0; i < store['ranking']; i++)
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 16),
                        for (var i = store['ranking']; i < 7; i++)
                          const Icon(Icons.star_border,
                              color: Colors.yellow, size: 16),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    followingStatus[store['id']] == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: followingStatus[store['id']] == true
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () {
                    if (followingStatus[store['id']] == true) {
                      unfollowStore(store['id']);
                    } else {
                      followStore(store['id']);
                    }
                  },
                ),
                onTap: () {
                  // Ação ao clicar na loja
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
