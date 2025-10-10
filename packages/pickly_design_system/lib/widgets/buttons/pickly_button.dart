import 'package:flutter/material.dart';
import 'package:pickly_design_system/pickly_design_system.dart';

/// Pickly 기본 버튼 컴포넌트
///
/// Figma componentSetId: 2:757
///
/// Variants:
/// - state: default | disabled | pressed
/// - ver: primary | secondary
///
/// Properties:
/// - Button Text (text)
/// - Show Left Icon (boolean)
/// - Left Icon (instance)
/// - Show Right Icon (boolean)
/// - Right Icon (instance)
enum ButtonVariant { primary, secondary }

class PicklyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const PicklyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.leftIcon,
    this.rightIcon,
  });

  /// Primary 버튼 팩토리 생성자
  const PicklyButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? leftIcon,
    Widget? rightIcon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.primary,
          isLoading: isLoading,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
        );

  /// Secondary 버튼 팩토리 생성자
  const PicklyButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? leftIcon,
    Widget? rightIcon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.secondary,
          isLoading: isLoading,
          leftIcon: leftIcon,
          rightIcon: rightIcon,
        );

  @override
  Widget build(BuildContext context) {
    final backgroundColor = variant == ButtonVariant.primary
        ? BrandColors.primary
        : BrandColors.secondary;

    final textColor = variant == ButtonVariant.primary
        ? Colors.white
        : BrandColors.primary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: ButtonColors.disabledBg,
          elevation: 0, // ✅ 그림자 없음 (Figma 스펙)
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PicklyBorderRadius.xl),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leftIcon != null) ...[
                    leftIcon!,
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: PicklyTypography.buttonLarge.copyWith(
                      color: onPressed != null ? textColor : TextColors.disabled,
                    ),
                  ),
                  if (rightIcon != null) ...[
                    const SizedBox(width: 10),
                    rightIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}
