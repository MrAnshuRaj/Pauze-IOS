import '../services/safe_web_controller_logic.dart';

class SafeModeJs {
  static String scriptFor(SafeSocialPlatform platform) {
    switch (platform) {
      case SafeSocialPlatform.instagram:
        return _instagramScript;
      case SafeSocialPlatform.youtube:
        return _youtubeScript;
      case SafeSocialPlatform.facebook:
        return _facebookScript;
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

  static const String _facebookScript = r'''
(function() {
  const reelHrefPatterns = ['/reel', '/reels', 'fb.watch'];
  const reelWord = 'reel';

  const getSignals = (el) => {
    if (!el || !el.getAttribute) {
      return { href: '', aria: '', label: '', text: '' };
    }
    return {
      href: (el.getAttribute('href') || '').toLowerCase(),
      aria: (el.getAttribute('aria-label') || '').toLowerCase(),
      label: (el.getAttribute('label') || '').toLowerCase(),
      text: (el.textContent || '').toLowerCase().trim(),
    };
  };

  const looksLikeReelsLink = (el) => {
    if (!el || !el.getAttribute) return false;
    const s = getSignals(el);

    if (reelHrefPatterns.some((p) => s.href.includes(p))) return true;
    if (s.aria.includes(reelWord) || s.label.includes(reelWord)) return true;
    if (s.text === 'reels' || s.text.includes(' reels') || s.text.includes('reels ')) {
      return true;
    }
    return false;
  };

  const markHidden = (node) => {
    if (!node || !node.style) return;
    node.style.display = 'none';
    node.style.visibility = 'hidden';
    node.style.background = '#ffffff';
    node.style.backgroundColor = '#ffffff';
    node.style.border = '0';
    node.style.boxShadow = 'none';
    node.style.pointerEvents = 'none';
    node.setAttribute('aria-hidden', 'true');
    node.setAttribute('tabindex', '-1');
  };

  const findTabHolder = (el) =>
    el.closest(
      '[role="tab"], [role="tablist"] > *, nav li, nav [role="link"], nav a, header li'
    ) || el;

  const hideReelsEntrypoints = () => {
    document.querySelectorAll('a, [role="link"], [role="tab"], button').forEach((el) => {
      if (looksLikeReelsLink(el)) {
        markHidden(findTabHolder(el));
        return;
      }

      // Some FB variants keep the label on children; inspect subtree text/aria.
      const s = getSignals(el);
      const combined = `${s.aria} ${s.label} ${s.text}`;
      if (combined.includes('reels')) {
        const holder = findTabHolder(el);
        if (holder.closest('nav,[role="tablist"],header')) {
          markHidden(holder);
        }
      }
    });
  };

  const isReelsTarget = (target) => {
    if (!target || !target.closest) return false;
    const candidate = target.closest('a, [role="link"], [role="tab"], button');
    if (!candidate) return false;
    if (looksLikeReelsLink(candidate)) return true;
    const s = getSignals(candidate);
    return `${s.aria} ${s.label} ${s.text}`.includes('reels');
  };

  // Prevent navigation if a reels entry point still flashes in before observer runs.
  document.addEventListener(
    'click',
    (event) => {
      if (isReelsTarget(event.target)) {
        event.preventDefault();
        event.stopPropagation();
        event.stopImmediatePropagation();
        const candidate =
          event.target && event.target.closest
            ? event.target.closest('a, [role="link"], [role="tab"], button')
            : null;
        if (candidate) {
          markHidden(findTabHolder(candidate));
        }
      }
    },
    true
  );

  hideReelsEntrypoints();

  const observer = new MutationObserver(() => hideReelsEntrypoints());
  observer.observe(document.documentElement || document.body, {
    childList: true,
    subtree: true,
    attributes: true,
    attributeFilter: ['href', 'aria-label'],
  });
})();
''';

}
