# Frontend Architecture

This document describes the responsibilities of the Flutter app folders.

## App Root
- Cloudy.App/cloudy: Flutter application root (pubspec, platform folders, lib/, test/).

## lib/
- core/constants: App-wide constants (API base URLs, keys, static values).
- core/utils: Small shared helpers (formatters, date utils, simple mappers).
- models: Data models/DTOs used by services and UI.
- services: HTTP/API clients and low-level data access.
- repositories: Data abstraction layer used by providers (optional but keeps UI clean).
- providers: State management (ChangeNotifier) and orchestration logic.
- screens: UI pages (home, details, search, etc.).
- widgets: Reusable UI pieces (cards, list items, loaders, error views).

## test/
- Unit and widget tests.
