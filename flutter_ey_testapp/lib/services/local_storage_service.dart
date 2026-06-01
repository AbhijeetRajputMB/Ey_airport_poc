import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_ey_testapp/models/airport_model.dart';

class LocalStorageService {
  static const String favoritesBoxName = 'favorites';

  Future<void> initializeHive() async {
    await Hive.initFlutter();

    // Register adapter (need to generate this with build_runner)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AirportAdapter());
    }

    // Open the box
    await Hive.openBox<Airport>(favoritesBoxName);
  }

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
}
