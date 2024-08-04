import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:meachou/components/loading/loading_dots.dart';
import 'package:meachou/screens/store/widgets/store_profile_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meachou/services/stores_service.dart';

class StoreProfileScreen extends StatefulWidget {
  final String storeId;

  const StoreProfileScreen({Key? key, required this.storeId}) : super(key: key);

  @override
  _StoreProfileScreenState createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  Map<String, dynamic>? store;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchStoreDetails();
  }

  Future<void> _fetchStoreDetails() async {
    try {
      final storeDetails = await StoreService().getStoreDetails(widget.storeId);
      setState(() {
        store = storeDetails;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Falha ao carregar os detalhes da loja';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (isLoading) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            const Center(
              child: LoadingDots(),
            ),
          ],
          if (!isLoading && errorMessage.isNotEmpty)
            Center(
              child: Text(errorMessage),
            ),
          if (!isLoading && errorMessage.isEmpty && store != null)
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoreProfileHeader(
                    store: store!,
                    onTapProfilePicture: (url) => _showImageDialog(url),
                  ),
                  const SizedBox(height: 16),
                  BusinessInfoCard(store: store!),
                  const SizedBox(height: 2),
                  Visibility(
                    visible: _hasContactInfo(),
                    child: Column(
                      children: [
                        ContactInfoCard(store: store!, onTap: _launchURL),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _hasSocialNetworks(),
                    child: Column(
                      children: [
                        SocialNetworksCard(store: store!, onTap: _launchURL),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _hasServiceValues(),
                    child: Column(
                      children: [
                        WorkingHoursAndServicesCard(store: store!),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PhotosSection(
                      store: store!, onTap: (url) => _showImageDialog(url)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir URL: $e')),
      );
    }
  }

  bool _hasContactInfo() {
    return store!['contact_phone']?.isNotEmpty == true ||
        store!['whatsapp_phone']?.isNotEmpty == true ||
        store!['website']?.isNotEmpty == true ||
        store!['email']?.isNotEmpty == true;
  }

  bool _hasSocialNetworks() {
    final socialNetworks = store!['social_networks'] as List<dynamic>?;
    return socialNetworks != null && socialNetworks.isNotEmpty;
  }

  bool _hasServiceValues() {
    return store!['service_values'] != null &&
        store!['service_values'] != 'NaN';
  }
}
