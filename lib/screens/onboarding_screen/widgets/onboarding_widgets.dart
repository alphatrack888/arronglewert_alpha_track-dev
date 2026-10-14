import 'package:alpha_track/utils/app_colors/app_colors.dart';
import 'package:alpha_track/utils/app_images/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// "AlphaTrack" brand wordmark (symbol + logotype) shown at the top of the
/// onboarding pages. Matches Figma `Wordmark_PrimaryBlue` (158×44 → height 32).
class OnboardingWordmark extends StatelessWidget {
  const OnboardingWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppImages.logoWordmark,
      height: 32,
      semanticsLabel: 'AlphaTrack',
    );
  }
}

/// Rounded device-mockup illustration shown on the onboarding pages.
///
/// [asset] is the full square illustration card exported from Figma (gradient
/// background + phone mockup). If the asset is missing it falls back to a
/// styled placeholder card so the screen still renders.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key, this.asset, this.size = 264});

  /// Path to the exported illustration PNG (see [AppImages]). When null/missing
  /// the placeholder card is shown.
  final String? asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: asset == null
            ? const _IllustrationPlaceholder()
            : Image.asset(
                asset!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _IllustrationPlaceholder(),
              ),
      ),
    );
  }
}

/// Fallback shown when an onboarding illustration asset is not yet present.
class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: AppColors.textFaint.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Page indicator dots — active dot is a blue pill, others are faint circles.
class OnboardingDots extends StatelessWidget {
  const OnboardingDots({super.key, required this.activeIndex, this.count = 4});
  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: active ? 20 : 6,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.textFaint.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}
