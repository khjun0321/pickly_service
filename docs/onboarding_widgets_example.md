# Onboarding Widgets - Usage Guide

Complete guide for using the reusable onboarding widgets in the Pickly mobile app.

## Overview

The onboarding widgets provide a consistent, accessible, and Material Design 3 compliant experience across all onboarding screens.

### Available Widgets

1. **OnboardingHeader** - Progress indicator showing step X of Y
2. **SelectionCard** - Icon-based card for multiple selection
3. **NextButton** - Bottom CTA button with enable/disable states

---

## OnboardingHeader

### Description
A header component that displays progress through the onboarding flow with a step counter and visual progress bar.

### Features
- Step counter display (e.g., "1 / 5")
- Linear progress indicator
- Percentage display
- Accessibility support
- Responsive design

### Basic Usage

```dart
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';

OnboardingHeader(
  currentStep: 2,
  totalSteps: 5,
)
```

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `currentStep` | `int` | Yes | - | Current step number (1-based) |
| `totalSteps` | `int` | Yes | - | Total number of steps |
| `showProgressBar` | `bool` | No | `true` | Whether to show progress bar |
| `progressBarHeight` | `double` | No | `4.0` | Height of progress bar |

### Examples

**Full screen with header:**
```dart
class OnboardingGoalsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            OnboardingHeader(
              currentStep: 1,
              totalSteps: 5,
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: YourContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Without progress bar:**
```dart
OnboardingHeader(
  currentStep: 3,
  totalSteps: 5,
  showProgressBar: false,
)
```

**Custom progress bar height:**
```dart
OnboardingHeader(
  currentStep: 4,
  totalSteps: 5,
  progressBarHeight: 6.0,
)
```

---

## SelectionCard

### Description
A card component for icon-based selection in onboarding flows. Supports both single and multiple selection modes.

### Features
- Icon and label display
- Optional subtitle
- Active/inactive visual states
- Touch feedback animations
- Multiple/single selection support
- Accessibility support
- Disabled state

### Basic Usage

```dart
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';

SelectionCard(
  icon: Icons.fitness_center,
  label: 'Fitness',
  isSelected: true,
  onTap: () => handleSelection('fitness'),
)
```

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `icon` | `IconData` | Yes | - | Icon to display |
| `label` | `String` | Yes | - | Main label text |
| `subtitle` | `String?` | No | `null` | Optional subtitle |
| `isSelected` | `bool` | No | `false` | Selection state |
| `onTap` | `VoidCallback?` | No | `null` | Tap callback |
| `width` | `double?` | No | `null` | Fixed width |
| `height` | `double?` | No | `null` | Fixed height |
| `iconSize` | `double` | No | `32.0` | Icon size |
| `enabled` | `bool` | No | `true` | Enabled state |

### Examples

**Multiple selection in a grid:**
```dart
class GoalSelectionScreen extends StatefulWidget {
  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final Set<String> _selectedGoals = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OnboardingHeader(currentStep: 1, totalSteps: 5),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: Spacing.lg,
                  crossAxisSpacing: Spacing.lg,
                  childAspectRatio: 1.0,
                  children: [
                    SelectionCard(
                      icon: Icons.fitness_center,
                      label: 'Fitness',
                      subtitle: 'Stay active',
                      isSelected: _selectedGoals.contains('fitness'),
                      onTap: () => _toggleSelection('fitness'),
                    ),
                    SelectionCard(
                      icon: Icons.restaurant,
                      label: 'Nutrition',
                      subtitle: 'Eat healthy',
                      isSelected: _selectedGoals.contains('nutrition'),
                      onTap: () => _toggleSelection('nutrition'),
                    ),
                    SelectionCard(
                      icon: Icons.spa,
                      label: 'Wellness',
                      subtitle: 'Mental health',
                      isSelected: _selectedGoals.contains('wellness'),
                      onTap: () => _toggleSelection('wellness'),
                    ),
                    SelectionCard(
                      icon: Icons.self_improvement,
                      label: 'Meditation',
                      subtitle: 'Inner peace',
                      isSelected: _selectedGoals.contains('meditation'),
                      onTap: () => _toggleSelection('meditation'),
                    ),
                  ],
                ),
              ),
            ),

            NextButton(
              label: 'Next',
              enabled: _selectedGoals.isNotEmpty,
              onPressed: _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelection(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _handleNext() {
    // Navigate to next screen
  }
}
```

**Single selection:**
```dart
class GenderSelectionScreen extends StatefulWidget {
  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SelectionCard(
            icon: Icons.male,
            label: 'Male',
            isSelected: _selectedGender == 'male',
            onTap: () => setState(() => _selectedGender = 'male'),
          ),
        ),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: SelectionCard(
            icon: Icons.female,
            label: 'Female',
            isSelected: _selectedGender == 'female',
            onTap: () => setState(() => _selectedGender = 'female'),
          ),
        ),
      ],
    );
  }
}
```

**Disabled state:**
```dart
SelectionCard(
  icon: Icons.lock,
  label: 'Premium Feature',
  subtitle: 'Coming soon',
  enabled: false,
  isSelected: false,
  onTap: null,
)
```

**Custom sizing:**
```dart
SelectionCard(
  icon: Icons.favorite,
  label: 'Health',
  width: 120.0,
  height: 120.0,
  iconSize: 40.0,
  isSelected: true,
  onTap: () {},
)
```

---

## NextButton

### Description
A bottom CTA button for navigating through onboarding screens with proper state management.

### Features
- Primary button styling
- Enabled/disabled states
- Loading state with spinner
- Full-width or compact sizing
- Optional icon support
- Safe area support
- Accessibility support
- Custom colors

### Basic Usage

```dart
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';

NextButton(
  label: 'Next',
  enabled: hasSelection,
  onPressed: () => navigateToNextScreen(),
)
```

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `label` | `String` | Yes | - | Button text |
| `onPressed` | `VoidCallback` | Yes | - | Tap callback |
| `enabled` | `bool` | No | `true` | Enabled state |
| `isLoading` | `bool` | No | `false` | Loading state |
| `fullWidth` | `bool` | No | `true` | Full width |
| `icon` | `IconData?` | No | `null` | Optional icon |
| `backgroundColor` | `Color?` | No | `null` | Custom bg color |
| `textColor` | `Color?` | No | `null` | Custom text color |

### Examples

**Complete onboarding screen:**
```dart
class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Set<String> _selectedItems = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            OnboardingHeader(
              currentStep: 2,
              totalSteps: 5,
            ),

            // Content
            Expanded(
              child: _buildContent(),
            ),

            // Bottom button
            NextButton(
              label: 'Continue',
              enabled: _selectedItems.isNotEmpty,
              isLoading: _isLoading,
              onPressed: _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Your content here
    return Container();
  }

  Future<void> _handleNext() async {
    setState(() => _isLoading = true);

    try {
      // Save data and navigate
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.pushNamed(context, '/next-screen');
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
```

**With icon:**
```dart
NextButton(
  label: 'Continue',
  enabled: true,
  icon: Icons.arrow_forward,
  onPressed: () => print('Next'),
)
```

**Custom colors:**
```dart
NextButton(
  label: 'Finish',
  enabled: true,
  backgroundColor: Colors.blue,
  textColor: Colors.white,
  onPressed: () => print('Finish'),
)
```

**Compact variant:**
```dart
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';

CompactNextButton(
  label: 'Skip',
  enabled: true,
  onPressed: () => skipOnboarding(),
)
```

**Two-button layout:**
```dart
Row(
  children: [
    Expanded(
      child: CompactNextButton(
        label: 'Back',
        enabled: true,
        onPressed: () => Navigator.pop(context),
      ),
    ),
    const SizedBox(width: Spacing.lg),
    Expanded(
      flex: 2,
      child: CompactNextButton(
        label: 'Next',
        enabled: canProceed,
        icon: Icons.arrow_forward,
        onPressed: () => handleNext(),
      ),
    ),
  ],
)
```

---

## Complete Integration Example

Here's a complete example showing all three widgets working together:

```dart
import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';
import 'package:pickly_mobile/features/onboarding/widgets/widgets.dart';

class CompleteOnboardingExample extends StatefulWidget {
  const CompleteOnboardingExample({super.key});

  @override
  State<CompleteOnboardingExample> createState() =>
      _CompleteOnboardingExampleState();
}

class _CompleteOnboardingExampleState extends State<CompleteOnboardingExample> {
  final Set<String> _selectedGoals = {};
  bool _isLoading = false;

  // Available goals
  final List<Map<String, dynamic>> _goals = [
    {'id': 'fitness', 'icon': Icons.fitness_center, 'label': 'Fitness', 'subtitle': 'Stay active'},
    {'id': 'nutrition', 'icon': Icons.restaurant, 'label': 'Nutrition', 'subtitle': 'Eat healthy'},
    {'id': 'wellness', 'icon': Icons.spa, 'label': 'Wellness', 'subtitle': 'Mental health'},
    {'id': 'meditation', 'icon': Icons.self_improvement, 'label': 'Meditation', 'subtitle': 'Inner peace'},
    {'id': 'sleep', 'icon': Icons.bedtime, 'label': 'Sleep', 'subtitle': 'Rest well'},
    {'id': 'hydration', 'icon': Icons.water_drop, 'label': 'Hydration', 'subtitle': 'Drink water'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.app,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Progress Header
            OnboardingHeader(
              currentStep: 2,
              totalSteps: 5,
            ),

            // 2. Content with Selection Cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'What are your goals?',
                      style: PicklyTypography.titleLarge.copyWith(
                        color: TextColors.primary,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Subtitle
                    Text(
                      'Select all that apply',
                      style: PicklyTypography.bodyMedium.copyWith(
                        color: TextColors.secondary,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxl),

                    // Grid of selection cards
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: Spacing.lg,
                        crossAxisSpacing: Spacing.lg,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        return SelectionCard(
                          icon: goal['icon'],
                          label: goal['label'],
                          subtitle: goal['subtitle'],
                          isSelected: _selectedGoals.contains(goal['id']),
                          onTap: () => _toggleGoal(goal['id']),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Next Button
            NextButton(
              label: 'Continue',
              enabled: _selectedGoals.isNotEmpty,
              isLoading: _isLoading,
              icon: Icons.arrow_forward,
              onPressed: _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleGoal(String goalId) {
    setState(() {
      if (_selectedGoals.contains(goalId)) {
        _selectedGoals.remove(goalId);
      } else {
        _selectedGoals.add(goalId);
      }
    });
  }

  Future<void> _handleNext() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Save goals (implement your logic)
      print('Selected goals: $_selectedGoals');

      // Navigate to next screen
      if (mounted) {
        Navigator.pushNamed(context, '/next-onboarding-step');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: StateColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
```

---

## Best Practices

### 1. Always Use SafeArea
```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        OnboardingHeader(...),
        // content
      ],
    ),
  ),
)
```

### 2. Validate User Input
```dart
NextButton(
  enabled: _selectedItems.isNotEmpty && _isValid(),
  onPressed: _handleNext,
)
```

### 3. Handle Loading States
```dart
Future<void> _handleNext() async {
  setState(() => _isLoading = true);
  try {
    await saveData();
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

### 4. Proper Error Handling
```dart
try {
  await operation();
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

### 5. Accessibility
- All widgets include semantic labels
- Touch targets are >= 44x44 logical pixels
- Color contrast meets WCAG AA standards

---

## Design System Integration

All widgets use the Pickly Design System tokens:

- **Colors**: `BrandColors`, `TextColors`, `ButtonColors`, etc.
- **Typography**: `PicklyTypography` styles
- **Spacing**: `Spacing` constants
- **Border Radius**: `PicklyBorderRadius` constants
- **Animations**: `PicklyAnimations` durations

Example:
```dart
import 'package:pickly_design_system/pickly_design_system.dart';

// Use design tokens
Container(
  padding: const EdgeInsets.all(Spacing.lg),
  decoration: BoxDecoration(
    color: BrandColors.primary,
    borderRadius: PicklyBorderRadius.radiusLg,
  ),
  child: Text(
    'Hello',
    style: PicklyTypography.titleMedium,
  ),
)
```

---

## Responsive Design

All widgets are responsive and adapt to different screen sizes:

```dart
// Grid adapts to screen width
GridView.count(
  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
  children: [...],
)
```

---

## Testing

Example widget tests:

```dart
testWidgets('NextButton disables when enabled is false', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: NextButton(
          label: 'Next',
          enabled: false,
          onPressed: () {},
        ),
      ),
    ),
  );

  final button = find.byType(ElevatedButton);
  expect(button, findsOneWidget);

  final elevatedButton = tester.widget<ElevatedButton>(button);
  expect(elevatedButton.onPressed, isNull);
});
```

---

## Troubleshooting

### Issue: Button not responding
**Solution**: Check that `enabled` is `true` and `onPressed` is not `null`.

### Issue: Cards not showing selection state
**Solution**: Ensure `isSelected` is properly managed in your state.

### Issue: Progress bar not updating
**Solution**: Verify `currentStep` changes trigger a rebuild.

---

## References

- [Material Design 3](https://m3.material.io/)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Pickly Design System](/packages/pickly_design_system)
