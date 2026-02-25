# Architecture & Implementation Guide

## Project Structure Overview

```
cloudy/
├── lib/
│   ├── main.dart                              # Application entry point
│   ├── core/
│   │   ├── constants/
│   │   │   └── [App constants and values]
│   │   └── storage/
│   │       └── app_storage.dart               # Local storage management
│   ├── models/
│   │   ├── weather_data.dart                  # Main weather model
│   │   ├── forecast_data.dart                 # Forecast model
│   │   ├── hourly_forecast_data.dart          # Hourly details
│   │   └── geo_data.dart                      # Geolocation model
│   ├── services/
│   │   ├── city_search_service.dart           # City search logic
│   │   └── city_search_state_service.dart     # Search state management
│   ├── repositories/
│   │   └── [Data access abstraction layer]
│   ├── providers/
│   │   ├── weather_provider.dart              # Main state provider
│   │   └── weather_state.dart                 # State definitions
│   ├── screens/
│   │   ├── home_screen.dart                   # Main weather display
│   │   ├── city_search_dialog.dart            # City search UI
│   │   ├── onboarding_screen.dart             # User onboarding
│   │   └── startup_screen.dart                # Splash screen
│   └── widgets/
│       ├── draggable_bottom_panel.dart        # Draggable UI component
│       ├── side_menu.dart                     # Navigation menu
│       └── [Other custom widgets]
├── assets/
│   ├── [Lottie animation JSON files]
│   ├── world_cities.json                      # City database
│   └── [App images and resources]
├── test/
│   ├── widget_test.dart                       # Widget tests
│   └── providers/                             # Provider tests
├── pubspec.yaml                               # Dependencies and metadata
├── analysis_options.yaml                      # Lint configuration
├── .env                                       # API keys (not in repo)
└── README.md                                  # Project documentation
```
