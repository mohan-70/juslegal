# JusLegal - Know Your Rights. Take Action.

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-1.0.0-orange)

## Overview

JusLegal is an AI-powered consumer legal assistant for Indian citizens, providing instant legal guidance based on Indian consumer law. It helps users understand their rights, take appropriate action, and navigate legal processes for common consumer issues like e-commerce disputes, banking fraud, travel problems, and more.

## Features

- **AI-Powered Legal Analysis** - Get instant legal guidance using Groq AI with OpenRouter fallback
- **Consumer Law Focus** - Specialized for Indian consumer protection laws and regulations
- **Step-by-Step Guidance** - Clear action steps for resolving legal issues
- **Authority Directory** - Contact information for relevant regulatory bodies
- **Document Generation** - Generate complaint letters and legal documents
- **Case Management** - Save and track your legal cases
- **Offline Knowledge Base** - Access legal information even without internet
- **Cross-Platform** - Works on Android, iOS, and Web
- **Trust & Verification System** - Legal expert verification badges and transparent AI sourcing
- **Real User Testimonials** - Social proof with actual case outcomes and success stories
- **Streaming AI Responses** - Real-time analysis with better user experience
- **Error Boundaries** - Graceful error handling with retry mechanisms

## Trust & Credibility Features

JusLegal addresses the fundamental trust issues in AI legal assistance through:

- **Transparent AI Sourcing** - Clear indication when advice is AI-generated vs legally verified
- **Legal Expert Verification** - Option for human-reviewed legal guidance on complex cases
- **Data Source Attribution** - References to specific Indian laws (Consumer Protection Act 2019, etc.)
- **Social Proof Integration** - Real user testimonials with actual monetary outcomes
- **Professional Disclaimers** - Clear guidance on AI limitations and when to consult lawyers
- **Trust-Building UI** - Banking-app color scheme and professional design patterns
- **Error Resilience** - Graceful failure handling with automatic fallback systems

**Languages & Frameworks:**
- Dart 3.2.3+
- Flutter 3.19.0+

**Core Libraries:**
- `flutter_riverpod` - State management
- `dio` - HTTP client for API calls
- `flutter_dotenv` - Environment variable management
- `go_router` - Navigation and routing
- `hive_flutter` - Local data storage
- `pretty_dio_logger` - Network request logging

**AI Services:**
- Groq API (Primary) - Llama 3.3 70B model
- OpenRouter API (Fallback) - Meta Llama 3.3 70B model

## Prerequisites

Before setting up JusLegal, ensure you have:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.19.0 or higher
- [Dart SDK](https://dart.dev/get-dart) 3.2.3 or higher
- Git for version control
- Code editor (VS Code recommended)

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/juslegal.git
   cd juslegal
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your API keys
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Usage

### Basic Legal Analysis

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juslegal/providers/ai_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);
    
    return ElevatedButton(
      onPressed: () {
        ref.read(analysisProvider.notifier).analyze(
          "My order was delivered defective",
          "E-commerce & Shopping"
        );
      },
      child: Text('Get Legal Guidance'),
    );
  }
}
```

### Accessing Analysis Results

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final result = ref.watch(analysisResultProvider);
  
  return result.when(
    data: (legalResult) => LegalResultDisplay(legalResult),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => Text('Error: $error'),
  );
}
```

## Configuration

### Environment Variables

Create a `.env` file in the project root with the following variables:

| Variable | Description | Required |
|----------|-------------|----------|
| `GROQ_API_KEY` | Groq API key for primary AI service | Yes |
| `OPENROUTER_API_KEY` | OpenRouter API key for fallback AI service | Yes |
| `APP_NAME` | Application name (used by OpenRouter) | No |
| `APP_URL` | Application URL (used by OpenRouter) | No |

### API Setup

1. **Groq API:**
   - Sign up at [console.groq.com](https://console.groq.com)
   - Create an API key
   - Add `GROQ_API_KEY=your_key_here` to `.env`

2. **OpenRouter API:**
   - Sign up at [openrouter.ai](https://openrouter.ai)
   - Create an API key
   - Add `OPENROUTER_API_KEY=your_key_here` to `.env`

## Project Structure

```
juslegal/
├── lib/
│   ├── core/                  # Core application logic
│   │   ├── constants/         # App constants and themes
│   │   ├── exceptions/        # Custom exception classes
│   │   └── router/           # Navigation configuration
│   ├── models/               # Data models
│   │   ├── legal_result_model.dart
│   │   └── saved_case_model.dart
│   ├── providers/            # Riverpod state management
│   │   ├── ai_provider.dart
│   │   └── ...other providers
│   ├── screens/              # UI screens
│   │   ├── problem_analyzer_screen.dart
│   │   ├── result_screen.dart
│   │   └── ...other screens
│   ├── services/             # Business logic services
│   │   ├── ai_service.dart
│   │   ├── groq_service.dart
│   │   ├── openrouter_service.dart
│   │   └── lkb_service.dart
│   └── widgets/              # Reusable UI components
├── assets/                  # Static assets
│   ├── legal_kb.json
│   └── ...other assets
├── .env.example             # Environment variables template
└── pubspec.yaml            # Dependencies and metadata
```

## Contributing

We welcome contributions! Here's how to get started:

1. **Fork the repository**
   ```bash
   git clone https://github.com/your-username/juslegal.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow existing code style
   - Add tests for new features
   - Update documentation as needed

4. **Submit a Pull Request**
   - Push to your fork
   - Open a PR against the `main` branch
   - Describe your changes clearly

### Development Guidelines

- Follow [Flutter/Dart style guidelines](https://dart.dev/guides/language/effective-dart/style)
- Write clear, descriptive commit messages
- Add unit tests for new functionality
- Ensure all tests pass before submitting

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact / Credits

**Development Team:** JusLegal Contributors  
**Website:** [juslegal.app](https://juslegal.app)  
**Support:** support@juslegal.app  

**Special Thanks:**
- Groq for providing the primary AI service
- OpenRouter for providing fallback AI service
- Flutter community for the excellent framework
- All contributors who help improve this project

