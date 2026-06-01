import 'package:hive/hive.dart';

part 'airport_model.g.dart';

@HiveType(typeId: 0)
class Airport extends HiveObject {
  @HiveField(0)
  final String code;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String city;

  @HiveField(3)
  final String country;

  @HiveField(4)
  final double lat;

  @HiveField(5)
  final double lon;

  @HiveField(6)
  bool isFavorite;

  Airport({
    required this.code,
    required this.name,
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
    this.isFavorite = false,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      code: json['code'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'city': city,
      'country': country,
      'lat': lat,
      'lon': lon,
      'isFavorite': isFavorite,
    };
  }

  Airport copyWith({
    String? code,
    String? name,
    String? city,
    String? country,
    double? lat,
    double? lon,
    bool? isFavorite,
  }) {
    return Airport(
      code: code ?? this.code,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
