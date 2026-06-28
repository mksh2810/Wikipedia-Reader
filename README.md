# Wikipedia Reader

<div align="center">
  <img src="assets/logo.png" alt="Wikipedia Reader Logo" width="200" height="200">
  <h3>Explore Wikipedia articles with ease</h3>
</div>

## About

Wikipedia Reader is a beautiful Flutter application that lets users explore random Wikipedia articles with a modern, intuitive interface. Perfect for discovering interesting topics and expanding your knowledge!

## Features

✨ **Key Features:**

- 🔀 **Random Article Discovery** - Tap a button to get a random Wikipedia article
- 🔍 **Live Search** - Search for any topic and view matching Wikipedia articles with descriptions and thumbnails
- 🎨 **Modern UI** - Clean, gradient-based design with smooth animations and interactive search controls
- 📱 **Cross-Platform** - Works on Android, iOS, Web, Windows, macOS, and Linux
- ⚡ **Fast Loading** - Efficient API integration with Wikipedia
- 🌐 **Real-Time Data** - Fetches live data from Wikipedia's Action and REST APIs

## Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK
- A device/emulator or web browser for testing

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd wikipedia_reader
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Building for Different Platforms

**Android:**
```bash
flutter build apk
# or for aab (Google Play)
flutter build appbundle
```

**iOS:**
```bash
flutter build ios
```

**Web:**
```bash
flutter build web
```

**Windows/macOS/Linux:**
```bash
flutter build windows
flutter build macos
flutter build linux
```

## Project Structure

```
wikipedia_reader/
├── lib/
│   ├── main.dart           # Main app entry point and UI logic
│   ├── summary.dart        # Data models for Wikipedia summaries
│   └── [other files]       # Additional components
├── assets/
│   └── logo.png            # App logo
├── android/                # Android-specific files
├── ios/                    # iOS-specific files
├── web/                    # Web-specific files
├── windows/                # Windows-specific files
├── macos/                  # macOS-specific files
├── linux/                  # Linux-specific files
├── test/                   # Unit tests
├── pubspec.yaml            # Flutter dependencies
└── README.md               # This file
```

## Architecture

### Components

**ArticleModel**
- Handles API communication with Wikipedia
- Fetches random article summaries
- Returns structured data through `Summary` objects

**ArticleViewModel**
- Manages application state using `ChangeNotifier`
- Handles loading states
- Manages error handling
- Provides data to the UI layer

**ArticleView**
- Main stateful widget
- Displays the UI based on current state
- Shows loading indicator, error messages, or article content

**Summary Model**
- Data class for storing article information
- Contains title, description, image URL, and other metadata

### State Management

The app uses Flutter's built-in `ChangeNotifier` and `ListenableBuilder` for reactive state management. This provides:
- Simple, readable state updates
- Automatic UI rebuilds when data changes
- Minimal boilerplate code

### UI Flow

```
App Start
   ↓
ArticleView (initializes ViewModel)
   ↓
ViewModel fetches article
   ↓
Is Loading? → Show CircularProgressIndicator
   ↓
Error? → Show Error Message
   ↓
Success? → Display ArticlePage with content
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | UI framework |
| `http` | ^1.6.0 | HTTP client for API calls |

## API Integration

The app integrates with Wikipedia APIs:

### 1. Wikipedia REST API (Random & Summaries)
```
Endpoint: https://en.wikipedia.org/api/rest_v1/page/random/summary
Endpoint: https://en.wikipedia.org/api/rest_v1/page/summary/{title}
Method: GET
Response: JSON with article metadata (title, extract, description, images)
```

### 2. Wikipedia Action API (Search)
```
Endpoint: https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch={query}&origin=*
Method: GET
Response: JSON containing a list of search result articles
```
*Note: The Action API request uses `origin=*` to enable cross-origin requests (CORS) when running on web platforms.*

### Response Structure

```json
{
  "titles": {
    "normalized": "Article Title",
    "display": "Article Title"
  },
  "description": "Brief article description",
  "image": {
    "source": "https://...",
    "width": 640,
    "height": 480
  },
  "content_urls": {
    "mobile": {
      "page": "https://..."
    }
  }
}
```

## Usage

### Basic Usage

1. **Launch the app** - It automatically loads a random Wikipedia article on startup
2. **View Article** - See the article title, description, and thumbnail image
3. **Load Next Article** - Tap the "Next" button to fetch another random article

### Code Example

```dart
// Fetch a random article
final viewModel = ArticleViewModel(ArticleModel());
await viewModel.fetchArticle();

// Access the loaded summary
print(viewModel.summary?.titles.normalized);
```

## Error Handling

The app gracefully handles various error scenarios:

- **Network Errors** - Displays user-friendly error messages
- **API Failures** - Shows HTTP error status codes
- **Invalid Data** - Handles malformed API responses
- **Loading States** - Clear feedback during data fetching

## Testing

Run the test suite:

```bash
flutter test
```

View test coverage:

```bash
flutter test --coverage
```

## Development

### Hot Reload

```bash
flutter run
# Then press 'r' for hot reload
# Press 'R' for full restart
```

### Debugging

```bash
flutter run -v  # Verbose logging
flutter analyze  # Code analysis
flutter format lib/  # Auto-format code
```

### Code Style

The project follows Flutter and Dart best practices:
- Use meaningful variable names
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Keep functions focused and small
- Add comments for complex logic

## Performance

- **App Size**: Minimal dependencies for smaller app size
- **Load Time**: ~2-3 seconds to fetch and display articles
- **Memory Usage**: Optimized for low-end devices
- **API Calls**: Efficient REST API integration with error retry logic

## Troubleshooting

**Issue: App crashes on startup**
- Solution: Ensure you have internet connectivity
- Solution: Check that Flutter SDK is properly installed

**Issue: Images not loading**
- Solution: Verify internet connection
- Solution: Check Wikipedia API is accessible in your region

**Issue: Build fails**
- Solution: Run `flutter clean` and then `flutter pub get`
- Solution: Update Flutter SDK: `flutter upgrade`

## Acknowledgments

- 🌍 Wikipedia and the Wikimedia Foundation
- 🎨 Flutter and Dart communities
- 📚 Open-source contributors

## Contact & Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact the development team

---

**Happy Reading! 📖**
