import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

enum TargetApp {
  instagram,
  instagramLite,
  youtube,
  facebook,
  snapchat,
  linkedIn,
  tikTok,
}

class TargetAppMeta {
  const TargetAppMeta({
    required this.id,
    required this.displayName,
    required this.bundleId,
    required this.androidPackageId,
    required this.iconData,
    required this.color,
    this.aliases = const <String>[],
    this.keywords = const <String>[],
  });

  final String id;
  final String displayName;
  final String bundleId;
  final String androidPackageId;
  final IconData iconData;
  final Color color;
  final List<String> aliases;
  final List<String> keywords;
}

const Map<TargetApp, TargetAppMeta> targetAppMeta = <TargetApp, TargetAppMeta>{
  TargetApp.instagram: TargetAppMeta(
    id: 'instagram',
    displayName: 'Instagram',
    bundleId: 'com.burbn.instagram',
    androidPackageId: 'com.instagram.android',
    iconData: FontAwesomeIcons.instagram,
    color: Color(0xFFE1306C),
    aliases: <String>['insta'],
    keywords: <String>['instagram', 'insta'],
  ),
  TargetApp.instagramLite: TargetAppMeta(
    id: 'instagram_lite',
    displayName: 'Instagram Lite',
    bundleId: 'com.burbn.instagramlite',
    androidPackageId: 'com.instagram.lite',
    iconData: FontAwesomeIcons.instagram,
    color: Color(0xFFF56040),
    aliases: <String>['instagramlite', 'iglite'],
    keywords: <String>['instagram lite', 'insta lite', 'ig lite'],
  ),
  TargetApp.youtube: TargetAppMeta(
    id: 'youtube',
    displayName: 'YouTube',
    bundleId: 'com.google.ios.youtube',
    androidPackageId: 'com.google.android.youtube',
    iconData: FontAwesomeIcons.youtube,
    color: Color(0xFFFF0000),
    aliases: <String>['yt'],
    keywords: <String>['youtube', 'you tube', 'yt'],
  ),
  TargetApp.facebook: TargetAppMeta(
    id: 'facebook',
    displayName: 'Facebook',
    bundleId: 'com.facebook.Facebook',
    androidPackageId: 'com.facebook.katana',
    iconData: FontAwesomeIcons.facebook,
    color: Color(0xFF1877F2),
    aliases: <String>['fb'],
    keywords: <String>['facebook', 'fb'],
  ),
  TargetApp.snapchat: TargetAppMeta(
    id: 'snapchat',
    displayName: 'Snapchat',
    bundleId: 'com.toyopagroup.picaboo',
    androidPackageId: 'com.snapchat.android',
    iconData: FontAwesomeIcons.snapchat,
    color: Color(0xFFFFFC00),
    aliases: <String>['snap'],
    keywords: <String>['snapchat', 'snap'],
  ),
  TargetApp.linkedIn: TargetAppMeta(
    id: 'linkedin',
    displayName: 'LinkedIn',
    bundleId: 'com.linkedin.LinkedIn',
    androidPackageId: 'com.linkedin.android',
    iconData: FontAwesomeIcons.linkedin,
    color: Color(0xFF0A66C2),
    aliases: <String>['linkedinapp'],
    keywords: <String>['linkedin', 'linked in'],
  ),
  TargetApp.tikTok: TargetAppMeta(
    id: 'tiktok',
    displayName: 'TikTok',
    bundleId: 'com.zhiliaoapp.musically',
    androidPackageId: 'com.zhiliaoapp.musically',
    iconData: FontAwesomeIcons.tiktok,
    color: Color(0xFF111111),
    aliases: <String>['musically'],
    keywords: <String>['tiktok', 'tik tok', 'musically'],
  ),
};

extension TargetAppX on TargetApp {
  TargetAppMeta get meta => targetAppMeta[this]!;
}

class LabelMappingResult {
  const LabelMappingResult({
    required this.labelToApp,
    required this.mappedApps,
    required this.unmappedLabels,
  });

  final Map<String, TargetApp> labelToApp;
  final List<TargetApp> mappedApps;
  final List<String> unmappedLabels;
}

TargetApp? targetAppFromId(String id) {
  for (final TargetApp app in TargetApp.values) {
    if (app.meta.id == id) {
      return app;
    }
  }
  return null;
}

TargetApp? inferTargetAppFromLabel(String rawLabel) {
  final String normalized = _normalize(rawLabel);
  if (normalized.isEmpty) {
    return null;
  }

  if (_containsAny(normalized, <String>['instagram lite', 'insta lite', 'ig lite']) ||
      (_containsWord(normalized, 'instagram') && _containsWord(normalized, 'lite'))) {
    return TargetApp.instagramLite;
  }

  if (_containsWord(normalized, 'instagram') || _containsWord(normalized, 'insta')) {
    return TargetApp.instagram;
  }

  for (final TargetApp app in TargetApp.values) {
    final TargetAppMeta meta = app.meta;
    final List<String> candidates = <String>[
      meta.displayName,
      meta.id,
      meta.bundleId,
      meta.androidPackageId,
      ...meta.aliases,
      ...meta.keywords,
    ];

    for (final String candidate in candidates) {
      final String candidateNormalized = _normalize(candidate);
      if (candidateNormalized.isEmpty) {
        continue;
      }
      if (normalized == candidateNormalized ||
          _containsWord(normalized, candidateNormalized)) {
        return app;
      }
    }
  }

  return null;
}

LabelMappingResult mapSelectedLabelsToApps(List<String> labels) {
  final Map<String, TargetApp> labelToApp = <String, TargetApp>{};
  final Set<TargetApp> appSet = <TargetApp>{};
  final List<String> unmappedLabels = <String>[];

  for (final String label in labels) {
    final TargetApp? app = inferTargetAppFromLabel(label);
    if (app == null) {
      unmappedLabels.add(label);
      continue;
    }
    labelToApp[label] = app;
    appSet.add(app);
  }

  final List<TargetApp> mappedApps = TargetApp.values
      .where((TargetApp app) => appSet.contains(app))
      .toList(growable: false);

  return LabelMappingResult(
    labelToApp: labelToApp,
    mappedApps: mappedApps,
    unmappedLabels: unmappedLabels,
  );
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _containsWord(String haystack, String needle) {
  final String h = ' $haystack ';
  final String n = ' ${_normalize(needle)} ';
  return h.contains(n);
}

bool _containsAny(String text, List<String> candidates) {
  for (final String candidate in candidates) {
    if (_containsWord(text, candidate)) {
      return true;
    }
  }
  return false;
}
