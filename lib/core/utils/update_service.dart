import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Checks GitHub Releases for new versions and downloads updates.
/// 100% transparent — open source, no telemetry.
class UpdateService {
  UpdateService._();

  static const _owner = 'jaredselasiegallant-sudo';
  static const _repo = 'pocket-ledger';
  static const _releasesUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';

  /// Fetch the latest release info from GitHub.
  static Future<GitHubRelease?> fetchLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse(_releasesUrl),
        headers: {'Accept': 'application/vnd.github+json'},
      );
      if (response.statusCode != 200) {
        developer.log('GitHub API returned ${response.statusCode}',
            name: 'UpdateService');
        return null;
      }
      return GitHubRelease.fromJson(jsonDecode(response.body));
    } catch (e) {
      developer.log('Failed to fetch release: $e', name: 'UpdateService');
      return null;
    }
  }

  /// Compare two semver strings. Returns:
  ///   -1 if a < b, 0 if equal, 1 if a > b
  static int compareVersions(String a, String b) {
    final partsA = a.split('.').map(int.tryParse).toList();
    final partsB = b.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final va = (i < partsA.length ? partsA[i] : 0) ?? 0;
      final vb = (i < partsB.length ? partsB[i] : 0) ?? 0;
      if (va < vb) return -1;
      if (va > vb) return 1;
    }
    return 0;
  }

  /// Check if an update is available. Returns null if no update or on error.
  static Future<UpdateInfo?> checkForUpdate() async {
    final release = await fetchLatestRelease();
    if (release == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final cmp = compareVersions(currentVersion, release.version);
    if (cmp >= 0) {
      developer.log('App is up to date ($currentVersion)',
          name: 'UpdateService');
      return null;
    }

    developer.log('Update available: $currentVersion -> ${release.version}',
        name: 'UpdateService');

    final asset = _getAssetForPlatform(release);
    if (asset == null) return null;

    return UpdateInfo(
      currentVersion: currentVersion,
      latestVersion: release.version,
      releaseName: release.name,
      releaseBody: release.body,
      downloadUrl: asset.browserDownloadUrl,
      assetName: asset.name,
      assetSize: asset.size,
    );
  }

  /// Download the update asset to the app's temp directory.
  static Future<File?> downloadUpdate(
    String downloadUrl,
    String fileName,
    void Function(double progress)? onProgress,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        developer.log('Download failed: ${response.statusCode}',
            name: 'UpdateService');
        return null;
      }

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;

      final sink = file.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress?.call(receivedBytes / totalBytes);
        }
      }
      await sink.close();

      developer.log('Download complete: ${file.path} ($receivedBytes bytes)',
          name: 'UpdateService');
      return file;
    } catch (e) {
      developer.log('Download error: $e', name: 'UpdateService');
      return null;
    }
  }

  /// Open the downloaded file or directory for manual install.
  static Future<void> openUpdateFile(File file) async {
    final uri = Uri.file(file.path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static _ReleaseAsset? _getAssetForPlatform(GitHubRelease release) {
    if (kIsWeb) return null;

    if (Platform.isAndroid) {
      for (final a in release.assets) {
        if (a.name.endsWith('.apk')) return a;
      }
      return null;
    }
    if (Platform.isWindows) {
      for (final a in release.assets) {
        if (a.name.endsWith('.zip')) return a;
      }
      return null;
    }
    return null;
  }
}

// ─── Models ───

class GitHubRelease {
  final String name;
  final String version;
  final String body;
  final List<_ReleaseAsset> assets;

  const GitHubRelease({
    required this.name,
    required this.version,
    required this.body,
    required this.assets,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String? ?? '';
    final version = tagName.replaceFirst('v', '');
    final assets = (json['assets'] as List?)
            ?.map((a) => _ReleaseAsset.fromJson(a))
            .toList() ??
        [];

    return GitHubRelease(
      name: json['name'] as String? ?? tagName,
      version: version,
      body: json['body'] as String? ?? '',
      assets: assets,
    );
  }
}

class _ReleaseAsset {
  final String name;
  final String browserDownloadUrl;
  final int size;

  const _ReleaseAsset({
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
  });

  factory _ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return _ReleaseAsset(
      name: json['name'] as String? ?? '',
      browserDownloadUrl: json['browser_download_url'] as String? ?? '',
      size: json['size'] as int? ?? 0,
    );
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseName;
  final String releaseBody;
  final String downloadUrl;
  final String assetName;
  final int assetSize;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseName,
    required this.releaseBody,
    required this.downloadUrl,
    required this.assetName,
    required this.assetSize,
  });

  String get sizeLabel {
    if (assetSize > 1048576) {
      return '${(assetSize / 1048576).toStringAsFixed(1)} MB';
    }
    return '${(assetSize / 1024).toStringAsFixed(0)} KB';
  }
}
