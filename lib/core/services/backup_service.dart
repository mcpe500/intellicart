import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:intl/intl.dart';
import 'logging_service.dart';

/// A service for handling data backup and recovery
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Backup the local database to a file
  Future<String> backupDatabase() async {
    try {
      // Get database path
      final databasePath = await getDatabasesPath();
      final dbPath = join(databasePath, 'intellicart.db');
      
      // Create backup directory
      final backupDir = join(databasePath, 'backups');
      await Directory(backupDir).create(recursive: true);
      
      // Generate backup filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupPath = join(backupDir, 'intellicart_backup_$timestamp.db');
      
      // Copy database file
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
        LoggingService().logInfo('Database backed up successfully', {
          'backup_path': backupPath,
        });
        return backupPath;
      } else {
        throw Exception('Database file does not exist');
      }
    } catch (e, stackTrace) {
      LoggingService().logError('Failed to backup database', e, stackTrace);
      rethrow;
    }
  }

  /// Restore database from a backup file
  Future<void> restoreDatabase(String backupPath) async {
    try {
      // Get database path
      final databasePath = await getDatabasesPath();
      final dbPath = join(databasePath, 'intellicart.db');
      
      // Check if backup file exists
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist: $backupPath');
      }
      
      // Close current database connection
      final db = await openDatabase(dbPath);
      await db.close();
      
      // Copy backup file to database location
      await backupFile.copy(dbPath);
      
      LoggingService().logInfo('Database restored successfully', {
        'backup_path': backupPath,
      });
    } catch (e, stackTrace) {
      LoggingService().logError('Failed to restore database', e, stackTrace);
      rethrow;
    }
  }

  /// List all available backups
  Future<List<String>> listBackups() async {
    try {
      final databasePath = await getDatabasesPath();
      final backupDir = join(databasePath, 'backups');
      
      final dir = Directory(backupDir);
      if (await dir.exists()) {
        final files = await dir.list().toList();
        final backupFiles = files
            .where((file) => file.path.endsWith('.db'))
            .map((file) => file.path)
            .toList();
        
        // Sort by modification time (newest first)
        backupFiles.sort((a, b) {
          final fileA = File(a);
          final fileB = File(b);
          return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
        });
        
        return backupFiles;
      }
      
      return [];
    } catch (e, stackTrace) {
      LoggingService().logError('Failed to list backups', e, stackTrace);
      return [];
    }
  }

  /// Delete a specific backup
  Future<void> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
        LoggingService().logInfo('Backup deleted successfully', {
          'backup_path': backupPath,
        });
      }
    } catch (e, stackTrace) {
      LoggingService().logError('Failed to delete backup', e, stackTrace);
      rethrow;
    }
  }

  /// Export data to JSON format
  Future<String> exportDataToJson() async {
    try {
      final databasePath = await getDatabasesPath();
      final dbPath = join(databasePath, 'intellicart.db');
      
      final db = await openDatabase(dbPath);
      
      // Export all tables
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'");
      
      final exportData = <String, dynamic>{};
      
      for (final table in tables) {
        final tableName = table['name'] as String;
        if (tableName != 'sqlite_sequence') { // Skip internal SQLite table
          final data = await db.query(tableName);
          exportData[tableName] = data;
        }
      }
      
      await db.close();
      
      // Create export directory
      final exportDir = join(databasePath, 'exports');
      await Directory(exportDir).create(recursive: true);
      
      // Generate export filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final exportPath = join(exportDir, 'intellicart_export_$timestamp.json');
      
      // Write JSON to file
      final jsonString = jsonEncode(exportData);
      final file = File(exportPath);
      await file.writeAsString(jsonString);
      
      LoggingService().logInfo('Data exported to JSON successfully', {
        'export_path': exportPath,
      });
      
      return exportPath;
    } catch (e, stackTrace) {
      LoggingService().logError('Failed to export data to JSON', e, stackTrace);
      rethrow;
    }
  }

  /// Import data from JSON format
  Future<void> importDataFromJson(String jsonPath) async {
    try {
      // final databasePath = await getDatabasesPath();
      // final dbPath = join(databasePath, 'intellicart.db');
      
      // final file = File(jsonPath);
      // if (!await file.exists()) {
      //   throw Exception('JSON file does not exist: $jsonPath');
      // }
      
      // final jsonString = await file.readAsString();
      // final importData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // final db = await openDatabase(dbPath);
      
      // Begin transaction for better performance
      // await db.transaction((txn) async {
      //   // Import data for each table
      //   for (final entry in importData.entries) {
      //     final tableName = entry.key;
      //     final tableData = entry.value as List;
          
      //     // Clear existing data
      //     await txn.delete(tableName);
          
      //     // Insert new data
      //     for (final row in tableData) {
      //       await txn.insert(tableName, row as Map<String, dynamic>);
      //     }
      //   }
      // });
      
      // await db.close();
      
      final file = File(jsonPath);
      if (!await file.exists()) {
        throw Exception('JSON file does not exist: $jsonPath');
      }
      
      final jsonString = await file.readAsString();
      final importData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Get database path
      final databasePath = await getDatabasesPath();
      final dbPath = join(databasePath, 'intellicart.db');
      
      final db = await openDatabase(dbPath);
      
      // Begin transaction for better performance
      await db.transaction((txn) async {
        // Import data for each table
        for (final entry in importData.entries) {
          final tableName = entry.key;
          final tableData = entry.value as List;
          
          // Clear existing data
          await txn.delete(tableName);
          
          // Insert new data
          for (final row in tableData) {
            await txn.insert(tableName, row as Map<String, dynamic>);
          }
        }
      });
      
      await db.close();
      
      LoggingService().logInfo('Data imported from JSON successfully', {
        'json_path': jsonPath,
      });
    } catch (e, stackTrace) {
      LoggingService().logError('Failed to import data from JSON', e, stackTrace);
      rethrow;
    }
  }
}