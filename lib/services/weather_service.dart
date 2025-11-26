import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../core/config/app_config.dart';
import '../core/constants/app_constants.dart';

class WeatherService {
  final _config = AppConfig();
  WeatherData? _cachedWeather;

  /// Get weather by coordinates
  Future<WeatherData> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    // Return cached data if still fresh
    if (_cachedWeather != null && _cachedWeather!.isFresh) {
      return _cachedWeather!;
    }

    final apiKey = _config.openWeatherApiKey;
    if (apiKey.isEmpty) {
      throw Exception('OpenWeather API key not configured');
    }

    final url = Uri.parse(
      '${AppConstants.weatherApiBaseUrl}/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url).timeout(AppConstants.networkTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final weather = _parseWeatherResponse(data);
        _cachedWeather = weather;
        return weather;
      } else {
        throw Exception(
          'Failed to fetch weather: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Weather API error: $e');
    }
  }

  /// Get weather by city name
  Future<WeatherData> getWeatherByCity(String cityName) async {
    final apiKey = _config.openWeatherApiKey;
    if (apiKey.isEmpty) {
      throw Exception('OpenWeather API key not configured');
    }

    final url = Uri.parse(
      '${AppConstants.weatherApiBaseUrl}/weather?q=$cityName&appid=$apiKey&units=metric',
    );

    try {
      final response = await http.get(url).timeout(AppConstants.networkTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final weather = _parseWeatherResponse(data);
        _cachedWeather = weather;
        return weather;
      } else {
        throw Exception(
          'Failed to fetch weather: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Weather API error: $e');
    }
  }

  /// Parse OpenWeatherMap API response
  WeatherData _parseWeatherResponse(Map<String, dynamic> data) {
    final main = data['main'] as Map<String, dynamic>;
    final weather = (data['weather'] as List).first as Map<String, dynamic>;
    final weatherCode = weather['id'] as int;

    return WeatherData(
      condition: _mapWeatherCodeToCondition(weatherCode),
      temperature: (main['temp'] as num).toDouble(),
      humidity: main['humidity'] as int,
      location: data['name'] as String,
      fetchedAt: DateTime.now(),
      weatherCode: weatherCode,
      description: weather['description'] as String?,
    );
  }

  /// Map OpenWeatherMap weather codes to simple conditions
  String _mapWeatherCodeToCondition(int code) {
    if (code >= 200 && code < 300) {
      return 'stormy';
    } else if (code >= 300 && code < 600) {
      return 'rainy';
    } else if (code >= 600 && code < 700) {
      return 'snowy';
    } else if (code >= 700 && code < 800) {
      return 'foggy';
    } else if (code == 800) {
      return 'sunny';
    } else if (code > 800) {
      return 'cloudy';
    }
    return 'clear';
  }

  /// Clear cached weather (for manual refresh)
  void clearCache() {
    _cachedWeather = null;
  }
}
