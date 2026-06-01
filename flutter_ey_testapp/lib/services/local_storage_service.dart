import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_ey_testapp/models/airport_model.dart';

class LocalStorageService {
  static const String favoritesBoxName = 'favorites';
  static const String airportsBoxName = 'airports';

  Future<void> initializeHive() async {
    await Hive.initFlutter();

    // Register adapter (need to generate this with build_runner)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AirportAdapter());
    }

    // Open the boxes
    await Hive.openBox<Airport>(favoritesBoxName);
    await Hive.openBox<Airport>(airportsBoxName);
  }

  // ========== FAVORITES MANAGEMENT ==========

  Future<void> addFavorite(Airport airport) async {
    final box = Hive.box<Airport>(favoritesBoxName);
    await box.put(airport.code, airport);
  }

  Future<void> removeFavorite(String airportCode) async {
    final box = Hive.box<Airport>(favoritesBoxName);
    await box.delete(airportCode);
  }

  List<Airport> getFavorites() {
    final box = Hive.box<Airport>(favoritesBoxName);
    return box.values.toList();
  }

  bool isFavorite(String airportCode) {
    final box = Hive.box<Airport>(favoritesBoxName);
    return box.containsKey(airportCode);
  }

  Future<void> clearAllFavorites() async {
    final box = Hive.box<Airport>(favoritesBoxName);
    await box.clear();
  }

  // ========== AIRPORTS CACHE MANAGEMENT ==========

  /// Save all airports to cache
  Future<void> cacheAirports(List<Airport> airports) async {
    final box = Hive.box<Airport>(airportsBoxName);
    await box.clear(); // Clear old data
    for (var airport in airports) {
      await box.put(airport.code, airport);
    }
  }

  /// Get cached airports
  List<Airport> getCachedAirports() {
    final box = Hive.box<Airport>(airportsBoxName);
    return box.values.toList();
  }

  /// Check if airports are cached
  bool hasAirportCache() {
    final box = Hive.box<Airport>(airportsBoxName);
    return box.isNotEmpty;
  }

  /// Clear airports cache
  Future<void> clearAirportCache() async {
    final box = Hive.box<Airport>(airportsBoxName);
    await box.clear();
  }
}
