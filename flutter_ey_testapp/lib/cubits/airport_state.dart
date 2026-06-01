part of 'airport_cubit.dart';

abstract class AirportState {
  const AirportState();
}

class AirportInitial extends AirportState {
  const AirportInitial();
}

class AirportLoading extends AirportState {
  const AirportLoading();
}

class AirportLoaded extends AirportState {
  final List<Airport> airports;
  final List<Airport> filteredAirports;
  final String searchQuery;
  final bool isFromCache; // Track if data is from cache

  const AirportLoaded({
    required this.airports,
    required this.filteredAirports,
    this.searchQuery = '',
    this.isFromCache = false,
  });

  AirportLoaded copyWith({
    List<Airport>? airports,
    List<Airport>? filteredAirports,
    String? searchQuery,
    bool? isFromCache,
  }) {
    return AirportLoaded(
      airports: airports ?? this.airports,
      filteredAirports: filteredAirports ?? this.filteredAirports,
      searchQuery: searchQuery ?? this.searchQuery,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

class AirportError extends AirportState {
  final String message;

  const AirportError(this.message);
}
