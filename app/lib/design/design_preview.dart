import 'package:flutter/material.dart';

import 'tokens/colors.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';
import 'widgets/lokal_button.dart';
import 'widgets/lokal_card.dart';
import 'widgets/lokal_chip.dart';
import 'widgets/lokal_text_field.dart';

/// Phase-1 visual check. Open this to verify theme, typography, and every
/// reusable widget renders correctly before building real screens.
class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key});

  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen> {
  int _chipIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LokalColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            LokalSpacing.lg,
            LokalSpacing.xl,
            LokalSpacing.lg,
            LokalSpacing.xxxl,
          ),
          children: [
            Text('LOKAL', style: LokalTypography.displayMd),
            const SizedBox(height: LokalSpacing.xs),
            Text(
              'Design system preview',
              style: LokalTypography.bodyLg
                  .copyWith(color: LokalColors.onSurfaceVariant),
            ),
            const SizedBox(height: LokalSpacing.xl),

            _sectionTitle('Typography'),
            Text('Display Md', style: LokalTypography.displayMd),
            Text('Headline Lg', style: LokalTypography.headlineLg),
            Text('Headline Md', style: LokalTypography.headlineMd),
            Text('Title Md', style: LokalTypography.titleMd),
            const SizedBox(height: LokalSpacing.sm),
            Text(
              'Body Lg — Helping hands, just around the corner.',
              style: LokalTypography.bodyLg,
            ),
            Text(
              'Body Sm — subtle supporting caption text.',
              style: LokalTypography.bodySm,
            ),

            const SizedBox(height: LokalSpacing.xl),
            _sectionTitle('Cards'),
            LokalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instant Ride Share', style: LokalTypography.headlineSm),
                  const SizedBox(height: LokalSpacing.xs),
                  Text(
                    'Nearby commutes, matched in seconds.',
                    style: LokalTypography.bodySm,
                  ),
                ],
              ),
            ),

            const SizedBox(height: LokalSpacing.xl),
            _sectionTitle('Buttons'),
            const LokalButton(label: 'Primary — Get Started', onPressed: _noop),
            const SizedBox(height: LokalSpacing.md),
            const LokalButton(
              label: 'Continue with Google',
              onPressed: _noop,
              variant: LokalButtonVariant.secondary,
              icon: Icons.g_mobiledata_rounded,
            ),
            const SizedBox(height: LokalSpacing.md),
            const LokalButton(
              label: 'Ghost action',
              onPressed: _noop,
              variant: LokalButtonVariant.ghost,
            ),

            const SizedBox(height: LokalSpacing.xl),
            _sectionTitle('Chips'),
            Wrap(
              spacing: LokalSpacing.sm,
              runSpacing: LokalSpacing.sm,
              children: [
                for (var i = 0; i < _chipLabels.length; i++)
                  LokalChip(
                    label: _chipLabels[i],
                    selected: _chipIndex == i,
                    onTap: () => setState(() => _chipIndex = i),
                  ),
              ],
            ),

            const SizedBox(height: LokalSpacing.xl),
            _sectionTitle('Input fields'),
            const LokalTextField(
              label: 'Email',
              hint: 'you@lokal.app',
              prefixIcon: Icons.mail_outline_rounded,
            ),
            const SizedBox(height: LokalSpacing.md),
            const LokalTextField(
              label: 'Password',
              hint: 'At least 8 characters',
              prefixIcon: Icons.lock_outline_rounded,
              obscure: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String label) => Padding(
        padding: const EdgeInsets.only(bottom: LokalSpacing.md),
        child: Text(label, style: LokalTypography.headlineMd),
      );
}

const List<String> _chipLabels = [
  'Ride & Delivery',
  'Techie',
  'Support Partner',
  'Non-Tech',
];

void _noop() {}
