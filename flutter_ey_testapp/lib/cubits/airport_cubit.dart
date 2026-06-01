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

  Future<void> fetchAirports() async {
    try {
      emit(const AirportLoading());

      final airports = await airportRepository.fetchAirports();

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
