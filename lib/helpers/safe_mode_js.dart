import '../services/safe_web_controller_logic.dart';

class SafeModeJs {
  static String scriptFor(SafeSocialPlatform platform) {
    switch (platform) {
      case SafeSocialPlatform.instagram:
        return _instagramScript;
      case SafeSocialPlatform.youtube:
        return _youtubeScript;
    }
  }

  // Keep this conservative: hide only known addictive entry points.
  static const String _instagramScript = r'''
(function() {
  const selectors = [
    'a[href="/reels/"]',
    'a[href*="/reels/"]',
    'a[href="/explore/"]',
    'a[href*="/explore/"]',
    '[aria-label="Reels"]',
    '[aria-label="Explore"]'
  ];

  const hideNodes = () => {
    selectors.forEach((selector) => {
      document.querySelectorAll(selector).forEach((el) => {
        const holder = el.closest('li,nav,section,div') || el;
        holder.style.display = 'none';
        holder.style.visibility = 'hidden';
        holder.setAttribute('aria-hidden', 'true');
      });
    });
  };

  hideNodes();

  const observer = new MutationObserver(() => hideNodes());
  observer.observe(document.documentElement || document.body, {
    childList: true,
    subtree: true,
  });
})();
''';

  static const String _youtubeScript = r'''
(function() {
  const selectors = [
    'a[href^="/shorts"]',
    'a[href*="/shorts/"]',
    'ytm-pivot-bar-item-renderer a[href*="shorts"]',
    'ytm-reel-shelf-renderer'
  ];

  const hideNodes = () => {
    selectors.forEach((selector) => {
      document.querySelectorAll(selector).forEach((el) => {
        const holder = el.closest('ytm-pivot-bar-item-renderer,ytm-reel-shelf-renderer,ytm-item-section-renderer,ytm-rich-item-renderer,div,section') || el;
        holder.style.display = 'none';
        holder.style.visibility = 'hidden';
        holder.setAttribute('aria-hidden', 'true');
      });
    });

    document.querySelectorAll('ytm-pivot-bar-item-renderer, ytm-item-section-renderer, ytm-rich-item-renderer').forEach((node) => {
      const text = (node.textContent || '').toLowerCase();
      if (text.includes('shorts')) {
        node.style.display = 'none';
      }
    });
  };

  hideNodes();

  const observer = new MutationObserver(() => hideNodes());
  observer.observe(document.documentElement || document.body, {
    childList: true,
    subtree: true,
  });
})();
''';
}
