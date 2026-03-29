import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../helpers/safe_mode_js.dart';
import '../../services/safe_web_controller_logic.dart';

class SafeWebViewScreen extends StatefulWidget {
  const SafeWebViewScreen({
    super.key,
    required this.logic,
  });

  final SafeWebControllerLogic logic;

  @override
  State<SafeWebViewScreen> createState() => _SafeWebViewScreenState();
}

class _SafeWebViewScreenState extends State<SafeWebViewScreen> {
  InAppWebViewController? _controller;
  bool _isLoading = true;
  bool _isRedirecting = false;
  int _fallbackIndex = 0;
  final CookieManager _cookieManager = CookieManager.instance();

  // Keep native WebView defaults where possible for maximum site compatibility.
  InAppWebViewSettings get _settings => InAppWebViewSettings(
        javaScriptEnabled: true,
        userAgent: widget.logic.customUserAgent,
        javaScriptCanOpenWindowsAutomatically: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        thirdPartyCookiesEnabled: true,
        sharedCookiesEnabled: true,
        cacheEnabled: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        safeBrowsingEnabled: true,
        clearCache: false,
        incognito: false,
        allowsBackForwardNavigationGestures: true,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.logic.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller?.reload(),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            InAppWebView(
              initialUrlRequest: widget.logic.safeHomeRequest(),
              initialSettings: _settings,
              onWebViewCreated: (InAppWebViewController controller) {
                _controller = controller;
              },
              shouldOverrideUrlLoading: _onShouldOverrideUrlLoading,
              onLoadStart: (InAppWebViewController controller, WebUri? url) {
                if (mounted) {
                  setState(() => _isLoading = true);
                }
                _guardAgainstBlockedUrl(url);
              },
              onProgressChanged: (InAppWebViewController controller, int progress) {
                if (!mounted) {
                  return;
                }
                if (progress >= 85 && _isLoading) {
                  setState(() => _isLoading = false);
                }
              },
              onLoadStop: (InAppWebViewController controller, WebUri? url) async {
                await _applySafetyScript();
                _guardAgainstBlockedUrl(url);
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              },
              onUpdateVisitedHistory:
                  (InAppWebViewController controller, WebUri? url, bool? isReload) {
                _guardAgainstBlockedUrl(url);
              },
              onReceivedError: (
                InAppWebViewController controller,
                WebResourceRequest request,
                WebResourceError error,
              ) {
                if ((request.isForMainFrame ?? true) && _isNameResolutionError(error)) {
                  unawaited(_loadNextFallbackHost());
                }
                if (!mounted) {
                  return;
                }
                if (request.isForMainFrame ?? true) {
                  setState(() => _isLoading = false);
                }
              },
              onReceivedHttpError: (
                InAppWebViewController controller,
                WebResourceRequest request,
                WebResourceResponse errorResponse,
              ) {
                if (!mounted) {
                  return;
                }
                if (request.isForMainFrame ?? true) {
                  setState(() => _isLoading = false);
                }
              },
            ),
            if (_isLoading)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        ),
      ),
    );
  }

  Future<NavigationActionPolicy> _onShouldOverrideUrlLoading(
    InAppWebViewController controller,
    NavigationAction action,
  ) async {
    final WebUri? target = action.request.url;

    // Only block explicit unsafe routes; allow all other navigation.
    if (_isBlocked(target)) {
      await _redirectToSafeHome();
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  bool _isBlocked(WebUri? uri) {
    if (uri == null) {
      return false;
    }

    final Uri parsed = Uri.parse(uri.toString());
    return widget.logic.isUrlBlocked(parsed);
  }

  void _guardAgainstBlockedUrl(WebUri? uri) {
    if (_isBlocked(uri)) {
      _redirectToSafeHome();
    }
  }

  Future<void> _redirectToSafeHome() async {
    if (_isRedirecting || _controller == null) {
      return;
    }

    _isRedirecting = true;
    try {
      await _controller!.loadUrl(urlRequest: widget.logic.safeHomeRequest());
    } finally {
      _isRedirecting = false;
    }
  }

  bool _isNameResolutionError(WebResourceError error) {
    final String desc = error.description.toLowerCase();
    return desc.contains('err_name_not_resolved');
  }

  Future<void> _loadNextFallbackHost() async {
    if (_controller == null) {
      return;
    }
    final List<Uri> fallbacks = widget.logic.fallbackHomeUris;
    if (_fallbackIndex >= fallbacks.length) {
      return;
    }

    final Uri nextUri = fallbacks[_fallbackIndex];
    _fallbackIndex += 1;
    await _controller!.loadUrl(
      urlRequest: URLRequest(url: WebUri.uri(nextUri)),
    );
  }

  Future<void> _applySafetyScript() async {
    if (_controller == null) {
      return;
    }

    try {
      final String script = SafeModeJs.scriptFor(widget.logic.platform);
      if (script.trim().isEmpty) {
        return;
      }
      await _cookieManager.getCookies(url: WebUri.uri(widget.logic.homeUri));
      await _controller!.evaluateJavascript(
        source: script,
      );
    } catch (_) {
      // Best effort injection: URL guard still enforces policy if selectors change.
    }
  }
}
