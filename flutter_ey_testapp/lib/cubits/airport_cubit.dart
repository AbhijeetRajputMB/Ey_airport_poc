import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ey_testapp/models/airport_model.dart';
import 'package:flutter_ey_testapp/data/repositories/airport_repository.dart';
import 'package:flutter_ey_testapp/services/local_storage_service.dart';

part 'airport_state.dart';

class AirportCubit extends Cubit<AirportState> {
  final AirportRepository airportRepository;
  final LocalStorageService localStorageService;

  AirportCubit({
    required this.airportRepository,
    required this.localStorageService,
  }) : super(const AirportInitial());

  /// Main fetch method with smart caching
  Future<void> fetchAirports() async {
    try {
      // Check if airports are cached
      if (localStorageService.hasAirportCache()) {
        // Load from cache immediately (no loader)
        await _loadFromCache(isInitialLoad: true);

        // Then fetch fresh data in background
        _fetchFreshDataInBackground();
      } else {
        // No cache: show loader and fetch from API
        emit(const AirportLoading());
        await _fetchAndCache();
      }
    } catch (e) {
      emit(AirportError(e.toString()));
    }
  }

  /// Load airports from cache
  Future<void> _loadFromCache({bool isInitialLoad = false}) async {
    try {
      final cachedAirports = localStorageService.getCachedAirports();

      // Load favorites from local storage
      final favorites = localStorageService.getFavorites();
      final favoriteCodes = favorites.map((a) => a.code).toSet();

      // Update isFavorite status
      final updatedAirports = cachedAirports.map((airport) {
        return airport.copyWith(
          isFavorite: favoriteCodes.contains(airport.code),
        );
      }).toList();

      emit(
        AirportLoaded(
          airports: updatedAirports,
          filteredAirports: updatedAirports,
          searchQuery: '',
          isFromCache: true,
        ),
      );
    } catch (e) {
      emit(AirportError('Failed to load from cache: $e'));
    }
  }

  /// Fetch fresh data from API and update cache in background
  Future<void> _fetchFreshDataInBackground() async {
    try {
      final airports = await airportRepository.fetchAirports();

      // Save to cache
      await localStorageService.cacheAirports(airports);

      // Load favorites
      final favorites = localStorageService.getFavorites();
      final favoriteCodes = favorites.map((a) => a.code).toSet();

      // Update isFavorite status
      final updatedAirports = airports.map((airport) {
        return airport.copyWith(
          isFavorite: favoriteCodes.contains(airport.code),
        );
      }).toList();

      // Update UI with fresh data
      emit(
        AirportLoaded(
          airports: updatedAirports,
          filteredAirports: updatedAirports,
          searchQuery: '',
          isFromCache: false, // Fresh data from API
        ),
      );
    } catch (e) {
      // Background fetch failed, but UI already showing cached data
      // Don't emit error state to avoid disrupting user experience
      // ignore: avoid_print
      print('Background refresh failed: $e');
    }
  }

  /// Fetch and cache airports when no cache exists
  Future<void> _fetchAndCache() async {
    try {
      final airports = await airportRepository.fetchAirports();

      // Save to cache
      await localStorageService.cacheAirports(airports);

      // Load favorites from local storage
      final favorites = localStorageService.getFavorites();
      final favoriteCodes = favorites.map((a) => a.code).toSet();

      // Update isFavorite status
      final updatedAirports = airports.map((airport) {
        return airport.copyWith(
          isFavorite: favoriteCodes.contains(airport.code),
        );
      }).toList();

      emit(
        AirportLoaded(
          airports: updatedAirports,
          filteredAirports: updatedAirports,
          searchQuery: '',
          isFromCache: false,
        ),
      );
    } catch (e) {
      emit(AirportError(e.toString()));
    }
  }

  void searchAirports(String query) {
    final currentState = state;

    if (currentState is AirportLoaded) {
      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredAirports: currentState.airports,
            searchQuery: '',
          ),
        );
      } else {
        final filtered = currentState.airports
            .where(
              (airport) =>
                  airport.name.toLowerCase().contains(query.toLowerCase()) ||
                  airport.code.toLowerCase().contains(query.toLowerCase()) ||
                  airport.city.toLowerCase().contains(query.toLowerCase()) ||
                  airport.country.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

        emit(
          currentState.copyWith(filteredAirports: filtered, searchQuery: query),
        );
      }
    }
  }

  Future<void> toggleFavorite(Airport airport) async {
    final currentState = state;

    if (currentState is AirportLoaded) {
      try {
        final isFavorite = !airport.isFavorite;

        if (isFavorite) {
          airport.isFavorite = true;
          await localStorageService.addFavorite(airport);
        } else {
          airport.isFavorite = false;
          await localStorageService.removeFavorite(airport.code);
        }

        // Update the airports list
        final updatedAirports = currentState.airports.map((a) {
          if (a.code == airport.code) {
            return a.copyWith(isFavorite: isFavorite);
          }
          return a;
        }).toList();

        // Update filtered list based on search query
        final updatedFiltered = currentState.filteredAirports.map((a) {
          if (a.code == airport.code) {
            return a.copyWith(isFavorite: isFavorite);
          }
          return a;
        }).toList();

        emit(
          AirportLoaded(
            airports: updatedAirports,
            filteredAirports: updatedFiltered,
            searchQuery: currentState.searchQuery,
            isFromCache: currentState.isFromCache,
          ),
        );
      } catch (e) {
        emit(AirportError('Failed to update favorite: $e'));
      }
    }
  }

  Future<void> retryFetch() async {
    await fetchAirports();
  }
}
