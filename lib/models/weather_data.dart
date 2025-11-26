import 'package:json_annotation/json_annotation.dart';

part 'weather_data.g.dart';

@JsonSerializable()
class WeatherData {
  final String condition;
  final double temperature;
  final int humidity;
  final String location;
  final DateTime fetchedAt;
  final int weatherCode;
  final String? description;

  const WeatherData({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.location,
    required this.fetchedAt,
    required this.weatherCode,
    this.description,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);

  // Check if weather data is still fresh (< 30 minutes old)
  bool get isFresh {
    final now = DateTime.now();
    final difference = now.difference(fetchedAt);
    return difference.inMinutes < 30;
  }

  // Get emoji for weather condition
  String get weatherEmoji {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return '☀️';
      case 'cloudy':
      case 'partly cloudy':
        return '⛅';
      case 'rainy':
      case 'rain':
        return '🌧️';
      case 'snowy':
      case 'snow':
        return '❄️';
      case 'stormy':
      case 'thunderstorm':
        return '⛈️';
      case 'foggy':
      case 'mist':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  WeatherData copyWith({
    String? condition,
    double? temperature,
    int? humidity,
    String? location,
    DateTime? fetchedAt,
    int? weatherCode,
    String? description,
  }) {
    return WeatherData(
      condition: condition ?? this.condition,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      location: location ?? this.location,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      weatherCode: weatherCode ?? this.weatherCode,
      description: description ?? this.description,
    );
  }
}
