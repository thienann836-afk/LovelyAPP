const CACHE='ban-linh-v2-2026-10b';
const ASSETS=['./','./index.html','./bl-config.js','./manifest.webmanifest','./assets/scenes/village.webp','./assets/scenes/bamboo.webp','./assets/scenes/sect.webp','./assets/scenes/celestial.webp',...Array.from({length:7},(_,i)=>`./assets/characters/cultivator-${i}.webp`),'./icon-192.png','./icon-512.png'];
self.addEventListener('install',e=>e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).then(()=>self.skipWaiting())));
self.addEventListener('activate',e=>e.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(k=>k.startsWith('ban-linh-')&&k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',e=>{
  const u=new URL(e.request.url);
  if(e.request.method!=='GET'||u.origin!==location.origin)return;
  const isNavigation=e.request.mode==='navigate'||u.pathname.endsWith('/index.html');
  const isConfig=u.pathname.endsWith('/bl-config.js');
  if(isNavigation||isConfig){
    e.respondWith(fetch(e.request).then(res=>{if(res.ok){const copy=res.clone();caches.open(CACHE).then(c=>c.put(e.request,copy))}return res}).catch(()=>caches.match(e.request).then(hit=>hit||caches.match('./index.html'))));
    return;
  }
  e.respondWith(caches.match(e.request).then(hit=>hit||fetch(e.request).then(res=>{if(res.ok){const copy=res.clone();caches.open(CACHE).then(c=>c.put(e.request,copy))}return res}).catch(()=>caches.match('./index.html'))));
});
