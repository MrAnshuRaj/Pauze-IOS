import 'package:flutter_inappwebview/flutter_inappwebview.dart';

enum SafeSocialPlatform {
  instagram,
  youtube,
  facebook,
}

class SafeWebControllerLogic {
  const SafeWebControllerLogic(this.platform);

  final SafeSocialPlatform platform;

  String get title {
    switch (platform) {
      case SafeSocialPlatform.instagram:
        return 'Safe Instagram';
      case SafeSocialPlatform.youtube:
        return 'Safe YouTube';
      case SafeSocialPlatform.facebook:
        return 'Safe Facebook';
    }
  }

  Uri get homeUri {
    switch (platform) {
      case SafeSocialPlatform.instagram:
        return Uri.parse('https://www.instagram.com/');
      case SafeSocialPlatform.youtube:
        return Uri.parse('https://m.youtube.com/');
      case SafeSocialPlatform.facebook:
        return Uri.parse('https://m.facebook.com/');
    }
  }

  List<Uri> get fallbackHomeUris {
    switch (platform) {
      case SafeSocialPlatform.instagram:
      case SafeSocialPlatform.youtube:
        return const <Uri>[];
      case SafeSocialPlatform.facebook:
        return <Uri>[
          Uri(scheme: 'https', host: 'www.facebook.com'),
          Uri(scheme: 'https', host: 'mbasic.facebook.com'),
        ];
    }
  }

  // Some providers (notably Facebook) can reject/blank embedded WebView UAs.
  String? get customUserAgent {
    switch (platform) {
      case SafeSocialPlatform.instagram:
      case SafeSocialPlatform.youtube:
      case SafeSocialPlatform.facebook:
        return null;
    }
  }

  // Platform-specific routes that should never be reachable in safe mode.
  List<String> get blockedPathTokens {
    switch (platform) {
      case SafeSocialPlatform.instagram:
        return const <String>['/reels/', '/explore/'];
      case SafeSocialPlatform.youtube:
        return const <String>['/shorts/'];
      case SafeSocialPlatform.facebook:
        // Keep blocking route-based only to avoid DOM-side blank screen issues.
        return const <String>['/reel', '/reels', '/watch/reel'];
    }
  }

  // URL blocking is host-aware so external links are unaffected.
  bool isUrlBlocked(Uri uri) {
    final String host = uri.host.toLowerCase();
    final String path = uri.path.toLowerCase();

    if (!_hostMatches(host)) {
      return false;
    }

    for (final String token in blockedPathTokens) {
      if (path.contains(token)) {
        return true;
      }
    }

    return false;
  }

  URLRequest safeHomeRequest() {
    return URLRequest(url: WebUri.uri(homeUri));
  }

  bool _hostMatches(String host) {
    switch (platform) {
      case SafeSocialPlatform.instagram:
        return host.contains('instagram.com');
      case SafeSocialPlatform.youtube:
        return host == 'm.youtube.com' ||
            host == 'youtube.com' ||
            host.endsWith('.youtube.com');
      case SafeSocialPlatform.facebook:
        return host == 'm.facebook.com' ||
            host == 'mbasic.facebook.com' ||
            host == 'facebook.com' ||
            host.endsWith('.facebook.com') ||
            host == 'fb.watch';
    }
  }
}


