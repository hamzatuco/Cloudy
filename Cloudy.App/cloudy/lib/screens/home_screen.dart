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
        title: const Text('Cloudy — API Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              onSubmitted: (value) {
                final city = value.trim();
                if (city.isNotEmpty) {
                  context.read<WeatherProvider>().fetchWeather(city);
                }
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  final state = weatherProvider.state;

                  if (state.status == WeatherStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

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
                            onPressed: () => weatherProvider.retry(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.status == WeatherStatus.success && state.data != null) {
                    final weather = state.data!;
                    final forecast = state.forecast;
                    final hourly = state.hourlyForecast;

                    return ListView(
                      children: [
                        // Current weather
                        Text(
                          '${weather.name}, ${weather.sys?.country ?? ''}',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '${weather.main?.temp?.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                        Center(
                          child: Text(
                            weather.weather?.isNotEmpty == true
                                ? weather.weather![0].main ?? 'Unknown'
                                : 'Unknown',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('Humidity', '${weather.main?.humidity}%'),
                        _buildDetailRow('Wind', '${weather.wind?.speed?.toStringAsFixed(1)} m/s'),
                        _buildDetailRow('Pressure', '${weather.main?.pressure} hPa'),

                        const Divider(height: 32),

                        // Daily forecast
                        Text(
                          '📅 Daily Forecast (${forecast?.list?.length ?? 0} days)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (forecast?.list != null)
                          ...forecast!.list!.map((day) {
                            final date = DateTime.fromMillisecondsSinceEpoch((day.dt ?? 0) * 1000);
                            final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width: 40, child: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  Text(day.weather?.first.main ?? ''),
                                  Text('+${day.temp?.max?.toStringAsFixed(0)}° / +${day.temp?.min?.toStringAsFixed(0)}°'),
                                ],
                              ),
                            );
                          }),

                        const Divider(height: 32),

                        // Hourly forecast
                        Text(
                          '🕐 Hourly Forecast (${hourly?.list?.length ?? 0} items)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (hourly?.list != null)
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: (hourly!.list!.length > 12) ? 12 : hourly.list!.length,
                              itemBuilder: (context, index) {
                                final item = hourly.list![index];
                                final time = DateTime.fromMillisecondsSinceEpoch((item.dt ?? 0) * 1000);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('${time.hour}:00', style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text('${item.main?.temp?.toStringAsFixed(0)}°', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(item.weather?.first.main ?? '', style: const TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  }

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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
