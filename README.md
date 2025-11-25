# StyleSnap - AI Personal Shopping Stylist

<div align="center">

![StyleSnap Logo](https://via.placeholder.com/200x200?text=StyleSnap)

**Your AI-Powered Personal Stylist in Your Pocket**

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [Contributing](#-contributing)

</div>

---

## 📖 About

StyleSnap is an AI-powered personal styling application that transforms how people interact with their wardrobe. Using advanced AI technology (Google Gemini 1.5 Flash), StyleSnap automatically categorizes your clothing, creates personalized daily outfit recommendations, and helps you shop smarter through affiliate partnerships.

**Target Markets**: 🇹🇷 Turkey, 🇪🇸 Spain, 🌍 Global

**Goal**: Reach 2M+ users and $2M+ net profit in the first 12 months

---

## ✨ Features

### 🎨 Core Features (MVP v1.0)

- **📸 Smart Wardrobe Scanning**
  - Scan clothes with camera or import from gallery
  - AI-powered automatic categorization
  - Color, pattern, and style detection
  - Multi-item upload support

- **🤖 Daily Outfit Recommendations**
  - 3 AI-curated outfits every morning
  - Weather-aware suggestions (integrates with OpenWeatherMap)
  - Calendar event consideration
  - Personalized to your style preferences

- **🛍️ Smart Shopping**
  - Discover missing wardrobe items
  - Integrated affiliate shopping (Trendyol, Zara, H&M, Shein, ASOS)
  - AI-powered product matching
  - One-tap purchase links

- **📱 Social Sharing**
  - Share outfits to Instagram & TikTok
  - Auto-generated watermarks
  - Viral referral system with deep links
  - Earn rewards for sharing

- **💎 Premium Features**
  - Ad-free experience ($4.99/month)
  - Premium outfit packs ($1.99)
  - Celebrity style packs ($2.99)
  - Advanced analytics

### 🌍 Multi-Language Support

- 🇬🇧 English
- 🇹🇷 Turkish (Türkçe)
- 🇪🇸 Spanish (Español)

---

## 🛠️ Tech Stack

### Frontend
- **Framework**: Flutter 3.24+ / Dart 3.4+
- **State Management**: Riverpod 2.5+
- **UI Components**: Material Design 3

### Backend & Services
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **AI**: Google Gemini 1.5 Flash API
- **Weather**: OpenWeatherMap API
- **Payments**: RevenueCat
- **Ads**: Google AdMob
- **Analytics**: Mixpanel
- **Push Notifications**: Firebase Cloud Messaging

### Key Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  supabase_flutter: ^2.5.6
  google_generative_ai: ^0.4.3
  image_picker: ^1.0.7
  google_ml_kit: ^0.18.0
  purchases_flutter: ^6.29.2
  google_mobile_ads: ^5.1.0
  share_plus: ^9.0.0
  firebase_messaging: ^14.9.4
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.24 or later)
- Dart SDK (3.4 or later)
- Android Studio / Xcode
- Supabase account
- Google Gemini API key
- RevenueCat account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/stylesnap.git
   cd stylesnap
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GEMINI_API_KEY=your_gemini_api_key
   REVENUECAT_API_KEY=your_revenuecat_key
   OPENWEATHER_API_KEY=your_weather_api_key
   ADMOB_APP_ID_IOS=ca-app-pub-xxx
   ADMOB_APP_ID_ANDROID=ca-app-pub-xxx
   ```

4. **Set up Supabase**
   
   Run the SQL migrations in `docs/DATABASE_SCHEMA.md` in your Supabase SQL Editor.

5. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   ```

### Build for Production

**Android**:
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS**:
```bash
flutter build ios --release
```

---

## 📚 Documentation

Comprehensive documentation is available in the `/docs` folder:

### Planning & Strategy
- [Feature Roadmap](docs/FEATURE_ROADMAP.md) - v1.0, v1.1, v2.0 features
- [Wireframes](docs/WIREFRAMES.md) - All 32 screen designs
- [Development Timeline](docs/DEVELOPMENT_TIMELINE.md) - 12-week sprint plan
- [Marketing Strategy](docs/MARKETING_STRATEGY.md) - Zero-budget growth to 500K users
- [MVP Cost Breakdown](docs/MVP_COST_BREAKDOWN.md) - Complete cost analysis
- [Branding Guide](docs/BRANDING.md) - Logo, domain, brand identity

### Technical Implementation
- [Database Schema](docs/DATABASE_SCHEMA.md) - Supabase tables & RLS policies
- [AI Prompts](docs/AI_PROMPTS.md) - Gemini integration & prompts
- [Image Pipeline](docs/IMAGE_PIPELINE.md) - Camera → AI → Database flow
- [RevenueCat Integration](docs/REVENUECAT_INTEGRATION.md) - In-app purchases
- [AdMob Integration](docs/ADMOB_INTEGRATION.md) - Ads implementation
- [Affiliate System](docs/AFFILIATE_SYSTEM.md) - Shopping partnerships
- [Social Sharing](docs/SOCIAL_SHARING.md) - Instagram/TikTok viral loop

### App Store
- [App Store Metadata](docs/APP_STORE_METADATA.md) - Descriptions, keywords, screenshots (TR/EN/ES)

---

## 📂 Project Structure

```
stylesnap/
├── lib/
│   ├── core/
│   │   ├── config/           # Environment & API configs
│   │   ├── constants/        # App constants
│   │   ├── theme/            # App theme & colors
│   │   ├── router/           # Navigation
│   │   └── utils/            # Helper functions
│   ├── features/
│   │   ├── auth/             # Authentication
│   │   ├── onboarding/       # Onboarding flow
│   │   ├── wardrobe/         # Wardrobe management
│   │   ├── recommendations/  # Outfit suggestions
│   │   ├── shopping/         # Affiliate shopping
│   │   ├── sharing/          # Social sharing
│   │   ├── paywall/          # Premium subscriptions
│   │   ├── profile/          # User profile
│   │   └── history/          # Outfit history
│   ├── models/               # Data models
│   ├── services/             # Business logic services
│   ├── repositories/         # Data access layer
│   ├── widgets/              # Reusable UI components
│   └── main.dart             # App entry point
├── docs/                     # Documentation
├── assets/                   # Images, fonts, etc.
├── test/                     # Unit & widget tests
└── pubspec.yaml             # Dependencies
```

---

## 💰 Revenue Model

StyleSnap uses multiple revenue streams:

| Revenue Source | Monthly Target (50K users) | Percentage |
|----------------|---------------------------|------------|
| **Subscriptions** (RevenueCat) | $15,000 | 30% |
| **Ads** (AdMob) | $24,500 | 49% |
| **Affiliate Commissions** | $10,000 | 20% |
| **One-time Purchases** | $500 | 1% |
| **Total** | **$50,000** | **100%** |

**First Year Target**: $2M+ net profit

---

## 📈 Roadmap

- [x] **Q4 2025**: MVP Development (Week 1-12)
- [ ] **Q1 2026**: Beta Launch (1K users)
- [ ] **Q1 2026**: Public Launch (10K users)
- [ ] **Q2 2026**: Scale to 100K users
- [ ] **Q3 2026**: Reach 500K users
- [ ] **Q4 2026**: 2M users milestone

See [FEATURE_ROADMAP.md](docs/FEATURE_ROADMAP.md) for detailed feature timeline.

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/ai_service_test.dart

# Run with coverage
flutter test --coverage
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Format code with `dart format .`

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

**Lead Developer**: [Your Name]

**AI Assistance**: Google Gemini, GitHub Copilot

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Supabase](https://supabase.com) for backend infrastructure
- [Google Gemini](https://ai.google.dev) for AI capabilities
- [RevenueCat](https://www.revenuecat.com) for monetization
- All open-source contributors

---

## 🔗 Links

- **Website**: https://stylesnap.app (coming soon)
- **Documentation**: [/docs](/docs)
- **Issues**: [GitHub Issues](https://github.com/yourusername/stylesnap/issues)
- **Discord**: [Join our community](https://discord.gg/stylesnap) (coming soon)

---

## 📞 Contact

- **Email**: hello@stylesnap.app
- **Support**: support@stylesnap.app
- **Press**: press@stylesnap.app

---

<div align="center">

**Made with ❤️ using Flutter**

**Powered by AI • Built for Fashion Lovers**

⭐ Star us on GitHub if you like this project!

</div>
