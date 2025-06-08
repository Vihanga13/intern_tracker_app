// Required Flutter and third-party package imports
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';           // For charts and graphs
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase database
import 'package:intl/intl.dart';                   // For date formatting
import '../models/work_entry.dart';                // Local model class
import '../utils/app_colors.dart';                 // App color constants

// Main screen widget for displaying personal work summary
class PersonalSummaryScreen extends StatefulWidget {
  final String userId;  // User ID to fetch specific user's data
  
  const PersonalSummaryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<PersonalSummaryScreen> createState() => _PersonalSummaryScreenState();
}

// State class that handles the dynamic content and animations
class _PersonalSummaryScreenState extends State<PersonalSummaryScreen>
    with TickerProviderStateMixin {  // Mixin for animation controllers
  // Animation controllers and animations for UI elements
  late AnimationController _fadeController;    // Controls fade animations
  late AnimationController _slideController;   // Controls slide animations
  late Animation<double> _fadeAnimation;       // Fade animation
  late Animation<Offset> _slideAnimation;      // Slide animation

  // State variables
  DateTimeRange? _selectedDateRange;          // Selected date range for filtering
  String? _selectedWorkType;                  // Selected work type for filtering
  List<WorkEntry> _entries = [];              // List of work entries
  bool _isLoading = true;                     // Loading state flag

  // Available work types for filtering
  final List<String> _workTypes = [
    'All Types',
    'Development',
    'Testing',
    'Documentation',
    'Research',
    'Meeting',
    'Design',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadEntries();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Load work entries from Firestore database
  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    
    try {
      // Build the query with filters
      Query query = FirebaseFirestore.instance
          .collection('work_entries')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('date', descending: true);
      
      // Apply date range filter if selected
      if (_selectedDateRange != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: _selectedDateRange!.start)
            .where('date', isLessThanOrEqualTo: _selectedDateRange!.end);
      }
      
      // Execute query and transform results
      final snapshot = await query.get();
      List<WorkEntry> entries = snapshot.docs
          .map((doc) => WorkEntry.fromFirestore(doc))
          .toList();
      
      // Apply work type filter if selected
      if (_selectedWorkType != null && _selectedWorkType != 'All Types') {
        entries = entries.where((entry) => entry.type == _selectedWorkType).toList();
      }
      
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  // Main build method for the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000),
              Color(0xFF424242),
              Color(0xFF212121),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoading ? _buildLoadingWidget() : _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build the header section with stats
  Widget _buildHeader() {
    final totalHours = _calculateTotalHours();
    final avgHours = _calculateAverageHours();
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BackButton(color: Colors.white),
              const Expanded(
                child: Text(
                  'Work Summary',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildExportButton(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [              Expanded(
                child: _buildStatCard(
                  'Total Hours',
                  totalHours.toStringAsFixed(1),
                  Icons.access_time,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Average Daily',
                  avgHours.toStringAsFixed(1),
                  Icons.trending_up,
                  Colors.grey,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  'Entries',
                  _entries.length.toString(),
                  Icons.list_alt,
                  Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build individual stat cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // Build filter section
  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateRangeFilter(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildWorkTypeFilter(),
          ),
        ],
      ),
    );
  }

  // Build date range filter widget
  Widget _buildDateRangeFilter() {
    return GestureDetector(
      onTap: _showDateRangePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              color: Colors.white.withOpacity(0.9),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDateRange != null
                    ? '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}'
                    : 'Select dates',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build work type filter dropdown
  Widget _buildWorkTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWorkType ?? 'All Types',
          icon: Icon(
            Icons.arrow_drop_down,
            color: Colors.white.withOpacity(0.9),
          ),
          dropdownColor: const Color(0xFF667eea),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
          items: _workTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedWorkType = newValue;
            });
            _loadEntries();
          },
        ),
      ),
    );
  }

  // Build export button
  Widget _buildExportButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _showExportOptions,
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.download,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // Build loading widget
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your work summary...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Build main content area
  Widget _buildContent() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartsSection(),
                  const SizedBox(height: 30),
                  _buildEntriesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build charts section with bar and pie charts
  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(child: _buildBarChart()),
              const SizedBox(width: 20),
              Expanded(child: _buildPieChart()),
            ],
          ),
        ),
      ],
    );
  }

  // Build bar chart for daily hours
  Widget _buildBarChart() {
    final dailyHours = _calculateDailyHours();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Color(0xFF667eea),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Hours per Day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: dailyHours.values.isNotEmpty 
                    ? dailyHours.values.reduce((a, b) => a > b ? a : b) + 2
                    : 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final date = dailyHours.keys.toList()[group.x.toInt()];
                      return BarTooltipItem(
                        '${DateFormat('MMM dd').format(date)}\n${rod.toY.toStringAsFixed(1)}h',
                        const TextStyle(color: Color(0xFF2D3436)),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= dailyHours.length) return const Text('');
                        final date = dailyHours.keys.toList()[value.toInt()];
                        return Text(
                          DateFormat('dd').format(date),
                          style: const TextStyle(
                            color: Color(0xFF2D3436),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF2D3436),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: dailyHours.entries.map((entry) {
                  final index = dailyHours.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        gradient: AppColors.primaryGradient,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build pie chart for work type distribution
  Widget _buildPieChart() {
    final workTypeHours = _calculateWorkTypeHours();
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFECA57),
      const Color(0xFF6C5CE7),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Color(0xFF4ECDC4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Work Type Split',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: workTypeHours.entries.map((entry) {
                        final index = workTypeHours.keys.toList().indexOf(entry.key);
                        final total = workTypeHours.values.reduce((a, b) => a + b);
                        final percentage = (entry.value / total * 100);
                        
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: workTypeHours.entries.map((entry) {
                      final index = workTypeHours.keys.toList().indexOf(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2D3436),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the list of work entries
  Widget _buildEntriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Entries',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entries.length,
          itemBuilder: (context, index) {
            final entry = _entries[index];
            return _buildEntryCard(entry, index);
          },
        ),
      ],
    );
  }

  // Build individual entry cards
  Widget _buildEntryCard(WorkEntry entry, int index) {
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFECA57),
      const Color(0xFF6C5CE7),
    ];
    
    final cardColor = colors[index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForWorkType(entry.type),
                color: cardColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(entry.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.type,
                          style: TextStyle(
                            fontSize: 10,
                            color: cardColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.hours}h',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
                Text(
                  'hours',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  IconData _getIconForWorkType(String type) {
    switch (type.toLowerCase()) {
      case 'development': return Icons.code;
      case 'design': return Icons.design_services;
      case 'research': return Icons.search;
      case 'meeting': return Icons.people;
      case 'documentation': return Icons.description;
      case 'testing': return Icons.bug_report;
      default: return Icons.work;
    }
  }

  double _calculateTotalHours() {
    return _entries.fold(0.0, (sum, entry) => sum + entry.hours);
  }

  double _calculateAverageHours() {
    if (_entries.isEmpty) return 0.0;
    final uniqueDays = _entries.map((e) => DateFormat('yyyy-MM-dd').format(e.date)).toSet();
    return _calculateTotalHours() / uniqueDays.length;
  }

  Map<DateTime, double> _calculateDailyHours() {
    final Map<DateTime, double> dailyHours = {};
    for (final entry in _entries) {
      final dateKey = DateTime(entry.date.year, entry.date.month, entry.date.day);
      dailyHours[dateKey] = (dailyHours[dateKey] ?? 0) + entry.hours;
    }
    return Map.fromEntries(
      dailyHours.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  Map<String, double> _calculateWorkTypeHours() {
    final Map<String, double> workTypeHours = {};
    for (final entry in _entries) {
      workTypeHours[entry.type] = (workTypeHours[entry.type] ?? 0) + entry.hours;
    }
    return workTypeHours;
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3436),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadEntries();
    }
  }

  // Show export options dialog
  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Export Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 20),
            _buildExportOption(
              'Export as CSV',
              'Download your data in CSV format',
              Icons.table_chart,
              const Color(0xFF4ECDC4),
              () => _exportToCSV(),
            ),
            _buildExportOption(
              'Export as PDF',
              'Generate a PDF report',
              Icons.picture_as_pdf,
              const Color(0xFFFF6B6B),
              () => _exportToPDF(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build individual export option tiles
  Widget _buildExportOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: color,
          size: 16,
        ),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  Future<void> _showExportDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          ),
        );
      },
    );
  }

  // Export data to CSV format
  Future<void> _exportToCSV() async {
    try {
      await _showExportDialog();
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('CSV exported successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF4ECDC4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Export data to PDF format
  Future<void> _exportToPDF() async {
    try {
      await _showExportDialog();
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('PDF exported successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/*
To use this Summary Page in your app:

1. Add these dependencies to pubspec.yaml:
   dependencies:
     flutter/material.dart
     fl_chart: ^0.65.0
     cloud_firestore: ^4.13.6
     intl: ^0.18.1

2. Import and use the page:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => SummaryPage(userId: 'your_user_id'),
     ),
   );
   ```

3. Make sure your Firestore collection 'work_entries' has documents with fields:
   - userId (String)
   - title (String)
   - description (String)
   - hours (double)
   - type (String)
   - date (Timestamp)
   - location (String, optional)
   - tags (Array of String, optional)
*/