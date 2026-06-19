import 'package:baytalmal/core/responsive/app_breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('windowSizeClassFor', () {
    test('returns compact below 600', () {
      expect(windowSizeClassFor(0), WindowSizeClass.compact);
      expect(windowSizeClassFor(599), WindowSizeClass.compact);
    });

    test('returns medium between 600 and 839', () {
      expect(windowSizeClassFor(600), WindowSizeClass.medium);
      expect(windowSizeClassFor(839), WindowSizeClass.medium);
    });

    test('returns expanded between 840 and 1199', () {
      expect(windowSizeClassFor(840), WindowSizeClass.expanded);
      expect(windowSizeClassFor(1199), WindowSizeClass.expanded);
    });

    test('returns large between 1200 and 1599', () {
      expect(windowSizeClassFor(1200), WindowSizeClass.large);
      expect(windowSizeClassFor(1599), WindowSizeClass.large);
    });

    test('returns extraLarge at 1600 and above', () {
      expect(windowSizeClassFor(1600), WindowSizeClass.extraLarge);
      expect(windowSizeClassFor(2000), WindowSizeClass.extraLarge);
    });
  });

  group('gridColumnCountFor', () {
    test('maps size classes to column counts', () {
      expect(gridColumnCountFor(WindowSizeClass.compact), 1);
      expect(gridColumnCountFor(WindowSizeClass.medium), 2);
      expect(gridColumnCountFor(WindowSizeClass.expanded), 3);
      expect(gridColumnCountFor(WindowSizeClass.large), 4);
      expect(gridColumnCountFor(WindowSizeClass.extraLarge), 4);
    });
  });
}
