import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class WeatherService {
  static const BASE_URL = 'http://api.openweathermap.org/data/2.5/weather/';
  WeatherService({String? apiKey})
      : apiKey = apiKey ?? dotenv.env['WEATHER_API_KEY'] ?? '';

  final String apiKey;

  Future<Weather> getWeather(String cityName) async {
    final response = await http
        .get(Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> getCurrentCity() async {
    // get permission from user
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      
    );


    // convert location into placemark object lists
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);


    //extract city name from placemark object
    String? cityName = placemarks[0].locality;
    return cityName ?? 'Unknown';
  }
}
