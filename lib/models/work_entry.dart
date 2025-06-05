import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WorkEntry {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double hours;
  final String type;
  final DateTime date;
  final String? location;
  final List<String>? tags;

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

  factory WorkEntry.fromMap(Map<String, dynamic> data, String docId) {
    return WorkEntry(
      id: docId,
      userId: data['userId'] ?? data['internId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      hours: (data['hours'] ?? data['hoursWorked'] ?? 0).toDouble(),
      type: data['type'] ?? 'Other',
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }

  // Getter for backward compatibility with supervisor dashboard
  double get hoursWorked => hours;

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
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

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
