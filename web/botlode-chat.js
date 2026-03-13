// BotLode Chat Controller v2.8
(function() {
  var iframe = document.getElementById('botlode-player');
  var hitzoneBotEl = document.getElementById('botlode-hitzone-bot');
  var hitzoneWppEl = document.getElementById('botlode-hitzone-wpp');
  if (!iframe) return;

  var isExpanded = false;
  var isAnimatingBubble = false;
  var BUBBLE_HEIGHT_SOLO_BOT = 140;
  var BUBBLE_HEIGHT_WITH_WPP = 290;
  var bubbleHeight = BUBBLE_HEIGHT_SOLO_BOT;

  var lastClickTime = 0;
  var CLICK_COOLDOWN_MS = 150;

  var iframeReady = false;
  var pendingOpenWhenReady = false;

  var touchHandled = false;
  var mouseHandled = false;

  var retryTimer = null;
  var retryCount = 0;
  var MAX_RETRIES = 2;
  var RETRY_DELAY_MS = 250;

  var chatOpenViewportHeight = null;
  var currentKeyboardHeight = 0;

  var TRUSTED_ORIGIN = 'https://botlode-player.vercel.app';

  function forwardEventToIframe(event, eventType) {
    try {
      if (!iframe.contentWindow) return;
      var iframeRect = iframe.getBoundingClientRect();
      iframe.contentWindow.postMessage({
        type: eventType,
        clientX: event.clientX || 0,
        clientY: event.clientY || 0,
        iframeX: iframeRect.left,
        iframeY: iframeRect.top,
      }, TRUSTED_ORIGIN);
    } catch (e) {}
  }

  function sendClickToIframe(source) {
    var rect = iframe.getBoundingClientRect();
    try {
      iframe.contentWindow.postMessage({
        type: 'HITZONE_CLICK_BOT',
        clientX: rect.left + rect.width / 2,
        clientY: rect.bottom - 70,
        iframeX: rect.left,
        iframeY: rect.top,
      }, TRUSTED_ORIGIN);
      iframe.contentWindow.postMessage('HITZONE_CLICK_BOT', TRUSTED_ORIGIN);
    } catch (e) {}
  }

  function openBotChat(source) {
    var now = Date.now();
    try { window.focus(); } catch(e) {}

    if (!iframeReady) {
      pendingOpenWhenReady = true;
      if (hitzoneBotEl) hitzoneBotEl.style.cursor = 'wait';
      return;
    }
    if (isExpanded) return;
    if (now - lastClickTime < CLICK_COOLDOWN_MS) return;

    lastClickTime = now;
    sendClickToIframe(source);

    retryCount = 0;
    if (retryTimer) clearTimeout(retryTimer);
    retryTimer = setTimeout(function retryFn() {
      if (isExpanded) return;
      retryCount++;
      if (retryCount <= MAX_RETRIES) {
        sendClickToIframe('retry-' + retryCount);
        retryTimer = setTimeout(retryFn, RETRY_DELAY_MS);
      }
    }, RETRY_DELAY_MS);
  }

  function openWppChat(source) {
    var now = Date.now();
    if (!iframeReady || isExpanded) return;
    if (now - lastClickTime < CLICK_COOLDOWN_MS) return;
    lastClickTime = now;
    var rect = iframe.getBoundingClientRect();
    try {
      iframe.contentWindow.postMessage({
        type: 'HITZONE_CLICK_WPP',
        clientX: rect.left + rect.width / 2,
        clientY: rect.top + 50,
        iframeX: rect.left,
        iframeY: rect.top,
      }, TRUSTED_ORIGIN);
    } catch (e) {}
  }

  function registerHitzoneEvents(el, openFn) {
    if (!el) return;
    el.addEventListener('pointerdown', function(e) {
      e.preventDefault(); e.stopPropagation();
      if (e.pointerType === 'touch') {
        touchHandled = true;
        setTimeout(function() { touchHandled = false; }, 500);
      } else {
        mouseHandled = true;
        setTimeout(function() { mouseHandled = false; }, 500);
      }
      openFn('pointerdown-' + e.pointerType);
    }, { passive: false });

    el.addEventListener('touchstart', function(e) {
      e.preventDefault(); e.stopPropagation();
      if (touchHandled) return;
      touchHandled = true;
      openFn('touchstart');
      setTimeout(function() { touchHandled = false; }, 500);
    }, { passive: false });

    el.addEventListener('mousedown', function(e) {
      e.preventDefault(); e.stopPropagation();
      if (mouseHandled || touchHandled) return;
      mouseHandled = true;
      openFn('mousedown');
      setTimeout(function() { mouseHandled = false; }, 500);
    }, { passive: false });

    el.addEventListener('click', function(e) {
      e.preventDefault(); e.stopPropagation();
      if (touchHandled || mouseHandled) return;
      openFn('click');
    }, { passive: false });

    el.addEventListener('contextmenu', function(e) { e.preventDefault(); });
    el.addEventListener('dragstart', function(e) { e.preventDefault(); });
  }

  registerHitzoneEvents(hitzoneBotEl, openBotChat);
  registerHitzoneEvents(hitzoneWppEl, openWppChat);

  if (hitzoneBotEl) {
    hitzoneBotEl.addEventListener('mouseenter', function(e) {
      if (!isExpanded) forwardEventToIframe(e, 'HITZONE_ENTER_BOT');
    });
    hitzoneBotEl.addEventListener('mouseleave', function(e) {
      if (!isExpanded) forwardEventToIframe(e, 'HITZONE_LEAVE_BOT');
    });
  }

  function updateHitzones(show) {
    if (hitzoneBotEl) {
      hitzoneBotEl.style.display = show ? 'block' : 'none';
      if (show) {
        hitzoneBotEl.style.pointerEvents = 'auto';
        hitzoneBotEl.style.cursor = iframeReady ? 'pointer' : 'wait';
      }
    }
  }

  function updateWppHitzone(show) {
    if (hitzoneWppEl) {
      hitzoneWppEl.style.display = show ? 'block' : 'none';
      if (show) {
        hitzoneWppEl.style.pointerEvents = 'auto';
        hitzoneWppEl.style.cursor = iframeReady ? 'pointer' : 'wait';
      }
    }
  }

  function isNarrowScreen() { return window.innerWidth < 600; }

  function applyBubblePosition() {
    iframe.style.left = 'auto';
    iframe.style.top = 'auto';
    iframe.style.right = '16px';
    iframe.style.bottom = '16px';
    iframe.style.width = '140px';
    iframe.style.height = bubbleHeight + 'px';
  }

  var T = {
    closeFadeOut: 120, closeWaitChat: 380, pauseBeforeEntrance: 100,
    entranceDelay: 60, entranceMain: 380, entranceBounce2: 180,
    entranceSettle: 120, resetAfter: 80
  };

  function animateBubbleEntrance() {
    isAnimatingBubble = true;
    iframe.style.opacity = '0';
    iframe.style.transform = 'translateZ(0) scale(0.3) rotate(-15deg)';
    iframe.style.filter = 'blur(8px) brightness(2)';

    setTimeout(function() {
      iframe.style.transition = 'opacity ' + (T.entranceMain * 0.4) + 'ms cubic-bezier(0.34, 1.56, 0.64, 1), transform ' + T.entranceMain + 'ms cubic-bezier(0.34, 1.56, 0.64, 1), filter ' + (T.entranceMain * 0.5) + 'ms ease-out';
      requestAnimationFrame(function() {
        iframe.style.opacity = '1';
        iframe.style.transform = 'translateZ(0) scale(1.1) rotate(3deg)';
        iframe.style.filter = 'blur(0px) brightness(1.3)';
      });

      setTimeout(function() {
        iframe.style.transition = 'transform ' + T.entranceBounce2 + 'ms cubic-bezier(0.25, 0.46, 0.45, 0.94), filter ' + T.entranceBounce2 + 'ms ease-out';
        iframe.style.transform = 'translateZ(0) scale(0.95) rotate(-1deg)';
        iframe.style.filter = 'blur(0px) brightness(1.1)';

        setTimeout(function() {
          iframe.style.transition = 'transform ' + T.entranceSettle + 'ms ease-out, filter ' + T.entranceSettle + 'ms ease-out';
          iframe.style.transform = 'translateZ(0) scale(1) rotate(0deg)';
          iframe.style.filter = 'blur(0px) brightness(1)';
          setTimeout(function() {
            iframe.style.transition = '';
            iframe.style.filter = '';
            isAnimatingBubble = false;
          }, T.resetAfter);
        }, T.entranceBounce2 * 0.6);
      }, T.entranceMain);
    }, T.entranceDelay);
  }

  window.addEventListener('message', function(event) {
    if (event.origin !== TRUSTED_ORIGIN && event.origin !== window.location.origin) return;
    var data = event.data;

    if (data === 'CMD_OPEN') {
      if (!isExpanded) {
        if (retryTimer) { clearTimeout(retryTimer); retryTimer = null; }
        isAnimatingBubble = false;
        iframe.style.filter = '';
        iframe.style.transform = 'translateZ(0)';
        iframe.style.transition = 'none';
        iframe.style.opacity = '0';
        iframe.style.pointerEvents = 'auto';
        try { iframe.focus(); } catch(e) {}
        updateHitzones(false);
        updateWppHitzone(false);

        if (isNarrowScreen()) {
          iframe.style.left = '0'; iframe.style.top = '0';
          iframe.style.right = '0'; iframe.style.bottom = '0';
          iframe.style.width = '100%'; iframe.style.height = '100%';
          if (window.visualViewport) chatOpenViewportHeight = window.visualViewport.height;
        } else {
          iframe.style.left = 'auto'; iframe.style.top = 'auto';
          iframe.style.right = '16px'; iframe.style.bottom = '16px';
          iframe.style.width = '450px'; iframe.style.height = 'calc(100vh - 32px)';
        }

        iframe.offsetHeight;
        requestAnimationFrame(function() {
          requestAnimationFrame(function() {
            iframe.style.transition = 'opacity 100ms ease-out';
            iframe.style.opacity = '1';
            setTimeout(function() { iframe.style.transition = 'none'; }, 150);
          });
        });
        isExpanded = true;
      }
    } else if (data === 'CMD_CLOSE') {
      if (isExpanded) {
        iframe.style.transition = 'opacity ' + (T.closeFadeOut / 1000) + 's ease-out';
        iframe.style.opacity = '0';
        iframe.style.pointerEvents = 'none';
        chatOpenViewportHeight = null;
        currentKeyboardHeight = 0;
        updateHitzones(true);

        setTimeout(function() {
          iframe.style.transition = 'none';
          if (isNarrowScreen()) { applyBubblePosition(); }
          else { iframe.style.width = '140px'; iframe.style.height = bubbleHeight + 'px'; }
          iframe.offsetHeight;
          setTimeout(function() { animateBubbleEntrance(); }, T.pauseBeforeEntrance);
        }, T.closeWaitChat);
        isExpanded = false;
      }
    } else if (data === 'CMD_WPP_VISIBLE') {
      bubbleHeight = BUBBLE_HEIGHT_WITH_WPP;
      updateWppHitzone(true);
      if (!isExpanded) {
        iframe.style.transition = 'height 0.25s ease-out';
        iframe.style.width = '140px';
        iframe.style.height = BUBBLE_HEIGHT_WITH_WPP + 'px';
      }
    } else if (data === 'CMD_WPP_HIDDEN') {
      bubbleHeight = BUBBLE_HEIGHT_SOLO_BOT;
      updateWppHitzone(false);
      if (!isExpanded) {
        iframe.style.transition = 'height 0.25s ease-out';
        iframe.style.width = '140px';
        iframe.style.height = BUBBLE_HEIGHT_SOLO_BOT + 'px';
      }
    }
  });

  function activateIframe(source) {
    if (iframeReady) return;
    iframeReady = true;
    iframe.style.transition = 'opacity 0.3s ease-out';
    iframe.style.opacity = '1';
    setTimeout(function() { iframe.style.transition = ''; }, 350);
    if (hitzoneBotEl) hitzoneBotEl.style.cursor = 'pointer';
    if (hitzoneWppEl && hitzoneWppEl.style.display !== 'none') hitzoneWppEl.style.cursor = 'pointer';
    if (pendingOpenWhenReady) {
      pendingOpenWhenReady = false;
      setTimeout(function() { openBotChat('pendingOpen'); }, 200);
    }
  }

  window.addEventListener('message', function(event) {
    if (event.origin !== TRUSTED_ORIGIN && event.origin !== window.location.origin) return;
    if (event.data === 'CMD_READY') activateIframe('CMD_READY');
  });

  setTimeout(function() {
    if (!iframeReady) activateIframe('timeout 8s');
  }, 8000);

  function updateHitzonePositions() {
    var isMobile = window.innerWidth < 600;
    var padBottom = isMobile ? 12 : 28;
    var padRight = isMobile ? 16 : 28;
    var hitzoneSize = isMobile ? 120 : 100;
    var gap = 12;

    if (hitzoneBotEl) {
      hitzoneBotEl.style.width = hitzoneSize + 'px';
      hitzoneBotEl.style.height = hitzoneSize + 'px';
      var offsetBottom = isMobile ? 10 : 16;
      var offsetRight = isMobile ? -2 : 4;
      hitzoneBotEl.style.bottom = (padBottom + offsetBottom) + 'px';
      hitzoneBotEl.style.right = (padRight + offsetRight) + 'px';
    }
    if (hitzoneWppEl) {
      hitzoneWppEl.style.width = hitzoneSize + 'px';
      hitzoneWppEl.style.height = hitzoneSize + 'px';
      hitzoneWppEl.style.bottom = (padBottom + 16 + hitzoneSize + gap) + 'px';
      hitzoneWppEl.style.right = (padRight + 4) + 'px';
    }
  }

  updateHitzonePositions();
  window.addEventListener('resize', updateHitzonePositions);

  var isTouchDevice = ('ontouchstart' in window) || (navigator.maxTouchPoints > 0);
  if (!isTouchDevice) {
    var lastMouseUpdate = 0;
    var MOUSE_THROTTLE_MS = 50;

    document.addEventListener('mousemove', function(event) {
      var now = Date.now();
      if (now - lastMouseUpdate < MOUSE_THROTTLE_MS) return;
      lastMouseUpdate = now;
      try {
        if (!iframe.contentWindow) return;
        var r = iframe.getBoundingClientRect();
        iframe.contentWindow.postMessage({
          type: 'MOUSE_MOVE', x: event.clientX, y: event.clientY,
          iframeX: r.left, iframeY: r.top, iframeWidth: r.width, iframeHeight: r.height
        }, TRUSTED_ORIGIN);
      } catch (e) {}
    }, true);

    document.addEventListener('mouseleave', function() {
      try { if (iframe.contentWindow) iframe.contentWindow.postMessage({ type: 'MOUSE_LEAVE' }, TRUSTED_ORIGIN); } catch (e) {}
    }, true);
    document.documentElement.addEventListener('mouseleave', function() {
      try { if (iframe.contentWindow) iframe.contentWindow.postMessage({ type: 'MOUSE_LEAVE' }, TRUSTED_ORIGIN); } catch (e) {}
    }, true);
  }

  if (window.visualViewport) {
    function handleKeyboardViewport() {
      if (!isExpanded || !isNarrowScreen() || !chatOpenViewportHeight) return;
      var vv = window.visualViewport;
      var diff = chatOpenViewportHeight - vv.height;
      if (diff > 80) {
        currentKeyboardHeight = diff;
        iframe.style.height = Math.round(vv.height) + 'px';
        iframe.style.top = Math.round(vv.offsetTop) + 'px';
        iframe.style.bottom = 'auto';
      } else if (currentKeyboardHeight > 0) {
        currentKeyboardHeight = 0;
        chatOpenViewportHeight = vv.height;
        iframe.style.height = '100%';
        iframe.style.top = '0';
        iframe.style.bottom = '0';
      }
    }
    window.visualViewport.addEventListener('resize', handleKeyboardViewport);
    window.visualViewport.addEventListener('scroll', handleKeyboardViewport);
  }
})();
