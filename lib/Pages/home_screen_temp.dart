import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'add_work_screen.dart';
import 'personal_summary_screen.dart';
import 'supervisor_dashboard_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  // Hardcoded user data
  final String userName = "Vihanga";
  final String userRole = "Software Engineering Intern";
  final String profileImageUrl = "https://via.placeholder.com/100";

  // Daily quotes
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

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

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

  Future<void> _pickAndUploadFile() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
        onFileLoading: (FilePickerStatus status) => print(status),
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Show loading indicator
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Starting upload...'),
            duration: Duration(seconds: 2),
          ),
        );

        if (file.bytes != null) {
          // Create a reference to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('uploads/${DateTime.now().millisecondsSinceEpoch}_${file.name}');

          // Upload file bytes
          final uploadTask = storageRef.putData(
            file.bytes!,
            SettableMetadata(contentType: file.extension),
          );

          // Monitor upload progress
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            if (mounted) {
              final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Uploading: ${progress.toStringAsFixed(1)}%'),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            }
          });

          // Wait for upload to complete
          await uploadTask;
          final downloadUrl = await storageRef.getDownloadURL();

          // Create Firestore record
          await FirebaseFirestore.instance.collection('uploads').add({
            'fileName': file.name,
            'uploadedBy': userName,
            'uploadedAt': FieldValue.serverTimestamp(),
            'fileSize': file.size,
            'fileType': file.extension,
            'downloadUrl': downloadUrl,
          });

          // Show success message
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File ${file.name} uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleButtonTap(String buttonTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$buttonTitle tapped!'),
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );    
    switch (buttonTitle) {
      case 'Add Work Entry':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddWorkEntryPage()));
        break;
      case 'Upload Files':
        _pickAndUploadFile();
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
          HapticFeedback.lightImpact();
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

  Widget _buildActionButtons() {
    final buttons = [
      {
        'icon': Icons.add_circle_outline,
        'title': 'Add Work Entry',
        'subtitle': 'Log your daily tasks',
        'color': const Color(0xFF4FC3F7),
        'gradient': const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
        ),
      },
      {
        'icon': Icons.upload_file,
        'title': 'Upload Files',
        'subtitle': 'Share documents & photos',
        'color': const Color(0xFF9575CD),
        'gradient': const LinearGradient(
          colors: [Color(0xFF9575CD), Color(0xFF7E57C2)],
        ),
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'My Summary',
        'subtitle': 'View your progress',
        'color': const Color(0xFF66BB6A),
        'gradient': const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
        ),
      },
      {
        'icon': Icons.supervisor_account_outlined,
        'title': 'Supervisor Dashboard',
        'subtitle': 'Manage team tasks',
        'color': const Color(0xFFFF7043),
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
        ),
      },
    ];

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final button = entry.value;
          
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
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF667eea),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserInfoCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFF8F9FF),
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
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.3),
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
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 500),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              child: Text('Hi, $userName 👋'),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userRole,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
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
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
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

  Widget _buildBottomSection() {
    final now = DateTime.now();
    final quote = dailyQuotes[now.day % dailyQuotes.length];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
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
                const Icon(
                  Icons.format_quote,
                  color: Color(0xFF667eea),
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6B73FF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildUserInfoCard(),
                      const SizedBox(height: 30),
                      _buildActionButtons(),
                      const SizedBox(height: 30),
                      _buildBottomSection(),
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
}
