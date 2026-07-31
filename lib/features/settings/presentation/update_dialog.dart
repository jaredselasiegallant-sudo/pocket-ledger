import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/update_service.dart';

/// Full-screen update dialog with download progress
class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  static Future<void> showIfAvailable(BuildContext context) async {
    final info = await UpdateService.checkForUpdate();
    if (info == null || !context.mounted) return;

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(updateInfo: info),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  _UpdatePhase _phase = _UpdatePhase.ready;
  double _progress = 0;
  String? _error;

  UpdateInfo get info => widget.updateInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: _phase == _UpdatePhase.ready,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.system_update_rounded,
                    color: colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Available',
                        style: AppTypography.titleMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info.releaseName,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ─── Version Info ───
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _VersionBadge(
                    label: info.currentVersion,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  _VersionBadge(
                    label: info.latestVersion,
                    color: colorScheme.primary,
                  ),
                  const Spacer(),
                  Text(
                    info.sizeLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Release Notes ───
            if (info.releaseBody.isNotEmpty) ...[
              Text(
                "What's New",
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 150),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _cleanReleaseNotes(info.releaseBody),
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ─── Progress / Error / Actions ───
            if (_phase == _UpdatePhase.downloading) ...[
              LinearProgressIndicator(
                value: _progress,
                borderRadius: BorderRadius.circular(4),
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Downloading... ${(_progress * 100).toInt()}%',
                  style: AppTypography.labelMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: colorScheme.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            Row(
              children: [
                if (_phase == _UpdatePhase.ready || _phase == _UpdatePhase.failed)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Later'),
                    ),
                  ),
                if (_phase == _UpdatePhase.ready ||
                    _phase == _UpdatePhase.failed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _downloadUpdate,
                      child: const Text('Download'),
                    ),
                  ),
                ],
                if (_phase == _UpdatePhase.downloading)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: null,
                      child: const Text('Downloading...'),
                    ),
                  ),
                if (_phase == _UpdatePhase.complete) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _openUpdate,
                      child: const Text('Install'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadUpdate() async {
    setState(() {
      _phase = _UpdatePhase.downloading;
      _progress = 0;
      _error = null;
    });

    final file = await UpdateService.downloadUpdate(
      info.downloadUrl,
      info.assetName,
      (p) => setState(() => _progress = p),
    );

    if (!mounted) return;

    if (file == null) {
      setState(() {
        _phase = _UpdatePhase.failed;
        _error = 'Download failed. Check your connection and try again.';
      });
      return;
    }

    setState(() {
      _phase = _UpdatePhase.complete;
      _downloadedFile = file;
    });
  }

  File? _downloadedFile;

  Future<void> _openUpdate() async {
    if (_downloadedFile != null) {
      await UpdateService.openUpdateFile(_downloadedFile!);
    }
    if (mounted) Navigator.pop(context);
  }

  String _cleanReleaseNotes(String body) {
    return body
        .replaceAll('## ', '')
        .replaceAll('### ', '')
        .replaceAll('**', '')
        .trim();
  }
}

class _VersionBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _VersionBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'v$label',
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum _UpdatePhase { ready, downloading, complete, failed }
