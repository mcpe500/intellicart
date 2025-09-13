# Backup and Recovery

This directory contains the backup and recovery functionality for the Intellicart application.

## BackupService

The `BackupService` provides comprehensive backup and recovery capabilities for the application's local database:

- Database backup to timestamped files
- Database restoration from backup files
- Listing and managing available backups
- Exporting data to JSON format
- Importing data from JSON format

### Usage

```dart
// Create a backup
final backupPath = await BackupService().backupDatabase();

// Restore from a backup
await BackupService().restoreDatabase(backupPath);

// List all backups
final backups = await BackupService().listBackups();

// Export data to JSON
final jsonPath = await BackupService().exportDataToJson();

// Import data from JSON
await BackupService().importDataFromJson(jsonPath);
```

### Backup Storage

Backups are stored in the application's documents directory:
- Database backups: `<documents>/backups/`
- JSON exports: `<documents>/exports/`

### Automatic Backups

The application automatically creates backups:
- Before major operations (e.g., database schema updates)
- When the application is updated to a new version
- Daily (configurable)

### Recovery Procedures

In case of data corruption or loss:
1. Identify the most recent valid backup
2. Restore the database from that backup
3. Verify data integrity after restoration