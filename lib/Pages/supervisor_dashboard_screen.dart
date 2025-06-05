import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/work_entry.dart';
import '../utils/app_colors.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> 
    with TickerProviderStateMixin {
  String? selectedInternId;
  String? selectedInternName;
  List<Map<String, dynamic>> allInterns = [];
  List<WorkEntry> selectedInternEntries = [];
  bool isLoading = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _loadAllInterns();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAllInterns() async {
    try {
      setState(() => isLoading = true);
      
      // Get all unique intern IDs and names from work entries
      final snapshot = await FirebaseFirestore.instance
          .collection('work_entries')
          .get();
      
      final Set<String> seenInterns = {};
      final List<Map<String, dynamic>> internsList = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final internId = data['internId'] as String?;
        final internName = data['internName'] as String?;
        
        if (internId != null && internName != null && !seenInterns.contains(internId)) {
          seenInterns.add(internId);
          internsList.add({
            'id': internId,
            'name': internName,
          });
        }
      }
      
      setState(() {
        allInterns = internsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading interns: $e')),
        );
      }
    }
  }

  Future<void> _loadInternData(String internId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('work_entries')
          .where('internId', isEqualTo: internId)
          .orderBy('date')
          .get();
      
      final entries = snapshot.docs
          .map((doc) => WorkEntry.fromMap(doc.data(), doc.id))
          .toList();
      
      setState(() {
        selectedInternEntries = entries;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading intern data: $e')),
        );
      }
    }
  }

  Map<String, dynamic> _calculateStats(List<WorkEntry> entries) {
    if (entries.isEmpty) {
      return {
        'totalHours': 0.0,
        'averageHours': 0.0,
        'lastUpdated': 'No entries',
        'totalDays': 0,
      };
    }
    
    final totalHours = entries.fold(0.0, (sum, entry) => sum + entry.hoursWorked);
    final averageHours = totalHours / entries.length;
    final lastEntry = entries.last;
    
    return {
      'totalHours': totalHours,
      'averageHours': averageHours,
      'lastUpdated': '${lastEntry.date.day}/${lastEntry.date.month}/${lastEntry.date.year}',
      'totalDays': entries.length,
    };
  }

  Future<List<Map<String, dynamic>>> _getAllInternsStats() async {
    final List<Map<String, dynamic>> stats = [];
    
    for (var intern in allInterns) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('work_entries')
            .where('internId', isEqualTo: intern['id'])
            .get();
        
        final entries = snapshot.docs
            .map((doc) => WorkEntry.fromMap(doc.data(), doc.id))
            .toList();
        
        final internStats = _calculateStats(entries);
        stats.add({
          'name': intern['name'],
          'id': intern['id'],
          ...internStats,
        });
      } catch (e) {
        // Continue with other interns if one fails
      }
    }
    
    // Sort by total hours descending
    stats.sort((a, b) => (b['totalHours'] as double).compareTo(a['totalHours'] as double));
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue.withOpacity(0.1),
              AppColors.accentPurple.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: CustomScrollView(
                      slivers: [
                        _buildAppBar(),
                        _buildInternSelector(),
                        if (selectedInternId != null) ...[
                          _buildOverviewCards(),
                          _buildChartsSection(),
                        ],
                        _buildComparisonSection(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.accentPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Text(
                  '👨‍💼 Supervisor Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Monitor intern progress and performance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInternSelector() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👥 Select Intern',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedInternId,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Choose an intern to view details'),
                  ),
                  isExpanded: true,
                  items: allInterns.map((intern) {
                    return DropdownMenuItem<String>(
                      value: intern['id'],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(intern['name']),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedInternId = value;
                        selectedInternName = allInterns
                            .firstWhere((intern) => intern['id'] == value)['name'];
                      });
                      _loadInternData(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final stats = _calculateStats(selectedInternEntries);
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                '📊 Overview for $selectedInternName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Row(
              children: [
                _buildStatCard(
                  icon: '⏰',
                  title: 'Total Hours',
                  value: '${stats['totalHours'].toStringAsFixed(1)}h',
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  icon: '📈',
                  title: 'Average Hours',
                  value: '${stats['averageHours'].toStringAsFixed(1)}h',
                  color: AppColors.accentGreen,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  icon: '📅',
                  title: 'Total Days',
                  value: '${stats['totalDays']}',
                  color: AppColors.accentPurple,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  icon: '🕒',
                  title: 'Last Updated',
                  value: stats['lastUpdated'],
                  color: AppColors.accentOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Progress Chart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: selectedInternEntries.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 2,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.3),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.3),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() < selectedInternEntries.length) {
                                  final entry = selectedInternEntries[value.toInt()];
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      '${entry.date.day}/${entry.date.month}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  '${value.toInt()}h',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                );
                              },
                              reservedSize: 32,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),                        minX: 0,
                        maxX: (selectedInternEntries.length - 1).toDouble(),
                        minY: 0,
                        maxY: selectedInternEntries.isEmpty 
                            ? 10 
                            : selectedInternEntries
                                .map((e) => e.hoursWorked)
                                .reduce((a, b) => a > b ? a : b) + 2,
                        lineBarsData: [
                          LineChartBarData(
                            spots: selectedInternEntries
                                .asMap()
                                .entries
                                .map((entry) => FlSpot(
                                    entry.key.toDouble(), entry.value.hoursWorked))
                                .toList(),
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.accentPurple,
                              ],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.primaryBlue,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primaryBlue.withOpacity(0.3),
                                  AppColors.primaryBlue.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 All Interns Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getAllInternsStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
                
                final stats = snapshot.data!;
                
                return Column(
                  children: [
                    // Summary stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            '👥',
                            'Total Interns',
                            '${stats.length}',
                          ),
                          _buildSummaryItem(
                            '⏰',
                            'Total Hours',
                            '${stats.fold(0.0, (sum, intern) => sum + (intern['totalHours'] as double)).toStringAsFixed(1)}h',
                          ),
                          _buildSummaryItem(
                            '📊',
                            'Avg Hours/Intern',
                            '${(stats.fold(0.0, (sum, intern) => sum + (intern['totalHours'] as double)) / stats.length).toStringAsFixed(1)}h',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Comparison table
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          AppColors.primaryBlue.withOpacity(0.1),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Rank',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Intern Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Total Hours',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Avg Hours',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: stats.asMap().entries.map((entry) {
                          final index = entry.key;
                          final intern = entry.value;
                          final isSelected = intern['id'] == selectedInternId;
                          
                          return DataRow(
                            color: MaterialStateProperty.all(
                              isSelected 
                                  ? AppColors.accentGreen.withOpacity(0.1)
                                  : null,
                            ),
                            cells: [
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRankColor(index),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '#${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  intern['name'],
                                  style: TextStyle(
                                    fontWeight: isSelected 
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected 
                                        ? AppColors.accentGreen
                                        : null,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text('${intern['totalHours'].toStringAsFixed(1)}h'),
                              ),
                              DataCell(
                                Text('${intern['averageHours'].toStringAsFixed(1)}h'),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String icon, String title, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey; // Silver
      case 2:
        return Colors.brown; // Bronze
      default:
        return AppColors.primaryBlue;
    }
  }
}