import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app_auto/models/weather_model.dart';
import 'package:weather_app_auto/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService(); // No API key
  Weather? _weather;
  final _cityController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _fetchWeather({String? cityName}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final city = cityName ?? await _weatherService.getCurrentCity();
      if (city.isEmpty && cityName == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location access denied. Enter a city manually.';
        });
        return;
      }
      final weather = await _weatherService.getWeather(city);
      setState(() {
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey, Colors.black],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Enter city',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    border: const OutlineInputBorder(),
                    hintStyle: const TextStyle(color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => _fetchWeather(
                          cityName: _cityController.text.isEmpty
                              ? null
                              : _cityController.text),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) _fetchWeather(cityName: value);
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _errorMessage != null
                        ? Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    )
                        : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _weather?.cityName ?? 'Unknown city',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.location_pin,
                            size: 30, color: Colors.white),
                        const SizedBox(height: 20),
                        Lottie.asset(
                          getWeatherAnimation(
                              _weather?.mainCondition),
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _weather?.mainCondition ?? 'Unknown',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 24),
                        ),
                        Text(
                          '${_weather?.temperature.round() ?? 0}°C',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}