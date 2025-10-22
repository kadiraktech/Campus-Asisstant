import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String? id; // Firestore document ID
  final String userId; // To link the course to a user
  final String name;
  final String dayOfWeek; // e.g., "Monday", "Tuesday"
  final String startTime; // e.g., "10:00"
  final String endTime; // e.g., "12:00"
  final String location; // For general area/building for weather
  final String? classroom; // For specific room/hall e.g. "Room 101"
  final String? instructor; // Added instructor
  // final Map<String, dynamic>? weatherForecast; // For FR22, optional for now
  final Map<String, dynamic>?
  cachedWeatherJson; // Store weather forecast as JSON
  final Timestamp? weatherLastFetched; // When the weather was last fetched

  Course({
    this.id,
    required this.userId,
    required this.name,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.classroom, // Added classroom
    this.instructor, // Added instructor
    // this.weatherForecast,
    this.cachedWeatherJson,
    this.weatherLastFetched,
  });

  // Factory constructor to create a Course from a Firestore document
  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      location: data['location'] ?? '',
      classroom: data['classroom'] as String?, // Added classroom
      instructor: data['instructor'] as String?, // Added instructor
      // weatherForecast: data['weatherForecast'] as Map<String, dynamic>?,
      cachedWeatherJson: data['cachedWeatherJson'] as Map<String, dynamic>?,
      weatherLastFetched: data['weatherLastFetched'] as Timestamp?,
    );
  }

  // Method to convert a Course instance to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      if (classroom != null) 'classroom': classroom, // Added classroom
      if (instructor != null) 'instructor': instructor, // Added instructor
      // if (weatherForecast != null) 'weatherForecast': weatherForecast,
      if (cachedWeatherJson != null) 'cachedWeatherJson': cachedWeatherJson,
      if (weatherLastFetched != null) 'weatherLastFetched': weatherLastFetched,
    };
  }

  Course copyWith({
    String? id,
    String? userId,
    String? name,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    String? classroom, // Added classroom
    String? instructor, // Added instructor
    Map<String, dynamic>? cachedWeatherJson,
    Timestamp? weatherLastFetched,
  }) {
    return Course(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      classroom: classroom ?? this.classroom, // Added classroom
      instructor: instructor ?? this.instructor, // Added instructor
      cachedWeatherJson: cachedWeatherJson ?? this.cachedWeatherJson,
      weatherLastFetched: weatherLastFetched ?? this.weatherLastFetched,
    );
  }
}
