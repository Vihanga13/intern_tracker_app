import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supervisor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
        brightness: Brightness.light,
      ),
      home: SupervisorDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SupervisorDashboard extends StatefulWidget {
  @override
  _SupervisorDashboardState createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String selectedIntern = 'test_user1';
  String selectedFilter = 'All';
  
  final Map<String, InternData> internData = {
    'test_user1': InternData(
      name: 'Alex Johnson',
      totalHours: 156.5,
      tasksThisWeek: 12,
      mostFrequentWorkType: 'Development',
      weeklyData: [45, 38, 42, 31],
      entries: [
        Entry('Mon', 'Development', 8.5, 'Frontend React work'),
        Entry('Tue', 'Meetings', 2.0, 'Team standup'),
        Entry('Wed', 'Development', 7.5, 'API integration'),
        Entry('Thu', 'Testing', 6.0, 'Unit tests'),
        Entry('Fri', 'Documentation', 4.0, 'README updates'),
      ],
    ),
    'test_user2': InternData(
      name: 'Sarah Chen',
      totalHours: 142.0,
      tasksThisWeek: 9,
      mostFrequentWorkType: 'Design',
      weeklyData: [40, 35, 38, 29],
      entries: [
        Entry('Mon', 'Design', 8.0, 'UI mockups'),
        Entry('Tue', 'Research', 3.5, 'User research'),
        Entry('Wed', 'Design', 7.0, 'Prototype creation'),
        Entry('Thu', 'Meetings', 1.5, 'Design review'),
        Entry('Fri', 'Design', 6.0, 'Final designs'),
      ],
    ),
    'test_user3': InternData(
      name: 'Mike Rodriguez',
      totalHours: 168.5,
      tasksThisWeek: 15,
      mostFrequentWorkType: 'Testing',
      weeklyData: [42, 41, 44, 41],
      entries: [
        Entry('Mon', 'Testing', 8.0, 'Automated tests'),
        Entry('Tue', 'Development', 6.5, 'Bug fixes'),
        Entry('Wed', 'Testing', 7.5, 'QA testing'),
        Entry('Thu', 'Documentation', 3.0, 'Test reports'),
        Entry('Fri', 'Testing', 8.0, 'Performance tests'),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onInternChanged(String? newIntern) {
    if (newIntern != null && newIntern != selectedIntern) {
      setState(() {
        selectedIntern = newIntern;
      });
      _slideController.reset();
      _scaleController.reset();
      _slideController.forward();
      _scaleController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIntern = internData[selectedIntern]!;
    
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  '🧑‍💼 Supervisor Dashboard',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                titlePadding: EdgeInsets.only(left: 24, bottom: 16),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Intern Selector
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildInternSelector(),
                  ),
                  SizedBox(height: 32),
                  
                  // Overview Cards
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildOverviewCards(currentIntern),
                  ),
                  SizedBox(height: 32),
                  
                  // Charts Section
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildChartsSection(),
                  ),
                  SizedBox(height: 32),
                  
                  // Entries Table
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildEntriesTable(currentIntern),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternSelector() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: Color(0xFF6366F1), size: 24),
          SizedBox(width: 16),
          Text(
            'Select Intern:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedIntern,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                  onChanged: _onInternChanged,
                  items: internData.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        '${entry.value.name} (${entry.key})',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF374151),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(InternData intern) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Hours', '${intern.totalHours}h', Icons.access_time, Color(0xFF10B981))),
        SizedBox(width: 16),
        Expanded(child: _buildStatCard('Tasks This Week', '${intern.tasksThisWeek}', Icons.task_alt, Color(0xFF3B82F6))),
        SizedBox(width: 16),
        Expanded(child: _buildStatCard('Primary Work', intern.mostFrequentWorkType, Icons.work_outline, Color(0xFF8B5CF6))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * animationValue),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartsSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparative Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 24),
          Container(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 200,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Color(0xFF374151),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String intern = internData.keys.elementAt(group.x.toInt());
                      return BarTooltipItem(
                        '${internData[intern]!.name}\n${rod.toY.round()}h',
                        TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        String intern = internData.keys.elementAt(value.toInt());
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            internData[intern]!.name.split(' ')[0],
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: internData.entries.map((entry) {
                  int index = internData.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.totalHours,
                        color: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF10B981)][index % 3],
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildEntriesTable(InternData intern) {
    List<Entry> filteredEntries = selectedFilter == 'All' 
        ? intern.entries 
        : intern.entries.where((e) => e.workType == selectedFilter).toList();

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time Entries',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilter = newValue!;
                      });
                    },
                    items: ['All', 'Development', 'Design', 'Testing', 'Meetings', 'Documentation', 'Research']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...filteredEntries.asMap().entries.map((entry) {
            int index = entry.key;
            Entry entryData = entry.value;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, animationValue, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            child: Text(
                              entryData.day,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          Container(
                            width: 100,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getWorkTypeColor(entryData.workType).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entryData.workType,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getWorkTypeColor(entryData.workType),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 60,
                            child: Text(
                              '${entryData.hours}h',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entryData.description,
                              style: TextStyle(
                                color: Color(0xFF6B7280),
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
          }).toList(),
        ],
      ),
    );
  }

  Color _getWorkTypeColor(String workType) {
    switch (workType) {
      case 'Development': return Color(0xFF10B981);
      case 'Design': return Color(0xFF8B5CF6);
      case 'Testing': return Color(0xFFF59E0B);
      case 'Meetings': return Color(0xFF3B82F6);
      case 'Documentation': return Color(0xFF6B7280);
      case 'Research': return Color(0xFFEF4444);
      default: return Color(0xFF6B7280);
    }
  }
}

class InternData {
  final String name;
  final double totalHours;
  final int tasksThisWeek;
  final String mostFrequentWorkType;
  final List<int> weeklyData;
  final List<Entry> entries;

  InternData({
    required this.name,
    required this.totalHours,
    required this.tasksThisWeek,
    required this.mostFrequentWorkType,
    required this.weeklyData,
    required this.entries,
  });
}

class Entry {
  final String day;
  final String workType;
  final double hours;
  final String description;

  Entry(this.day, this.workType, this.hours, this.description);
}