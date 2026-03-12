import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import '../widgets/category_card.dart';
import '../widgets/community_win_card.dart';
import '../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  late Future<List<dynamic>> _winsFuture;

  final _categories = const [
    (
      'E-commerce & Shopping',
      Icons.shopping_bag,
      'Refunds, fake products, seller disputes'
    ),
    (
      'Banking & UPI Fraud',
      Icons.account_balance,
      'Unauthorized transactions, card fraud'
    ),
    (
      'Flights & Travel Issues',
      Icons.flight,
      'Cancellations, delays, refund denials'
    ),
    (
      'Restaurant & Food Billing',
      Icons.restaurant,
      'Overcharging, GST violations, food quality'
    ),
    (
      'Hospital Billing Problems',
      Icons.local_hospital,
      'Overcharging, denied treatment, billing errors'
    ),
    (
      'Traffic & Vehicle Issues',
      Icons.directions_car,
      'Wrong challans, accidents, license issues'
    ),
    (
      'Telecom & Internet Services',
      Icons.wifi,
      'Data theft, billing disputes, poor service'
    ),
    (
      'Education & Coaching Complaints',
      Icons.school,
      'Fee refunds, false promises, certificates'
    ),
    (
      'Rental & Housing Issues',
      Icons.home,
      'Deposit disputes, illegal eviction, repairs'
    ),
    (
      'Government Service Problems',
      Icons.account_balance_wallet,
      'Delayed services, corruption, document issues'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _winsFuture = _loadWins();
  }

  Future<List<dynamic>> _loadWins() async {
    final raw = await rootBundle.loadString('assets/community_wins.json');
    return json.decode(raw) as List<dynamic>;
  }

  void _onTab(int index) {
    setState(() => _tabIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        context.go('/home/cases');
        break;
      case 2:
        context.go('/home/authorities');
        break;
      case 3:
        context.go('/home/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JusLegal'),
        centerTitle: false,
        actions: const [
          Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.notifications_none))
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Know Your Rights',
                style: TextStyle(color: AppColors.trustNavy.withOpacity(0.7))),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final c = _categories[index];
                  return CategoryCard(
                    icon: c.$2,
                    title: c.$1,
                    description: c.$3,
                    index: index,
                    onTap: () => context.go(
                        '/home/analyzer?category=${Uri.encodeComponent(c.$1)}'),
                  );
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🏆 Community Wins',
                        style: TextStyle(
                          fontWeight: FontWeight.w700, 
                          fontSize: 18,
                          color: AppColors.surfaceWhite,
                        )),
                    SizedBox(height: 4),
                    Text('Real legal victories from citizens like you',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.surfaceWhite,
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder(
                future: _winsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator()));
                  }
                  final wins = snapshot.data!;
                  return SizedBox(
                    height: 170,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
                        final w = wins[i] as Map<String, dynamic>;
                        return CommunityWinCard(
                          city: w['city'],
                          category: w['category'],
                          outcome: w['outcome'],
                          law: w['law'],
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: wins.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _onTab,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.folder_open), label: 'My Cases'),
          NavigationDestination(
              icon: Icon(Icons.gavel_outlined), label: 'Authorities'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
