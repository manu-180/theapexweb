'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "71646a361b91d1b96951f48da1addfe5",
"assets/AssetManifest.bin.json": "ff459308e1ef5bed41b8741db41fee92",
"assets/assets/animations/envia_apex.json": "55b49131057525fba4ffbb166186a0fa",
"assets/assets/animations/envia_assistify.json": "eba6a935a7e94219c1b6e720adfc834b",
"assets/assets/animations/envia_flutter.json": "7feea515b1acefdd8b0003e7ad95844f",
"assets/assets/animations/envia_riverpod.json": "f1da9b1ab4089b20322cb19bb7a35874",
"assets/assets/animations/envia_supabase.json": "773bc4af711be912402f3796ea61cdd5",
"assets/assets/animations/password_assistify.json": "26c3b50779fc085fb53ad5f1d675965e",
"assets/assets/animations/password_flutter.json": "f45bb5835230622e45fffd56330f4f21",
"assets/assets/animations/password_neutral.json": "006504aad8d88eb92332c4f3a9d87ce4",
"assets/assets/animations/password_riverpod.json": "09f2d0643a7d969ac2c33bc226c71ef8",
"assets/assets/animations/password_supabase.json": "5b3b11286c142d8483ef3c3d7904e3fb",
"assets/assets/fonts/Oxanium-VariableFont_wght.ttf": "81de8d6e17fbf408ab24bf57bfd1776e",
"assets/assets/icons/logo_assistify.png": "222a3c7ff1e65c629b59418b6b82516c",
"assets/assets/icons/metalwailers_logo.png": "e904a5a6385e7073970a91f4ff2eb509",
"assets/assets/icons/mnl_logo.png": "2e46c0f4fae1d7068c9558085c144d04",
"assets/assets/icons/perez_logo.PNG": "34b7d31e2518f76303d736f11d5b313a",
"assets/assets/icons/pulpiprint_logo.png": "6e4ce521a18cc7dd2cc719c6b145bf27",
"assets/assets/icons/simon_logo.png": "6aa461a40509b3deeba3efce2a44434a",
"assets/assets/images/favicon.png": "3750a43ed8de6561a97ad67011a4a27c",
"assets/assets/videos/yoapex.webm": "151304d8e0103a9bb316a5d43c7431df",
"assets/assets/videos/yoassistify.webm": "1bc146f7468420b04d4a48d99a4fa026",
"assets/assets/videos/yoflutter.webm": "abd6379d227a66dacc953497dea665dc",
"assets/assets/videos/yoriverpod.webm": "f91bd105a4a80288599659951cc1cc19",
"assets/assets/videos/yosupabase.webm": "78bcf8b264c6ee769d0a555ce9c733f2",
"assets/FontManifest.json": "10c2699f2a98d2c437b536d18c24d29a",
"assets/fonts/MaterialIcons-Regular.otf": "84541c970cb77885055256142b2dd243",
"assets/NOTICES": "3923d0c4b42e42277a69186d657b6fd4",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "a2e69ba65dc0876966df07de69578aa2",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "07d6f96697faf3e493e3f5072ac3a4dd",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "457f7ced0dcb29af8d169594f4919cfd",
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
"favicon.png": "50a8557d39a264275caacbbf6206cd9a",
"favicons/favicon_assistify.png": "24e87fb2e4e4039f53fa68da58c70d7f",
"favicons/favicon_flutter.png": "2cbe2a7ab2d77529f458fb752db77ae3",
"favicons/favicon_neutral.png": "13fe80125fdbe4031929877be3d44d4c",
"favicons/favicon_riverpod.png": "6725cb0a7c912366c40ecdc22bd2fc62",
"favicons/favicon_supabase.png": "86621263c2beee234fe1d5135b8909a0",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "f2363d2c173c2d0c0630b88eecaadf39",
"icons/Icon-192.png": "60ed491803bfd2a163b92db45a9e2f64",
"icons/Icon-512.png": "f0a96202bd8495d5ebf56de07231ce4a",
"icons/Icon-maskable-192.png": "60ed491803bfd2a163b92db45a9e2f64",
"icons/Icon-maskable-512.png": "f0a96202bd8495d5ebf56de07231ce4a",
"index.html": "3955eadbc7b99599e7270b40b14ebdbc",
"/": "3955eadbc7b99599e7270b40b14ebdbc",
"main.dart.js": "25339150bb02c73b8a2b4192b7f64965",
"manifest.json": "e5edcf06e24f861629b52fd028025b96",
"version.json": "3dd4c16e8899da670ae1401b86a9ae53"};
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
