import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ey_testapp/models/airport_model.dart';
import 'package:flutter_ey_testapp/cubits/airport_cubit.dart';

class AirportListItem extends StatelessWidget {
  final Airport airport;

  const AirportListItem({super.key, required this.airport});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            airport.code,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          airport.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${airport.city}, ${airport.country}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              'Lat: ${airport.lat.toStringAsFixed(4)}, Lon: ${airport.lon.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () {
            context.read<AirportCubit>().toggleFavorite(airport);
          },
          child: Icon(
            airport.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: airport.isFavorite ? Colors.red : Colors.grey,
            size: 28,
          ),
        ),
      ),
    );
  }
}
