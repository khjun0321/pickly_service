# Figma Design Alignment - Age Category Screen (003)

## 📋 Overview
This document summarizes the changes made to align the Age Category screen implementation with the Figma design specifications.

**Figma URL**: https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly?node-id=481-10088
**Design File**: `/Users/kwonhyunjun/Downloads/003.01_onboarding.png`

## ✅ Changes Made

### 1. Title Text (age_category_screen.dart)
**Before**: "현재 연령 및 세대 기준을\n선택해주세요"
**After**: "맞춤 혜택을 위해 내 상황을 알려주세요."

**Figma Spec**:
- Position: top 116px
- Font: 18px, w700
- Color: #3E3E3E (TextColors.primary)
- Line height: 1.33

### 2. Layout Restructure (age_category_screen.dart)
**Changed**:
- Moved subtitle ("나에게 맞는 정책과 혜택에 대해 안내해드려요") from top to bottom section
- Added progress bar below subtitle
- Updated bottom section layout to match Figma

**Figma Spec**:
- Guidance text: top 656px, 15px w600, #828282, center aligned
- Progress bar: top 704px, height 4px, 50% progress
- Button: top 732px, height 56px

### 3. Progress Bar (NEW)
**Added**: LinearProgressIndicator component

**Figma Spec**:
- Height: 4px
- Background: #DDDDDD
- Progress color: #27B473 (BrandColors.primary)
- Value: 0.5 (50% = step 3 of 5)
- Border radius: 2px

### 4. Button Border Radius (age_category_screen.dart)
**Before**: 12px
**After**: 16px

**Figma Spec**:
- Border radius: 16px
- Height: 56px
- Width: 343px (full width with 16px margins)
- Padding: 12px vertical, 80px horizontal
- Font: 16px, w700, white

### 5. Border Width (selection_list_item.dart)
**Before**: 2px for selected, 1px for unselected
**After**: 1px for all states

**Figma Spec**:
- All states: 1px border
- Selected: #27B473 (BorderColors.active)
- Unselected: #EBEBEB (BorderColors.subtle)

### 6. Typography (selection_list_item.dart)
**Title**:
- Before: FontWeight varied by selection
- After: Always FontWeight.w700
- Size: 14px
- Color: #3E3E3E (TextColors.primary)

**Description**:
- Font weight: w600
- Size: 12px
- Color: #828282 (TextColors.secondary)
- Gap: 4px from title

### 7. Icon Color Filter (selection_list_item.dart)
**Changed**: Removed colorFilter from SVG icons

**Reason**: Figma uses emoji icons with original colors (not tinted)
- Icons display in their original colors
- Size remains 32x32px as per Figma

### 8. Checkmark Circle (selection_list_item.dart)
**Verified** (already correct):
- Size: 24x24px ✅
- Selected: #27B473 background, white check ✅
- Unselected: #DDDDDD background, transparent check ✅

## 📐 Complete Figma Specifications

### Screen Layout
- Background: #F4F4F4 (BackgroundColors.app)
- Total height: 812px
- Total width: 375px

### Header
- Height: 48px
- Includes back button and progress indicator
- Step: 3/5

### Title Section
- Position: top 116px (68px below header)
- Horizontal padding: 16px (Spacing.lg)

### List Section
- Start position: top 156px
- Item height: 64px
- Item gap: 12px (Spacing.md)
- Horizontal padding: 16px

### List Item (SelectionListItem)
- Width: 343px (375 - 32px padding)
- Height: 64px
- Padding: 16px (Spacing.lg)
- Border radius: 16px
- Icon: 32x32px (left aligned)
- Checkmark: 24x24px (right aligned)

### Bottom Section
- Guidance text: top 656px
- Progress bar: top 704px
- Button: top 732px
- Bottom padding: 16px

## 🎨 Design Tokens Used

### Colors
- Background: `BackgroundColors.app` (#F4F4F4)
- Surface: `SurfaceColors.base` (#FFFFFF)
- Primary text: `TextColors.primary` (#3E3E3E)
- Secondary text: `TextColors.secondary` (#828282)
- Brand primary: `BrandColors.primary` (#27B473)
- Border active: `BorderColors.active` (#27B473)
- Border subtle: `BorderColors.subtle` (#EBEBEB)

### Spacing
- `Spacing.xs`: 4px
- `Spacing.md`: 12px
- `Spacing.lg`: 16px
- `Spacing.xl`: 24px

### Typography
- Title: 18px, w700, line-height 1.33
- Subtitle: 15px, w600
- Item title: 14px, w700
- Item description: 12px, w600
- Button text: 16px, w700

### Border Radius
- `PicklyBorderRadius.radiusLg`: 16px
- Button: 16px
- Progress bar: 2px

## 📁 Files Modified

1. **age_category_screen.dart**
   - Title text updated
   - Layout restructured
   - Progress bar added
   - Button border radius updated
   - Typography adjusted

2. **selection_list_item.dart**
   - Border width standardized to 1px
   - Typography weights and sizes updated
   - Icon color filter removed
   - Figma spec comments added

## ✨ Key Improvements

1. **Pixel-Perfect Alignment**: All dimensions now match Figma exactly
2. **Proper Typography**: Font sizes and weights match design system
3. **Correct Layout Flow**: Bottom section properly structured
4. **Progress Indicator**: Visual feedback for onboarding progress
5. **Better Documentation**: Code comments reference Figma specs

## 🚀 Next Steps

- Test on physical device to verify visual accuracy
- Verify icon assets exist at specified paths
- Test with real data from Supabase
- Validate accessibility with screen readers
- Performance test with animation smoothness

## 📸 Visual Verification Checklist

- [ ] Title matches Figma text exactly
- [ ] List items have 12px gap
- [ ] Selected items have 1px green border
- [ ] Icons display at 32x32px
- [ ] Checkmarks are 24x24px circles
- [ ] Progress bar shows at bottom
- [ ] Button has 16px border radius
- [ ] Bottom guidance text is centered
- [ ] All colors match design tokens
- [ ] Typography sizes are correct
