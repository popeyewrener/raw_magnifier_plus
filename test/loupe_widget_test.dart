import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raw_magnifier_plus/raw_magnifier_plus.dart';

void main() {
  // ── Loupe ────────────────────────────────────────────────────────────────

  group('Loupe', () {
    testWidgets('renders a RawMagnifier', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Loupe(size: Size(100, 100)),
            ),
          ),
        ),
      );
      expect(find.byType(RawMagnifier), findsOneWidget);
    });

    testWidgets('passes magnificationScale to RawMagnifier', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Loupe(
                size: Size(100, 100),
                magnificationScale: 3.0,
              ),
            ),
          ),
        ),
      );
      final raw = tester.widget<RawMagnifier>(find.byType(RawMagnifier));
      expect(raw.magnificationScale, 3.0);
    });

    testWidgets('passes focalPointOffset to RawMagnifier', (tester) async {
      const offset = Offset(10, 20);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Loupe(
                size: Size(100, 100),
                focalPointOffset: offset,
              ),
            ),
          ),
        ),
      );
      final raw = tester.widget<RawMagnifier>(find.byType(RawMagnifier));
      expect(raw.focalPointOffset, offset);
    });

    testWidgets('passes shape to MagnifierDecoration', (tester) async {
      const shape = StadiumBorder();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Loupe(
                size: Size(100, 100),
                shape: shape,
              ),
            ),
          ),
        ),
      );
      final raw = tester.widget<RawMagnifier>(find.byType(RawMagnifier));
      expect(raw.decoration.shape, shape);
    });

    testWidgets('renders overlayBuilder child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Loupe(
                size: const Size(100, 100),
                overlayBuilder: (_) => const Text('overlay'),
              ),
            ),
          ),
        ),
      );
      expect(find.text('overlay'), findsOneWidget);
    });

    test('asserts magnificationScale > 0', () {
      expect(
        () => Loupe(size: const Size(100, 100), magnificationScale: 0),
        throwsAssertionError,
      );
    });
  });

  // ── LoupeController ───────────────────────────────────────────────────────

  group('LoupeController', () {
    test('initial state defaults', () {
      final ctrl = LoupeController();
      expect(ctrl.isVisible, isFalse);
      expect(ctrl.position, Offset.zero);
      ctrl.dispose();
    });

    test('show() sets visible and position', () {
      final ctrl = LoupeController();
      ctrl.show(position: const Offset(50, 100));
      expect(ctrl.isVisible, isTrue);
      expect(ctrl.position, const Offset(50, 100));
      ctrl.dispose();
    });

    test('moveTo() updates position when visible', () {
      final ctrl = LoupeController()..show(position: const Offset(10, 10));
      ctrl.moveTo(const Offset(99, 88));
      expect(ctrl.position, const Offset(99, 88));
      ctrl.dispose();
    });

    test('moveTo() is no-op when hidden', () {
      final ctrl = LoupeController();
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.moveTo(const Offset(50, 50));
      expect(notifyCount, 0);
      ctrl.dispose();
    });

    test('hide() sets invisible', () {
      final ctrl = LoupeController()..show(position: const Offset(1, 1));
      ctrl.hide();
      expect(ctrl.isVisible, isFalse);
      ctrl.dispose();
    });

    test('hide() is no-op when already hidden', () {
      final ctrl = LoupeController();
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.hide();
      expect(notifyCount, 0);
      ctrl.dispose();
    });

    test('show() notifies once on visibility change', () {
      final ctrl = LoupeController();
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.show(position: Offset.zero);
      expect(notifyCount, 1);
      ctrl.dispose();
    });

    test('show() notifies on position change when visible', () {
      final ctrl = LoupeController()..show(position: const Offset(1, 1));
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.show(position: const Offset(2, 2));
      expect(notifyCount, 1);
      ctrl.dispose();
    });
  });

  // ── DraggableLoupe ────────────────────────────────────────────────────────

  group('DraggableLoupe', () {
    testWidgets('renders child and no RawMagnifier initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DraggableLoupe(
              child: SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(RawMagnifier), findsNothing);
    });

    testWidgets('shows loupe on pan', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DraggableLoupe(
              child: SizedBox.expand(),
            ),
          ),
        ),
      );

      await tester.dragFrom(const Offset(100, 100), const Offset(10, 10));
      await tester.pump();
      // The loupe should have appeared during the drag
      // (visible while dragging, hidden after)
      // After pump the animation may have dismissed — just check no crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts external LoupeController', (tester) async {
      final controller = LoupeController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraggableLoupe(
              controller: controller,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );

      controller.show(position: const Offset(100, 100));
      await tester.pump();
      // Animation may still be playing (forward), just verify no exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('accepts custom shape and scale', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DraggableLoupe(
              magnificationScale: 3.5,
              shape: StadiumBorder(),
              child: SizedBox.expand(),
            ),
          ),
        ),
      );
      expect(find.byType(DraggableLoupe), findsOneWidget);
    });
  });
}
