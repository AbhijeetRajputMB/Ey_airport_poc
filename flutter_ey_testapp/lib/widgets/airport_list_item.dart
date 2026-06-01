import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ey_testapp/models/airport_model.dart';
import 'package:flutter_ey_testapp/cubits/airport_cubit.dart';

class AirportListItem extends StatelessWidget {
  final Airport airport;

  const AirportListItem({super.key, required this.airport});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Optional: Navigate to airport details
            },

            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Airport Code Box
                  _AirportCodeBox(airport: airport),
                  const SizedBox(width: 16),
                  // Airport Info
                  Expanded(child: _AirportInfoColumn(airport: airport)),
                  const SizedBox(width: 12),
                  // Favorite Button + Chevron
                  _FavoriteAndChevron(airport: airport),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AirportCodeBox extends StatelessWidget {
  final Airport airport;

  const _AirportCodeBox({required this.airport});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: Colors.blue),
      child: Center(
        child: Text(
          airport.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _AirportInfoColumn extends StatelessWidget {
  final Airport airport;

  const _AirportInfoColumn({required this.airport});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Airport Name
        Text(
          airport.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        // City and Country
        Row(
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${airport.city}, ${airport.country}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FavoriteAndChevron extends StatelessWidget {
  final Airport airport;

  const _FavoriteAndChevron({required this.airport});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heart Icon
        GestureDetector(
          onTap: () {
            context.read<AirportCubit>().toggleFavorite(airport);
          },
          child: Icon(
            airport.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: airport.isFavorite ? Colors.red : Colors.grey.shade400,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        // Chevron Icon
        Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 24),
      ],
    );
  }
}
