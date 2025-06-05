import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

// Data Models
class InternData {
  final String id;
  final String name;
  final String email;
  final double totalHours;
  final double averageHours;
  final DateTime lastUpdated;
  final List<TimeEntry> entries;

  InternData({
    required this.id,
    required this.name,
    required this.email,
    required this.totalHours,
    required this.averageHours,
    required this.lastUpdated,
    required this.entries,
  });

  factory InternData.fromFirestore(DocumentSnapshot doc, List<TimeEntry> entries) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    double total = entries.fold(0.0, (sum, entry) => sum + entry.hours);
    double average = entries.isNotEmpty ? total / entries.length : 0.0;
    DateTime lastUpdate = entries.isNotEmpty 
        ? entries.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b)
        : DateTime.now();

    return InternData(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      totalHours: total,
      averageHours: average,
      lastUpdated: lastUpdate,
      entries: entries,
    );
  }
}

class TimeEntry {
  final String id;
  final DateTime date;
  final double hours;
  final String description;

  TimeEntry({
    required this.id,
    required this.date,
    required this.hours,
    required this.description,
  });

  factory TimeEntry.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TimeEntry(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      hours: (data['hours'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
    );
  }
}

// Firebase Service
class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<InternData>> loadAllInterns() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      List<InternData> interns = [];

      for (DocumentSnapshot userDoc in usersSnapshot.docs) {
        List<TimeEntry> entries = await fetchEntriesForUser(userDoc.id);
        InternData intern = InternData.fromFirestore(userDoc, entries);
        interns.add(intern);
      }

      interns.sort((a, b) => b.totalHours.compareTo(a.totalHours));
      return interns;
    } catch (e) {
      print('Error loading interns: $e');
      return _getMockData(); // Return mock data if Firebase fails
    }
  }

  static Future<List<TimeEntry>> fetchEntriesForUser(String userId) async {
    try {
      QuerySnapshot entriesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('timeEntries')
          .orderBy('date', descending: true)
          .get();

      return entriesSnapshot.docs
          .map((doc) => TimeEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching entries for user $userId: $e');
      return [];
    }
  }

  // Mock data for testing
  static List<InternData> _getMockData() {
    List<TimeEntry> mockEntries1 = [
      TimeEntry(id: '1', date: DateTime.now().subtract(Duration(days: 1)), hours: 8.0, description: 'Project work'),
      TimeEntry(id: '2', date: DateTime.now().subtract(Duration(days: 2)), hours: 7.5, description: 'Meeting'),
      TimeEntry(id: '3', date: DateTime.now().subtract(Duration(days: 3)), hours: 6.0, description: 'Research'),
    ];
    
    List<TimeEntry> mockEntries2 = [
      TimeEntry(id: '4', date: DateTime.now().subtract(Duration(days: 1)), hours: 6.5, description: 'Development'),
      TimeEntry(id: '5', date: DateTime.now().subtract(Duration(days: 2)), hours: 7.0, description: 'Testing'),
    ];

    List<TimeEntry> mockEntries3 = [
      TimeEntry(id: '6', date: DateTime.now().subtract(Duration(days: 1)), hours: 9.0, description: 'Design work'),
      TimeEntry(id: '7', date: DateTime.now().subtract(Duration(days: 2)), hours: 8.5, description: 'Client meeting'),
      TimeEntry(id: '8', date: DateTime.now().subtract(Duration(days: 3)), hours: 7.0, description: 'Documentation'),
    ];

    return [
      InternData(
        id: '1',
        name: 'Alice Johnson',
        email: 'alice@company.com',
        totalHours: 21.5,
        averageHours: 7.17,
        lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        entries: mockEntries1,
      ),
      InternData(
        id: '2',
        name: 'Bob Smith',
        email: 'bob@company.com',
        totalHours: 13.5,
        averageHours: 6.75,
        lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        entries: mockEntries2,
      ),
      InternData(
        id: '3',
        name: 'Carol Davis',
        email: 'carol@company.com',
        totalHours: 24.5,
        averageHours: 8.17,
        lastUpdated: DateTime.now().subtract(Duration(days: 1)),
        entries: mockEntries3,
      ),
    ];
  }
}

// Custom Dropdown Widget
class DropdownSearch extends StatefulWidget {
  final List<InternData> items;
  final InternData? selectedItem;
  final Function(InternData?) onChanged;
  final String hint;

  const DropdownSearch({
    Key? key,
    required this.items,
    this.selectedItem,
    required this.onChanged,
    this.hint = 'Select an intern',
  }) : super(key: key);

  @override
  _DropdownSearchState createState() => _DropdownSearchState();
}

class _DropdownSearchState extends State<DropdownSearch> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.person_search, color: Colors.blue.shade600),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.selectedItem?.name ?? widget.hint,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.selectedItem != null 
                            ? Colors.blue.shade800 
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue.shade600,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.blue.shade200),
            Container(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        item.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${item.totalHours.toStringAsFixed(1)} hours total',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    onTap: () {
                      widget.onChanged(item);
                      setState(() => isExpanded = false);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Stats Card Widget
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// Progress Chart Widget
class ProgressChart extends StatelessWidget {
  final InternData internData;

  const ProgressChart({Key? key, required this.internData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    List<TimeEntry> sortedEntries = List.from(internData.entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    double cumulativeHours = 0;
    for (int i = 0; i < sortedEntries.length; i++) {
      cumulativeHours += sortedEntries[i].hours;
      spots.add(FlSpot(i.toDouble(), cumulativeHours));
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.blue.shade400,
                          barWidth: 4,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.shade400.withOpacity(0.3),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                                return Text(
                                  '${sortedEntries[value.toInt()].date.day}/${sortedEntries[value.toInt()].date.month}',
                                  style: TextStyle(fontSize: 10),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}h', style: TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Main Supervisor Dashboard
class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({Key? key}) : super(key: key);

  @override
  _SupervisorDashboardScreenState createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen> {
  List<InternData> allInterns = [];
  InternData? selectedIntern;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() => isLoading = true);
    
    try {
      List<InternData> interns = await FirebaseService.loadAllInterns();
      
      setState(() {
        allInterns = interns;
        if (interns.isNotEmpty && selectedIntern == null) {
          selectedIntern = interns.first;
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Supervisor Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: loadDashboardData,
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Dashboard...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Statistics
                    Text(
                      'Overview Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        StatsCard(
                          title: 'Total Interns',
                          value: '${allInterns.length}',
                          icon: Icons.people,
                          color: Colors.blue.shade600,
                        ),
                        StatsCard(
                          title: 'Total Hours',
                          value: '${allInterns.fold(0.0, (sum, intern) => sum + intern.totalHours).toStringAsFixed(0)}',
                          icon: Icons.access_time,
                          color: Colors.green.shade600,
                        ),
                        StatsCard(
                          title: 'Average Hours',
                          value: allInterns.isNotEmpty 
                              ? '${(allInterns.fold(0.0, (sum, intern) => sum + intern.totalHours) / allInterns.length).toStringAsFixed(1)}'
                              : '0',
                          icon: Icons.trending_up,
                          color: Colors.orange.shade600,
                        ),
                        StatsCard(
                          title: 'Active Interns',
                          value: '${allInterns.where((intern) => intern.lastUpdated.isAfter(DateTime.now().subtract(Duration(days: 7)))).length}',
                          icon: Icons.schedule,
                          color: Colors.purple.shade600,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Intern Selection
                    Text(
                      'Select Intern',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownSearch(
                      items: allInterns,
                      selectedItem: selectedIntern,
                      onChanged: (InternData? intern) {
                        setState(() {
                          selectedIntern = intern;
                        });
                      },
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Selected Intern Details
                    if (selectedIntern != null) ...[
                      Text(
                        'Intern Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    selectedIntern!.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedIntern!.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        selectedIntern!.email,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '${selectedIntern!.totalHours.toStringAsFixed(1)}h',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade600,
                                      ),
                                    ),
                                    Text('Total Hours'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${selectedIntern!.averageHours.toStringAsFixed(1)}h',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                    Text('Average'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${selectedIntern!.lastUpdated.day}/${selectedIntern!.lastUpdated.month}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade600,
                                      ),
                                    ),
                                    Text('Last Updated'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      ProgressChart(internData: selectedIntern!),
                    ],
                    
                    SizedBox(height: 32),
                    
                    // Comparison Table
                    Text(
                      'All Interns Comparison',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Total Hours', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Average', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Last Updated', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: allInterns.map((intern) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.blue.shade100,
                                        child: Text(
                                          intern.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.blue.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(intern.name),
                                    ],
                                  ),
                                ),
                                DataCell(Text('${intern.totalHours.toStringAsFixed(1)}h')),
                                DataCell(Text('${intern.averageHours.toStringAsFixed(1)}h')),
                                DataCell(Text('${intern.lastUpdated.day}/${intern.lastUpdated.month}')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}