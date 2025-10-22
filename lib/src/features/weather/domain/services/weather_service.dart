import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectv1/src/features/weather/domain/models/weather_forecast_model.dart';
import 'package:projectv1/src/core/config/api_keys.dart'; // Import the API key
import 'package:timezone/timezone.dart' as tz;
import 'package:logging/logging.dart';

class WeatherService {
  // final String apiKey; // No longer pass via constructor
  static const String _baseUrl = 'api.openweathermap.org';
  static const String _weatherPath = '/data/2.5/weather'; // Current weather
  static const String _forecastPath =
      '/data/2.5/forecast'; // 5 day / 3 hour forecast

  // WeatherService({required this.apiKey}); // Remove constructor
  WeatherService(); // Default constructor

  final _logger = Logger('WeatherService');

  Future<WeatherForecast> getCurrentWeather(String city) async {
    final queryParameters = {
      'q': city,
      'appid': openWeatherApiKey, // Use the imported API key
      'units': 'metric', // For Celsius
    };

    try {
      final uri = Uri.https(_baseUrl, _weatherPath, queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherForecast.fromJson(
          data,
          city,
        ); // Pass city name explicitly
      } else if (response.statusCode == 401) {
        // print('WeatherService Error: Invalid API Key'); // Commented out
        throw Exception(
          'Invalid API Key. Please check your OpenWeatherMap API key.',
        );
      } else if (response.statusCode == 404) {
        // print('WeatherService Error: City not found - $city'); // Commented out
        throw Exception('City not found: $city. Please check the city name.');
      } else {
        // print(
        //   'WeatherService Error: Failed to load weather data. Status: ${response.statusCode}, Body: ${response.body}',
        // ); // Commented out
        throw Exception(
          'Failed to load weather data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // print('WeatherService Exception: $e'); // Commented out
      // Rethrow to allow UI to handle it, or handle more gracefully here
      rethrow;
    }
  }

  // Fetches 5-day forecast with data points every 3 hours.
  // You might need to process this list to get daily averages or specific times.
  Future<List<WeatherForecast>> getFiveDayForecast(String city) async {
    final queryParameters = {
      'q': city,
      'appid': openWeatherApiKey,
      'units': 'metric',
    }; // Use the imported API key

    try {
      final uri = Uri.https(_baseUrl, _forecastPath, queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = data['list'] as List;
        final cityName = data['city']?['name'] as String? ?? city;
        return list
            .map(
              (item) => WeatherForecast.fromJson(
                item as Map<String, dynamic>,
                cityName,
              ),
            )
            .toList();
      } else if (response.statusCode == 401) {
        // print('WeatherService Error (Forecast): Invalid API Key'); // Commented out
        throw Exception(
          'Invalid API Key for forecast. Please check your OpenWeatherMap API key.',
        );
      } else if (response.statusCode == 404) {
        // print('WeatherService Error (Forecast): City not found - $city'); // Commented out
        throw Exception(
          'City not found for forecast: $city. Please check the city name.',
        );
      } else {
        // print(
        //   'WeatherService Error (Forecast): Failed to load forecast data. Status: ${response.statusCode}, Body: ${response.body}',
        // ); // Commented out
        throw Exception(
          'Failed to load forecast data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      // print('WeatherService Exception (Forecast): $e'); // Commented out
      rethrow;
    }
  }

  // You might want a method that filters the 5-day forecast to get one forecast per day
  // (e.g., for midday) or processes it based on specific needs for courses.

  Future<WeatherForecast?> getForecastForCourseDate(
    String city,
    DateTime targetDate,
  ) async {
    try {
      final List<WeatherForecast> fiveDayForecasts = await getFiveDayForecast(
        city,
      );

      if (fiveDayForecasts.isEmpty) {
        return null;
      }

      // Find the forecast closest to midday on the targetDate
      WeatherForecast? closestForecast;
      Duration smallestDiff = const Duration(
        days: 1,
      ); // Max possible difference initially

      final targetDateTimeAtNoon = tz.TZDateTime(
        // Use timezone aware DateTime
        tz.local, // Assuming targetDate is in local timezone
        targetDate.year,
        targetDate.month,
        targetDate.day,
        12, // Target noon
      );

      for (final forecast in fiveDayForecasts) {
        // Ensure forecast.date is treated as local if it came as UTC from service
        final forecastDateTimeLocal = tz.TZDateTime.from(
          forecast.date,
          tz.local,
        );

        // Check if it's the same day
        if (forecastDateTimeLocal.year == targetDateTimeAtNoon.year &&
            forecastDateTimeLocal.month == targetDateTimeAtNoon.month &&
            forecastDateTimeLocal.day == targetDateTimeAtNoon.day) {
          final Duration currentDiff =
              (forecastDateTimeLocal.difference(targetDateTimeAtNoon)).abs();
          if (currentDiff < smallestDiff) {
            smallestDiff = currentDiff;
            closestForecast = forecast;
          }
        }
      }
      if (closestForecast == null) {
        _logger.warning(
          "No forecast found for $city on ${targetDate.toIso8601String().split('T')[0]}",
        );
      }
      return closestForecast;
    } catch (e) {
      _logger.severe(
        'Error in getForecastForCourseDate for $city on ${targetDate.toIso8601String()}: $e',
      );
      rethrow; // Or return null, or handle error as per app's needs
    }
  }
}
