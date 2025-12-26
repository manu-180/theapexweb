'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "16d59409a037282fba75c19d037d5483",
"assets/AssetManifest.bin.json": "03094e5665a23bdaa34115c92992b768",
"assets/assets/animations/actualizar.json": "c2265657a5995b5716fa72f878baa964",
"assets/assets/animations/calendario.json": "15201828994b9d825a5a77cc4dcd3f3e",
"assets/assets/animations/cancelarclase.json": "9ea21fb7daddde62dea81a782af40ca0",
"assets/assets/animations/cargandoclases.json": "afa6a6e4706d861d778b972861b8b957",
"assets/assets/animations/cargandoclases2.json": "5af0a738ef5f8d8c6ed3a68970ff93d6",
"assets/assets/animations/cargandoespera.json": "fc97a483e50b93d53fde92714f33e91d",
"assets/assets/animations/cargandomisclases.json": "812018e91fbfa8213e385b55c32f550a",
"assets/assets/animations/cargandomucho.json": "b2fa75beb6eb1055ff66d4d3407f55d6",
"assets/assets/animations/charge.json": "691aa6374e1f14b5a6be2d529181db0f",
"assets/assets/animations/circularprogress.json": "485cb272c07512ad74c1700186c8b287",
"assets/assets/animations/claseconfirmada.json": "d76204033f9d13b4dbbacadaf2af60e3",
"assets/assets/animations/coin.json": "b83a0752d36d0596f823bbd7f924bbff",
"assets/assets/animations/creandoclasesmujer.json": "9fe08cb14754ccd5ba56198ec0bc8e6b",
"assets/assets/animations/credit_approve.json": "41702372d754ab07db60c72afdb4e4b0",
"assets/assets/animations/listadeesperacheck.json": "80ddb8b7ded60a04f2c9c56f45d553a0",
"assets/assets/animations/loading.json": "01534ba32dbf2b07b4028f50af1ba6fb",
"assets/assets/animations/login2.json": "454490021982ff56c1fdb33c55e475b2",
"assets/assets/animations/loginscreen.json": "c39310f0690d38e7ae04da8ff703df9c",
"assets/assets/animations/phone_nudge.json": "53fbc428ec2774b0c68acd32941ff8a8",
"assets/assets/animations/redirigiendoclases.json": "a157e7da20d5a7d58f4f7ccd83b14d52",
"assets/assets/animations/register.json": "0738853cfcd56fde67698ad85c1ad400",
"assets/assets/animations/replace.json": "41c571b0882d496dfc4a7b32115c22a7",
"assets/assets/fonts/Oxanium-VariableFont_wght.ttf": "81de8d6e17fbf408ab24bf57bfd1776e",
"assets/assets/icons/logo_assistify.png": "222a3c7ff1e65c629b59418b6b82516c",
"assets/assets/icons/metalwailers_logo.png": "e904a5a6385e7073970a91f4ff2eb509",
"assets/assets/icons/mnl_logo.png": "2e46c0f4fae1d7068c9558085c144d04",
"assets/assets/icons/perez_logo.PNG": "34b7d31e2518f76303d736f11d5b313a",
"assets/assets/icons/pulpiprint_logo.png": "6e4ce521a18cc7dd2cc719c6b145bf27",
"assets/assets/icons/simon_logo.png": "6aa461a40509b3deeba3efce2a44434a",
"assets/FontManifest.json": "10c2699f2a98d2c437b536d18c24d29a",
"assets/fonts/MaterialIcons-Regular.otf": "3a0dc6960f2c7ff6f0256108966baeab",
"assets/NOTICES": "3923d0c4b42e42277a69186d657b6fd4",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "a2e69ba65dc0876966df07de69578aa2",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "70b69b9c0571d462180c4fa9aa00d166",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "75db1dd50e9b35fe9c17efbfd5e9b51e",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "de08a9ab3eecede374a32045fa55c86e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "6d395807b227695aeff14e66524cc6e6",
"/": "6d395807b227695aeff14e66524cc6e6",
"main.dart.js": "9cb590751de21f226a728d2c76e9cf87",
"manifest.json": "f06c5969ea52b23dbd7c9cb3a8b15af4",
"version.json": "0e63d3726e66bf15e65f5c4968f716af"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
