import 'package:dio/dio.dart';
import 'package:flutter_ey_testapp/data/api/dio_client.dart';
import 'package:flutter_ey_testapp/models/airport_model.dart';

class AirportRepository {
  final DioClient dioClient;

  AirportRepository({required this.dioClient});

  Future<List<Airport>> fetchAirports() async {
    try {
      final response = await dioClient.get(
        'https://mocki.io/v1/70c236fd-0b01-4987-a6bc-0b97bdb3f005',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final airportList = (data['airports'] as List)
            .map((airport) => Airport.fromJson(airport as Map<String, dynamic>))
            .toList();
        return airportList;
      } else {
        throw Exception('Failed to load airports: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Please try again.');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else if (e.type == DioExceptionType.unknown) {
        throw Exception('Network error. Please try again.');
      } else {
        throw Exception('Failed to fetch airports: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
