import 'package:flutter/material.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';

/// About PocketLedger - Precision Utilitarian Bento Grid Layout
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // ─── Top App Bar ───
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'About PocketLedger',
              style: AppTypography.titleLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Hero Section / Brand Mark ───
          _buildHeroSection(context, colorScheme),

          const SizedBox(height: 32),

          // ─── Bento Grid Layout ───
          _buildBentoGrid(context, colorScheme),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // App Icon
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: colorScheme.inversePrimary,
            size: 48,
          ),
        ),

        const SizedBox(height: 16),

        // App Name
        Text(
          'PocketLedger',
          style: AppTypography.headlineLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        // Version Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colorScheme.secondaryContainer),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'v${AppConstants.appVersion}',
                style: AppTypography.labelNumeric.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSecondaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Offline-First & Privacy-Focused',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // ─── Mission Statement (Wide Card) ───
        _BentoCard(
          padding: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OUR MISSION',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: 'PocketLedger is built on the principle of ',
                  style: AppTypography.headlineSmall.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text: 'financial privacy',
                      style: TextStyle(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. No cloud, no tracking, just your data on your device.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ─── Developer Info Card ───
        _BentoCard(
          padding: 24,
          color: colorScheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Developer Avatar + Name
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surfaceContainerLowest,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          color: colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Name & Role
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jared Gallant',
                        style: AppTypography.titleLarge.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Lead Developer',
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bio
              Text(
                'Dedicated to building high-performance technical tools that empower users with data sovereignty.',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              // Portfolio Link
              Row(
                children: [
                  Text(
                    'PORTFOLIO',
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ─── Core Engine Card ───
        _BentoCard(
          padding: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CORE ENGINE',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 20),

              // Feature 1
              _FeatureTile(
                icon: Icons.terminal,
                title: 'Local RegEx Engine',
                subtitle:
                    'Advanced pattern matching for transaction categorization, all processed on-device.',
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 16),

              // Feature 2
              _FeatureTile(
                icon: Icons.storage,
                title: 'ACID-Compliant SQLite',
                subtitle:
                    'Relational integrity for your financial records using industry-standard local storage.',
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 16),

              // Feature 3
              _FeatureTile(
                icon: Icons.cloud_off,
                title: 'Zero Cloud Dependency',
                subtitle:
                    'The application functions 100% without an internet connection or external servers.',
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ─── Resources & Legal Card ───
        _BentoCard(
          padding: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RESOURCES',
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 16),

              // Website
              _ResourceTile(
                title: 'Website',
                icon: Icons.arrow_forward,
                onTap: () {},
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 8),

              // Support
              _ResourceTile(
                title: 'Support',
                icon: Icons.contact_support,
                onTap: () {},
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 8),

              // Privacy Policy
              _ResourceTile(
                title: 'Privacy Policy',
                icon: Icons.gavel,
                onTap: () {},
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 24),

              // Footer
              Divider(
                color: colorScheme.surfaceContainer,
                height: 1,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2024 PocketLedger',
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'PRO LICENSED',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bento Card Container
class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.child,
    this.padding = 16,
    this.color,
  });

  final Widget child;
  final double padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color ?? colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// Feature Tile (for Core Engine section)
class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryFixed.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorScheme.onTertiaryContainer,
            size: 20,
          ),
        ),

        const SizedBox(width: 16),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Resource Tile (for Resources section)
class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Icon(
                icon,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
