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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.trustNavy, Color(0xFF2C3E7C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.balance, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 9),
            const Text(
              'JusLegal',
              style: TextStyle(
                color: AppColors.textDarkGrey,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(Icons.notifications_none_rounded,
                      color: AppColors.textDarkGrey, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Banner ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 24 : 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B2B6B), Color(0xFF2C3E7C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.trustNavy.withOpacity(0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.justiceGold.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: AppColors.justiceGold, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'AI-Powered Legal Guidance',
                              style: TextStyle(
                                color: AppColors.justiceGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Know Your Rights',
                        style: TextStyle(
                          fontSize: isTablet ? 26 : 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select a category to get instant AI-powered legal guidance for your situation.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.72),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Section Header ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.justiceGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Legal Categories',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDarkGrey,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_categories.length} topics',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMediumGrey.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Category Grid ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = isTablet ? (screenWidth > 900 ? 4 : 3) : 2;
                    // Fix: use SliverGrid crossAxisExtent approach to avoid
                    // overflow — using explicit pixel height per cell
                    final cellWidth =
                        (constraints.maxWidth - (cols - 1) * 12.0) / cols;
                    final cellHeight = cellWidth * 1.18;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(_categories.length, (index) {
                        final c = _categories[index];
                        return SizedBox(
                          width: cellWidth,
                          height: cellHeight,
                          child: CategoryCard(
                            icon: c.$2,
                            title: c.$1,
                            description: c.$3,
                            index: index,
                            onTap: () => context.go(
                                '/home/analyzer?category=${Uri.encodeComponent(c.$1)}'),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // ── Community Wins Header ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B2B6B), Color(0xFF2C4099)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.trustNavy.withOpacity(0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('🏆',
                            style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Community Wins',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Real victories from citizens like you',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xAAFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Community Wins Horizontal List ───────────────────
              FutureBuilder(
                future: _winsFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator()));
                  }
                  final wins = snapshot.data!;
                  return SizedBox(
                    height: 175,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, i) {
                        final w = wins[i] as Map<String, dynamic>;
                        return CommunityWinCard(
                          city: w['city'],
                          category: w['category'],
                          outcome: w['outcome'],
                          law: w['law'],
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                      itemCount: wins.length,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── Disclaimer footer ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 13,
                        color: AppColors.textMediumGrey.withOpacity(0.6)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'AI guidance only · Not a substitute for legal advice',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMediumGrey.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
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
              icon: Icon(Icons.folder_open_rounded),
              selectedIcon: Icon(Icons.folder_rounded),
              label: 'My Cases'),
          NavigationDestination(
              icon: Icon(Icons.gavel_outlined),
              selectedIcon: Icon(Icons.gavel),
              label: 'Authorities'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}
