import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter_ey_testapp/cubits/airport_cubit.dart';
import 'package:flutter_ey_testapp/widgets/airport_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController _searchController;
  bool _showOnlyFavorites = false;
  Timer? _searchDebounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<AirportCubit>().fetchAirports();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      context.read<AirportCubit>().searchAirports(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            children: [
              // Header Section with extra padding to accommodate search bar
              RepaintBoundary(child: _buildHeader()),

              // Extra space for floating search bar
              const SizedBox(height: 20),

              // Cache Indicator
              _buildCacheIndicator(),

              // Airport List
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildAirportList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Background Image
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
          ),
          child: CachedNetworkImage(
            imageUrl:
                'https://images.pexels.com/photos/37005078/pexels-photo-37005078.jpeg',
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: Colors.blue.shade400),
            errorWidget: (context, url, error) =>
                Container(color: Colors.blue.shade400),
            cacheManager: null,
          ),
        ),
        // Overlay gradient
        Container(
          height: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
        // Header Content
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Airplane Icon and Favorites Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _AirplaneIconButton(),
                    _FavoritesToggleButton(
                      isActive: _showOnlyFavorites,
                      onTap: () {
                        setState(() {
                          _showOnlyFavorites = !_showOnlyFavorites;
                        });
                      },
                    ),
                  ],
                ),
                // Title and Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Airports',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Explore and find airports\naround the world',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildSearchBar(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, code, city, or country...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.grey.shade400),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AirportCubit>().searchAirports('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: Colors.transparent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCacheIndicator() {
    return BlocBuilder<AirportCubit, AirportState>(
      buildWhen: (previous, current) {
        if (previous is AirportLoaded && current is AirportLoaded) {
          return previous.isFromCache != current.isFromCache;
        }
        return false;
      },
      builder: (context, state) {
        if (state is AirportLoaded && state.isFromCache) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200, width: 1),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.amber.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cached • Updating from server',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildAirportList() {
    return BlocBuilder<AirportCubit, AirportState>(
      builder: (context, state) {
        if (state is AirportInitial) {
          return const _EmptyStateWidget(
            message: 'Tap search to load airports',
          );
        } else if (state is AirportLoading) {
          return const _LoadingStateWidget();
        } else if (state is AirportLoaded) {
          final airportsToShow = _showOnlyFavorites
              ? state.filteredAirports
                    .where((airport) => airport.isFavorite)
                    .toList()
              : state.filteredAirports;

          if (airportsToShow.isEmpty) {
            return _EmptyStateWidget(
              message: _showOnlyFavorites
                  ? 'No favorites yet\nAdd some to get started'
                  : state.searchQuery.isEmpty
                  ? 'No airports available'
                  : 'No airports found for\n"${state.searchQuery}"',
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: airportsToShow.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AirportListItem(airport: airportsToShow[index]),
              );
            },
          );
        } else if (state is AirportError) {
          return _ErrorStateWidget(
            message: state.message,
            onRetry: () {
              context.read<AirportCubit>().retryFetch();
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}

// Extracted widgets for better performance
class _AirplaneIconButton extends StatelessWidget {
  const _AirplaneIconButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 26),
    );
  }
}

class _FavoritesToggleButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _FavoritesToggleButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          isActive ? Icons.favorite : Icons.favorite_border,
          color: isActive ? Colors.red : Colors.blue,
          size: 22,
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final String message;

  const _EmptyStateWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flight_takeoff, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _LoadingStateWidget extends StatelessWidget {
  const _LoadingStateWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading airports...',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
