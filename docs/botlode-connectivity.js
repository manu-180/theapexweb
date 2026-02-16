/**
 * BotLode Connectivity Snackbar
 * Script para páginas que embeben el widget BotLode (iframe).
 * Escucha mensajes del iframe cuando el usuario pierde/recupera la conexión
 * y muestra un snackbar profesional (solo si el bot tiene show_offline_alert = true).
 *
 * Uso: incluir en la página que contiene el iframe del bot.
 * <script src="https://tu-dominio.com/botlode-connectivity.js"></script>
 */
(function() {
  'use strict';

  var CONTAINER_ID = 'botlode-connectivity-snackbars';
  var OFFLINE_ID = 'botlode-snackbar-offline';
  var ONLINE_ID = 'botlode-snackbar-online';

  var CSS = [
    '#' + CONTAINER_ID + '{position:fixed;bottom:24px;left:50%;transform:translateX(-50%);z-index:2147483646;display:flex;flex-direction:column;align-items:center;gap:12px;pointer-events:none}',
    '.botlode-snackbar{position:relative;display:flex;align-items:center;gap:14px;padding:14px 22px;min-width:280px;max-width:90vw;border-radius:14px;font-family:\'Oxanium\',-apple-system,BlinkMacSystemFont,\'Segoe UI\',sans-serif;font-size:14px;font-weight:600;letter-spacing:.5px;box-sizing:border-box;pointer-events:auto;opacity:0;transform:translateY(20px) scale(.96);transition:opacity .4s cubic-bezier(.34,1.56,.64,1),transform .4s cubic-bezier(.34,1.56,.64,1),box-shadow .3s ease;backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px)}',
    '.botlode-snackbar.show{opacity:1;transform:translateY(0) scale(1)}',
    '.botlode-snackbar.hide{opacity:0;transform:translateY(-12px) scale(.96);transition-duration:.3s}',
    '.botlode-snackbar-offline{background:rgba(20,12,8,.75);border:1px solid rgba(255,140,60,.5);color:#ffb380;box-shadow:0 0 24px rgba(255,120,40,.15),inset 0 1px 0 rgba(255,192,0,.08)}',
    '.botlode-snackbar-offline .snackbar-glow{position:absolute;inset:-1px;border-radius:14px;padding:1px;background:linear-gradient(135deg,rgba(255,140,60,.25) 0%,transparent 50%,rgba(200,60,40,.15) 100%);-webkit-mask:linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0);mask:linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0);-webkit-mask-composite:xor;mask-composite:exclude;pointer-events:none;animation:botlode-pulse-off 2.5s ease-in-out infinite}',
    '@keyframes botlode-pulse-off{0%,100%{opacity:.6}50%{opacity:1}}',
    '.botlode-snackbar-online{background:rgba(8,24,16,.75);border:1px solid rgba(80,220,140,.45);color:#90ffc0;box-shadow:0 0 24px rgba(60,220,120,.12),inset 0 1px 0 rgba(120,255,180,.1)}',
    '.botlode-snackbar-online .snackbar-glow{position:absolute;inset:-1px;border-radius:14px;padding:1px;background:linear-gradient(135deg,rgba(80,220,140,.2) 0%,transparent 50%,rgba(60,180,100,.1) 100%);-webkit-mask:linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0);mask:linear-gradient(#fff 0 0) content-box,linear-gradient(#fff 0 0);-webkit-mask-composite:xor;mask-composite:exclude;pointer-events:none;animation:botlode-pulse-on 2.5s ease-in-out infinite}',
    '@keyframes botlode-pulse-on{0%,100%{opacity:.5}50%{opacity:1}}',
    '.botlode-snackbar .snackbar-icon{flex-shrink:0;width:28px;height:28px;display:flex;align-items:center;justify-content:center}',
    '.botlode-snackbar .snackbar-icon svg{width:100%;height:100%}',
    '.botlode-snackbar-offline .snackbar-icon{color:#ff9060}',
    '.botlode-snackbar-online .snackbar-icon{color:#60e090}',
    '.botlode-snackbar .snackbar-text{flex:1}'
  ].join('');

  var SVG_OFFLINE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.55a11 11 0 0 1 14.08 0"/><path d="M1.42 9a16 16 0 0 1 21.16 0"/><path d="M8.53 16.11a6 6 0 0 1 6.95 0"/><line x1="12" y1="20" x2="12.01" y2="20"/><line x1="2" y1="2" x2="22" y2="22" stroke-dasharray="2 2"/></svg>';
  var SVG_ONLINE = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';

  function injectStyles() {
    if (document.getElementById('botlode-connectivity-styles')) return;
    var el = document.createElement('style');
    el.id = 'botlode-connectivity-styles';
    el.textContent = CSS;
    (document.head || document.documentElement).appendChild(el);
  }

  function createSnackbars() {
    if (document.getElementById(CONTAINER_ID)) return;
    var wrap = document.createElement('div');
    wrap.id = CONTAINER_ID;
    wrap.setAttribute('aria-live', 'polite');
    wrap.innerHTML =
      '<div id="' + OFFLINE_ID + '" class="botlode-snackbar botlode-snackbar-offline" role="status" hidden>' +
        '<span class="snackbar-glow"></span>' +
        '<span class="snackbar-icon" aria-hidden="true">' + SVG_OFFLINE + '</span>' +
        '<span class="snackbar-text">Conexión perdida. Comprueba tu red.</span>' +
      '</div>' +
      '<div id="' + ONLINE_ID + '" class="botlode-snackbar botlode-snackbar-online" role="status" hidden>' +
        '<span class="snackbar-glow"></span>' +
        '<span class="snackbar-icon" aria-hidden="true">' + SVG_ONLINE + '</span>' +
        '<span class="snackbar-text">Reconexión exitosa</span>' +
      '</div>';
    document.body.appendChild(wrap);
  }

  var onlineTimeout = null;
  var lastOnlineCallTime = 0; // ⬅️ Para debounce de showOnline()
  var DEBOUNCE_MS = 500; // ⬅️ Tiempo mínimo entre llamadas a showOnline()
  
  /** Solo mostrar cartel de conectividad si el bot tiene show_offline_alert = true en la tabla bots (no bot_notifications). */
  var showOfflineAlert = false;
  var currentNetworkStatus = navigator.onLine; // ⬅️ Trackear estado actual de la red

  function showOffline() {
    currentNetworkStatus = false; // ⬅️ Actualizar estado interno
    if (!showOfflineAlert) return;
    var so = document.getElementById(OFFLINE_ID);
    var son = document.getElementById(ONLINE_ID);
    if (!so) return;
    if (onlineTimeout) { clearTimeout(onlineTimeout); onlineTimeout = null; }
    if (son) {
      son.classList.remove('show');
      son.classList.add('hide');
      son.setAttribute('hidden', '');
    }
    so.removeAttribute('hidden');
    so.classList.remove('hide');
    requestAnimationFrame(function() { so.classList.add('show'); });
  }

  function showOnline() {
    currentNetworkStatus = true; // ⬅️ Actualizar estado interno
    if (!showOfflineAlert) return;
    
    // ⬅️ DEBOUNCE: Evitar llamadas múltiples en corto tiempo
    var now = Date.now();
    if (now - lastOnlineCallTime < DEBOUNCE_MS) {
      return; // Ignorar si se llamó hace menos de 500ms
    }
    lastOnlineCallTime = now;
    
    var so = document.getElementById(OFFLINE_ID);
    var son = document.getElementById(ONLINE_ID);
    if (!son || !so) return;
    
    // Ocultar mensaje offline si está visible
    so.classList.remove('show');
    so.classList.add('hide');
    setTimeout(function() {
      so.setAttribute('hidden', '');
      so.classList.remove('hide');
    }, 300);
    
    // Mostrar mensaje online
    son.removeAttribute('hidden');
    son.classList.remove('hide');
    requestAnimationFrame(function() { 
      son.classList.add('show'); 
    });
    
    // Limpiar timeout previo si existe
    if (onlineTimeout) {
      clearTimeout(onlineTimeout);
      onlineTimeout = null;
    }
    
    // Configurar nuevo timeout para ocultar después de 3 segundos
    onlineTimeout = setTimeout(function() {
      if (son) {
        son.classList.remove('show');
        son.classList.add('hide');
        setTimeout(function() {
          if (son) {
            son.setAttribute('hidden', '');
            son.classList.remove('show', 'hide');
          }
        }, 300);
      }
      onlineTimeout = null;
    }, 3000);
  }

  function onMessage(ev) {
    var d = ev.data;
    
    // Configuración del bot
    if (d && typeof d === 'object' && d.type === 'BOT_CONFIG') {
      var previousShowOfflineAlert = showOfflineAlert;
      showOfflineAlert = d.showOfflineAlert === true;
      
      // ⬅️ Si se desactivó: ocultar cartel si está visible
      if (!showOfflineAlert) {
        var so = document.getElementById(OFFLINE_ID);
        if (so && so.classList.contains('show')) {
          so.classList.remove('show');
          so.classList.add('hide');
          setTimeout(function() {
            so.setAttribute('hidden', '');
          }, 300);
        }
      } 
      // ⬅️ Si se activó y estamos offline: mostrar cartel inmediatamente
      else if (showOfflineAlert && !previousShowOfflineAlert && !currentNetworkStatus) {
        // Verificar también el estado del navegador por si acaso
        if (!navigator.onLine) {
          showOffline();
        }
      }
      return;
    }
    
    // Mensajes de conectividad
    if (d && typeof d === 'object' && d.type === 'connectivity') {
      if (d.online) {
        showOnline();
      } else {
        showOffline();
      }
      return;
    }
    
    // Soporte legacy (por si acaso hay mensajes string antiguos)
    if (d === 'NETWORK_OFFLINE') { 
      showOffline(); 
      return; 
    }
    if (d === 'NETWORK_ONLINE') { 
      showOnline(); 
      return; 
    }
  }

  /** Respaldo: cuando la ventana recupera conexión, quitar snackbar offline por si el iframe no envió NETWORK_ONLINE */
  function onWindowOnline() {
    currentNetworkStatus = true;
    var so = document.getElementById(OFFLINE_ID);
    if (so && so.classList.contains('show')) showOnline();
  }
  
  /** Respaldo: cuando la ventana pierde conexión, mostrar snackbar si está habilitado */
  function onWindowOffline() {
    currentNetworkStatus = false;
    if (showOfflineAlert) {
      showOffline();
    }
  }

  function init() {
    injectStyles();
    createSnackbars();
    window.addEventListener('message', onMessage);
    window.addEventListener('online', onWindowOnline);
    window.addEventListener('offline', onWindowOffline);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
