# Nigerian Ingredients Recognition & Recipe Recommendation System

A Flutter mobile app that uses **Azure ML API** and **AI Language model** to recognize Nigerian food ingredients from photos and suggest South-Western Nigerian recipes.

## Features

- **Ingredient Recognition**: Capture or upload photos of ingredients
- **AI-Powered Detection**: Azure TFLite model recognizes 30+ Nigerian ingredients
- **Smart Recipe Suggestions**: Google Gemini AI generates relevant south-western Nigerian recipes based on detected ingredients
- **Recipe Database**: Browse and bookmark favorite recipes
- **History Tracking**: View past ingredient scans and recipe suggestions

## Getting Started

### Prerequisites

- Flutter SDK 3.35.2 or higher
- Android Studio / Xcode (for mobile development)
- Android device or emulator (API 24+)
- Google Gemini API key (FREE) 

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Promise30/SmartCook.git
   cd SmartCook
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**
   ```bash
   # Copy the template
   cp lib/config/api_config.dart.example lib/config/api_config.dart
   ```
   
   Edit `lib/config/api_config.dart` and add your API key:
   - **Gemini (FREE)**: Get key at https://aistudio.google.com/apikey
  
4. **Run the app**
   ```bash
   # List available devices
   flutter devices
   
   # Run on connected device
   flutter run -d <device_id>
   ```

## Security Notes

**IMPORTANT**: Never commit files with real API keys!

- ✅ `api_config.dart.example` - Template with placeholders (safe to commit)
- ❌ `api_config.dart` - Your actual keys (gitignored, never commit)
- ❌ `test_gemini_api.dart` - Test file with keys (gitignored)

The `.gitignore` is configured to prevent accidental key exposure.

## Testing

```bash
# Run unit tests
flutter test

# Run on specific device
flutter run -d <device_id>
```

## API Integration

### Azure ML API
- Endpoint: `https://food-ingredients-recogition-api.azurewebsites.net`

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Promise** - [GitHub](https://github.com/Promise30)

## Acknowledgments

- Azure ML for ingredient recognition API
- Google Gemini for AI recipe generation
- Flutter team for the amazing framework

---

**If you find this project useful, please consider giving it a star!**
