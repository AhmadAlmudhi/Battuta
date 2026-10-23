# بطوطة · Battuta

**Every country, stamped.** · كل دولة، بختمها

[![CI](https://github.com/AhmadAlmudhi/Battuta/actions/workflows/ci.yml/badge.svg)](https://github.com/AhmadAlmudhi/Battuta/actions/workflows/ci.yml)
[![Deploy](https://github.com/AhmadAlmudhi/Battuta/actions/workflows/deploy.yml/badge.svg)](https://github.com/AhmadAlmudhi/Battuta/actions/workflows/deploy.yml)

Battuta is an app for exploring every country in the world, keeping track of the ones you've visited, and planning the next trip. It is named after Ibn Battuta, the 14th-century traveler from Tangier.

**Try it: [battuta-travel.web.app](https://battuta-travel.web.app)**

It works in any modern browser, on a phone or a computer, with no account and no install.

## What you can do

- **Explore** 249 countries and territories with their flags. Search in English or Arabic, filter by region, language, or currency, and sort by name, population, or area.
- **Read the details** of each country: capital, population, area, languages, currencies, time zones, and neighbors. Open any country in Maps.
- **Record your travels.** Mark countries as visited, with an optional date, rating, and notes, or add them to your wishlist with a priority and target year. A passport stamp lands on the flag when you save a visit.
- **See your stats** on a world map: visited countries in amber, your wishlist hatched. You can zoom in, focus on a region, replay your trips in date order, and share an image of your map.
- **Use it offline.** Your travels are saved on your device first, so the app works without an account or a connection.
- **Sync across devices**, if you want to: sign in with an email and password to back up your travels and keep them in sync.
- **Choose English or Arabic**, with a full right-to-left layout, and a light or dark theme.

## Run it locally

You need [Flutter](https://docs.flutter.dev/get-started/install) 3.47.7.

```bash
flutter pub get
flutter run -d chrome
```

The app starts with the country data bundled in `assets/data/`, so it runs without an API key. To let **Refresh data** download fresh data, get a key from [REST Countries](https://restcountries.com), copy `env.example.json` to `env.json`, add the key, and run with it:

```bash
flutter run -d chrome --dart-define-from-file=env.json
```

`env.json` is git-ignored; never commit it. Android and iOS build from the same code (`flutter build apk`, `flutter build ios --no-codesign`), but only the web app is published.

## Checks

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

GitHub Actions runs these, plus web, Android, and iOS builds, on every push to `main` and every pull request. Pull requests from this repository also get a preview site.

Pushing a version tag such as `v1.0.0` deploys the web app. Every Monday, the latest release is redeployed with fresh country data. The tag must match `version` in `pubspec.yaml`.

## Built with

- Flutter, with Riverpod and go_router
- Drift (SQLite) for the on-device database, including on the web
- Firebase Authentication and Cloud Firestore for accounts and sync
- Firebase Hosting for the website
- A world map drawn by the app itself, with no map service

For the full product requirements and design, see [docs/Battuta_PRD.md](docs/Battuta_PRD.md).

## Credits

- Country data and flags: [REST Countries](https://restcountries.com)
- Map data: [Natural Earth](https://www.naturalearthdata.com) (public domain)
- Fonts: [Inter](https://rsms.me/inter/) and [IBM Plex Sans Arabic](https://github.com/IBM/plex), under the SIL Open Font License
