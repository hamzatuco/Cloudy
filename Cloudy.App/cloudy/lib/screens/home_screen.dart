import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/weather_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final city = _cityController.text.trim();
                    if (city.isNotEmpty) {
                      context.read<WeatherProvider>().fetchWeather(city);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Display weather data
            Expanded(
              child: Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  final state = weatherProvider.state;

                  // Loading state
                  if (state.status == WeatherStatus.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Error state
                  if (state.status == WeatherStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${state.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              final city = _cityController.text.trim();
                              if (city.isNotEmpty) {
                                weatherProvider.retry(city);
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Success state
                  if (state.status == WeatherStatus.success && state.data != null) {
                    final weather = state.data!;
                    return RefreshIndicator(
                      onRefresh: () async {
                        final city = _cityController.text.trim();
                        if (city.isNotEmpty) {
                          await weatherProvider.fetchWeather(city);
                        }
                      },
                      child: ListView(
                        children: [
                          // City name
                          Text(
                            '${weather.name}, ${weather.sys?.country ?? ''}',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),

                          // Temperature
                          Center(
                            child: Text(
                              '${weather.main?.temp?.toStringAsFixed(1)}°C',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Weather description
                          Center(
                            child: Text(
                              weather.weather?.isNotEmpty == true
                                  ? weather.weather![0].main ?? 'Unknown'
                                  : 'Unknown',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Additional details
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                    'Feels Like',
                                    '${weather.main?.feelsLike?.toStringAsFixed(1)}°C',
                                  ),
                                  _buildDetailRow(
                                    'Humidity',
                                    '${weather.main?.humidity}%',
                                  ),
                                  _buildDetailRow(
                                    'Pressure',
                                    '${weather.main?.pressure} hPa',
                                  ),
                                  _buildDetailRow(
                                    'Wind Speed',
                                    '${weather.wind?.speed?.toStringAsFixed(2)} m/s',
                                  ),
                                  _buildDetailRow(
                                    'Wind Direction',
                                    '${weather.wind?.deg?.toStringAsFixed(0)}°',
                                  ),
                                  _buildDetailRow(
                                    'Cloudiness',
                                    '${weather.clouds?.all}%',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Initial state
                  return const Center(
                    child: Text('Enter a city name to search for weather'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
