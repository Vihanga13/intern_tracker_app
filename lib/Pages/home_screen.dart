import 'package:flutter/material.dart';
import './add_work_screen.dart';
import './personal_summary_screen.dart';
import './supervisor_dashboard_screen.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardsController;
  late AnimationController _fabController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _fabAnimation;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    // Create staggered animations for cards
    _cardAnimations = List.generate(3, (index) {
      final delay = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsController,
          curve: Interval(
            delay,
            delay + 0.6,
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });

    _cardsController.forward();
    _fabController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardsController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildWelcomeText(),
                        const SizedBox(height: 40),
                        _buildNavigationCards(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWorkScreen(userId: "user123")),
          ),
          backgroundColor: const Color(0xFF4CAF50),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Quick Entry'),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                math.cos(_backgroundAnimation.value),
                math.sin(_backgroundAnimation.value),
              ),
              end: Alignment(
                math.cos(_backgroundAnimation.value + math.pi),
                math.sin(_backgroundAnimation.value + math.pi),
              ),
              colors: const [
                Color(0xFF1E88E5), // Brighter blue
                Color(0xFF0D47A1),
                Color(0xFF311B92), // Deep purple
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Intern Work Tracker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track your progress and growth',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCards() {
    final List<Map<String, dynamic>> cards = [
      {
        'title': 'Add Work Entry',
        'subtitle': 'Record your daily tasks and achievements',
        'icon': Icons.add_task_rounded,
        'colors': [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddWorkEntryPage(userId: "user123")),
        ),
      },
      {
        'title': 'My Summary',
        'subtitle': 'View your performance analytics',
        'icon': Icons.analytics_rounded,
        'colors': [const Color(0xFF2196F3), const Color(0xFF03A9F4)],
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PersonalSummaryScreen(userId: "user123")),
        ),
      },
      {
        'title': 'Supervisor Dashboard',
        'subtitle': 'Monitor team progress and performance',
        'icon': Icons.supervisor_account_rounded,
        'colors': [const Color(0xFF9C27B0), const Color(0xFFE91E63)],
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SupervisorDashboardScreen(supervisorId: "supervisor123"),
          ),
        ),
      },
    ];

    return Expanded(
      child: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _cardAnimations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  50 * (1 - _cardAnimations[index].value),
                ),
                child: Opacity(
                  opacity: _cardAnimations[index].value,
                  child: _buildNavigationCard(
                    cards[index]['title'],
                    cards[index]['subtitle'],
                    cards[index]['icon'],
                    cards[index]['colors'][0],
                    cards[index]['colors'][1],
                    cards[index]['onTap'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNavigationCard(
    String title,
    String subtitle,
    IconData icon,
    Color startColor,
    Color endColor,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [startColor, endColor],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: startColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    icon,
                    size: 120,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddWorkEntryPage extends StatelessWidget {
  final String userId;

  const AddWorkEntryPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Work Entry'),
      ),
      body: Center(
        child: Text('User ID: $userId'),
      ),
    );
  }
}