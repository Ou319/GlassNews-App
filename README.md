### GlassNews – Modern Flutter News App

A sleek, glassmorphism-inspired news app built with Flutter. Browse top headlines, search globally, filter by language and country, save favorites, and personalize your reading experience with a beautiful, animated UI.

### Table of Contents
- Overview
- Features
- Screens
- Tech Stack
- App Architecture
- Setup
- Environment
- Running and Building
- App Structure
- API and Data
- State, Persistence, and Theming
- Animations and Design System
- Accessibility
- Roadmap
- Contributing
- License

### Overview
GlassNews delivers a premium, fluid news experience:
- Liquid‑glass filter panels and navigation
- Smooth transitions, bounce physics, subtle shimmer
- Clean typography, balanced spacing, dark‑first design

### Features
- Search news: live search with debounce, reels‑style cards
- Top headlines by country: category tabs and spotlight on Home
- Save articles: one‑tap bookmark with animation and local persistence
- Filters (language, country, sort): modern liquid‑glass bottom sheet
- Settings: default language/country, dark mode toggle, saved locally
- Splash: custom “Z” logo, connectivity gate with Retry + auto‑navigation
- Brand: custom Z launcher icons, app name “GlassNews”

### Screens
- Splash: black background, white Z logo, “Glass News”
- Home: category chips, spotlight/random card, swipable lists
- Search: Lottie empty state, liquid‑glass filter in the input, reels cards
- Saved: list of saved articles with preview + detail bottom sheet
- Settings: glass cards for language/country/theme

Screenshots (replace with your images):
- ![Splash](assets/images/readme/splash.png)
- ![Home](assets/images/readme/home.png)
- ![Search](assets/images/readme/search.png)
- ![Saved](assets/images/readme/saved.png)
- ![Settings](assets/images/readme/settings.png)

### Tech Stack
- Flutter (Dart), GetX (state + nav)
- Shared Preferences (local storage)
- flutter_dotenv (.env configuration)
- flutter_card_swiper (reels)
- lottie (Lottie animations)
- liquid_glass_renderer (glass effect; Impeller)

### App Architecture
- Presentation: Widgets + GetX Controllers
- Domain: Controllers orchestrate filters/search/saves
- Data: Services (News API client) + local persistence (SharedPreferences)
- Config: `.env` for API base URL + key

### Setup
1) Install Flutter SDK  
2) Clone:
```bash
git clone <your_repo_url>
cd GlassNews-App
```
3) Install:
```bash
flutter pub get
```

### Environment
Create `.env` in project root:
```
NEWSAPI_BASE_URL=https://newsapi.org/v2
NEWSAPI_KEY=YOUR_NEWSAPI_KEY
```
Note: `.env` is loaded in `main.dart` via `flutter_dotenv` and read in `lib/const/api.dart`.

### Running and Building
- Run: `flutter run`
- Android: `flutter build apk`
- iOS: `flutter build ios`

### App Structure
- `lib/`
  - `main.dart` (boot + dotenv)
  - `const/` (API consts)
  - `constants/` (strings, sizes)
  - `controler/` (GetX controllers)
  - `data/` (services)
  - `compenent/` (reusable UI: cards, filter button)
  - `view/` (pages: home, search, save, settings, splash)
  - `routes/` (route consts + generator)
- `assets/`
  - `images/` (icons/screenshots, app icon source)
  - `icons/`

### API and Data
- Provider: NewsAPI.org (do not commit your key)
  - Base URL: `https://newsapi.org/v2`
  - Auth: `X-Api-Key: YOUR_NEWSAPI_KEY`
- Endpoints used:
  - `/top-headlines` (country/category)
  - `/everything` (q/language/sort/pageSize)
- Models:
  - `NewsResponse(status, totalResults, articles)`
  - `Article(source{id,name}, author, title, description, url, urlToImage, publishedAt, content)`
- Filter propagation:
  - `SearchController`: language/sort (search), country (initial headlines)
  - `CategoryNewsController`: country
  - Filters + Settings persist in SharedPreferences and apply immediately

### State, Persistence, and Theming
- State: GetX controllers (`SearchController`, `CategoryNewsController`, etc.)
- Persistence: SharedPreferences keys
  - `settings_language`, `settings_country`, `settings_theme_dark`
  - `saved_articles_v1`
- Theming:
  - Dark‑first palette, glass panels, rounded shapes
  - Dark mode flag stored (can be wired to app ThemeMode)

### Animations and Design System
- Liquid‑glass filter sheet:
  - `LiquidGlassLayer` + `LiquidGlass.inLayer` (rounded superellipse, 24px)
  - Handle bar, bounce scroll, staggered fields, custom glass buttons, shimmer overlay
- Transitions:
  - Scale/opacity entrance
  - Slide/fade page transitions
  - Swiper reels with bounce physics
- Lottie:
  - Search empty state
  - Saved empty‑state animation

### Accessibility
- Clear hierarchy + high contrast
- Crisp text rendered above glass backgrounds
- Offline gate on splash with Retry option

### Roadmap
- Wire dark/light ThemeMode globally
- Source/domain filters, richer metadata
- Infinite scroll pagination
- Deep links / share targets
- Cached last results for offline view

### Contributing
- Fork and branch from `main`
- Commit with descriptive messages
- Open PRs for review

### License
- feel free

### API Notes
- Get your key at `https://newsapi.org/v2` (NewsAPI).  
- Keep keys private: use `.env`, never commit them.
- Free plan has rate limits; app uses debounce and local settings storage.

### IMG got the app

Home Page (https://github.com/user-attachments/assets/2d5062a6-321e-4056-9f2b-c59fc638255f)
Filter the News (https://github.com/user-attachments/assets/4503958e-7779-4325-83f8-4e2b248d266e)
Empty search (https://github.com/user-attachments/assets/78f4afa1-942f-4400-9bf1-b2826781715b)
Swip News Searched (https://github.com/user-attachments/assets/7618f877-d88d-4706-a003-5d4d25ecebac)
Empty Save(https://github.com/user-attachments/assets/37b97e30-e93e-4c05-8e6e-f4cb141b70c5)
Saved News (https://github.com/user-attachments/assets/75e2e3a1-881f-4208-91a3-5ee7fc10198a)
(https://github.com/user-attachments/assets/219b9339-718d-4e31-b20d-d15944c8b78a)
(https://github.com/user-attachments/assets/388a6d68-7d38-4a9c-95e3-241da1fafe1d)
Setting (https://github.com/user-attachments/assets/d65a5649-124c-4915-9cb2-065e665da87b)


there's more....








