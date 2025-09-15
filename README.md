# GlassNews – Modern Flutter News App

A sleek, glassmorphism-inspired news app built with Flutter. Browse top headlines, search globally, filter by language and country, save favorites, and personalize your reading experience with a beautiful, animated UI.

## Table of Contents
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

## Overview
GlassNews delivers a premium, fluid news experience:

- Liquid‑glass filter panels and navigation  
- Smooth transitions, bounce physics, subtle shimmer  
- Clean typography, balanced spacing, dark‑first design  

## Features
- **Search news:** live search with debounce, reels‑style cards  
- **Top headlines by country:** category tabs and spotlight on Home  
- **Save articles:** one‑tap bookmark with animation and local persistence  
- **Filters (language, country, sort):** modern liquid‑glass bottom sheet  
- **Settings:** default language/country, dark mode toggle, saved locally  
- **Splash:** custom “Z” logo, connectivity gate with Retry + auto‑navigation  
- **Brand:** custom Z launcher icons, app name “GlassNews”  

## Screens

### Splash
![Splash](https://github.com/user-attachments/assets/2d5062a6-321e-4056-9f2b-c59fc638255f)

### Home
![Home](https://github.com/user-attachments/assets/4503958e-7779-4325-83f8-4e2b248d266e)

### Search
![Empty Search](https://github.com/user-attachments/assets/78f4afa1-942f-4400-9bf1-b2826781715b)
![Swip News Searched](https://github.com/user-attachments/assets/7618f877-d88d-4706-a003-5d4d25ecebac)

### Saved
![Empty Save](https://github.com/user-attachments/assets/37b97e30-e93e-4c05-8e6e-f4cb141b70c5)
![Saved News](https://github.com/user-attachments/assets/75e2e3a1-881f-4208-91a3-5ee7fc10198a)

### Settings
![Settings](https://github.com/user-attachments/assets/d65a5649-124c-4915-9cb2-065e665da87b)

## Tech Stack
- Flutter (Dart), GetX (state + nav)  
- Shared Preferences (local storage)  
- flutter_dotenv (.env configuration)  
- flutter_card_swiper (reels)  
- lottie (Lottie animations)  
- liquid_glass_renderer (glass effect; Impeller)  

## App Architecture
- **Presentation:** Widgets + GetX Controllers  
- **Domain:** Controllers orchestrate filters/search/saves  
- **Data:** Services (News API client) + local persistence (SharedPreferences)  
- **Config:** .env for API base URL + key  

## Setup
1. Install Flutter SDK  
2. Clone repository:  
```bash
git clone <your_repo_url>
cd GlassNews-App
flutter pub get
