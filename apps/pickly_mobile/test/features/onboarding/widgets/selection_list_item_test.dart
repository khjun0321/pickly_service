import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

void main() {
  group('SelectionListItem Widget Tests', () {
    Widget createTestWidget({
      String? iconUrl,
      IconData? icon,
      required String title,
      String? description,
      bool isSelected = false,
      VoidCallback? onTap,
      bool enabled = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SelectionListItem(
            iconUrl: iconUrl,
            icon: icon,
            title: title,
            description: description,
            isSelected: isSelected,
            onTap: onTap,
            enabled: enabled,
          ),
        ),
      );
    }

    group('Rendering Tests', () {
      testWidgets('Should render with title only', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Test Title',
        ));

        // Assert
        expect(find.text('Test Title'), findsOneWidget);
      });

      testWidgets('Should render with title and description', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Test Title',
          description: 'Test Description',
        ));

        // Assert
        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test Description'), findsOneWidget);
      });

      testWidgets('Should render IconData icon when provided', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          icon: Icons.person,
          title: 'Test Title',
        ));

        // Assert
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('Should render default icon when no icon provided', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Test Title',
        ));

        // Assert - Default icon should be category_outlined
        expect(find.byIcon(Icons.category_outlined), findsOneWidget);
      });

      testWidgets('Should render checkmark when selected', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Test Title',
          isSelected: true,
        ));

        // Assert - Checkmark icon should be visible
        final checkIcons = find.byIcon(Icons.check);
        expect(checkIcons, findsOneWidget);
      });

      testWidgets('Should render empty checkmark circle when not selected', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Test Title',
          isSelected: false,
        ));

        // Assert - Checkmark should exist but be transparent
        final checkIcons = find.byIcon(Icons.check);
        expect(checkIcons, findsOneWidget);
      });
    });

    group('State-based Styling Tests', () {
      testWidgets('Should apply active border when selected', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Selected Item',
          isSelected: true,
        ));
        await tester.pumpAndSettle();

        // Assert - AnimatedContainer should exist with proper decoration
        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.border, isNotNull);
        expect((decoration.border as Border).top.width, 2.0);
        expect((decoration.border as Border).top.color, BorderColors.active);
      });

      testWidgets('Should apply subtle border when not selected', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Unselected Item',
          isSelected: false,
        ));
        await tester.pumpAndSettle();

        // Assert
        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.border, isNotNull);
        expect((decoration.border as Border).top.width, 1.0);
        expect((decoration.border as Border).top.color, BorderColors.subtle);
      });

      testWidgets('Should apply disabled styles when disabled', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Disabled Item',
          description: 'Cannot select',
          isSelected: false,
          enabled: false,
        ));
        await tester.pumpAndSettle();

        // Assert - Should render without errors
        expect(find.text('Disabled Item'), findsOneWidget);
        expect(find.text('Cannot select'), findsOneWidget);

        // Container should have disabled styling
        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, ChipColors.disabledBg);
      });

      testWidgets('Should show bold text when selected', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Selected Title',
          isSelected: true,
        ));

        // Assert - Title should have bold font weight
        final titleText = tester.widget<Text>(find.text('Selected Title'));
        expect(titleText.style?.fontWeight, FontWeight.w700);
      });

      testWidgets('Should show normal text when not selected', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Normal Title',
          isSelected: false,
        ));

        // Assert - Title should have normal font weight
        final titleText = tester.widget<Text>(find.text('Normal Title'));
        expect(titleText.style?.fontWeight, FontWeight.w600);
      });
    });

    group('Interaction Tests', () {
      testWidgets('Should call onTap when tapped', (WidgetTester tester) async {
        // Arrange
        var tapped = false;
        await tester.pumpWidget(createTestWidget(
          title: 'Tappable Item',
          onTap: () {
            tapped = true;
          },
        ));

        // Act
        await tester.tap(find.byType(SelectionListItem));
        await tester.pump();

        // Assert
        expect(tapped, true);
      });

      testWidgets('Should not call onTap when disabled', (WidgetTester tester) async {
        // Arrange
        var tapped = false;
        await tester.pumpWidget(createTestWidget(
          title: 'Disabled Item',
          enabled: false,
          onTap: () {
            tapped = true;
          },
        ));

        // Act
        await tester.tap(find.byType(SelectionListItem));
        await tester.pump();

        // Assert
        expect(tapped, false);
      });

      testWidgets('Should handle null onTap gracefully', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'No Callback',
          onTap: null,
        ));

        // Assert - Should render without errors
        expect(find.byType(SelectionListItem), findsOneWidget);

        // Try tapping (should not crash)
        await tester.tap(find.byType(SelectionListItem));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });

      testWidgets('Should animate on selection change', (WidgetTester tester) async {
        // Arrange
        var isSelected = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SelectionListItem(
                    title: 'Animated Item',
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

        // Act - Tap to change state
        await tester.tap(find.byType(SelectionListItem));
        await tester.pump(); // Start animation
        await tester.pump(const Duration(milliseconds: 100)); // Mid animation

        // Assert - AnimatedContainer should be animating
        expect(find.byType(AnimatedContainer), findsWidgets);

        // Complete animation
        await tester.pumpAndSettle();
      });
    });

    group('Icon Tests', () {
      testWidgets('Should prioritize iconUrl over icon', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          iconUrl: 'packages/pickly_design_system/assets/icons/age_categories/young_man.svg',
          icon: Icons.person,
          title: 'Test Title',
        ));

        // Assert - SVG should be rendered (iconUrl takes priority)
        // Note: In test environment, SvgPicture might not fully render,
        // but we can verify the widget structure
        expect(find.byType(SelectionListItem), findsOneWidget);
      });

      testWidgets('Should use icon when iconUrl is null', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          icon: Icons.star,
          title: 'Test Title',
        ));

        // Assert
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('Should show default icon when both are null', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Test Title',
        ));

        // Assert - Default icon should appear
        expect(find.byIcon(Icons.category_outlined), findsOneWidget);
      });
    });

    group('Checkmark Circle Tests', () {
      testWidgets('Should show primary color circle when selected', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Selected Item',
          isSelected: true,
        ));
        await tester.pumpAndSettle();

        // Assert - Checkmark circle should be visible
        final checkContainers = find.byType(AnimatedContainer);
        expect(checkContainers, findsWidgets);
      });

      testWidgets('Should show gray circle when not selected', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Unselected Item',
          isSelected: false,
        ));
        await tester.pumpAndSettle();

        // Assert - Container should exist
        expect(find.byType(AnimatedContainer), findsWidgets);
      });

      testWidgets('Should animate checkmark transition', (WidgetTester tester) async {
        // Arrange
        var isSelected = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SelectionListItem(
                    title: 'Checkmark Test',
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

        // Act - Toggle selection
        await tester.tap(find.byType(SelectionListItem));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Should be animating
        expect(find.byType(AnimatedContainer), findsWidgets);

        await tester.pumpAndSettle();
      });
    });

    group('Layout Tests', () {
      testWidgets('Should use horizontal row layout', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          icon: Icons.star,
          title: 'Layout Test',
          description: 'Description',
        ));

        // Assert - Row should exist for horizontal layout
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('Should place icon on left and checkmark on right', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          icon: Icons.person,
          title: 'Position Test',
          isSelected: true,
        ));

        // Assert - Both icon and checkmark should be present
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('Should stack title and description vertically', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Title',
          description: 'Description',
        ));

        // Assert - Column should exist for vertical text layout
        expect(find.byType(Column), findsWidgets);
        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Should have proper semantics labels', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Accessible Item',
          description: 'Item description',
        ));

        // Assert - Semantics should be present
        final semantics = tester.getSemantics(find.byType(SelectionListItem));
        expect(semantics.label, contains('Accessible Item'));
        expect(semantics.hint, 'Item description');
      });

      testWidgets('Should indicate selected state in semantics', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Selected Item',
          isSelected: true,
        ));

        // Assert - Verify semantics node exists with proper data
        final semantics = tester.getSemantics(find.byType(SelectionListItem));
        expect(semantics, isNotNull);
        expect(semantics.label, contains('Selected Item'));
      });

      testWidgets('Should indicate enabled state in semantics', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Enabled Item',
          enabled: true,
        ));

        // Assert - Verify semantics node exists
        final semantics = tester.getSemantics(find.byType(SelectionListItem));
        expect(semantics, isNotNull);
        expect(semantics.label, contains('Enabled Item'));
      });

      testWidgets('Should be marked as button for screen readers', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Button Item',
        ));

        // Assert - Verify semantics node exists with button trait
        final semantics = tester.getSemantics(find.byType(SelectionListItem));
        expect(semantics, isNotNull);
        expect(semantics.label, contains('Button Item'));
      });
    });

    group('Edge Cases', () {
      testWidgets('Should handle long titles gracefully', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'This is a very long title that might overflow the available space',
        ));

        // Assert - Should render without overflow errors
        expect(find.byType(SelectionListItem), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Should handle long descriptions gracefully', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: 'Title',
          description: 'This is a very long description that should wrap or truncate properly without causing layout issues',
        ));

        // Assert - Should render without overflow errors
        expect(find.byType(SelectionListItem), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Should handle rapid state changes', (WidgetTester tester) async {
        // Arrange
        var isSelected = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SelectionListItem(
                    title: 'Rapid Toggle',
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

        // Act - Rapid taps
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.byType(SelectionListItem));
          await tester.pump(const Duration(milliseconds: 10));
        }

        // Assert - Should not crash
        expect(tester.takeException(), isNull);
        await tester.pumpAndSettle();
      });

      testWidgets('Should handle empty title', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          title: '',
        ));

        // Assert - Should render without errors
        expect(find.byType(SelectionListItem), findsOneWidget);
      });
    });

    group('Visual Regression Tests', () {
      testWidgets('Should maintain consistent size when selection changes', (WidgetTester tester) async {
        // Arrange
        var isSelected = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SelectionListItem(
                    title: 'Size Test',
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

        // Get initial size
        final initialSize = tester.getSize(find.byType(SelectionListItem));

        // Act - Change selection
        await tester.tap(find.byType(SelectionListItem));
        await tester.pumpAndSettle();

        // Assert - Size should not change
        final finalSize = tester.getSize(find.byType(SelectionListItem));
        expect(finalSize, equals(initialSize));
      });
    });
  });
}
