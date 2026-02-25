# Cloudy - Weather Application

![Flutter](https://img.shields.io/badge/Flutter-3.11-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-SDK%203.11-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)

A modern, intuitive weather application featuring smooth animations and rich weather data visualization. Provides real-time weather information, hourly forecasts, and the ability to track favorite cities with elegant animations and a professionally designed user interface.

## Features

- Current Location Detection - Automatically fetches weather for your current position using device geolocation
- City Search - Search and add cities from a comprehensive world city database with autocomplete
- Favorite Cities - Save favorite cities for quick access with persistent storage
- Animated Weather Icons - Lottie-based animations for different weather conditions
- Detailed Forecasts - Hourly and daily weather predictions with temperature trends
- Dark Theme - Modern UI with gradient backgrounds and glassmorphism effects
- Pull-to-Refresh - Refresh weather data with smooth animations
- Local Storage - Persistent storage of favorite locations using SharedPreferences

## Technologies

### Frontend / Mobile

- Flutter 3.11+ - Cross-platform mobile framework
- Dart 3.11+ - Programming language
- Provider 6.1 - State management with ChangeNotifier pattern
- Lottie 3.3 - Animated weather icons (Thunder, Snow, Rain, Mist, Clouds, Clear Sky)
- Google Fonts 8.0 - Modern typography

### API & Network

- HTTP 1.2 - REST API client
- OpenWeatherMap API - Weather data and forecasts
- Flutter Dotenv 5.2 - Secure API key management

### Device Features

- Geolocator 14.0 - Device location services
- Shared Preferences 2.5 - Persistent local storage

### UI Components

- Liquid Glass Renderer 0.2 - Glassmorphism effects
- Material Design 3 - Modern UI framework

## Architecture

The application uses clean architecture with clear separation of concerns:

```
lib/
├── main.dart                      # Application entry point
├── core/
│   ├── constants/                 # Application constants
│   └── storage/                   # Local storage (AppStorage)
├── models/
│   ├── weather_data.dart          # Weather data models
│   ├── forecast_data.dart         # Forecast models
│   ├── hourly_forecast_data.dart  # Hourly forecast data
│   └── geo_data.dart              # Geolocation data
├── services/
│   ├── city_search_service.dart   # City search functionality
│   └── city_search_state_service.dart
├── providers/
│   ├── weather_provider.dart      # State management via Provider
│   └── weather_state.dart         # Weather state models
├── repositories/                  # Data access layer
├── screens/
│   ├── home_screen.dart           # Main weather display screen
│   ├── onboarding_screen.dart     # User onboarding flow
│   ├── startup_screen.dart        # Splash/startup animation
│   └── city_search_dialog.dart    # City search dialog
└── widgets/
    ├── draggable_bottom_panel.dart # Draggable panel component
    ├── side_menu.dart             # Navigation side menu
    └── [other custom widgets]
```

### State Management - Provider Pattern

Uses Provider for efficient state management with ChangeNotifier pattern:

```dart
// Reading provider state
context.read<WeatherProvider>().fetchWeather(cityName);

// Consuming provider state with state union
Consumer<WeatherProvider>(
  builder: (context, provider, child) {
    return provider.weatherState.map(
      initial: (_) => IntroductionWidget(),
      loading: (_) => LoadingAnimation(),
      success: (state) => WeatherDisplay(data: state.weatherData),
      failure: (state) => ErrorWidget(message: state.message),
    );
  },
)
```

## Animations

The application uses Lottie animations for weather condition visualization:

| Weather Condition | Animation                  | Asset File               |
| ----------------- | -------------------------- | ------------------------ |
| Thunderstorm      | Lightning animation        | `assets/thunder.json`    |
| Snow              | Falling snow animation     | `assets/snow.json`       |
| Rain              | Rainfall animation         | `assets/rain.json`       |
| Mist/Fog          | Misty atmosphere animation | `assets/mist.json`       |
| Cloudy            | Moving clouds animation    | `assets/cloudy_day.json` |
| Clear Sky         | Sunny animation            | `assets/clear_day.json`  |

The startup animation displays on app launch:

```
assets/loading_weather.json
```

Glassmorphism effects are applied throughout the UI for modern visual presentation.

## Getting Started

### Prerequisites

- Flutter SDK 3.11 or later
- Dart SDK 3.11 or later
- Android Studio / Xcode (for mobile development)
- OpenWeatherMap API key (free at [openweathermap.org](https://openweathermap.org))

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/cloudy.git
cd cloudy
```

2. Set up environment variables:

Create a `.env` file in the project root:

```env
OPENWEATHER_API_KEY=your_api_key_here
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

For Android:

```bash
flutter run -d android
```

For iOS:

```bash
flutter run -d ios
```

For Web:

```bash
flutter run -d chrome
```

## Screens Overview

### Startup Screen

Displays app loading animation on first launch with smooth transitions and logo animation.

### Onboarding Screen

Introduces main app features to new users with interactive steps and visual demonstrations.

### Home Screen

Main weather display with:

- Gradient backgrounds (Sky-Blue #38B6FF to Deep Navy #060C22)
- Animated weather icon that changes based on current conditions
- Current temperature and detailed weather description
- Horizontal scrolling hourly forecast
- Daily forecast predictions
- Additional meteorological data (wind speed, humidity, atmospheric pressure)
- Pull-to-refresh functionality with smooth animation

### City Search Dialog

Modal dialog for adding new cities with:

- Autocomplete functionality
- World city database search
- Add cities to favorites

## API Integration

### OpenWeatherMap API

The application uses the following API endpoints:

```dart
// Current weather data
GET /data/2.5/weather?q={city}&appid={API_KEY}&units=metric

// 5-day forecasts with hourly detail
GET /data/2.5/forecast?q={city}&appid={API_KEY}&units=metric

// Geocoding for city lookup
GET /geo/1.0/direct?q={city}&limit=5&appid={API_KEY}
```

Example API call:

```dart
final response = await http.get(
  Uri.parse(
    'https://api.openweathermap.org/data/2.5/weather'
    '?q=$city&appid=$apiKey&units=metric'
  ),
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  return WeatherData.fromJson(data);
}
```

## Local Storage

Uses SharedPreferences for persistent storage of:

- Favorite cities
- User location preferences
- Application settings

```dart
// Save favorite city
await AppStorage.setFavoriteCity('London');

// Retrieve favorite city
final favorite = await AppStorage.getFavoriteCity();

// Clear favorite city
await AppStorage.setFavoriteCity('');
```

## Design & UI/UX

- Gradient Backgrounds: Sky-Blue (#38B6FF) to Mid-Blue (#1565C0) to Deep Navy (#060C22)
- Material Design 3: Modern, readable, intuitive components
- Glassmorphism: Semi-transparent effects for visual hierarchy
- Responsive Layout: Adapts to all screen sizes (phone, tablet, web)

## Data Models

### WeatherData

```dart
class WeatherData {
  final String city;
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;
  final double pressure;
  final String iconCode;
  final int timestamp;
}
```

### ForecastData

```dart
class ForecastData {
  final List<HourlyForecastData> hourly;
  final List<DailyForecastData> daily;
  final DateTime generatedAt;
}
```

## Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

## Performance

- Optimized animations using Lottie for efficient rendering versus traditional video/GIF
- Lazy loading of weather data on demand
- Caching of weather data for faster access and reduced data consumption
- Responsive design with minimal overhead across different screen sizes

## Debugging

The application uses debugPrint for detailed logging during development:

```dart
debugPrint('[HomeScreen.build] START');
debugPrint('[HomeScreen] Added city to favorites');
debugPrint('[HomeScreen.onRefresh] Refreshing weather for: $currentCity');
```
