import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Mock class for demonstration when Firestore is not available
class MockDocumentSnapshot extends QueryDocumentSnapshot {
  final Map<String, dynamic> _data;
  
  MockDocumentSnapshot(this._data);
  
  @override
  Map<String, dynamic> data() => _data;
  
  @override
  String get id => 'mock_${_data.hashCode}';
  
  @override
  DocumentReference get reference => throw UnimplementedError();
  
  @override
  bool get exists => true;
  
  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
  
  @override
  dynamic operator [](Object field) => _data[field];
  
  @override
  dynamic get(Object field) => _data[field];
}

class PersonalSummaryView extends StatefulWidget {
  final String userId;
  
  const PersonalSummaryView({
    Key? key,
    this.userId = 'test_user1', // Default hardcoded user
  }) : super(key: key);

  @override
  State<PersonalSummaryView> createState() => _PersonalSummaryViewState();
}

class _PersonalSummaryViewState extends State<PersonalSummaryView>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _chartController;
  late Animation<double> _slideAnimation;
  late Animation<double> _chartAnimation;
  
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedWorkType;
  
  List<QueryDocumentSnapshot> _allEntries = [];
  List<QueryDocumentSnapshot> _filteredEntries = [];
  bool _isLoading = true;
  
  final List<String> _workTypes = [
    'All Types',
    'Coding',
    'Design',
    'Meeting',
    'Documentation',
    'Testing',
    'Research',
    'Planning',
    'Review'
  ];
  
  final List<Color> _chartColors = [
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFFEC4899), // Pink
    const Color(0xFF84CC16), // Lime
  ];

  @override
  void initState() {
    super.initState();
    _selectedWorkType = _workTypes.first;
    _initializeAnimations();
    _fetchData();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeInOutBack,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('work_entries')
          .where('name', isEqualTo: widget.userId)
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _allEntries = snapshot.docs;
        _filteredEntries = List.from(_allEntries);
        _isLoading = false;
      });
      
      // If no data found, generate sample data
      if (_allEntries.isEmpty) {
        await _generateSampleData();
        return;
      }
      
      _slideController.forward();
      _chartController.forward();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error and generate sample data as fallback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Using sample data: ${e.toString()}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      await _generateSampleData();
    }
  }

  Future<void> _generateSampleData() async {
    try {
      // Generate sample work entries for the past 2 weeks
      final sampleEntries = <Map<String, dynamic>>[];
      final now = DateTime.now();
      
      for (int i = 0; i < 14; i++) {
        final date = now.subtract(Duration(days: i));
        final workTypes = ['Coding', 'Design', 'Meeting', 'Documentation', 'Testing'];
        final workType = workTypes[i % workTypes.length];
        final duration = 2.0 + (i % 6); // 2-7 hours
        
        sampleEntries.add({
          'name': widget.userId,
          'workTitle': 'Sample ${workType} Task ${i + 1}',
          'description': 'This is a sample ${workType.toLowerCase()} task for demonstration',
          'date': Timestamp.fromDate(date),
          'workType': workType,
          'duration': duration,
          'createdAt': Timestamp.now(),
        });
      }
      
      // Add sample entries to Firestore
      final batch = FirebaseFirestore.instance.batch();
      for (final entry in sampleEntries) {
        final docRef = FirebaseFirestore.instance.collection('work_entries').doc();
        batch.set(docRef, entry);
      }
      await batch.commit();
      
      // Refresh data
      await _fetchData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data generated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
    } catch (e) {
      // If Firestore fails, use local sample data
      _createLocalSampleData();
    }
  }

  void _createLocalSampleData() {
    final now = DateTime.now();
    final sampleDocs = <QueryDocumentSnapshot>[];
    
    for (int i = 0; i < 14; i++) {
      final date = now.subtract(Duration(days: i));
      final workTypes = ['Coding', 'Design', 'Meeting', 'Documentation', 'Testing'];
      final workType = workTypes[i % workTypes.length];
      final duration = 2.0 + (i % 6); // 2-7 hours
      
      final mockDoc = MockDocumentSnapshot({
        'name': widget.userId,
        'workTitle': 'Sample ${workType} Task ${i + 1}',
        'description': 'This is a sample ${workType.toLowerCase()} task for demonstration',
        'date': Timestamp.fromDate(date),
        'workType': workType,
        'duration': duration,
        'createdAt': Timestamp.now(),
      });
      
      sampleDocs.add(mockDoc as QueryDocumentSnapshot);
    }
    
    setState(() {
      _allEntries = sampleDocs;
      _filteredEntries = List.from(_allEntries);
      _isLoading = false;
    });
    
    _slideController.forward();
    _chartController.forward();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using local sample data for demonstration'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEntries = _allEntries.where((entry) {
        final data = entry.data() as Map<String, dynamic>;
        final entryDate = (data['date'] as Timestamp).toDate();
        final workType = data['workType'] as String;
        
        // Date filter
        if (_startDate != null && entryDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && entryDate.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }
        
        // Work type filter
        if (_selectedWorkType != null && 
            _selectedWorkType != 'All Types' && 
            workType != _selectedWorkType) {
          return false;
        }
        
        return true;
      }).toList();
    });
    
    // Restart chart animation
    _chartController.reset();
    _chartController.forward();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedWorkType = _workTypes.first;
      _filteredEntries = List.from(_allEntries);
    });
    _chartController.reset();
    _chartController.forward();
  }

  Map<String, double> _getWorkTypeData() {
    final Map<String, double> workTypeHours = {};
    
    for (final entry in _filteredEntries) {
      final data = entry.data() as Map<String, dynamic>;
      final workType = data['workType'] as String;
      final duration = (data['duration'] as num).toDouble();
      
      workTypeHours[workType] = (workTypeHours[workType] ?? 0) + duration;
    }
    
    return workTypeHours;
  }

  Map<String, double> _getDateData() {
    final Map<String, double> dateHours = {};
    
    for (final entry in _filteredEntries) {
      final data = entry.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final duration = (data['duration'] as num).toDouble();
      final dateKey = DateFormat('MMM dd').format(date);
      
      dateHours[dateKey] = (dateHours[dateKey] ?? 0) + duration;
    }
    
    return dateHours;
  }

  double get _totalHours {
    return _filteredEntries.fold(0.0, (sum, entry) {
      final data = entry.data() as Map<String, dynamic>;
      return sum + (data['duration'] as num).toDouble();
    });
  }

  int get _totalTasks {
    return _filteredEntries.length;
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 50 * (index + 1)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
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

  Widget _buildPieChart() {
    final workTypeData = _getWorkTypeData();
    if (workTypeData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
          ),
        ),
      );
    }

    final sections = workTypeData.entries.map((entry) {
      final index = workTypeData.keys.toList().indexOf(entry.key);
      final color = _chartColors[index % _chartColors.length];
      final percentage = (entry.value / _totalHours * 100);
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _chartAnimation.value,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: workTypeData.entries.map((entry) {
                  final index = workTypeData.keys.toList().indexOf(entry.key);
                  final color = _chartColors[index % _chartColors.length];
                  
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.key} (${entry.value.toStringAsFixed(1)}h)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart() {
    final dateData = _getDateData();
    if (dateData.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
          ),
        ),
      );
    }

    final sortedEntries = dateData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final barGroups = sortedEntries.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value,
            color: const Color(0xFF6366F1),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _chartAnimation.value,
          child: SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < sortedEntries.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              sortedEntries[value.toInt()].key,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE2E8F0),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '📊 Personal Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading your data...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _filteredEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Data Available',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No work entries found for ${widget.userId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _generateSampleData,
                        icon: const Icon(Icons.add_chart),
                        label: const Text('Generate Sample Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _fetchData,
                        child: const Text('Refresh Data'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _slideAnimation.value) * 30),
                        child: Opacity(
                          opacity: _slideAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF6366F1),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.userId,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'Intern',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Filters
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _slideAnimation.value) * 40),
                        child: Opacity(
                          opacity: _slideAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filters',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: _selectDateRange,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFFE2E8F0),
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.date_range,
                                                size: 16,
                                                color: Color(0xFF6B7280),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _startDate != null && _endDate != null
                                                      ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                                                      : 'Select Date Range',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: _startDate != null && _endDate != null
                                                        ? const Color(0xFF374151)
                                                        : const Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedWorkType,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE2E8F0),
                                            ),
                                          ),
                                        ),
                                        items: _workTypes.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(
                                              type,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedWorkType = value;
                                          });
                                          _applyFilters();
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      onPressed: _clearFilters,
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Color(0xFF6B7280),
                                        size: 20,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: const Color(0xFFF1F5F9),
                                        padding: const EdgeInsets.all(8),
                                        minimumSize: const Size(36, 36),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Hours',
                          value: _totalHours.toStringAsFixed(1),
                          icon: Icons.access_time,
                          color: const Color(0xFF6366F1),
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Tasks Completed',
                          value: _totalTasks.toString(),
                          icon: Icons.task_alt,
                          color: const Color(0xFF10B981),
                          index: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Charts
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, (1 - _slideAnimation.value) * 60),
                        child: Opacity(
                          opacity: _slideAnimation.value,
                          child: Column(
                            children: [
                              // Pie Chart
                              Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hours by Work Type',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildPieChart(),
                                  ],
                                ),
                              ),

                              // Bar Chart
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Hours by Date',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildBarChart(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
      floatingActionButton: !_isLoading && _filteredEntries.isNotEmpty
          ? FloatingActionButton(
              onPressed: _fetchData,
              backgroundColor: const Color(0xFF6366F1),
              child: const Icon(Icons.refresh, color: Colors.white),
            )
          : null,
    );
  }
}