import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// WorkEntry represents a single work record in the intern progress tracking system.
/// It contains all the information about a specific work task or activity performed
/// by an intern, including duration, type of work, and other metadata.
class WorkEntry {
  /// Unique identifier for the work entry
  final String id;
  
  /// ID of the user (intern) who created this entry
  final String userId;
  
  /// Title or name of the work task
  final String title;
  
  /// Detailed description of the work performed
  final String description;
  
  /// Number of hours spent on the task
  final double hours;
  
  /// Category or type of work (e.g., 'Development', 'Testing', etc.)
  final String type;
  
  /// Date when the work was performed
  final DateTime date;
  
  /// Optional location where the work was performed (can be null)
  final String? location;
  
  /// Optional list of tags for categorizing or searching entries
  final List<String>? tags;

  /// Creates a new WorkEntry instance with the required and optional fields
  WorkEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.hours,
    required this.type,
    required this.date,
    this.location,
    this.tags,
  });

  /// Creates a WorkEntry instance from a Firestore DocumentSnapshot
  /// Handles null values and type conversions from Firestore data
  factory WorkEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkEntry(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hours: (data['hours'] ?? 0).toDouble(),
      type: data['type'] ?? 'Other',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }

  /// Creates a WorkEntry instance from a Map and document ID
  /// Provides backward compatibility with different field names
  factory WorkEntry.fromMap(Map<String, dynamic> data, String docId) {
    return WorkEntry(
      id: docId,
      userId: data['userId'] ?? data['internId'] ?? '', // Supports legacy 'internId' field
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hours: (data['hours'] ?? data['hoursWorked'] ?? 0).toDouble(), // Supports legacy 'hoursWorked' field
      type: data['type'] ?? 'Other',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }

  /// Getter for backward compatibility with supervisor dashboard
  /// Returns the hours worked (same as 'hours' field)
  double get hoursWorked => hours;

  /// Converts the WorkEntry instance to a Map for storing in Firestore
  /// Includes all fields and adds a server timestamp for creation time
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'hours': hours,
      'type': type,
      'date': Timestamp.fromDate(date),
      'location': location,
      'tags': tags,
      'createdAt': FieldValue.serverTimestamp(), // Adds server timestamp
    };
  }

  /// Converts the WorkEntry instance to a CSV row format
  /// Used for exporting work entries to CSV files
  List<String> toCsvRow() {
    return [
      DateFormat('yyyy-MM-dd').format(date),
      title,
      description,
      hours.toString(),
      type,
      location ?? '',
      tags?.join(';') ?? '',
    ];
  }

  /// Returns the headers for CSV export
  /// Defines the column names when exporting to CSV format
  static List<String> csvHeaders() {
    return [
      'Date',
      'Title',
      'Description',
      'Hours',
      'Type',
      'Location',
      'Tags',
    ];
  }
}
