// Importing required packages
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'dart:io';

// Define WorkEntry model class
class WorkEntry {
  final String id;
  final String title;
  final String type;
  final double hours;
  final DateTime date;
  final String description;
  final String? attachmentUrl;

  const WorkEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.hours,
    required this.date,
    required this.description,
    this.attachmentUrl,
  });

  factory WorkEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkEntry(
      id: doc.id,
      title: data['workTitle'] ?? '',
      type: data['workType'] ?? '',
      hours: (data['duration'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      attachmentUrl: data['attachmentUrl'],
    );
  }

  Map<String, dynamic> toCsv() {
    return {
      'Date': DateFormat('yyyy-MM-dd').format(date),
      'Title': title,
      'Type': type,
      'Hours': hours,
      'Description': description,
    };
  }
}

// Define PersonalSummaryScreen widget
class PersonalSummaryScreen extends StatefulWidget {
  final String userId;

  const PersonalSummaryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<PersonalSummaryScreen> createState() => _PersonalSummaryScreenState();
}

// Define PersonalSummaryScreen state
class _PersonalSummaryScreenState extends State<PersonalSummaryScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _slideController;
  late final AnimationController _chartController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _chartAnimation;

  // State variables
  bool _isLoading = false;
  List<WorkEntry> _filteredEntries = [];
  List<WorkEntry> _allEntries = [];
  Map<String, double> _typeDistribution = {};
  double _totalHours = 0;
  double _averageHoursPerDay = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedWorkType;

  // Constants
  final List<String> _workTypes = [
    'All',
    'Feature',
    'Bug Fix',
    'Research',
    'Meeting',
    'Documentation',
    'Testing',
    'Review',
    'Other'
  ];

  final List<Color> _chartColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchData();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    );

    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutBack,
    );

    _slideController.forward().then((_) {
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('work_entries')
          .where('userId', isEqualTo: widget.userId)
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _allEntries = querySnapshot.docs
            .map((doc) => WorkEntry.fromFirestore(doc))
            .toList();
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    _filteredEntries = _allEntries.where((entry) {
      bool dateFilter = true;
      if (_startDate != null && _endDate != null) {
        dateFilter = entry.date.isAfter(_startDate!) && 
                    entry.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }

      bool typeFilter = true;
      if (_selectedWorkType != null && _selectedWorkType != 'All') {
        typeFilter = entry.type == _selectedWorkType;
      }

      return dateFilter && typeFilter;
    }).toList();

    _calculateMetrics();
  }

  void _calculateMetrics() {
    _totalHours = _filteredEntries.fold(0, (sum, entry) => sum + entry.hours);
    
    if (_filteredEntries.isNotEmpty) {
      final days = _filteredEntries
          .map((e) => DateFormat('yyyy-MM-dd').format(e.date))
          .toSet()
          .length;
      _averageHoursPerDay = _totalHours / days;
    } else {
      _averageHoursPerDay = 0;
    }

    _typeDistribution = {};
    for (var entry in _filteredEntries) {
      _typeDistribution[entry.type] = 
          (_typeDistribution[entry.type] ?? 0) + entry.hours;
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null && mounted) {
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
      _selectedWorkType = null;
      _filteredEntries = _allEntries;
      _calculateMetrics();
    });
  }

  Future<void> _exportToCsv() async {
    try {
      final headers = ['Date', 'Title', 'Type', 'Hours', 'Description'];
      final rows = _filteredEntries.map((e) => e.toCsv().values.toList()).toList();
      rows.insert(0, headers);

      final csvData = const ListToCsvConverter().convert(rows);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/work_report.csv');
      await file.writeAsString(csvData);

      if (mounted) {
        await Share.shareFiles(
          [file.path],
          text: 'Work Report (${DateFormat('yyyy-MM-dd').format(DateTime.now())})',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting data: $e')),
        );
      }
    }
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
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        };
      },
    );
  }

  Widget _buildPieChart() {
    if (_typeDistribution.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, _) {
        final sections = _typeDistribution.entries.map((entry) {
          final idx = _typeDistribution.keys.toList().indexOf(entry.key);
          return PieChartSectionData(
            color: _chartColors[idx % _chartColors.length],
            value: entry.value,
            title: '${entry.key}\n${entry.value.toStringAsFixed(1)}h',
            radius: 80 * _chartAnimation.value,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList();

        return PieChart(
          PieChartData(
            sections: sections,
            sectionsSpace: 2,
            centerSpaceRadius: 0,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary for ${widget.userId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCsv,
            tooltip: 'Export to CSV',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allEntries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No work entries found',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                title: 'Total Hours',
                                value: _totalHours.toStringAsFixed(1),
                                icon: Icons.access_time,
                                color: Colors.blue,
                                index: 0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                title: 'Average Hours/Day',
                                value: _averageHoursPerDay.toStringAsFixed(1),
                                icon: Icons.analytics,
                                color: Colors.green,
                                index: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filters',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: _selectDateRange,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                _startDate != null && _endDate != null
                                                    ? '${DateFormat('MMM dd').format(_startDate!)} - ${DateFormat('MMM dd').format(_endDate!)}'
                                                    : 'Select Date Range',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            hint: const Text('Work Type'),
                                            value: _selectedWorkType,
                                            items: _workTypes.map((type) {
                                              return DropdownMenuItem(
                                                value: type == 'All' ? null : type,
                                                child: Text(type),
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
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: _clearFilters,
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Clear Filters'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Work Type Distribution',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 300,
                                  child: _buildPieChart(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Work Entries',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ExpansionTile(
                                leading: Icon(
                                  Icons.work,
                                  color: _chartColors[_workTypes.indexOf(entry.type) % _chartColors.length],
                                ),
                                title: Text(entry.title),
                                subtitle: Text(
                                  '${DateFormat('MMM dd, yyyy').format(entry.date)} • ${entry.hours}h',
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Description:',
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(entry.description),
                                        if (entry.attachmentUrl != null) ...[
                                          const SizedBox(height: 16),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              // TODO: Implement attachment download
                                            },
                                            icon: const Icon(Icons.attachment),
                                            label: const Text('View Attachment'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}