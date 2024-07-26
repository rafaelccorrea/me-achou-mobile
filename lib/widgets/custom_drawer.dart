import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meachou/screens/follow/followers_screen.dart';
import 'package:meachou/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:meachou/services/auth_service.dart';
import 'package:meachou/services/subscription_client.dart';

class CustomDrawer extends StatefulWidget {
  final bool isOpen;
  final VoidCallback toggleDrawer;
  final String userName;
  final String? userAvatarUrl;

  const CustomDrawer({
    required this.isOpen,
    required this.toggleDrawer,
    required this.userName,
    this.userAvatarUrl,
  });

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late final SubscriptionClient _subscriptionClient;
  final ValueNotifier<String?> _subscriptionStatusNotifier =
      ValueNotifier<String?>('NONE');
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _subscriptionClient =
        Provider.of<SubscriptionClient>(context, listen: false);

    _subscriptionClient.subscriptionStatusStream.listen((status) {
      _updateSubscriptionStatus(status);
    });

    _loadInitialSubscriptionStatus();
  }

  Future<void> _loadInitialSubscriptionStatus() async {
    String? cachedStatus =
        await secureStorage.read(key: SubscriptionClient.subscriptionStatusKey);
    if (cachedStatus != null) {
      _subscriptionStatusNotifier.value = cachedStatus;
    } else {
      AuthService authService =
          Provider.of<AuthService>(context, listen: false);
      authService.getUser().then((userData) {
        if (userData != null &&
            userData['store'] != null &&
            userData['store']['subscription'] != null) {
          _updateSubscriptionStatus(
              userData['store']['subscription']['status']);
        } else {
          _updateSubscriptionStatus('NONE');
        }
      });
    }
  }

  Future<void> _updateSubscriptionStatus(String? status) async {
    if (status != null) {
      await secureStorage.write(
          key: SubscriptionClient.subscriptionStatusKey, value: status);
    } else {
      await secureStorage.delete(key: SubscriptionClient.subscriptionStatusKey);
    }
    _subscriptionStatusNotifier.value = status;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: authService.getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Drawer(
                child: Center(
                    child: Text('Erro ao carregar informações do usuário')),
              );
            } else {
              return ValueListenableBuilder<String?>(
                valueListenable: _subscriptionStatusNotifier,
                builder: (context, subscriptionStatus, child) {
                  return Drawer(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          _buildDrawerHeader(context),
                          _buildUserInfoSection(),
                          if (snapshot.data?['store'] != null &&
                              subscriptionStatus != 'NONE')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Status da assinatura: ',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      subscriptionStatus == 'ACTIVE'
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: subscriptionStatus == 'ACTIVE'
                                          ? Colors.green
                                          : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      subscriptionStatus == 'ACTIVE'
                                          ? 'Ativa'
                                          : 'Inativa',
                                      style: TextStyle(
                                        color: subscriptionStatus == 'ACTIVE'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Divider(color: Colors.grey[300], thickness: 0.5),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildDrawerItem(
                                    context,
                                    icon: Icons.person,
                                    text: 'Meu Perfil',
                                    onTap: () => _navigateTo(
                                        context, const ProfileScreen()),
                                  ),
                                  _buildDrawerItem(context,
                                      icon: Icons.star_rate,
                                      text: 'Avaliações'),
                                  _buildDrawerItem(context,
                                      icon: Icons.article, text: 'Publicações'),
                                  _buildDrawerItem(
                                    context,
                                    icon: Icons.group,
                                    text: 'Seguindo',
                                    onTap: () =>
                                        _navigateTo(context, FollowersScreen()),
                                  ),
                                  _buildDrawerItem(context,
                                      icon: Icons.event_available,
                                      text: 'Eventos'),
                                  if (snapshot.data?['store'] != null)
                                    _buildStoreSection(subscriptionStatus),
                                  if (snapshot.data?['store'] == null)
                                    _buildDrawerItem(
                                      context,
                                      icon: Icons.store,
                                      text: 'Criar Loja',
                                      onTap: () {
                                        // Implementar lógica para criar loja
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 40,
            backgroundImage: widget.userAvatarUrl != null
                ? NetworkImage(widget.userAvatarUrl!)
                : const AssetImage('assets/default_avatar.png')
                    as ImageProvider,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Text(
            widget.userName,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String text, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(text, style: TextStyle(color: Colors.grey[700])),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildStoreSection(String? subscriptionStatus) {
    print('############### $subscriptionStatus');
    if (subscriptionStatus == 'ACTIVE') {
      return _buildExpansionTileForActiveSubscription(context);
    } else if (subscriptionStatus == 'INACTIVE') {
      return _buildExpansionTileForInactiveSubscription(context);
    } else {
      return _buildExpansionTileForNoSubscription(context);
    }
  }

  Widget _buildExpansionTile(BuildContext context,
      {required IconData icon,
      required String text,
      required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(text, style: TextStyle(color: Colors.grey[700])),
        childrenPadding: const EdgeInsets.only(left: 16.0),
        children: children,
      ),
    );
  }

  Widget _buildExpansionTileForActiveSubscription(BuildContext context) {
    return _buildExpansionTile(
      context,
      icon: Icons.store,
      text: 'Minha Loja',
      children: [
        _buildDrawerSubItem(context,
            icon: Icons.person_outline, text: 'Perfil'),
        _buildDrawerSubItem(context,
            icon: Icons.article_outlined, text: 'Publicações'),
        _buildDrawerSubItem(context,
            icon: Icons.rate_review, text: 'Avaliações'),
        _buildDrawerSubItem(context, icon: Icons.campaign, text: 'Campanhas'),
        _buildDrawerSubItem(context, icon: Icons.event, text: 'Eventos'),
        _buildDrawerSubItem(context,
            icon: Icons.subscriptions, text: 'Assinatura'),
        _buildDrawerSubItem(context, icon: Icons.payment, text: 'Cobranças'),
        _buildDrawerSubItem(context, icon: Icons.receipt, text: 'Faturas'),
      ],
    );
  }

  Widget _buildExpansionTileForInactiveSubscription(BuildContext context) {
    return _buildExpansionTile(
      context,
      icon: Icons.store,
      text: 'Minha Loja',
      children: [
        _buildDrawerSubItem(context,
            icon: Icons.person_outline, text: 'Perfil'),
        _buildDrawerSubItem(context,
            icon: Icons.subscriptions, text: 'Assinatura'),
        _buildDrawerSubItem(context, icon: Icons.payment, text: 'Cobranças'),
        _buildDrawerSubItem(context, icon: Icons.receipt, text: 'Faturas'),
      ],
    );
  }

  Widget _buildExpansionTileForNoSubscription(BuildContext context) {
    return _buildExpansionTile(
      context,
      icon: Icons.store,
      text: 'Minha Loja',
      children: [
        _buildDrawerSubItem(context,
            icon: Icons.person_outline, text: 'Perfil'),
        _buildDrawerSubItem(context,
            icon: Icons.subscriptions, text: 'Criar Assinatura'),
      ],
    );
  }

  Widget _buildDrawerSubItem(BuildContext context,
      {required IconData icon, required String text, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(text, style: TextStyle(color: Colors.grey[700])),
      onTap: onTap ?? () {},
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => screen));
  }
}
