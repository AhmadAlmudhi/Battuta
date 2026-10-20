# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

**بطوطة (Battuta)** is a local-first Flutter app for browsing every country, recording visited countries, and keeping a wishlist. English and Arabic (full RTL), light and dark themes. Works fully without an account; email/password sign-in adds Firebase backup and cross-device sync.

- **Production:** web only, at `battuta-travel.web.app` (Firebase Hosting). Android and iOS are built and tested from the same code but not published in 1.0.
- **Naming:** the app is always called **Battuta** / **بطوطة** in the UI, titles, launcher labels, and copy. `battuta-travel` is only the web address, and `battuta-b8451` is only the Firebase project ID; never show either to users.
- **Identifiers:** package `battuta`; Android/iOS app ID `com.ahmadalmudhi.battuta`; Firebase project `battuta-b8451`; Hosting site `battuta-travel`; Firestore `(default)` in `eur3`.
- **Source of truth:** [docs/Battuta_PRD.md](docs/Battuta_PRD.md). Where the code and the PRD disagree, the PRD wins until it is updated. Cite requirement IDs (`FR-EXP-03`, `NFR-05`, `AC-SYNC-01`, `D-6`) in commits, PRs, and tests.
- **Current state:** done so far:
  - Firebase, the Drift database, country parsing, search normalization, and the snapshot import.
  - The app shell: theme and fonts, English/Arabic localization, settings (theme, language, onboarding flag), all PRD routes, adaptive navigation, browser tab titles, and a working Welcome and Settings.
  - Explore is complete: flag grid, search, filters, sort, badges, offline banner, and pull to refresh / Refresh data with the API refresh rules.
  - Country details shows only its header (flag hero, names); facts and actions are next. My travels, Stats, Account, and sign-in are routed placeholders. `TravelRepository` only has `watchStatuses()` so far.
  - Not started: travel entries and forms, stats, auth, sync, the app icon, and CI.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed, json_serializable, drift; generated files are committed
dart run tool/fetch_snapshot.dart                          # refresh assets/data/countries_snapshot.json (3 API requests)
dart run tool/fetch_flags.dart                             # download missing flags into assets/flags/ (no API quota; --force to redo all)
dart format --set-exit-if-changed .
flutter analyze                                            # must report zero issues (NFR-12)
flutter test --coverage
flutter test test/path/to/file_test.dart                   # single test file

flutter run -d chrome --dart-define-from-file=env.json     # web is the primary target
flutter build web --dart-define-from-file=env.json
flutter build apk --dart-define-from-file=env.json
flutter build ios --no-codesign --dart-define-from-file=env.json

firebase deploy --only firestore:rules                     # after editing firestore.rules
firebase deploy --only hosting                             # production deploy; only when asked
flutterfire configure --project=battuta-b8451              # regenerate configs after adding a Firebase plugin/platform
```

`env.json` (git-ignored) holds the REST Countries API key; `env.example.json` documents the keys. Never commit secrets (NFR-06).

## Architecture

Feature-first, three layers per feature (PRD section 11):

```
lib/
  core/            theme, router, l10n, network client, errors, adaptive layout
  features/
    countries/     Explore + Country details   (data/ domain/ presentation/)
    travels/       My travels
    stats/
    auth/          accounts, guest merge, sync
    settings/
    onboarding/    Welcome screen
  app.dart         MaterialApp.router: theme, locale, localization delegates
  main.dart        loads SharedPreferences and Firebase, then runs the app
assets/data/countries_snapshot.json
tool/              snapshot script
test/              mirrors lib/
```

- **presentation:** screens, widgets, Riverpod providers. Never calls the API, Drift, or Firebase directly.
- **domain:** entities, repository interfaces, pure logic (merge, search normalization, filter, sort). No Flutter or I/O imports.
- **data:** `CountryRepository`, `TravelRepository`, `SyncService`, `AuthRepository`, implementing domain interfaces.

Stack: `flutter_riverpod`, `go_router`, `dio`, `freezed` + `json_serializable`, `drift` + `drift_flutter`, `firebase_auth`, `cloud_firestore`, `shared_preferences`, `flutter_animate`, `url_launcher`, `connectivity_plus`, `flutter_localizations` + `intl`, `mocktail`.

## Dependency constraints

- The Flutter SDK pins `meta` 1.17.0. That holds `drift` below 2.35 (`>=2.34.0 <2.35.0`, because newer `drift_dev` needs a newer analyzer) and `flutter_riverpod` at 2.x. Use Riverpod 2 APIs (`Provider`, `FutureProvider`, `StreamProvider`, `Notifier`), without code generation. Revisit after a Flutter upgrade.

## Country data facts

- The API returns 254 records. 4 disputed territories (Abkhazia, Northern Cyprus, Somaliland, South Ossetia) have no ISO codes and `parseCountry` skips them, leaving **250**, the Stats total (D-3).
- Missing values arrive as empty strings, not null; the parser maps them to null.
- The snapshot keeps the raw API record shape (trimmed to the Arabic translation) so one parser serves both the snapshot and the live refresh. The request fields live in `lib/features/countries/data/rest_countries.dart` (pure Dart, also imported by the tool); keep them in step with `country_parser.dart`.
- `ensureSeeded` imports the snapshot when the DB is empty or older than the bundled snapshot (so a redeploy refreshes web visitors for free). Data age is `MAX(countries.fetched_at)`.
- API refresh goes only through `CountryRefresher`: automatic when data is older than 7 days (attempted at most once per 7 days, `auto_refresh_at`), manual at most once per 60 minutes (`manual_refresh_at`). Overlapping calls share one refresh. Without `RC_API_KEY` the API client is null and refresh fails gracefully.
- Search/filter/sort run in memory in `CountrySearchIndex` (normalized once per data load). Starts-with matches rank above contains; an Arabic name also counts as starting with the text when ال is dropped. Name sort uses the app language's names.

## Core invariants

- **Local-first (D-1, NFR-05):** every screen reads from the Drift database. Every user change is written locally before any network call.
- **One entry per country (D-2):** `travel_entries.country_code` is the primary key; Firestore doc ID is `users/{uid}/entries/{countryCode}`. Status is `visited` or `wishlist`, never both.
- **Soft delete:** set `is_deleted = 1` and bump `updated_at`; screens must filter out deleted rows. Purge only after synced and older than 30 days.
- **Every change bumps `updated_at`** (epoch ms). `synced_at` null or older than `updated_at` means "needs upload".
- **Merge / conflicts (section 7.3, D-6):** last write wins per country by `updatedAt`; on a tie, cloud wins. Soft-deleted entries participate. Don't touch local data until the cloud download succeeds; save the merge in one DB transaction, upload in one Firestore batch, then add the uid to `merged_uids`.
- **Sign out (D-4)** removes the user's entries from the device; the cloud copy stays.
- **Country data (section 8.2, D-9):** import the bundled snapshot on first launch with zero API calls. Auto-refresh only if data is older than 7 days and online; manual refresh at most once per 60 minutes. Refresh is all-or-nothing (3 pages, `limit=100`, offsets 0/100/200) and replaces all rows in one transaction. A normal launch makes no API requests (NFR-13): the quota is 1,000 requests/month shared by all users.
- **REST Countries v5 only** (`https://api.restcountries.com/countries/v5`, `Authorization: Bearer <key>`); v1–v4 are retired. Field mapping is in PRD section 8.1. Parse defensively: capitals, borders, currencies, Arabic names may be missing.
- **Stats total (D-3)** is the full dataset count (~250), kept as one constant.

## UI conventions

- Material 3. Theme from seed `#0E7C86` (Lagoon Teal) with fixed secondary `#F2B24B` (Stamp Amber), `onSecondary` `#13232B`. Never use amber for text on white. See PRD section 1.4 for the exact `ColorScheme.fromSeed` code.
- Fonts bundled as assets (never fetched at runtime): Inter (Latin), IBM Plex Sans Arabic (Arabic). Stats numbers use tabular figures.
- 8 dp spacing grid, 12 dp card radius, Material Symbols Rounded, 48 dp minimum touch targets.
- Window size classes (FR-PLT-02): compact < 600 (bottom bar, 2 cols, bottom sheets), medium 600–839 (bottom bar, 3–4 cols, dialogs), expanded ≥ 840 (nav rail, up to 6 cols, dialogs). Content max width 1,200 dp.
- Every swipe/long-press action also has a visible control; web needs keyboard focus, hover states, Enter submits, Esc closes.
- Respect reduced-motion settings for decorative animation (NFR-09). Haptics on Android/iOS only. Motion specs are in PRD section 10.2.
- Every screen needs loading, empty, error, and offline states per PRD section 10.3.

## Localization and RTL

- All user-facing text comes from `lib/l10n/app_en.arb` and `app_ar.arb`. Keys are camelCase prefixed with the screen name (`exploreSearchHint`). No hard-coded strings.
- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, start/end, and directional icons. Never left/right. Flags never mirror.
- Western digits (0–9) in both languages (D-5). Dates follow the active locale.
- Arabic country name falls back to the English name.
- Search normalization (section 10.4) applies to both query and stored fields: Latin lowercased, trimmed, accents stripped; Arabic `أ إ آ ٱ → ا`, `ة → ه`, `ى → ي`, diacritics U+064B–U+0652 and tatweel U+0640 removed.
- Validation and Firebase auth error messages are listed in PRD section 8.6.

## Routing (go_router)

Routes: `/welcome`, `/explore`, `/country/:code` (3-letter ISO), `/travels` (`?tab=wishlist`), `/stats`, `/account`, `/account/sign-in`, `/account/sign-up`, `/account/reset`, `/settings`. Visit and wishlist forms are modals, not routes.

Call `usePathUrlStrategy()` before `runApp` (no `#` in URLs). Every route must survive refresh and deep linking; browser Back/Forward must work. Explore search/filter/sort state persists across navigation for the session (FR-EXP-09). Web tab title: `Japan · Battuta` / `اليابان · بطوطة`.

## Navigation conventions

- `GoRouter.optionURLReflectsImperativeAPIs` is on. Open detail screens (`/country/:code`, `/account`, `/settings`, sign-in) with `context.push` so in-app Back works; the URL still updates. Switch tabs with the shell (`goBranch`); use `context.go` only to reset the stack (Welcome → Explore, not-found → Explore).
- Screens that can be opened by URL set `leading: upButton(context, fallback: ...)` so a deep-linked page with nothing underneath still has a way up.
- Wrap each screen in `ScreenTitle` for the browser tab title.
- go_router's indexed shell keeps inactive tabs in the tree (Offstage) without disabling their heroes. Before another tab shows flags with `flagHeroTag`, wrap inactive branches in `HeroMode(enabled: false)` (custom `navigatorContainerBuilder`) or hero tags will collide.
- Until `onboarding_done` is set, `redirectFor` sends every route except `/welcome` and `/account/*` to `/welcome?from=<target>`; Welcome continues to `from`.
- Theme: `fontFamily: 'Inter'` with `fontFamilyFallback: ['IBMPlexSansArabic']`. Inter has no Arabic glyphs, so Arabic text uses Plex in both languages without switching on locale.

## Build gotchas

- After adding or removing a plugin, run `flutter clean` if the web app throws `MissingPluginException`: the web plugin registrant in `.dart_tool/flutter_build/` can go stale. Widget tests won't catch it because they mock plugins.
- Android uses Kotlin Gradle plugin 2.3.20 (Firebase Android SDK metadata is Kotlin 2.4) and the `kotlin { compilerOptions { ... } }` DSL.
- The iOS deployment target is 15.0 (required by `cloud_firestore`, and the PRD minimum). If `pod install` says the specs repo is out of date, run `cd ios && pod install --repo-update`.
- Firebase is moving iOS from CocoaPods to Swift Package Manager; new Firebase pods stop after October 2026. Plan to switch Flutter's iOS build to SwiftPM.

## Web platform gotchas

- Drift on web needs `web/sqlite3.wasm` and `web/drift_worker.js`, both downloaded from the drift GitHub release that matches the `drift` version in `pubspec.lock` (`gh release download drift-<version> -R simolus3/drift -p drift_worker.js -p sqlite3.wasm -D web --clobber`). Update them whenever drift is upgraded. Don't add COOP/COEP headers; without them drift uses IndexedDB storage, which is expected.
- `firebase.json` rewrites all paths to `/index.html`.
- Flags are bundled (`assets/flags/{alpha2}.png`, 320 px) because the flag CDN sends no CORS headers. Use `FlagImage`, which decodes at display size and falls back to the 2-letter code. Hero tag: `flagHeroTag(code)`.
- The REST Countries key only answers browsers from its allowed origins; until `localhost` is added in the REST Countries dashboard, Refresh data on `flutter run -d chrome` gets 403 (handled: "Couldn't refresh").
- Headless Chrome has no WebGL by default, and Flutter's CPU fallback doesn't paint images. For screenshots, launch Chrome with `--use-angle=swiftshader --enable-unsafe-swiftshader`.
- The API key is visible in the browser; it is restricted by allowed origins (`localhost`, `battuta-travel.web.app`, `battuta-travel.firebaseapp.com`).

## Testing and done

- Unit-test domain logic, especially every merge-rule row, search normalization, filter/sort, and parsing of records with missing fields.
- Repository tests use a mocked API and an in-memory Drift database (snapshot import, stale refresh, failed page keeps old data, 401/403/429 mapping).
- Widget tests cover screen states, form validation, Arabic mirroring, and compact vs expanded layouts.
- Definition of done (section 12.4): acceptance criteria pass on web; works on mobile at compact and expanded widths; strings in English and Arabic and RTL-checked; light and dark themes; tested; merged via PR with green CI.
