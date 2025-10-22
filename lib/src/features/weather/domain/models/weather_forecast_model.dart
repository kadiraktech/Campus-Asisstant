import 'package:flutter/material.dart'; // Material importu eklendi

class WeatherForecast {
  final DateTime date;
  final String city;
  final double temperature; // Celsius
  final String condition; // e.g., 'Clear', 'Clouds', 'Rain'
  final String conditionIcon; // Icon code from OpenWeatherMap (e.g., '01d')
  final int humidity; // Percentage
  final double windSpeed; // meter/sec

  WeatherForecast({
    required this.date,
    required this.city,
    required this.temperature,
    required this.condition,
    required this.conditionIcon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json, String cityName) {
    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List<dynamic>;
    final weather = weatherList[0] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final dt = json['dt'] as int;

    return WeatherForecast(
      date: DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true),
      city:
          cityName, // OpenWeatherMap daily forecast doesn't always return city in each item
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'] as String? ?? 'Unknown',
      conditionIcon: weather['icon'] as String? ?? '01d',
      humidity: (main['humidity'] as num).toInt(),
      windSpeed: (wind['speed'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'city': city,
      'temperature': temperature,
      'condition': condition,
      'conditionIcon': conditionIcon,
      'humidity': humidity,
      'windSpeed': windSpeed,
    };
  }

  factory WeatherForecast.fromCachedJson(Map<String, dynamic> json) {
    return WeatherForecast(
      date: DateTime.parse(json['date'] as String),
      city: json['city'] as String,
      temperature: json['temperature'] as double,
      condition: json['condition'] as String,
      conditionIcon: json['conditionIcon'] as String,
      humidity: json['humidity'] as int,
      windSpeed: json['windSpeed'] as double,
    );
  }

  // Helper to get the full icon URL
  String get iconUrl =>
      'https://openweathermap.org/img/wn/$conditionIcon@2x.png';

  WeatherDisplayData getDisplayData(BuildContext context) {
    bool isDayTime =
        true; // Varsayılan olarak gündüz kabul edelim, API'den gelen saate göre ayarlanabilir
    // API'den gelen 'dt' Unix timestamp'ini kullanarak gün batımı/doğumu kontrolü daha doğru olur
    // veya ikon kodundaki 'd' (gündüz) / 'n' (gece) harfine bakılabilir.
    if (conditionIcon.endsWith('n')) {
      isDayTime = false;
    }

    Color defaultTextColor = isDayTime ? Colors.black87 : Colors.white;
    Color defaultIconColor = isDayTime ? Colors.orange : Colors.blue[300]!;
    Color? cardBackgroundColor =
        isDayTime ? Colors.lightBlue[100] : Colors.blueGrey[800];
    IconData icon = Icons.wb_sunny; // Varsayılan ikon

    switch (conditionIcon.substring(0, 2)) {
      case '01': // Clear sky
        icon = isDayTime ? Icons.wb_sunny_rounded : Icons.nightlight_round;
        defaultIconColor =
            isDayTime ? Colors.orangeAccent : Colors.yellow[600]!;
        cardBackgroundColor = isDayTime ? Colors.blue[200] : Colors.indigo[900];
        defaultTextColor = isDayTime ? Colors.black : Colors.white70;
        break;
      case '02': // Few clouds
        icon =
            isDayTime
                ? Icons.filter_drama_rounded
                : Icons.cloud_queue_rounded; // Biraz bulutlu
        defaultIconColor =
            isDayTime ? Colors.blueGrey[600]! : Colors.blueGrey[300]!;
        cardBackgroundColor =
            isDayTime ? Colors.lightBlue[200] : Colors.blueGrey[700];
        defaultTextColor = isDayTime ? Colors.black87 : Colors.white;
        break;
      case '03': // Scattered clouds
      case '04': // Broken clouds, Overcast clouds
        icon = Icons.cloud_rounded;
        defaultIconColor = isDayTime ? Colors.grey[700]! : Colors.grey[400]!;
        cardBackgroundColor =
            isDayTime ? Colors.blueGrey[200] : Colors.blueGrey[600];
        defaultTextColor = isDayTime ? Colors.black54 : Colors.white70;
        break;
      case '09': // Shower rain
      case '10': // Rain
        icon = Icons.water_drop_rounded; // Yağmur ikonu
        defaultIconColor = isDayTime ? Colors.blue[700]! : Colors.blue[300]!;
        cardBackgroundColor = isDayTime ? Colors.blue[300] : Colors.indigo[700];
        defaultTextColor = isDayTime ? Colors.black : Colors.white;
        break;
      case '11': // Thunderstorm
        icon = Icons.thunderstorm_rounded;
        defaultIconColor =
            isDayTime ? Colors.yellow[800]! : Colors.yellow[600]!;
        cardBackgroundColor = isDayTime ? Colors.grey[500] : Colors.grey[800];
        defaultTextColor = isDayTime ? Colors.black : Colors.white70;
        break;
      case '13': // Snow
        icon = Icons.ac_unit_rounded;
        defaultIconColor = Colors.lightBlue[200]!;
        cardBackgroundColor =
            isDayTime ? Colors.lightBlue[50] : Colors.blueGrey[400];
        defaultTextColor = isDayTime ? Colors.black54 : Colors.white70;
        break;
      case '50': // Mist, Fog etc.
        icon =
            Icons
                .foggy; // Flutter 3.19+ veya custom ikon gerekebilir, şimdilik waves
        defaultIconColor = Colors.grey[500]!;
        cardBackgroundColor = isDayTime ? Colors.grey[300] : Colors.grey[700];
        defaultTextColor = isDayTime ? Colors.black54 : Colors.white70;
        break;
      default:
        icon = isDayTime ? Icons.wb_sunny_outlined : Icons.nightlight_outlined;
        break;
    }

    return WeatherDisplayData(
      weatherIcon: icon,
      iconColor: defaultIconColor,
      textColor: defaultTextColor,
      backgroundColor: cardBackgroundColor,
      // backgroundImage: AssetImage('assets/images/weather/${conditionIcon.substring(0,2)}${isDayTime ? 'd' : 'n'}.png'), // Örnek resim yolu
    );
  }
}

class WeatherDisplayData {
  final IconData weatherIcon;
  final Color iconColor;
  final Color textColor;
  final Color? backgroundColor;
  final AssetImage? backgroundImage; // Arka plan resmi için

  WeatherDisplayData({
    required this.weatherIcon,
    required this.iconColor,
    required this.textColor,
    this.backgroundColor,
    this.backgroundImage,
  });
}
