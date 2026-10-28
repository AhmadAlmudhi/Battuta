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
  - The app shell: theme and fonts, English/Arabic localization, settings (theme, language, onboarding flag), all PRD routes, adaptive navigation, browser tab titles, Settings, and Welcome (the logo among round flags, what the app does, a no-account note, and a language switch, FR-ONB-05).
  - Explore is complete: flag grid, search, filters, sort, badges, offline banner, and pull to refresh / Refresh data with the API refresh rules.
  - Country details is complete: a header tinted with the flag's color behind a transparent app bar, with the flag hero, passport stamp, region tag, and Open in Maps; fact tiles and a fact list; round neighbor flags; the save buttons or status card with the visit and wishlist forms (`lib/features/travels/presentation/travel_forms.dart`), remove with Undo; and two columns on expanded screens.
  - `TravelRepository` saves, removes (soft delete), and restores entries.
  - My travels is complete: a Visited and Wishlist toggle with counts and their own URLs, a summary line per tab, sorting with year or priority groups, search, region chips with counts, swipe and menu Edit/Delete with Undo, and empty states.
  - Stats is complete: headline (visited over the dataset total, with share and wishlist tags), a bar per region (most visited first, with share), highlight tiles (most recent trip, first trip, regions visited, wishlist), count-up animation, and the zero state.
  - Accounts and cloud sync are complete: sign in, create account, reset password, Account screen with sync status, Sync now, and Sign out; guest merge on first sign-in, live two-way sync, and server-enforced last write wins.
  - Settings has its About section (FR-SET-04); app icons and the favicon are generated; the home-screen name is Battuta or بطوطة on Android and iOS.
  - The world map is built (PRD section 6.10, data in 8.7, rendering in 11.5): the base map at the top of Stats, dots for small countries, the tap card with hover on web, zoom and pan, region focus, the reveal, and the Could items: the spread from the tap with the stamp on the tap card, Replay my travels, and Share my map. About credits Natural Earth.
  - CI and production deploys are set up with GitHub Actions (see CI and deploys). Releases are version tags, starting with `v1.0.0`.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed, json_serializable, drift; generated files are committed
dart run tool/fetch_snapshot.dart                          # refresh assets/data/countries_snapshot.json (3 API requests)
dart run tool/fetch_flags.dart                             # download missing flags into assets/flags/ (no API quota; --force to redo all)
dart run tool/fetch_tourism.dart                           # rewrite lib/features/countries/data/tourism_arrivals.dart from the World Bank (1 request, no key, no API quota)
dart run tool/build_world_map.dart <ne_10m_admin_0_countries_sau.geojson>  # rebuild assets/data/world_map.json (needs Node.js for mapshaper; no API requests)
dart format --set-exit-if-changed .
flutter analyze                                            # must report zero issues (NFR-12)
flutter test --coverage
flutter test test/path/to/file_test.dart                   # single test file

flutter run -d chrome --dart-define-from-file=env.json     # web is the primary target
flutter build web --dart-define-from-file=env.json
flutter build apk --dart-define-from-file=env.json
flutter build ios --no-codesign --dart-define-from-file=env.json

firebase deploy --only firestore:rules                     # after editing firestore.rules
git tag v1.0.0 <main commit> && git push origin v1.0.0     # release: deploy.yml deploys it to production; only when asked
firebase deploy --only hosting                             # manual production deploy, bypassing CI; only when asked
flutterfire configure --project=battuta-b8451              # regenerate configs after adding a Firebase plugin/platform

dart run flutter_launcher_icons                            # regenerate app icons; then revert its project.pbxproj change (see flutter_launcher_icons.yaml)

# Firebase emulators (need Java: Homebrew openjdk@21, not on the system PATH)
PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH" firebase emulators:start --only auth,firestore --project battuta-b8451
flutter run -d chrome --dart-define-from-file=env.json --dart-define=USE_FIREBASE_EMULATORS=true
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
    world_map/     World map card on Stats (domain/ presentation/)
    auth/          accounts, guest merge, sync
    settings/
    onboarding/    Welcome screen
  app.dart         MaterialApp.router: theme, locale, localization delegates
  main.dart        loads SharedPreferences and Firebase, then runs the app
assets/data/countries_snapshot.json, world_map.json
tool/              snapshot, flag, and map scripts
test/              mirrors lib/
```

- **presentation:** screens, widgets, Riverpod providers. Never calls the API, Drift, or Firebase directly.
- **domain:** entities, repository interfaces, pure logic (merge, search normalization, filter, sort). No Flutter or I/O imports.
- **data:** `CountryRepository`, `TravelRepository`, `SyncService`, `AuthRepository`, implementing domain interfaces.

Stack: `flutter_riverpod`, `go_router`, `dio`, `freezed` + `json_serializable`, `drift` + `drift_flutter`, `firebase_auth`, `cloud_firestore`, `shared_preferences`, `flutter_animate`, `url_launcher`, `connectivity_plus`, `share_plus` (with `web` for the download on web), `flutter_localizations` + `intl`, `mocktail`.

## Dependency constraints

- Flutter 3.47.7 (Dart 3.13.5). Code generation: drift 2.35.2 with drift_dev 2.35.1, freezed 4, json_serializable 6.15, on analyzer 14.
- drift must stay at **2.35.1 or newer**: older versions never flush transactions to IndexedDB on web, so saved entries are lost when the browser closes (drift #3864).
- The app still uses Riverpod 2.x (`flutter_riverpod` 2.6.1) and go_router 17. Riverpod 3 and go_router 18 now resolve, but each is a separate migration. Until then, use Riverpod 2 APIs (`Provider`, `FutureProvider`, `StreamProvider`, `Notifier`), without code generation.

## Country data facts

- The API returns 254 records. 4 disputed territories (Abkhazia, Northern Cyprus, Somaliland, South Ossetia) have no ISO codes and `parseCountry` skips them. It also skips Israel (`excludedCountryCodes`, D-12), drops it from neighbors' borders, and drops the Israeli new shekel (`excludedCurrencyCodes`), leaving **249**, the Stats total (D-3). The snapshot and flags scripts leave them out too; for data saved earlier, `ensureSeeded` deletes Israel's row and the repository filters currencies and borders when reading. The map draws Israel's area as Palestine.
- Missing values arrive as empty strings, not null; the parser maps them to null.
- The snapshot keeps the raw API record shape (trimmed to the Arabic translation) so one parser serves both the snapshot and the live refresh. The request fields live in `lib/features/countries/data/rest_countries.dart` (pure Dart, also imported by the tool); keep them in step with `country_parser.dart`.
- `ensureSeeded` imports the snapshot when the DB is empty or older than the bundled snapshot (so a redeploy refreshes web visitors for free). Data age is `MAX(countries.fetched_at)`.
- API refresh goes only through `CountryRefresher`: automatic when data is older than 7 days (attempted at most once per 7 days, `auto_refresh_at`), manual at most once per 60 minutes (`manual_refresh_at`). Overlapping calls share one refresh. Without `RC_API_KEY` the API client is null and refresh fails gracefully.
- Manual refresh shows "can take up to a minute" through `refreshManually(onStart:)`, which runs only when a download starts (or one is already running), never for the instant "up to date" answer.
- Explore's default sort is Most visited (FR-EXP-08, PRD 8.8): `CountrySearchIndex` takes `arrivals`, the generated `tourismArrivals` map (World Bank `ST.INT.ARVL`, each country's latest figure from 2012, skipping 2020 and 2021; 198 countries). Countries without a figure follow by name. The figures live in Dart, not an asset, so widget tests need no loader override; About credits them (CC BY 4.0).
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
- **Stats total (D-3)** is the number of countries in the dataset (249 today), computed in one place: `TravelStats.total`. Entries for countries that leave the dataset aren't counted anywhere.

## UI conventions

- Material 3. Theme from seed `#0E7C86` (Lagoon Teal) with fixed secondary `#F2B24B` (Stamp Amber), `onSecondary` `#13232B`. Never use amber for text on white. See PRD section 1.4 for the exact `ColorScheme.fromSeed` code.
- Font: Alexandria for Latin and Arabic, bundled as four static weights in `assets/fonts/alexandria/` (cut from the Google Fonts variable font with fontTools' instancer; never fetched at runtime). Stats numbers use tabular figures, which Alexandria supports; check `tnum` before switching fonts.
- Every app bar shows the logo, centered by `appBarTheme`: use `AppTitle(screen: ...)`, which draws `BattutaLogo` and gives screen readers the screen's name too (FR-PLT-09). Tests find a screen with `appBarOf(name)` from `pump_app.dart`.
- Country details extends its body behind the app bar, whose background resolves to transparent at rest and `surfaceContainer` once scrolled under (`WidgetState.scrolledUnder`); the header pads itself by `MediaQuery.paddingOf(context).top`. On expanded screens it has two `ListView`s, and the left one sets `primary: false` so they don't share the primary scroll controller on iOS and Android. Short figures use `context.formatCompact` (35.3M, 35.3 مليون); time zones sort with `byUtcOffset`. Its `VisitStamp` sets `landOnArrival`: an already-visited country's stamp lands after the flag's hero flight and fades out on the way back. A route is built offstage on its first entrance frame with its animation proxied to complete, so check `route.offstage` as well as the animation.
- The visit and wishlist forms (`travel_forms.dart`) share `_FormFrame`: round flag, title, "Everything here is optional.", a ✕ (tooltip Close; there's no Cancel), and a full-width plain `FilledButton` Save. Date: one centered Pick a date chip that opens the calendar and then shows the date; rating words come from `visitFormRatingWord` (a `select` on the rating, since gen-l10n only allows =0 to =2 as exact plural cases). Clear actions sit in the section title and keep their space while hidden.
- Explore cards are circles: the flag with `BoxFit.cover`, the name and region on a black gradient (clear, then 55% where the text starts, 70% at the bottom) in a caption of fixed height so text lines up across a row, and a status badge on the top end edge. Country details uses `FramedFlag` (own shape, rounded corners, hairline edge, shadow); Explore cards and My travels rows (round 48 dp flags) fly a `FlagFlight` both ways through `flightShuttleBuilder`, which morphs the circle into the framed shape using the flight's progress (0 at the circle, 1 on Country details, in both directions). Neighbor flags on Country details share those hero tags, so each sits in `HeroMode(enabled: false)` except from its own tap until it has flown back (`_NeighborState._flies`, cleared when the page's `secondaryAnimation` is dismissed); otherwise every visible neighbor flies whenever the page opens or closes.
- My travels groups rows (`TravelListGroups`: by year in Visited, by priority in Wishlist) only in the default sort; name order has one ungrouped panel. Region chips count the whole tab, not the filtered list.
- Text the user wrote (notes) goes through `NoteText`, which picks the text's own direction (`Bidi.detectRtlDirectionality`) and aligns it to the screen's start edge, so English notes on Arabic screens keep their punctuation in place.
- The logo (`lib/core/widgets/battuta_logo.dart`, PRD 1.4) is drawn, not an image: `BattutaMark` (a `CustomPainter` measured from the app icon; under 40 dp it drops the inner ring and dots) beside `BattutaName` (Alexandria Bold, primary). The app bar, Welcome (mark among the flags, name under it), the licenses page, and the Share my map canvas (`BattutaMarkPainter` and `BattutaName.style`) use it. Welcome's flags are decorative, so they load `assets/flags/{alpha2}.png` directly instead of through `FlagImage`, which needs the country data that Welcome is still importing.
- `AnimatedSize` asserts when its child resizes with a zero duration, so with reduced motion skip it instead of passing `Duration.zero` (see `_Resizing` in `world_map_card.dart`).
- 8 dp spacing grid, 12 dp card radius, Material Symbols Rounded, 48 dp minimum touch targets.
- Grouped content on Country details, My travels, and Stats (the map card too) uses `Panel` (`lib/core/widgets/panel.dart`): a `Material` with `surfaceContainerLow`, a hairline edge, and 16 dp corners, so ink from rows inside shows and is clipped. Tiles lead with `IconBadge`.
- Window size classes (FR-PLT-02): compact < 600 (floating tab bar, 2 cols, bottom sheets), medium 600–839 (floating tab bar, 3–4 cols, dialogs), expanded ≥ 840 (nav rail on a tinted panel, up to 6 cols, dialogs). Content max width 1,200 dp.
- The floating tab bar (`FloatingNavBar` in `app_shell.dart`) sits in a Scaffold with `extendBody: true`, so pages scroll behind it and `MediaQuery.paddingOf(context).bottom` includes it. Scroll views on tab screens add that to their bottom padding, and `MessageView` centers above it. Anything that pops up from a tab must clear it: `showAdaptiveModal` opens phone sheets with `useRootNavigator: true`, and every `MenuAnchor` sets `useRootOverlay: true`. Snack bars float (`snackBarTheme`) and appear above it.
- List rows use `Dismissible`: swipe toward the end edits, toward the start deletes (both mirror in RTL), and the ⋮ menu offers the same actions. A dismissed row must leave the tree at once, before the database stream catches up, so `TravelsScreen` hides it locally (`_swiped`) until the stream confirms the deletion. Deletes go through `removeWithUndo` (4-second Undo, `persist: false`).
- Every swipe/long-press action also has a visible control; web needs keyboard focus, hover states, Enter submits, Esc closes.
- Respect reduced-motion settings for decorative animation (NFR-09). Haptics on Android/iOS only. Motion specs are in PRD section 10.2.
- Every screen needs loading, empty, error, and offline states per PRD section 10.3.

## Localization and RTL

- All user-facing text comes from `lib/l10n/app_en.arb` and `app_ar.arb`. Keys are camelCase prefixed with the screen name (`exploreSearchHint`). No hard-coded strings.
- Use `EdgeInsetsDirectional`, `AlignmentDirectional`, start/end, and directional icons. Never left/right. Flags never mirror.
- Western digits (0–9) in both languages (D-5). Dates follow the active locale. Flutter's Arabic date data defaults to Arabic-Indic digits, so `BattutaApp` calls `useWesternDigits()` before the localizations build; always format dates through `context.formatDate` / `formatDateTime`.
- Arabic country name falls back to the English name.
- Search normalization (section 10.4) applies to both query and stored fields: Latin lowercased, trimmed, accents stripped; Arabic `أ إ آ ٱ → ا`, `ة → ه`, `ى → ي`, diacritics U+064B–U+0652 and tatweel U+0640 removed.
- Validation and Firebase auth error messages are listed in PRD section 8.6.

## Routing (go_router)

Routes: `/welcome`, `/explore`, `/country/:code` (3-letter ISO), `/travels` (`?tab=wishlist`), `/stats`, `/account`, `/account/sign-in`, `/account/sign-up`, `/account/reset`, `/settings`. Visit and wishlist forms are modals, not routes.

Call `usePathUrlStrategy()` before `runApp` (no `#` in URLs). Every route must survive refresh and deep linking; browser Back/Forward must work. Explore search/filter/sort state persists across navigation for the session (FR-EXP-09). Web tab title: `Japan · Battuta` / `اليابان · بطوطة`.

## World map

- `assets/data/world_map.json` is committed. `tool/build_world_map.dart` builds it from Natural Earth's 1:10m Saudi point-of-view edition (D-11); download the source GeoJSON from github.com/nvkelso/natural-earth-vector (geojson folder) and don't commit it. `MapFrame.project` (pure Dart, Equal Earth) is shared by the script and the app.
- Antarctica and Western Sahara have no shape or dot (D-11); the script reads the dataset through `parseCountry`, so Israel (D-12) isn't in it. Overseas parts (French departments, Caribbean Netherlands, Svalbard and Jan Mayen, Bouvet, Tokelau, Christmas and Cocos Islands) are split out by location in `_splitOverseas`. `world_map_asset_test.dart` fails if a dataset country goes missing.
- A country gets a dot when its largest part fits within 6 × 6 map units, or when its shape vanishes in simplification (then it's placed from the full-detail source).
- Hit testing (`MapHitTester`, FR-MAP-11): a tap on a dot (within 4 dp of its center) selects it; otherwise over land the country under the tap, and over water the nearest country or dot within 24 dp of its edge, so a tap just off a coast selects that country. Only dataset countries can be selected.
- The map never mirrors; positions on it are physical in both languages. The card around it mirrors as usual.
- The view is a `MapView` (pure Dart: zoom and center in map units, so it survives resizes). The card draws through it and handles its own gestures: `_MapGestureRecognizer` claims drags only when zoomed, so the page scrolls at 1×; the plain wheel is left to the page, Ctrl/⌘ + wheel zooms. Flights (600 ms), the reveal (once per session, `_revealPlayedProvider`), changes from the tap card, and the replay run on `AnimationController`s; reduced motion jumps to the end and hides Replay.
- Every animation reaches `WorldMapPainter` as one `MapMotion` (fills and their origins, hatching, `fading` old statuses, the flight path), built in `_currentMotion`: replay first, then the reveal, then changes. `_noticeChanges` compares each new statuses map with the last one; a change from one status to another paints the old one underneath.
- Share my map: `renderMapShareImage` paints the image on a `PictureRecorder` canvas (no widget tree), and `mapImageSharerProvider` hands it to `share_plus` or, on web, downloads it (conditional import on `dart.library.js_interop`). Tests override the provider; `toImage` needs `tester.runAsync`.
- Tapping the selected country again closes its card; so does a tap anywhere else on Stats, which wraps the page in a `GestureDetector` that calls `WorldMapCard.tapOutside` (buttons and the map win their own taps, a scroll isn't a tap, and taps on the country card are ignored). Double taps are told apart by pointer timestamps, so tests of repeated taps need a gesture with explicit `timeStamp`s. Every close goes through `_closeCard`, which also hides the hover highlight while the pointer stays on the closed country (`_hoverHidden`), so it doesn't look selected; a tap outside also unfocuses the map. A focused region's summary sits under the map.
- `mapRegionProvider` holds the focused region; Stats' region bars set it and scroll the map card into view through a `GlobalKey`, which also keeps the map's state when the first visit replaces the zero state.
- In widget tests, an animation started by a tap gets its first tick on the next frame: `pump()` once before `pump(duration)`. To see the reveal's start, pump without moving the clock until the map appears (see `world_map_motion_test.dart`).
- `pumpApp` overrides `worldMapLoaderProvider` with `testWorldMap` (the real file, read from disk): `compute` and the asset bundle can't finish under the widget-test clock. It takes extra `overrides`. Map colors are tested by painting to an image and reading pixels, not with golden files.

## Accounts and sync

- `lib/features/auth/`: `AuthRepository` (Firebase Auth), `CloudEntries` (Firestore at `users/{uid}/entries/{code}`), `LocalSyncStore` (sync-level access to `travel_entries`), `SyncEngine` (merge and live sync), and `SyncController` (follows the signed-in account; kept alive by `BattutaApp`).
- One conflict rule everywhere, `SyncRules.cloudWins`: the newer `updatedAt` wins, the cloud wins ties. The first sign-in on a device runs `merge` (download from the server, apply in one transaction, upload local winners in one batch); afterwards live sync applies server-confirmed cloud changes and uploads pending rows (`synced_at` null or older than `updated_at`) whenever online.
- The live listener ignores documents with pending writes: only server-confirmed copies count as synced.
- `firestore.rules` refuses updates that move `updatedAt` backwards; the engine handles that rejection by downloading and re-applying, then uploading what is still newer.
- Sign-out: `SyncController.signOut` signs out, then `forgetUser` clears the device. `stop()` waits for in-flight sync work, so nothing writes after the device is cleared; `claimDevice` removes another account's entries before a merge (`local_data_owner`).
- Tests use `FakeAuthRepository` and `FakeCloudEntries` (`test/helpers/fakes.dart`). The fake cloud enforces the same last-write-wins rule as the security rules.

## Navigation conventions

- `GoRouter.optionURLReflectsImperativeAPIs` is on. Open detail screens (`/country/:code`, `/account`, `/settings`, sign-in) with `context.push` so in-app Back works; the URL still updates. Switch tabs with the shell (`goBranch`); use `context.go` only to reset the stack (Welcome → Explore, not-found → Explore).
- Screens that can be opened by URL set `leading: upButton(context, fallback: ...)` so a deep-linked page with nothing underneath still has a way up.
- Wrap each screen in `ScreenTitle` for the browser tab title.
- The tab shell uses `BranchStack` (in `app_shell.dart`) as its `navigatorContainerBuilder`: inactive tabs stay alive but have heroes and tickers off. Without it, Explore's hidden flag cards would join flights from My travels and collide on `flagHeroTag`.
- My travels tabs are URLs (`/travels`, `/travels?tab=wishlist`); `TravelsScreen` syncs its `TabController` with the `tab` parameter in both directions.
- Until `onboarding_done` is set, `redirectFor` sends every route except `/welcome` and `/account/*` to `/welcome?from=<target>`; Welcome continues to `from`.
- Theme: `fontFamily: 'Alexandria'`, one family for both scripts, so Latin text on Arabic screens matches the Arabic around it.

## Build gotchas

- After adding or removing a plugin, run `flutter clean` if the web app throws `MissingPluginException`: the web plugin registrant in `.dart_tool/flutter_build/` can go stale. Widget tests won't catch it because they mock plugins.
- Android uses Kotlin Gradle plugin 2.3.20 (Firebase Android SDK metadata is Kotlin 2.4) and the `kotlin { compilerOptions { ... } }` DSL.
- The iOS home-screen name comes from `ios/Runner/{en,ar}.lproj/InfoPlist.strings` (a localized resource in the Runner target; Arabic is in the project's known regions and `CFBundleLocalizations`). Edit the Xcode project with the `xcodeproj` Ruby library that ships with CocoaPods (`GEM_HOME=/opt/homebrew/Cellar/cocoapods/<version>/libexec /opt/homebrew/opt/ruby/bin/ruby -rxcodeproj`), not by hand.
- The iOS deployment target is 15.0 (required by `cloud_firestore`, and the PRD minimum). If `pod install` says the specs repo is out of date, run `cd ios && pod install --repo-update`.
- iOS builds with CocoaPods: `pubspec.yaml` sets `flutter: config: enable-swift-package-manager: false`, because Firebase's Swift Package Manager release (13.x) needs Xcode 26.2 or later and this Mac has Xcode 26.1. Firebase stopped publishing new CocoaPods releases after 12.19.0 (October 2026), so after updating Xcode, remove that setting to move iOS to Swift Package Manager.
- Gradle 8.14 and Android Gradle Plugin 8.11 work but Flutter warns their support will be dropped; moving to AGP 9 is a pending, separate change.

## Web platform gotchas

- Drift on web needs `web/drift_worker.js` and `web/sqlite3.wasm`. Regenerate both whenever drift or sqlite3 changes in `pubspec.lock`:
  - `dart compile js -O4 --no-source-maps -o web/drift_worker.js tool/drift_worker.dart` (compiled from the locked drift and sqlite3 versions, so the worker always matches the app; delete the `web/drift_worker.js.deps` it leaves behind).
  - `gh release download sqlite3-<version> -R simolus3/sqlite3.dart -p sqlite3.wasm -D web --clobber`, with the `sqlite3` version from `pubspec.lock`.
- Don't add COOP/COEP headers; without them drift uses IndexedDB storage, which is expected.
- `firebase.json` rewrites all paths to `/index.html`.
- Flags are bundled (`assets/flags/{alpha2}.png`, 320 px) because the flag CDN sends no CORS headers. Use `FlagImage`, which decodes once at the bundled size (one shared image per flag, so hero flights draw at once; decoding at display size would re-decode every frame of a flight) and falls back to the 2-letter code. Hero tag: `flagHeroTag(code)`.
- The REST Countries key only answers browsers from its allowed origins. `localhost` is allowed, so Refresh data works on `flutter run -d chrome` (and really spends 3 requests); other hosts, such as preview channels, get 403 (handled: "Couldn't refresh").
- Emulator testing on web: use a debug build (`flutter run`). FlutterFire re-applies the Auth emulator after a reload only in debug builds; a release build restores the session against production, gets a 400, and signs out. The emulator setting is also per tab, so reload the same tab rather than opening a new one.
- Chrome DevTools offline emulation (`Network.emulateNetworkConditions`) ends when the DevTools session disconnects, so do offline checks within one connected session.
- To check web persistence, restart the browser, not just the page: drift's shared worker keeps the database in memory across reloads in one session, which hides unsaved writes. Launch headless Chrome with a fixed `--user-data-dir`, save, close it, start it again with the same directory, and check the data.
- Headless Chrome has no WebGL by default, and Flutter's CPU fallback doesn't paint images. For screenshots, launch Chrome with `--use-angle=swiftshader --enable-unsafe-swiftshader`.
- The API key is visible in the browser; it is restricted by allowed origins (`localhost`, `battuta-travel.web.app`, `battuta-travel.firebaseapp.com`).

## CI and deploys

- `.github/workflows/ci.yml` runs on pushes to main and on pull requests (PRD section 12.3). It checks that build_runner and `flutter gen-l10n` reproduce the committed files, then runs format, analyze, and tests with coverage. It also builds web (pull requests from this repo get a 7-day preview channel), an Android APK, and iOS without signing on `macos-26` (CocoaPods, like this Mac).
- `.github/workflows/deploy.yml` deploys production only from a `v*` tag that matches `version` in `pubspec.yaml`, and every Monday redeploys the latest tag. Each run tests the tagged code, fetches a fresh snapshot (3 API requests), builds, and deploys to the `live` channel. `fetch_snapshot.dart` exits without writing when pages are missing or fewer than 240 records parse, so a broken API response stops the deploy.
- Secrets: `RC_API_KEY`, and `FIREBASE_SERVICE_ACCOUNT_BATTUTA_B8451`, a service account key created by `firebase init hosting:github`. It lives only in GitHub's secret store, never in the repo.
- `FLUTTER_VERSION` in both workflows must match the Flutter version above. Third-party actions are pinned to commit SHAs because they see the deploy key, and `firebase-tools` is pinned in the deploy steps.
- Pushing files under `.github/workflows/` needs a GitHub token with the `workflow` scope (`gh auth refresh -h github.com -s workflow`).
- Preview channels aren't among the REST Countries key's allowed origins, so Refresh data on a preview says "Couldn't refresh". That's expected.
- GitHub turns off scheduled workflows after 60 days without repository activity; turn the weekly deploy back on in the Actions tab.

## Testing and done

- In `testWidgets`, never await a drift stream (`watch...().first`) in the test body: it waits on a fake-clock timer and hangs until the 10-minute timeout. Read the provider the screen already watches (`container.read(travelEntryProvider(code)).valueOrNull`) or await a one-shot query. Run tests with `flutter test --timeout=90s` so a hang fails fast.
- Mock platform channels (for example haptics) per test and remove the handler in `addTearDown`; handlers otherwise leak into later tests.

- Unit-test domain logic, especially every merge-rule row, search normalization, filter/sort, and parsing of records with missing fields.
- Repository tests use a mocked API and an in-memory Drift database (snapshot import, stale refresh, failed page keeps old data, 401/403/429 mapping).
- Widget tests cover screen states, form validation, Arabic mirroring, and compact vs expanded layouts.
- Definition of done (section 12.4): acceptance criteria pass on web; works on mobile at compact and expanded widths; strings in English and Arabic and RTL-checked; light and dark themes; tested; merged via PR with green CI.
