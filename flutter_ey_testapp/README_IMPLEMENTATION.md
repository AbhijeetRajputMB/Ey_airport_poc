# Airport Finder - Flutter App

A complete Flutter application demonstrating modern app architecture with BLoC state management, REST API integration, local storage, and search functionality.

## 🎯 Features Implemented

### 1. **API Integration with DIO**
- Fetches airport data from MockAPI endpoint
- DIO client with request/response logging interceptor
- Error handling for connection timeouts, server errors, and network failures
- Clean error messages displayed to users

### 2. **BLoC State Management**
- **AirportCubit**: Manages airport list state
- **States**:
  - `AirportInitial`: Initial state
  - `AirportLoading`: Loading indicator state
  - `AirportLoaded`: Successfully loaded airports with search filtering
  - `AirportError`: Error with message display
- Methods:
  - `fetchAirports()`: Loads data from API
  - `searchAirports(query)`: Filters airports by name/code/city/country
  - `toggleFavorite(airport)`: Add/remove from favorites
  - `retryFetch()`: Retry failed requests

### 3. **Local Storage with Hive**
- Persists favorite airports locally
- Automatic favorite status sync on app restart
- Zero-dependency local database
- Generates type-safe adapters

### 4. **Search Functionality**
- Real-time search across multiple fields
- Searches by airport name, code, city, or country
- Case-insensitive matching
- Clear button for quick reset

### 5. **Favorites Management**
- Heart icon button on each airport card
- Persists to local storage (Hive)
- Visual feedback (red heart when favorited)
- Toggle on/off functionality

### 6. **Error Handling**
- Comprehensive error handling throughout
- User-friendly error messages
- Retry button for failed requests
- Timeout handling (30 seconds)

### 7. **Beautiful UI**
- Material Design 3
- Airport cards with all information
- Search bar with clear button
- Loading indicators
- Error states with visual feedback
- Responsive list view

## 📁 Project Structure

```
lib/
├── models/
│   ├── airport_model.dart      # Hive model with JSON serialization
│   └── airport_model.g.dart    # Generated Hive adapter
│
├── data/
│   ├── api/
│   │   └── dio_client.dart     # DIO HTTP client with interceptor
│   │
│   └── repositories/
│       └── airport_repository.dart  # Data layer with API calls
│
├── cubits/
│   ├── airport_cubit.dart      # State management logic
│   └── airport_state.dart      # State definitions
│
├── services/
│   └── local_storage_service.dart  # Hive database wrapper
│
├── screens/
│   └── home_screen.dart        # Main UI screen
│
├── widgets/
│   └── airport_list_item.dart  # Reusable list tile widget
│
└── main.dart                   # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.12.0
- Dart SDK ≥ 3.12.0

### Installation

1. **Get dependencies**:
```bash
flutter pub get
```

2. **Generate Hive adapters** (optional, already generated):
```bash
flutter pub run build_runner build
```

3. **Run the app**:
```bash
flutter run
```

## 🔧 How It Works

### State Flow

```
User Opens App
    ↓
main.dart initializes Hive
    ↓
BlocProvider creates AirportCubit
    ↓
HomeScreen calls fetchAirports()
    ↓
AirportRepository.fetchAirports()
    ↓
DioClient makes GET request to MockAPI
    ↓
JSON parsed to Airport models
    ↓
Favorite status loaded from Hive
    ↓
AirportLoaded state emitted
    ↓
UI renders ListView with all airports
```

### Search Flow

```
User types in search field
    ↓
searchAirports(query) called
    ↓
Filters airports by multiple fields
    ↓
AirportLoaded state with filtered data emitted
    ↓
UI updates with filtered results
```

### Favorite Toggle Flow

```
User taps heart icon
    ↓
toggleFavorite(airport) called
    ↓
Update isFavorite status locally
    ↓
Save/delete from Hive storage
    ↓
AirportLoaded state with updated status emitted
    ↓
UI updates with filled/empty heart
```

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^9.0.0 | State management |
| dio | ^5.3.0 | HTTP client |
| hive | ^2.2.3 | Local storage |
| hive_flutter | ^1.1.0 | Hive Flutter integration |
| build_runner | ^2.4.0 | Code generation |
| hive_generator | ^2.0.0 | Hive adapter generation |

## 🎨 UI Components

### Airport List Item
- Circular avatar with airport code
- Airport name (max 2 lines)
- City and country
- Latitude and longitude
- Favorite button (trailing)

### Search Bar
- Icon search prefix
- Clear button (shown when text present)
- Material design input decoration
- Real-time filtering

### Error Screen
- Error icon
- Error message display
- Retry button
- Centered layout

## 🌐 API Integration

**Endpoint**: `https://mocki.io/v1/70c236fd-0b01-4987-a6bc-0b97bdb3f005`

**Response Format**:
```json
{
  "airports": [
    {
      "code": "ATL",
      "name": "Hartsfield-Jackson Atlanta International",
      "city": "Atlanta",
      "country": "US",
      "lat": 33.6407,
      "lon": -84.4277
    }
  ]
}
```

## 🔒 Error Handling

The app handles various error scenarios:

| Error Type | Handling |
|-----------|----------|
| Connection Timeout | Shows user-friendly message |
| Receive Timeout | Asks user to retry |
| Bad Response (4xx, 5xx) | Shows server error code |
| Network Error | Generic error message |
| Unknown Error | Generic error with details |

## 💾 Local Storage

Favorites are stored using Hive:
- Key: Airport code (String)
- Value: Airport object with isFavorite = true
- Persists across app restarts
- No internet required to access favorites

## 🎯 Usage Tips

1. **First Load**: Wait for airports to load from API
2. **Search**: Type any part of airport information
3. **Favorites**: Tap heart icon to save/remove
4. **Offline**: Favorites work offline, but needs internet for initial load
5. **Retry**: Use retry button if network fails

## 📝 Notes

- All airports data is fetched from MockAPI on first load
- Favorites are stored locally and persist between sessions
- Search is case-insensitive and real-time
- 30-second timeout for API requests
- DIO interceptor logs all requests/responses to console

## 🚧 Future Enhancements

Possible improvements:
- Filter by country
- Sort by distance
- Map view integration
- Share favorite airports
- Export/import favorites
- Caching with time-to-live
- Pagination for large datasets
- Offline mode with cached data

## 📞 Support

For issues or questions about the implementation:
1. Check the error message displayed on screen
2. Review console logs from DIO interceptor
3. Verify internet connection
4. Clear app data and restart

---

**Built with Flutter & BLoC** ✨
