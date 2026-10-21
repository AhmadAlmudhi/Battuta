import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:battuta/core/theme/app_theme.dart';
import 'package:battuta/features/travels/domain/travel_entry.dart';
import 'package:battuta/features/travels/domain/travel_repository.dart';
import 'package:battuta/features/travels/presentation/travel_providers.dart';
import 'package:battuta/features/world_map/domain/map_projection.dart';
import 'package:battuta/features/world_map/presentation/map_image_sharer.dart';
import 'package:battuta/features/world_map/presentation/map_share_image.dart';
import 'package:battuta/features/world_map/presentation/widgets/map_country_card.dart';
import 'package:battuta/features/world_map/presentation/widgets/world_map_card.dart';
import 'package:battuta/features/world_map/presentation/world_map_colors.dart';
import 'package:battuta/features/world_map/presentation/world_map_geometry.dart';
import 'package:battuta/features/world_map/presentation/world_map_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import '../../../helpers/test_world_map.dart';

// Inland points in degrees.
const spain = (-4.0, 40.0);
const germany = (10.4, 51.0);

void main() {
  Future<TestApp> openStats(
    WidgetTester tester,
    Future<void> Function(TravelRepository repo) seed, {
    Map<String, Object> prefs = const {},
    List<Override> overrides = const [],
  }) async {
    final app = await pumpApp(
      tester,
      prefs: {...returningUser, ...prefs},
      overrides: overrides,
    );
    await seed(app.container.read(travelRepositoryProvider));
    await app.goTo(tester, '/stats');
    return app;
  }

  Future<void> threeTrips(TravelRepository repo) async {
    await repo.saveVisit('FRA', visitedOn: DateTime(2019, 7, 2));
    await repo.saveVisit('ESP', visitedOn: DateTime(2021, 5, 10));
    await repo.saveVisit('JPN', visitedOn: DateTime(2024, 3, 14));
    await repo.saveWishlist('SAU');
  }

  WorldMapPainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byKey(WorldMapCard.mapKey),
                  matching: find.byWidgetPredicate(
                    (widget) =>
                        widget is CustomPaint &&
                        widget.painter is WorldMapPainter,
                  ),
                ),
              )
              .painter!
          as WorldMapPainter;

  Offset onMap(WidgetTester tester, (double, double) place) {
    final rect = tester.getRect(find.byKey(WorldMapCard.mapKey));
    final (x, y) = MapFrame.project(place.$1, place.$2);
    return rect.topLeft + Offset(x, y) * (rect.width / MapFrame.width);
  }

  Finder inCard(String text) => find.descendant(
    of: find.byType(MapCountryCard),
    matching: find.text(text),
  );

  Finder inMapCard(String text) =>
      find.descendant(of: find.byType(WorldMapCard), matching: find.text(text));

  /// Pumps frames, without moving the clock, until [done].
  Future<void> pumpUntil(WidgetTester tester, bool Function() done) async {
    for (var frame = 0; frame < 30 && !done(); frame++) {
      await tester.pump();
    }
    expect(done(), isTrue);
  }

  group('changes from the tap card', () {
    testWidgets('marking a country visited spreads amber from the tap '
        'point, then the stamp lands (FR-MAP-32, AC-MAP-21)', (tester) async {
      await openStats(tester, (repo) async {
        await repo.saveVisit('FRA', visitedOn: DateTime(2019, 7, 2));
      });
      await tester.tapAt(onMap(tester, spain));
      await tester.pumpAndSettle();

      await tester.tap(inCard('Mark as visited'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await pumpUntil(
        tester,
        () => painter(tester).motion?.fills.containsKey('ESP') ?? false,
      );
      await tester.pump(); // The animation's first frame.

      final motion = painter(tester).motion!;
      final (x, y) = MapFrame.project(spain.$1, spain.$2);
      expect(motion.fills['ESP'], lessThan(0.2));
      expect((motion.origins['ESP']! - Offset(x, y)).distance, lessThan(1));
      await tester.pump(const Duration(milliseconds: 250));
      expect(painter(tester).motion?.fills['ESP'], inExclusiveRange(0, 1));
      expect(inCard('VISITED'), findsNothing);

      await tester.pump(const Duration(milliseconds: 300));
      expect(painter(tester).motion, isNull);
      await tester.pump(const Duration(milliseconds: 600));
      expect(inCard('VISITED'), findsOneWidget);
    });

    testWidgets('a wishlist country being visited keeps its hatching under '
        'the spread (FR-MAP-32)', (tester) async {
      await openStats(tester, (repo) async {
        await repo.saveWishlist('ESP');
      });
      await tester.tapAt(onMap(tester, spain));
      await tester.pumpAndSettle();

      await tester.tap(inCard('Mark as visited'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await pumpUntil(
        tester,
        () => painter(tester).motion?.fills.containsKey('ESP') ?? false,
      );
      await tester.pump(); // The animation's first frame.
      await tester.pump(const Duration(milliseconds: 250));

      final motion = painter(tester).motion!;
      expect(motion.fills['ESP'], inExclusiveRange(0, 1));
      expect(motion.fading['ESP'], (TravelStatus.wishlist, 1.0));
      await tester.pump(const Duration(milliseconds: 300));
      expect(painter(tester).motion, isNull);
    });

    testWidgets('adding a country to the wishlist fades its hatching in '
        '(FR-MAP-33)', (tester) async {
      await openStats(tester, (repo) async {
        await repo.saveVisit('FRA', visitedOn: DateTime(2019, 7, 2));
      });
      await tester.tapAt(onMap(tester, germany));
      await tester.pumpAndSettle();

      await tester.tap(inCard('Add to wishlist'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await pumpUntil(
        tester,
        () => painter(tester).motion?.hatchings.containsKey('DEU') ?? false,
      );
      await tester.pump(); // The animation's first frame.

      expect(painter(tester).motion!.hatchings['DEU'], lessThan(0.2));
      await tester.pump(const Duration(milliseconds: 150));
      expect(painter(tester).motion?.hatchings['DEU'], inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(painter(tester).motion, isNull);
    });

    testWidgets('a removed country\'s color fades out (FR-MAP-34)', (
      tester,
    ) async {
      final app = await openStats(tester, (repo) async {
        await repo.saveVisit('FRA', visitedOn: DateTime(2019, 7, 2));
      });

      await app.container.read(travelRepositoryProvider).remove('FRA');
      await pumpUntil(
        tester,
        () => painter(tester).motion?.fading.containsKey('FRA') ?? false,
      );
      await tester.pump(); // The animation's first frame.

      final (status, left) = painter(tester).motion!.fading['FRA']!;
      expect(status, TravelStatus.visited);
      expect(left, greaterThan(0.8));
      await tester.pump(const Duration(milliseconds: 600));
      expect(painter(tester).motion, isNull);
    });
  });

  group('replay', () {
    testWidgets('plays dated visits in order, with flight paths and the '
        'year, and ends on the normal map (AC-MAP-22, FR-MAP-35 to 37)', (
      tester,
    ) async {
      await openStats(tester, threeTrips);

      await tester.tap(find.text('Replay my travels'));
      await tester.pump(); // The replay's first frame.
      await tester.pump(const Duration(milliseconds: 100));
      var motion = painter(tester).motion!;
      expect(motion.fills['FRA'], inExclusiveRange(0, 1));
      expect(motion.fills['ESP'], 0);
      expect(motion.fills['JPN'], 0);
      expect(motion.hatching, 0);
      expect(motion.flight, isNull);
      expect(inMapCard('2019'), findsOneWidget);
      // The year and Skip take the place of the actions, off the map.
      expect(inMapCard('Share my map'), findsNothing);

      await tester.pump(const Duration(milliseconds: 800));
      motion = painter(tester).motion!;
      expect(motion.fills['FRA'], 1);
      expect(motion.flight, isNotNull);
      expect(inMapCard('2021'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      expect(inMapCard('2024'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(painter(tester).motion, isNull);
      expect(find.text('Skip'), findsNothing);
      expect(inMapCard('2024'), findsNothing);
      expect(inMapCard('Replay my travels'), findsOneWidget);
      expect(inMapCard('Share my map'), findsOneWidget);
    });

    testWidgets('Skip ends the replay at once (FR-MAP-39)', (tester) async {
      await openStats(tester, threeTrips);
      await tester.tap(find.text('Replay my travels'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Skip'));
      await tester.pump();

      expect(painter(tester).motion, isNull);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('needs 2 dated visits, and isn\'t offered with reduced '
        'motion (FR-MAP-40)', (tester) async {
      await openStats(tester, (repo) async {
        await repo.saveVisit('FRA', visitedOn: DateTime(2019, 7, 2));
        await repo.saveVisit('ESP');
      });
      expect(find.text('Replay my travels'), findsNothing);
    });

    testWidgets('isn\'t offered with reduced motion', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await openStats(tester, threeTrips);
      expect(find.text('Replay my travels'), findsNothing);
    });
  });

  group('share my map', () {
    testWidgets('hands a 1,080 × 1,350 PNG to the platform (FR-MAP-41, '
        'FR-MAP-42, AC-MAP-23)', (tester) async {
      final shared = <(Uint8List, String)>[];
      await openStats(
        tester,
        threeTrips,
        overrides: [
          mapImageSharerProvider.overrideWithValue(
            (png, {required fileName, origin}) async =>
                shared.add((png, fileName)),
          ),
        ],
      );

      await tester.tap(find.text('Share my map'));
      // A second click while the image is drawing doesn't share it twice.
      await tester.tap(find.text('Share my map'));
      // Drawing the image needs real time; then wait a little longer in
      // case a second image follows.
      for (var i = 0, after = 0; i < 20 && after < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump();
        if (shared.isNotEmpty) after++;
      }

      final (png, fileName) = shared.single;
      expect(fileName, 'battuta-map.png');
      final header = ByteData.sublistView(png);
      expect(png.sublist(1, 4), 'PNG'.codeUnits);
      expect(header.getUint32(16), 1080);
      expect(header.getUint32(20), 1350);
    });

    testWidgets('isn\'t offered before the first visit', (tester) async {
      await openStats(tester, (repo) async => repo.saveWishlist('SAU'));
      expect(find.text('Share my map'), findsNothing);
    });

    testWidgets('its words are the headline\'s, in the app language '
        '(FR-MAP-41, FR-MAP-43)', (tester) async {
      for (final (locale, appName, detail) in [
        ('en', 'Battuta', 'of 249 · 6.4% · 12 on your wishlist'),
        ('ar', 'بطوطة', 'من 249 · 6.4% · 12 في قائمة أمنياتك'),
      ]) {
        await openStats(tester, threeTrips, prefs: {'locale': locale});
        final texts = MapShareTexts.of(
          tester.element(find.byType(WorldMapCard)),
          visited: 16,
          total: 249,
          wishlist: 12,
        );
        expect(texts.appName, appName);
        expect(texts.count, '16');
        expect(texts.detail, detail);
      }
    });
  });

  test('the image uses the current theme (FR-MAP-43)', () async {
    final geometry = WorldMapGeometry(testWorldMap);
    for (final (theme, colors) in [
      (AppTheme.light(), WorldMapColors.light),
      (AppTheme.dark(), WorldMapColors.dark),
    ]) {
      final png = await renderMapShareImage(
        geometry: geometry,
        statuses: const {'BRA': TravelStatus.visited},
        theme: theme,
        direction: TextDirection.ltr,
        texts: const MapShareTexts(
          appName: 'Battuta',
          label: 'Countries visited',
          count: '1',
          detail: 'of 249 · 0.4% · 0 on your wishlist',
          visited: 'Visited',
          wishlist: 'Wishlist',
        ),
      );
      final codec = await ui.instantiateImageCodec(png);
      final image = (await codec.getNextFrame()).image;
      final pixels = (await image.toByteData())!;
      Color at(int x, int y) {
        final i = (y * image.width + x) * 4;
        return Color.fromARGB(
          pixels.getUint8(i + 3),
          pixels.getUint8(i),
          pixels.getUint8(i + 1),
          pixels.getUint8(i + 2),
        );
      }

      expect((image.width, image.height), (1080, 1350));
      expect(at(10, 10), theme.colorScheme.surface);
      // Where the map lands depends on the fonts, so look everywhere: the
      // theme's ocean, and Brazil in amber.
      final colorsFound = {
        for (var y = 0; y < image.height; y += 3)
          for (var x = 0; x < image.width; x += 3) at(x, y),
      };
      expect(colorsFound, containsAll([colors.ocean, colors.visitedFill]));
    }
  });
}
