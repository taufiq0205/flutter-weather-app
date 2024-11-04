import 'package:flutter/material.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //API key
  final _weatherService = WeatherService(apiKey: dotenv.env['WEATHER_API_KEY']);
  Weather? _weather;

  //fetch weather data
  _fetchWeather() async {
    //get current city
    String cityName = await _weatherService.getCurrentCity();

    //get weather data in city

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }
    //error handling
    catch (e) {
      print(e);
    }
  }

  //weather animation
  String _getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase().trim()) {
      case 'clouds':
      case 'scattered clouds':
      case 'broken clouds':
      case 'few clouds':
      case 'overcast clouds':
      case 'mist':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'smoke':
        return 'assets/cloudy.json';

      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';

      case 'thunderstorm':
        return 'assets/thunder.json';

      case 'clear':
      case 'clear sky':
        return 'assets/sunny.json';

      default:
        print('Unknown weather condition: $mainCondition');
        return 'assets/sunny.json';
    }
  }

  //init state
  @override
  void initState() {
    super.initState();

    //fetch weather data on start
    _fetchWeather();
  }

  //change dark/light mode depending on time
  bool _isNightTime() {
    final now = DateTime.now().hour;
    return now < 7 || now > 18; // Night time between 6 PM and 7 AM
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isNightTime();
    // Colors for dark mode
    final darkGrey = const Color(0xFF202020);
    final softWhite = Colors.white.withOpacity(0.87); // Softer white for text
    final softWhiteSecondary =
        Colors.white.withOpacity(0.6); // Even softer white for secondary text

    // Colors for light mode
    final warmWhite =
        const Color(0xFFF5F5F5); // Slightly off-white/warm grey for background
    final softBlack = Colors.black87; // Softer black for text
    final softBlackSecondary =
        Colors.black54; // Softer black for secondary text

    return Scaffold(
      backgroundColor: isDark ? darkGrey : warmWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location row with icon
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: isDark ? softWhiteSecondary : softBlackSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _weather?.cityName ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? softWhite : softBlack,
                    ),
                  ),
                ],
              ),

              // Expanded space for weather animation
              Expanded(
                child: Center(
                  child: Lottie.asset(
                    _getWeatherAnimation(_weather?.condition),
                    width: 200,
                    height: 200,
                  ),
                ),
              ),

              // Temperature at bottom
              Center(
                child: Text(
                  '${_weather?.temperature.round()}°',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: isDark ? softWhite : softBlack,
                  ),
                ),
              ),

              // Weather condition
              Center(
                child: Text(
                  _weather?.condition ?? "",
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? softWhiteSecondary : softBlackSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
