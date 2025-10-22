import 'package:flutter/material.dart';
import 'package:projectv1/src/features/course_schedule/domain/models/course_model.dart';
import 'package:projectv1/src/features/weather/domain/models/weather_forecast_model.dart';
import 'package:projectv1/src/features/weather/domain/services/weather_service.dart';
import 'package:intl/intl.dart'; // For date formatting if needed for weather display
// import 'package:projectv1/src/core/widgets/shimmer_loading.dart'; // Comment out or remove if using local shimmer
import 'package:shimmer/shimmer.dart'; // Ensure shimmer is imported
// import 'package:cloud_firestore/cloud_firestore.dart'; // Not strictly needed if not updating cache here
import 'package:timezone/timezone.dart' as tz; // For timezone calculations
import 'package:timezone/data/latest_all.dart'
    as tz_data; // For initializing timezones

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherForecast? _weatherForecast;
  bool _isLoadingWeather = false;
  String? _weatherError;
  DateTime? _nextCourseDate; // To store the calculated next course date

  // static const Duration _weatherCacheDuration = Duration(hours: 3); // Cache for 3 hours - Not using course object cache for daily forecast for now

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones(); // Ensure timezones are initialized
    _nextCourseDate = _calculateNextCourseOccurrence(
      widget.course.dayOfWeek,
      widget.course.startTime,
    );
    _fetchWeatherForCourseDate();
  }

  // Adapted from NotificationService
  DateTime? _calculateNextCourseOccurrence(
    String dayOfWeek,
    String startTimeStr,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    int currentDayOfWeek = now.weekday;

    Map<String, int> dayMapping = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    int targetDay = dayMapping[dayOfWeek] ?? -1;
    if (targetDay == -1) {
      debugPrint("Invalid dayOfWeek for weather forecast: $dayOfWeek");
      return null;
    }

    int daysToAdd = targetDay - currentDayOfWeek;

    List<String> timeParts = startTimeStr.split(':');
    if (timeParts.length != 2) {
      debugPrint(
        "Invalid startTime format for weather forecast: $startTimeStr",
      );
      return null;
    }
    int hour = int.tryParse(timeParts[0]) ?? 0;
    int minute = int.tryParse(timeParts[1]) ?? 0;

    tz.TZDateTime potentialNextCourseDay = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (daysToAdd < 0 ||
        (daysToAdd == 0 && potentialNextCourseDay.isBefore(now))) {
      daysToAdd += 7;
    }

    // Return as standard DateTime, as WeatherService expects DateTime
    return DateTime(now.year, now.month, now.day + daysToAdd, hour, minute);
  }

  Future<void> _fetchWeatherForCourseDate() async {
    if (widget.course.location.isEmpty) {
      if (mounted) {
        setState(() {
          _weatherError = "Location not set for this course.";
          _isLoadingWeather = false;
        });
      }
      return;
    }

    if (_nextCourseDate == null) {
      if (mounted) {
        setState(() {
          _weatherError = "Could not determine course date for weather.";
          _isLoadingWeather = false;
        });
      }
      return;
    }
    // Check if the target date is more than 5 days in the future
    // OpenWeatherMap free tier typically provides 5-day forecast.
    // The service method getForecastForCourseDate will return null if it can't find a forecast.
    final fiveDaysFromNow = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(days: 5));
    if (tz.TZDateTime.from(
      _nextCourseDate!,
      tz.local,
    ).isAfter(fiveDaysFromNow)) {
      if (mounted) {
        setState(() {
          _weatherError =
              "Weather forecast is only available up to 5 days in advance.";
          _isLoadingWeather = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingWeather = true;
        _weatherError = null;
      });
    }

    try {
      // Not using or updating widget.course.cachedWeatherJson for daily specific forecasts for now
      WeatherForecast? forecast = await _weatherService
          .getForecastForCourseDate(widget.course.location, _nextCourseDate!);

      if (mounted) {
        setState(() {
          _weatherForecast = forecast; // This can be null if not found
          _isLoadingWeather = false;
          if (forecast == null && _weatherError == null) {
            // If service returned null and no other error yet
            _weatherError = "Weather forecast not available for this day.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherError = "Failed to load weather: ${e.toString()}";
          _isLoadingWeather = false;
        });
      }
      debugPrint(
        "Error fetching weather for course ${widget.course.name} on $_nextCourseDate: $e",
      );
    }
  }

  Widget _buildWeatherSection(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoadingWeather) {
      // return ShimmerLoading(height: 100, width: double.infinity); // Use your shimmer widget
      return _buildShimmerLoading(height: 100); // Call local shimmer method
    }
    if (_weatherError != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _weatherError!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }
    if (_weatherForecast == null) {
      // This case might occur if location is empty and _fetchWeatherForCourse returned early
      if (widget.course.location.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No location set for this course to fetch weather.",
            style: theme.textTheme.bodyMedium,
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Weather data not available.",
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            _weatherForecast!.iconUrl.isNotEmpty
                ? Image.network(
                  _weatherForecast!.iconUrl,
                  width: 50,
                  height: 50,
                  errorBuilder:
                      (c, e, s) => Icon(
                        Icons.cloud_off_outlined,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                )
                : Icon(
                  Icons.wb_sunny_outlined,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _weatherForecast!.city, // Displaying city from forecast
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_weatherForecast!.temperature.toStringAsFixed(1)}°C, ${_weatherForecast!.condition}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    'Humidity: ${_weatherForecast!.humidity}%',
                    style: theme.textTheme.bodyMedium,
                  ),
                  // Add more details if needed, e.g., wind
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    '${widget.course.dayOfWeek} at ${widget.course.startTime} - ${widget.course.endTime}',
                    theme,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    Icons.location_on_outlined,
                    widget.course.location.isNotEmpty
                        ? widget.course.location
                        : 'No location set',
                    theme,
                  ),
                  if (widget.course.classroom != null &&
                      widget.course.classroom!.isNotEmpty)
                    _buildDetailItem(
                      context,
                      icon:
                          Icons
                              .meeting_room_outlined, // Or another suitable icon for classroom
                      label: 'Classroom',
                      value: widget.course.classroom!,
                    ),
                  // Add more course details here if needed
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                _nextCourseDate != null
                    ? 'Weather on ${DateFormat.yMMMd().format(_nextCourseDate!)}'
                    : 'Weather Forecast',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            _buildWeatherSection(context),
            // Note: Fetching weather for the *specific day of the course* if it's in the future
            // and not just current weather for the location is more complex.
            // The current _weatherService.getCurrentWeather gets current weather.
            // OpenWeatherMap's 5-day/3-hour forecast API could be used for future days,
            // but requires parsing and finding the correct day/time.
            // For now, this shows current weather for the course's location.
            // FR21 implies fetching for the *day of each course*.
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Add local shimmer loading method
  Widget _buildShimmerLoading({
    required double height,
    double width = double.infinity,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(height: height, width: width, color: Colors.white),
    );
  }
}

// Ensure ShimmerLoading widget exists or replace with a standard CircularProgressIndicator
// e.g., in lib/src/core/widgets/shimmer_loading.dart
// class ShimmerLoading extends StatelessWidget {
//   final double height;
//   final double? width;
//   const ShimmerLoading({super.key, required this.height, this.width});
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Shimmer.fromColors( // Requires shimmer package
//       baseColor: theme.colorScheme.surfaceVariant.withAlpha(100),
//       highlightColor: theme.colorScheme.surfaceVariant.withAlpha(200),
//       child: Container(
//         height: height,
//         width: width ?? double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.white, // Shimmer needs a child with a color
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//       ),
//     );
//   }
// }
