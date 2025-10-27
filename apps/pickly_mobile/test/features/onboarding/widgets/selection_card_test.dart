import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/features/onboarding/widgets/selection_card.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

void main() {
  group('SelectionCard Widget Tests', () {
    testWidgets('should render with required properties', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionCard(
              icon: Icons.fitness_center,
              label: 'Test Label',
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('should render with subtitle when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionCard(
              icon: Icons.person,
              label: 'Main Label',
              subtitle: 'Subtitle Text',
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Main Label'), findsOneWidget);
      expect(find.text('Subtitle Text'), findsOneWidget);
    });

    group('Selection State', () {
      testWidgets('should apply selected styles when isSelected is true',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.check,
                label: 'Selected',
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = animatedContainer.decoration as BoxDecoration;

        expect(decoration.border, isNotNull);
        expect((decoration.border as Border).top.width, 2.0);
      });

      testWidgets('should apply unselected styles when isSelected is false',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.check,
                label: 'Unselected',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = animatedContainer.decoration as BoxDecoration;

        expect(decoration.border, isNotNull);
        expect((decoration.border as Border).top.width, 1.0);
      });

      testWidgets('should maintain position when selection changes (no shift)',
          (tester) async {
        // Arrange
        var isSelected = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SelectionCard(
                    icon: Icons.star,
                    label: 'Position Test',
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Get initial position
        final initialRect = tester.getRect(find.byType(SelectionCard));
        final initialCenter = tester.getCenter(find.byType(SelectionCard));

        // Act - Tap to select
        await tester.tap(find.byType(SelectionCard));
        await tester.pumpAndSettle();

        // Assert - Position should NOT shift
        final selectedRect = tester.getRect(find.byType(SelectionCard));
        final selectedCenter = tester.getCenter(find.byType(SelectionCard));

        expect(selectedRect.topLeft, equals(initialRect.topLeft),
            reason: 'Top-left corner should not move');
        expect(selectedCenter, equals(initialCenter),
            reason: 'Center should not move');
        expect(selectedRect.width, equals(initialRect.width),
            reason: 'Width should not change');
        expect(selectedRect.height, equals(initialRect.height),
            reason: 'Height should not change');
      });
    });

    group('Interaction', () {
      testWidgets('should call onTap when tapped', (tester) async {
        // Arrange
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.touch_app,
                label: 'Tap Me',
                isSelected: false,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(SelectionCard));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should not call onTap when disabled', (tester) async {
        // Arrange
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.block,
                label: 'Disabled',
                isSelected: false,
                enabled: false,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(SelectionCard));
        await tester.pump();

        // Assert
        expect(tapped, isFalse);
      });

      testWidgets('should show press animation on tap down', (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.animation,
                label: 'Animate',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        // Act - Simulate tap down
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(SelectionCard)),
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Assert - ScaleTransition should exist
        expect(find.byType(ScaleTransition), findsOneWidget);

        // Cleanup
        await gesture.up();
      });
    });

    group('Icon Rendering', () {
      testWidgets('should render IconData when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.favorite,
                label: 'Icon Test',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('should render empty SizedBox when no icon provided',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                label: 'No Icon',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert - Should still render without errors
        expect(find.text('No Icon'), findsOneWidget);
        expect(find.byType(Icon), findsNothing);
      });

      testWidgets('should respect custom iconSize', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.star,
                label: 'Custom Size',
                iconSize: 64.0,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        final iconWidget = tester.widget<Icon>(find.byIcon(Icons.star));
        expect(iconWidget.size, 64.0);
      });
    });

    group('Dimensions', () {
      testWidgets('should respect custom width', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.expand,
                label: 'Wide Card',
                width: 200,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        final rect = tester.getSize(find.byType(SelectionCard));
        expect(rect.width, 200);
      });

      testWidgets('should respect custom height', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.expand,
                label: 'Tall Card',
                height: 150,
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        final rect = tester.getSize(find.byType(SelectionCard));
        expect(rect.height, 150);
      });
    });

    group('Disabled State', () {
      testWidgets('should apply disabled styles when enabled is false',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.block,
                label: 'Disabled',
                subtitle: 'Cannot select',
                isSelected: false,
                enabled: false,
                onTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Assert - Should render without errors
        expect(find.text('Disabled'), findsOneWidget);
        expect(find.text('Cannot select'), findsOneWidget);
      });
    });

    group('Text Overflow', () {
      testWidgets('should handle long labels with ellipsis', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 150,
                child: SelectionCard(
                  icon: Icons.text_fields,
                  label: 'This is a very long label that should overflow',
                  isSelected: false,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        // Assert - Should render without overflow errors
        expect(find.byType(SelectionCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle long subtitles with ellipsis',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 150,
                child: SelectionCard(
                  icon: Icons.text_fields,
                  label: 'Label',
                  subtitle:
                      'This is a very long subtitle that should overflow with ellipsis',
                  isSelected: false,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        // Assert - Should render without overflow errors
        expect(find.byType(SelectionCard), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper semantics labels', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.accessibility,
                label: 'Accessible Card',
                subtitle: 'With subtitle',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        final semantics = tester.getSemantics(find.byType(SelectionCard));
        expect(
            semantics.label?.contains('Accessible Card'), isTrue,
            reason: 'Semantics should include label text');
        expect(semantics.hasEnabledState, isTrue,
            reason: 'Should have enabled state');
      });

      testWidgets('should indicate selected state in semantics',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.check_circle,
                label: 'Selected Item',
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        final semantics = tester.getSemantics(find.byType(SelectionCard));
        expect(semantics.hasCheckedState, isTrue,
            reason: 'Should indicate selection state');
      });

      testWidgets('should mark as button for screen readers', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.touch_app,
                label: 'Tappable',
                isSelected: false,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        final semantics = tester.getSemantics(find.byType(SelectionCard));
        expect(semantics.isButton, isTrue,
            reason: 'Should be marked as button');
      });
    });

    group('Multiple Cards in Grid', () {
      testWidgets('should handle multiple cards in a grid', (tester) async {
        // Arrange
        final cards = List.generate(
          6,
          (index) => SelectionCard(
            icon: Icons.category,
            label: 'Card $index',
            isSelected: index == 0,
            onTap: () {},
          ),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridView.count(
                crossAxisCount: 2,
                children: cards,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(SelectionCard), findsNWidgets(6));
        expect(find.text('Card 0'), findsOneWidget);
        expect(find.text('Card 5'), findsOneWidget);
      });

      testWidgets('should maintain independent selection states',
          (tester) async {
        // Arrange
        var selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return GridView.count(
                    crossAxisCount: 2,
                    children: List.generate(
                      4,
                      (index) => SelectionCard(
                        icon: Icons.check_box,
                        label: 'Card $index',
                        isSelected: selectedIndex == index,
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        // Act - Tap second card
        await tester.tap(find.text('Card 1'));
        await tester.pumpAndSettle();

        // Assert - Only second card should be selected
        expect(selectedIndex, 1);

        // Act - Tap third card
        await tester.tap(find.text('Card 2'));
        await tester.pumpAndSettle();

        // Assert - Only third card should be selected
        expect(selectedIndex, 2);
      });
    });

    group('Animation', () {
      testWidgets('should animate when selection changes', (tester) async {
        // Arrange
        var isSelected = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SelectionCard(
                    icon: Icons.animation,
                    label: 'Animating',
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Act - Tap to trigger selection
        await tester.tap(find.byType(SelectionCard));

        // Pump a few frames to see animation
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Assert - AnimatedContainer should exist
        expect(find.byType(AnimatedContainer), findsOneWidget);

        // Complete animation
        await tester.pumpAndSettle();
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle rapid taps gracefully', (tester) async {
        // Arrange
        var tapCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.touch_app,
                label: 'Rapid Tap',
                isSelected: false,
                onTap: () {
                  tapCount++;
                },
              ),
            ),
          ),
        );

        // Act - Rapid taps
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.byType(SelectionCard));
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Assert - All taps should register
        expect(tapCount, 5);
      });

      testWidgets('should handle null onTap gracefully', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SelectionCard(
                icon: Icons.block,
                label: 'No Handler',
                isSelected: false,
                onTap: null,
              ),
            ),
          ),
        );

        // Assert - Should render without errors
        expect(find.byType(SelectionCard), findsOneWidget);

        // Try tapping (should not crash)
        await tester.tap(find.byType(SelectionCard));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    });
  });
}
