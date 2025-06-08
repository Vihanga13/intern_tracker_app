// Import necessary Flutter packages and local screens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import 'add_work_screen.dart';
import 'personal_summary_screen.dart';
import 'supervisor_dashboard_screen.dart';

// Main HomePage widget that represents the home screen of the intern progress tracker
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// State class for HomePage that includes animations using TickerProviderStateMixin
class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  // Animation controllers for different animation effects
  late AnimationController _fadeController;   // Controls fade-in animations
  late AnimationController _scaleController;  // Controls scaling animations
  late AnimationController _slideController;  // Controls sliding animations
  
  // Animation objects that define how elements animate
  late Animation<double> _fadeAnimation;      // Controls opacity transitions
  late Animation<double> _scaleAnimation;     // Controls size transitions
  late Animation<Offset> _slideAnimation;     // Controls position transitions

  // Mock user data (to be replaced with real data in production)
  final String userName = "Vihanga";
  final String userRole = "Software Engineering Intern";
  final String profileImageUrl = "https://via.placeholder.com/100";

  // Collection of motivational quotes displayed daily
  final List<String> dailyQuotes = [
    "Every expert was once a beginner. 🌟",
    "Progress, not perfection. 💪",
    "Your potential is endless. 🚀",
    "Great things take time. ⏰",
    "Believe in your journey. ✨"
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  // Initialize animation controllers and their properties
  void _initializeAnimations() {
    // Set up fade animation (1 second duration)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Set up scale animation (0.8 seconds duration)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Set up slide animation (1.2 seconds duration)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Define animation curves and ranges
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  // Start animations in sequence with slight delays
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Main build method that constructs the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(        // Beautiful gradient background using new color scheme
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryRoyalBlue,
              AppColors.primaryRoyalBlue.withOpacity(0.8),
              AppColors.secondaryCoralOrange.withOpacity(0.6),
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          // CustomScrollView for better scrolling experience
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildUserInfoCard(),      // User profile section
                      const SizedBox(height: 30),
                      _buildActionButtons(),     // Main action buttons
                      const SizedBox(height: 30),
                      _buildBottomSection(),     // Daily quote and date
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a beautiful gradient app bar with animated title
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: const Text(
                'Intern Work Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            );
          },
        ),        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryRoyalBlue,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build user profile card with animations and gradient effects
  Widget _buildUserInfoCard() {    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cardBackground,
                    AppColors.backgroundLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRoyalBlue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 500),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              child: Text('Hi, $userName 👋'),
                            ),
                            const SizedBox(height: 5),                            Text(
                              userRole,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🎯 Ready to track your amazing work today?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build the main action buttons with beautiful gradients and animations
  Widget _buildActionButtons() {    // Define button configurations with new color scheme
    final buttons = [
      {
        'icon': Icons.add_circle_outline,
        'title': 'Add Work Entry',
        'subtitle': 'Log your daily tasks',
        'color': AppColors.secondaryCoralOrange,
        'gradient': AppColors.secondaryGradient,
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'My Summary',
        'subtitle': 'View your progress',
        'color': AppColors.primaryRoyalBlue,
        'gradient': AppColors.primaryGradient,
      },
      {
        'icon': Icons.supervisor_account_outlined,
        'title': 'Supervisor Dashboard',
        'subtitle': 'Manage team tasks',
        'color': AppColors.secondaryCoralOrange,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE74C3C)],
        ),
      },
    ];

    // Animate buttons sliding in from bottom
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final button = entry.value;
          
          // Staggered animation for each button
          return AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 100)),
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildActionButton(
              icon: button['icon'] as IconData,
              title: button['title'] as String,
              subtitle: button['subtitle'] as String,
              gradient: button['gradient'] as LinearGradient,
              onTap: () => _handleButtonTap(button['title'] as String),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Build an individual action button with gradient and hover effects
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();  // Add haptic feedback for better UX
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build bottom section with daily quote and date display
  Widget _buildBottomSection() {
    // Select quote based on the day of the month
    final now = DateTime.now();
    final quote = dailyQuotes[now.day % dailyQuotes.length];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Daily quote card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  color: AppColors.primaryRoyalBlue,
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Date and version display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${now.day}/${now.month}/${now.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Version display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Version',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Handle button taps and navigate to appropriate screens
  void _handleButtonTap(String buttonTitle) {
    // Show feedback snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$buttonTitle tapped!'),
        backgroundColor: AppColors.primaryRoyalBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    
    // Navigate to the appropriate screen based on button title
    switch (buttonTitle) {
      case 'Add Work Entry':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWorkEntryPage()));
        break;
      case 'My Summary':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonalSummaryScreen(userId: userName),
          ),
        );
        break;
      case 'Supervisor Dashboard':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SupervisorDashboardScreen(),
          ),
        );
        break;
    }
  }
}