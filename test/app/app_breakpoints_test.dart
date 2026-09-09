import 'package:flutter_test/flutter_test.dart';
import 'package:healthylog/app/app_breakpoints.dart';

void main() {
  group('AppBreakpoint.fromWidth', () {
    test('sotto 600 è compact', () {
      expect(AppBreakpoint.fromWidth(360), AppBreakpoint.compact);
      expect(AppBreakpoint.fromWidth(599), AppBreakpoint.compact);
    });

    test('tra 600 e 899 è medium', () {
      expect(AppBreakpoint.fromWidth(600), AppBreakpoint.medium);
      expect(AppBreakpoint.fromWidth(899), AppBreakpoint.medium);
    });

    test('tra 900 e 1279 è expanded', () {
      expect(AppBreakpoint.fromWidth(900), AppBreakpoint.expanded);
      expect(AppBreakpoint.fromWidth(1279), AppBreakpoint.expanded);
    });

    test('da 1280 in su è large', () {
      expect(AppBreakpoint.fromWidth(1280), AppBreakpoint.large);
      expect(AppBreakpoint.fromWidth(1920), AppBreakpoint.large);
    });

    test('expanded e large sono "almeno esteso"', () {
      expect(AppBreakpoint.expanded.isAtLeastExpanded, isTrue);
      expect(AppBreakpoint.large.isAtLeastExpanded, isTrue);
      expect(AppBreakpoint.compact.isAtLeastExpanded, isFalse);
      expect(AppBreakpoint.medium.isAtLeastExpanded, isFalse);
    });
  });
}
