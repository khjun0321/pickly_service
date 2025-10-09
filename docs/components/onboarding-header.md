# Onboarding Header Component

## Overview

The `OnboardingHeader` is a reusable Flutter widget that displays progress through the onboarding flow. It shows a linear progress indicator representing the current step in the multi-step onboarding process.

**Location:** `apps/pickly_mobile/lib/features/onboarding/widgets/onboarding_header.dart`

**Package:** `pickly_design_system` (re-exported for app usage)

---

## Visual Design

```
┌──────────────────────────────────────────┐
│  [████████░░░░░░░░░░░░░░░]  (Step 2/5)  │  ← Progress Bar
└──────────────────────────────────────────┘
```

### Specifications

| Property | Value | Description |
|----------|-------|-------------|
| Container Padding | 16px (horizontal), 8px (vertical) | Spacing around content |
| Progress Bar Height | 4px (default) | Configurable via props |
| Progress Bar Radius | Full (pill shape) | Rounded corners |
| Progress Color | `#27B473` (Primary Green) | Active portion color |
| Background Color | Muted gray | Inactive portion color |

---

## Usage

### Basic Usage

```dart
import 'package:pickly_design_system/pickly_design_system.dart';

class AgeCategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress indicator
            OnboardingHeader(
              currentStep: 3,
              totalSteps: 5,
            ),

            // Rest of screen content
            Expanded(
              child: YourScreenContent(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### With Custom Height

```dart
OnboardingHeader(
  currentStep: 2,
  totalSteps: 5,
  progressBarHeight: 6.0,  // Thicker progress bar
)
```

### Without Progress Bar

```dart
OnboardingHeader(
  currentStep: 1,
  totalSteps: 5,
  showProgressBar: false,  // Only shows container spacing
)
```

---

## Props

### Required Props

| Prop | Type | Description | Constraints |
|------|------|-------------|-------------|
| `currentStep` | `int` | Current step number (1-based) | Must be > 0 and ≤ totalSteps |
| `totalSteps` | `int` | Total number of steps | Must be > 0 |

### Optional Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `showProgressBar` | `bool` | `true` | Whether to display progress bar |
| `progressBarHeight` | `double` | `4.0` | Height of progress bar in pixels |

---

## Component API

### Constructor

```dart
const OnboardingHeader({
  super.key,
  required this.currentStep,
  required this.totalSteps,
  this.showProgressBar = true,
  this.progressBarHeight = 4.0,
})
```

### Assertions

The component validates props with assertions:

```dart
assert(currentStep > 0, 'currentStep must be greater than 0')
assert(totalSteps > 0, 'totalSteps must be greater than 0')
assert(currentStep <= totalSteps, 'currentStep cannot exceed totalSteps')
```

**Invalid Examples:**
```dart
// ❌ Will throw assertion error
OnboardingHeader(currentStep: 0, totalSteps: 5)  // currentStep must be > 0
OnboardingHeader(currentStep: 6, totalSteps: 5)  // currentStep exceeds totalSteps
OnboardingHeader(currentStep: 1, totalSteps: -1) // totalSteps must be > 0
```

### Getters

#### `_progress`

Calculates the progress value as a double between 0.0 and 1.0.

```dart
double get _progress => currentStep / totalSteps;
```

**Examples:**
- Step 1 of 5: `1/5 = 0.2` (20%)
- Step 3 of 5: `3/5 = 0.6` (60%)
- Step 5 of 5: `5/5 = 1.0` (100%)

---

## Layout Structure

```dart
Semantics(
  label: 'Onboarding progress: Step $currentStep of $totalSteps',
  value: '${(_progress * 100).toInt()} percent complete',
  child: Container(
    padding: EdgeInsets.symmetric(
      horizontal: Spacing.lg,  // 16px
      vertical: Spacing.md,    // 8px
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showProgressBar) _buildProgressBar(),
      ],
    ),
  ),
)
```

### Progress Bar Implementation

```dart
Widget _buildProgressBar() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(PicklyBorderRadius.full),
    child: SizedBox(
      height: progressBarHeight,
      child: LinearProgressIndicator(
        value: _progress,
        backgroundColor: BackgroundColors.muted,
        valueColor: AlwaysStoppedAnimation<Color>(
          BrandColors.primary,
        ),
        semanticsLabel: 'Progress indicator',
        semanticsValue: '${(_progress * 100).toInt()}%',
      ),
    ),
  );
}
```

---

## Styling

### Design System Integration

The component uses tokens from `pickly_design_system`:

| Token | Value | Usage |
|-------|-------|-------|
| `Spacing.lg` | 16px | Horizontal padding |
| `Spacing.md` | 8px | Vertical padding |
| `PicklyBorderRadius.full` | 9999px | Pill-shaped corners |
| `BrandColors.primary` | `#27B473` | Progress bar color |
| `BackgroundColors.muted` | Gray shade | Progress bar background |

### Theming

The component respects Material Theme colors:

```dart
// The LinearProgressIndicator uses theme colors
Theme(
  data: ThemeData(
    colorScheme: ColorScheme.light(
      primary: BrandColors.primary,  // Progress color
    ),
  ),
  child: OnboardingHeader(/* ... */),
)
```

---

## Accessibility

### Semantic Labels

The component provides comprehensive screen reader support:

```dart
Semantics(
  label: 'Onboarding progress: Step 3 of 5',  // Main description
  value: '60 percent complete',                // Current progress
  child: /* ... */,
)
```

**Screen Reader Output:**
> "Onboarding progress: Step 3 of 5, 60 percent complete"

### Progress Bar Semantics

```dart
LinearProgressIndicator(
  semanticsLabel: 'Progress indicator',
  semanticsValue: '60%',
  // ...
)
```

---

## Responsive Design

### Padding Adaptation

The component uses consistent spacing from the design system, which can adapt to screen size:

```dart
// Small screens
padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6)

// Medium/Large screens
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)
```

### Progress Bar Scaling

For accessibility, consider increasing bar height on larger screens:

```dart
final isLargeScreen = MediaQuery.of(context).size.width > 600;

OnboardingHeader(
  currentStep: 2,
  totalSteps: 5,
  progressBarHeight: isLargeScreen ? 6.0 : 4.0,
)
```

---

## Integration Examples

### In Onboarding Flow

```dart
// Screen 001: Splash/Welcome
OnboardingHeader(currentStep: 1, totalSteps: 5)  // 20%

// Screen 003: Age Category
OnboardingHeader(currentStep: 2, totalSteps: 5)  // 40%

// Screen 004: Income Level
OnboardingHeader(currentStep: 3, totalSteps: 5)  // 60%

// Screen 005: Interests
OnboardingHeader(currentStep: 4, totalSteps: 5)  // 80%

// Screen 006: Complete
OnboardingHeader(currentStep: 5, totalSteps: 5)  // 100%
```

### With Navigation Logic

```dart
class OnboardingFlow extends StatefulWidget {
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int currentStep = 1;
  final int totalSteps = 5;

  void nextStep() {
    if (currentStep < totalSteps) {
      setState(() => currentStep++);
    }
  }

  void previousStep() {
    if (currentStep > 1) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OnboardingHeader(
              currentStep: currentStep,
              totalSteps: totalSteps,
            ),
            Expanded(
              child: _buildCurrentScreen(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }
}
```

---

## Testing

### Widget Test Example

```dart
testWidgets('OnboardingHeader displays progress correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: OnboardingHeader(
          currentStep: 3,
          totalSteps: 5,
        ),
      ),
    ),
  );

  // Find progress bar
  final progressBar = find.byType(LinearProgressIndicator);
  expect(progressBar, findsOneWidget);

  // Verify progress value
  final widget = tester.widget<LinearProgressIndicator>(progressBar);
  expect(widget.value, 0.6);  // 3/5 = 60%
});

testWidgets('OnboardingHeader respects showProgressBar prop', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: OnboardingHeader(
        currentStep: 1,
        totalSteps: 5,
        showProgressBar: false,
      ),
    ),
  );

  // Progress bar should not be found
  expect(find.byType(LinearProgressIndicator), findsNothing);
});
```

### Assertion Tests

```dart
testWidgets('OnboardingHeader throws on invalid currentStep', (tester) async {
  expect(
    () => OnboardingHeader(currentStep: 0, totalSteps: 5),
    throwsAssertionError,
  );

  expect(
    () => OnboardingHeader(currentStep: 6, totalSteps: 5),
    throwsAssertionError,
  );
});
```

---

## Common Use Cases

### 1. Linear Onboarding Flow

```dart
// Standard usage in sequential screens
OnboardingHeader(currentStep: currentStepIndex, totalSteps: 5)
```

### 2. Multi-Section Form

```dart
// Show progress through form sections
OnboardingHeader(currentStep: completedSections, totalSteps: totalSections)
```

### 3. Tutorial Steps

```dart
// Guide users through app tutorial
OnboardingHeader(currentStep: tutorialStep, totalSteps: tutorialSteps)
```

### 4. Dynamic Total Steps

```dart
// Adjust total based on user type
final totalSteps = isBusinessUser ? 7 : 5;
OnboardingHeader(currentStep: step, totalSteps: totalSteps)
```

---

## Animation

### Add Transition Animation

```dart
class AnimatedOnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, -0.5),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: OnboardingHeader(
        key: ValueKey(currentStep),
        currentStep: currentStep,
        totalSteps: totalSteps,
      ),
    );
  }
}
```

---

## Customization

### Custom Colors

```dart
// Wrap in Theme to override colors
Theme(
  data: Theme.of(context).copyWith(
    colorScheme: ColorScheme.light(
      primary: Colors.blue,  // Custom progress color
    ),
  ),
  child: OnboardingHeader(currentStep: 2, totalSteps: 5),
)
```

### Custom Progress Bar

For more advanced customization, extend the component:

```dart
class CustomOnboardingHeader extends OnboardingHeader {
  const CustomOnboardingHeader({
    super.key,
    required super.currentStep,
    required super.totalSteps,
  });

  @override
  Widget _buildProgressBar() {
    // Custom implementation with gradient, etc.
    return Container(/* ... */);
  }
}
```

---

## Best Practices

1. **Always use 1-based indexing** for `currentStep` (matches user expectations)
2. **Keep totalSteps consistent** throughout the flow
3. **Update currentStep** when user navigates between screens
4. **Test edge cases** (first step, last step, mid-flow navigation)
5. **Provide semantic labels** for accessibility
6. **Use consistent spacing** with design system tokens

---

## Common Issues & Solutions

### Issue: Progress Not Updating

**Problem:** Step changes but progress bar doesn't update

**Solution:** Ensure parent widget rebuilds when step changes

```dart
// ✅ CORRECT: Use setState
void nextStep() {
  setState(() => currentStep++);
}

// ❌ WRONG: Direct mutation without setState
void nextStep() {
  currentStep++;  // Widget won't rebuild
}
```

### Issue: Assertion Error on Navigation

**Problem:** `currentStep` exceeds `totalSteps` during navigation

**Solution:** Add boundary checks

```dart
void nextStep() {
  if (currentStep < totalSteps) {
    setState(() => currentStep++);
  }
}
```

---

## Future Enhancements

1. **Step Labels**
   - Display step names below progress bar
   - Example: "Profile • Preferences • Complete"

2. **Back Navigation Indicator**
   - Show which steps can be navigated back to
   - Darken completed steps

3. **Animation**
   - Smooth progress transitions
   - Pulsing effect on active step

4. **Responsive Sizing**
   - Adaptive height based on screen size
   - Tablet/desktop layout variations

5. **Step Validation**
   - Visual indicator for completed/incomplete steps
   - Error state for invalid steps

---

## Related Documentation

- [Age Category Screen](../flows/onboarding-flow.md)
- [Age Selection Card](./age-selection-card.md)
- [Design System Tokens](../../packages/pickly_design_system/README.md)
