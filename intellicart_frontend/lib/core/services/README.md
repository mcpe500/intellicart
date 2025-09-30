# Core Services

This directory contains core services that are used throughout the application.

## LoggingService

The `LoggingService` provides a unified interface for logging and monitoring application events. It includes:

- Info, warning, and error logging
- Analytics event tracking
- Crash reporting through Firebase Crashlytics
- User interaction tracking
- Screen view tracking

### Usage

```dart
// Initialize the service
await LoggingService().initialize();

// Log an info message
LoggingService().logInfo('Application started');

// Log an error
LoggingService().logError('Failed to load products', error, stackTrace);

// Log a custom event
LoggingService().logEvent('product_added_to_cart', {
  'product_id': productId,
  'quantity': quantity,
});

// Log a screen view
LoggingService().logScreenView('ProductListScreen');
```