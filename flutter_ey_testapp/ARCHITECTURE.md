# 🏗️ Architecture & Code Examples

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      UI LAYER                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │        HomeScreen + AirportListItem                 │   │
│  │  - ListView rendering                               │   │
│  │  - Search bar interaction                           │   │
│  │  - Favorite button taps                             │   │
│  └──────────┬───────────────────────────────────────────┘   │
└─────────────┼──────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│               STATE MANAGEMENT (BLoC)                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              AirportCubit                           │   │
│  │  • fetchAirports()                                  │   │
│  │  • searchAirports(query)                            │   │
│  │  • toggleFavorite(airport)                          │   │
│  │  • retryFetch()                                     │   │
│  │                                                      │   │
│  │  States: Initial, Loading, Loaded, Error           │   │
│  └──────────┬─────────────────────────────────┬────────┘   │
└─────────────┼─────────────────────────────────┼──────────┬──┘
              │                                 │          │
              ▼                                 ▼          ▼
    ┌──────────────────┐          ┌──────────────────────┐
    │  REPOSITORY LAYER│          │  LOCAL STORAGE       │
    ├──────────────────┤          ├──────────────────────┤
    │AirportRepository │          │LocalStorageService   │
    │                  │          │                      │
    │fetchAirports()   │          │• addFavorite()      │
    │error handling    │          │• removeFavorite()   │
    │JSON parsing      │          │• isFavorite()       │
    └────────┬─────────┘          │• getFavorites()     │
             │                     └──────────┬──────────┘
             │                                │
             ▼                                ▼
    ┌──────────────────┐          ┌──────────────────────┐
    │  API LAYER       │          │  HIVE DATABASE       │
    ├──────────────────┤          ├──────────────────────┤
    │  DioClient       │          │  Local Device        │
    │                  │          │  Persistent Storage  │
    │GET /airports     │          │  Favorites Box       │
    │Logging           │          │                      │
    │Error handling    │          │  TypeId: 0           │
    └────────┬─────────┘          │  Key: Airport.code   │
             │                     └──────────────────────┘
             ▼
    ┌──────────────────────────┐
    │   MockAPI Endpoint       │
    │ https://mocki.io/v1/...  │
    │                          │
    │  30 Airports JSON        │
    └──────────────────────────┘
```

---

## Key Classes Explained

### **1. Airport Model (Data Class)**

```dart
@HiveType(typeId: 0)
class Airport extends HiveObject {
  @HiveField(0)
  final String code;           // "ATL"
  
  @HiveField(1)
  final String name;           // "Hartsfield-Jackson Atlanta International"
  
  @HiveField(2)
  final String city;           // "Atlanta"
  
  @HiveField(3)
  final String country;        // "US"
  
  @HiveField(4)
  final double lat;            // 33.6407
  
  @HiveField(5)
  final double lon;            // -84.4277
  
  @HiveField(6)
  bool isFavorite;             // User preference
  
  // Methods:
  // - fromJson()  : Parse API response
  // - toJson()    : Serialize to JSON
  // - copyWith()  : Immutable updates
}
```

**Why @HiveType?**
- Hive generates type adapters for fast serialization
- Binary storage is faster than JSON
- Type-safe database queries
- Automatic migration support

---

### **2. DIO Client (HTTP Layer)**

```dart
class DioClient {
  late Dio _dio;
  
  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: '',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      contentType: Headers.jsonContentType,
    ));
    
    // Add logging interceptor
    _dio.interceptors.add(DioInterceptor());
  }
  
  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;  // Success
    } on DioException {
      rethrow;  // Propagate to caller
    }
  }
}

// Interceptor logs all requests
class DioInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, handler) {
    print('🔗 REQUEST: ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, handler) {
    print('✅ RESPONSE: ${response.statusCode}');
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, handler) {
    print('❌ ERROR: ${err.message}');
    super.onError(err, handler);
  }
}
```

**Features:**
- Automatic timeout handling
- Comprehensive error types
- Request/response logging
- Extensible interceptor pattern

---

### **3. Repository (Data Layer)**

```dart
class AirportRepository {
  final DioClient dioClient;
  
  AirportRepository({required this.dioClient});
  
  Future<List<Airport>> fetchAirports() async {
    try {
      final response = await dioClient.get(
        'https://mocki.io/v1/70c236fd-0b01-4987-a6bc-0b97bdb3f005',
      );
      
      // Success: Parse response
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final airportList = (data['airports'] as List)
            .map((airport) => Airport.fromJson(airport))
            .toList();
        return airportList;
      } else {
        throw Exception('Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle specific error types
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout.');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Server error: ${e.response?.statusCode}');
      } else if (e.type == DioExceptionType.unknown) {
        throw Exception('Network error.');
      } else {
        throw Exception('Failed: ${e.message}');
      }
    }
  }
}
```

**Responsibilities:**
- Data fetching from network
- JSON parsing to models
- Error handling and translation
- Clean data to business layer

---

### **4. State Classes (State Management)**

```dart
// Base state
abstract class AirportState {
  const AirportState();
}

// Initial state
class AirportInitial extends AirportState {
  const AirportInitial();
}

// Loading state
class AirportLoading extends AirportState {
  const AirportLoading();
}

// Success state with immutable updates
class AirportLoaded extends AirportState {
  final List<Airport> airports;         // Full list
  final List<Airport> filteredAirports;  // Filtered by search
  final String searchQuery;              // Current search term
  
  const AirportLoaded({
    required this.airports,
    required this.filteredAirports,
    this.searchQuery = '',
  });
  
  // Immutable copy with updates
  AirportLoaded copyWith({
    List<Airport>? airports,
    List<Airport>? filteredAirports,
    String? searchQuery,
  }) {
    return AirportLoaded(
      airports: airports ?? this.airports,
      filteredAirports: filteredAirports ?? this.filteredAirports,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Error state
class AirportError extends AirportState {
  final String message;
  const AirportError(this.message);
}
```

**Design Principles:**
- Immutable states (no side effects)
- Sealed class hierarchy
- copyWith() for state updates
- Type-safe error messages

---

### **5. AirportCubit (Business Logic)**

```dart
class AirportCubit extends Cubit<AirportState> {
  final AirportRepository airportRepository;
  final LocalStorageService localStorageService;
  
  AirportCubit({
    required this.airportRepository,
    required this.localStorageService,
  }) : super(const AirportInitial());
  
  // Fetch airports from API
  Future<void> fetchAirports() async {
    try {
      emit(const AirportLoading());
      
      // 1. Fetch from API
      final airports = await airportRepository.fetchAirports();
      
      // 2. Load favorites from Hive
      final favorites = localStorageService.getFavorites();
      final favoriteCodes = favorites.map((a) => a.code).toSet();
      
      // 3. Update isFavorite status
      final updated = airports.map((airport) {
        return airport.copyWith(
          isFavorite: favoriteCodes.contains(airport.code),
        );
      }).toList();
      
      // 4. Emit success state
      emit(AirportLoaded(
        airports: updated,
        filteredAirports: updated,
        searchQuery: '',
      ));
    } catch (e) {
      emit(AirportError(e.toString()));
    }
  }
  
  // Search airports
  void searchAirports(String query) {
    final currentState = state;
    
    if (currentState is AirportLoaded) {
      if (query.isEmpty) {
        // Clear search
        emit(currentState.copyWith(
          filteredAirports: currentState.airports,
          searchQuery: '',
        ));
      } else {
        // Filter by multiple fields
        final filtered = currentState.airports
            .where((airport) =>
                airport.name.toLowerCase().contains(query.toLowerCase()) ||
                airport.code.toLowerCase().contains(query.toLowerCase()) ||
                airport.city.toLowerCase().contains(query.toLowerCase()) ||
                airport.country.toLowerCase().contains(query.toLowerCase()))
            .toList();
        
        emit(currentState.copyWith(
          filteredAirports: filtered,
          searchQuery: query,
        ));
      }
    }
  }
  
  // Toggle favorite status
  Future<void> toggleFavorite(Airport airport) async {
    final currentState = state;
    
    if (currentState is AirportLoaded) {
      try {
        final isFavorite = !airport.isFavorite;
        airport.isFavorite = isFavorite;
        
        // Save/delete from Hive
        if (isFavorite) {
          await localStorageService.addFavorite(airport);
        } else {
          await localStorageService.removeFavorite(airport.code);
        }
        
        // Update both lists
        final updatedAirports = currentState.airports.map((a) {
          return a.code == airport.code
              ? a.copyWith(isFavorite: isFavorite)
              : a;
        }).toList();
        
        final updatedFiltered = currentState.filteredAirports.map((a) {
          return a.code == airport.code
              ? a.copyWith(isFavorite: isFavorite)
              : a;
        }).toList();
        
        emit(AirportLoaded(
          airports: updatedAirports,
          filteredAirports: updatedFiltered,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        emit(AirportError('Failed to update favorite: $e'));
      }
    }
  }
}
```

**Key Methods:**
- `fetchAirports()`: Loads and processes data
- `searchAirports()`: Filters list
- `toggleFavorite()`: Manages favorites
- `retryFetch()`: Recovers from errors

---

## 🎯 Usage Patterns

### **Pattern 1: Reading State**

```dart
BlocBuilder<AirportCubit, AirportState>(
  builder: (context, state) {
    if (state is AirportLoading) {
      return CircularProgressIndicator();
    } else if (state is AirportLoaded) {
      return ListView.builder(
        itemCount: state.filteredAirports.length,
        itemBuilder: (context, index) {
          return AirportListItem(
            airport: state.filteredAirports[index],
          );
        },
      );
    } else if (state is AirportError) {
      return ErrorWidget(message: state.message);
    }
    return SizedBox();
  },
)
```

### **Pattern 2: Triggering Actions**

```dart
// Search
context.read<AirportCubit>().searchAirports(query);

// Toggle favorite
context.read<AirportCubit>().toggleFavorite(airport);

// Retry
context.read<AirportCubit>().retryFetch();
```

### **Pattern 3: Local Storage**

```dart
// Add to favorites
await localStorageService.addFavorite(airport);

// Check if favorited
bool isFav = localStorageService.isFavorite('ATL');

// Get all favorites
List<Airport> favs = localStorageService.getFavorites();

// Remove from favorites
await localStorageService.removeFavorite('ATL');
```

---

## 🔍 Error Handling Examples

### **API Timeout**
```
User sees: "Connection timeout. Please check your internet connection."
System: Shows retry button
Recovery: User taps retry after fixing connection
```

### **Invalid Response**
```
User sees: "Server error: 500"
System: Shows error screen
Recovery: Retry button tries again
```

### **No Favorites Saved**
```
All hearts empty initially
User adds favorites
Hearts fill and persist
App restarts → Hearts still filled
```

---

## 📊 State Transitions Diagram

```
         fetchAirports()
            │
            ▼
       AirportInitial ──→ AirportLoading
                              │
                    ┌─────────┴─────────┐
                    │                   │
                    ▼                   ▼
            (Success)            (Error)
        AirportLoaded          AirportError
            │                      │
    ┌──────┴──────┐           retryFetch()
    │             │                │
    │      searchAirports()        │
    │             │                │
    ▼             ▼                ▼
AirportLoaded  AirportLoaded  AirportLoading
(filtered)     (full list)          │
                                    └─→ (Success/Error)
    
    toggleFavorite()
         │
         ▼
    AirportLoaded
    (with updated isFavorite)
```

---

## ✅ Testing Flow

```
1. Launch App
   ├─ AirportInitial
   ├─ AirportLoading (shows spinner)
   ├─ fetchAirports() → API call
   ├─ Load favorites from Hive
   ├─ Parse JSON → Models
   └─ AirportLoaded (show list)

2. User Searches "London"
   ├─ searchAirports("london")
   ├─ Filter by name, code, city, country
   └─ AirportLoaded(filtered=[London Heathrow])

3. User Taps Heart
   ├─ toggleFavorite(airport)
   ├─ Update isFavorite = true
   ├─ Save to Hive
   └─ AirportLoaded(updated status)

4. App Restarts
   ├─ Hive loads favorites
   ├─ Heart still filled
   └─ Persistence verified ✅
```

---

## 🚀 Performance Optimizations

1. **Immutable States**: No unnecessary rebuilds
2. **Filtered Lists**: Only display items change
3. **Hive Binary Storage**: Faster than JSON
4. **Interceptor Logging**: Helps debug without code changes
5. **Type Safety**: Compile-time error detection
6. **DIO Connection Pooling**: Reuses connections

---

**Complete Architecture Reference Ready!** 📚
