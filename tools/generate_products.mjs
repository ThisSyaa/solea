// ============================================================
// Generator katalog SOLEA — ambil foto sepatu dari Unsplash (default)
// atau Pexels, lalu buat data produk.
//
// Cara pakai (dari folder root projek, butuh Node.js 18+):
//   UNSPLASH_ACCESS_KEY=xxxx node tools/generate_products.mjs
//   (Windows PowerShell)  $env:UNSPLASH_ACCESS_KEY="xxxx"; node tools/generate_products.mjs
//
// Opsi:
//   --provider unsplash|pexels   sumber foto (default unsplash)
//                                Pexels butuh PEXELS_API_KEY; saat ini
//                                Pexels sedang menghentikan key baru.
//   --count 200                  jumlah produk (default 200)
//   --out path                   file keluaran (default assets/data/products.json)
//   --mock                       tanpa internet / tanpa API key, hanya uji logika
//
// Hasil acak bersifat deterministik (seed tetap), jadi kalau dijalankan
// ulang nama produk tetap sama. Penting, karena keranjang & wishlist
// mencocokkan produk lewat NAMA.
// ============================================================
import { writeFile, mkdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const argValue = (name) => {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : undefined;
};

const MOCK = args.includes('--mock');
const TOTAL = Number(argValue('--count') ?? 200);
const OUT = path.resolve(
  ROOT,
  argValue('--out') ?? (MOCK ? 'tools/products.mock.json' : 'assets/data/products.json'),
);
const PROVIDER = argValue('--provider') ?? 'unsplash';
const KEY_ENV = PROVIDER === 'pexels' ? 'PEXELS_API_KEY' : 'UNSPLASH_ACCESS_KEY';
const API_KEY = process.env[KEY_ENV];
if (!['unsplash', 'pexels'].includes(PROVIDER)) {
  console.error('--provider harus unsplash atau pexels.');
  process.exit(1);
}
const SEED = 20260;

// ---------- konfigurasi kategori ----------
// share = porsi dari total produk, price = rentang harga (Rupiah)
const CATEGORIES = {
  Running: {
    share: 0.2, price: [899000, 1699000],
    queries: ['running shoes', 'jogging sneakers'],
    prefixes: ['Air', 'Swift', 'Velocity', 'Stride', 'Pace', 'Tempo', 'Rush', 'Sprint', 'Cloud', 'Aero', 'Pulse', 'Nimbus'],
    models: ['Runner', 'Racer', 'Glide', 'Dash', 'Boost', 'Flow', 'Sprinter', 'Jogger', 'Lite', 'Wave'],
    descriptions: [
      'Sepatu lari ringan dengan bantalan empuk untuk jarak jauh maupun lari harian.',
      'Upper breathable dan midsole responsif yang menjaga langkah tetap ringan.',
      'Dirancang untuk pelari harian: stabil, nyaman, dan tetap stylish di luar trek.',
      'Bantalan lembut dengan outsole grip kuat untuk berbagai permukaan jalan.',
    ],
  },
  Lifestyle: {
    share: 0.2, price: [799000, 1399000],
    queries: ['sneakers street style', 'lifestyle sneakers'],
    prefixes: ['Street', 'Metro', 'Downtown', 'Avenue', 'Loft', 'District', 'Studio', 'Grid', 'Retro', 'Alley', 'Block', 'Vibe'],
    models: ['Classic', 'Low', 'Mid', 'Origin', 'Heritage', 'Cruiser', 'Edition', 'Walker', 'Court', 'Icon'],
    descriptions: [
      'Gaya klasik yang mudah dipadukan dengan outfit casual maupun streetwear.',
      'Siluet bersih dengan detail premium untuk tampilan kota yang rapi.',
      'Sneakers serbaguna yang nyaman dipakai dari pagi sampai malam.',
      'Desain timeless dengan sentuhan modern, cocok untuk aktivitas sehari-hari.',
    ],
  },
  Basketball: {
    share: 0.125, price: [999000, 1899000],
    queries: ['basketball shoes', 'high top sneakers'],
    prefixes: ['Court', 'Hoop', 'Dunk', 'Baseline', 'Rebound', 'Fastbreak', 'Clutch', 'Arena', 'Jump', 'Zone'],
    models: ['Vision', 'High', 'Elite', 'Force', 'Shot', 'Flight', 'Drive', 'Pro', 'Rise'],
    descriptions: [
      'Midsole responsif dan upper stabil untuk gerakan cepat di lapangan.',
      'Pergelangan kaki terlindungi dengan grip kuat untuk pivot dan lompatan.',
      'Siap untuk permainan intens: bantalan tebal, traksi tajam, fit mantap.',
    ],
  },
  Casual: {
    share: 0.2, price: [649000, 1099000],
    queries: ['white sneakers', 'casual shoes'],
    prefixes: ['Urban', 'Daily', 'Clean', 'Pure', 'Easy', 'Plain', 'Fresh', 'Calm', 'Simple', 'Soft', 'Basic', 'Cozy'],
    models: ['White', 'Slip', 'Step', 'Mono', 'Canvas', 'Walk', 'Base', 'Lite', 'Move', 'Day'],
    descriptions: [
      'Sneaker clean untuk gaya minimalis sehari-hari.',
      'Ringan dan fleksibel, pas untuk kuliah, kerja, atau jalan santai.',
      'Tampilan simpel yang cocok dipadukan dengan hampir semua outfit.',
      'Nyaman dipakai seharian dengan desain rapi yang tidak ribet.',
    ],
  },
  Outdoor: {
    share: 0.125, price: [1199000, 2099000],
    queries: ['hiking boots', 'trail shoes'],
    prefixes: ['Trail', 'Summit', 'Ridge', 'Terra', 'Canyon', 'Alpine', 'Rocky', 'Forest', 'Peak', 'Wild'],
    models: ['Max', 'Trek', 'Hiker', 'Ranger', 'Climb', 'Explorer', 'Grip', 'Path', 'Boot'],
    descriptions: [
      'Outsole bergrip untuk jalur outdoor dan medan yang lebih menantang.',
      'Material kokoh dan tahan cuaca untuk hiking maupun trekking.',
      'Proteksi ekstra di bagian jari dan tumit untuk medan berbatu.',
    ],
  },
  Training: {
    share: 0.15, price: [849000, 1399000],
    queries: ['gym shoes', 'training sneakers'],
    prefixes: ['Daily', 'Core', 'Power', 'Flex', 'Iron', 'Active', 'Drive', 'Strong', 'Motion', 'Rep'],
    models: ['Flex', 'Trainer', 'Lift', 'Burn', 'Fit', 'Form', 'Move', 'Gym', 'Max'],
    descriptions: [
      'Sepatu training fleksibel untuk gym, workout, dan aktivitas ringan.',
      'Sol stabil untuk angkat beban dan cukup lentur untuk latihan kardio.',
      'Upper breathable dengan dukungan samping yang kuat saat latihan.',
    ],
  },
};

const SUFFIXES = ['', '', '', '2', '3', 'Pro', 'Lite', 'GT', 'X', 'SE'];
const SHOE_WORDS = /shoe|sneaker|boot|footwear|trainer|kicks|sole|loafer|nike|adidas|puma|jordan|converse|vans|reebok|new balance/i;
const PEOPLE_WORDS = /\b(man|men|woman|women|girl|boy|people|person|model|portrait|child|kid)\b/i;

// ---------- RNG deterministik ----------
function mulberry32(seed) {
  return () => {
    seed |= 0; seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const rand = mulberry32(SEED);
const pick = (arr) => arr[Math.floor(rand() * arr.length)];
const between = (a, b) => a + rand() * (b - a);

// ---------- ambil foto ----------
// Semua provider dinormalisasi ke bentuk:
// { id, alt, photographer, url, image, imageLarge }
async function fetchPage(query, page) {
  if (MOCK) {
    return Array.from({ length: 30 }, (_, i) => {
      const id = String(Math.abs(hash(`${query}-${page}-${i}`)));
      return {
        id, alt: i % 7 === 0 ? 'Smiling woman portrait' : 'Pair of sneakers on floor',
        photographer: 'Mock Photographer', url: `https://example.invalid/photo/${id}`,
        image: `https://example.invalid/${id}-regular.jpg`,
        imageLarge: `https://example.invalid/${id}-large.jpg`,
      };
    });
  }

  if (PROVIDER === 'pexels') {
    const url = new URL('https://api.pexels.com/v1/search');
    url.search = new URLSearchParams({ query, per_page: '80', page: String(page) });
    const res = await fetch(url, { headers: { Authorization: API_KEY } });
    if (res.status === 401) throw new Error('PEXELS_API_KEY tidak valid.');
    if (res.status === 429) throw new Error('Kena rate limit Pexels. Coba lagi nanti.');
    if (!res.ok) throw new Error(`Pexels error ${res.status}`);
    const data = await res.json();
    console.log(`  "${query}" hal.${page}: ${data.photos.length} foto`);
    return data.photos.map((p) => ({
      id: String(p.id), alt: p.alt, photographer: p.photographer, url: p.url,
      image: p.src.large, imageLarge: p.src.large2x,
    }));
  }

  // Unsplash (mode demo: 50 request/jam, per_page maksimal 30)
  const url = new URL('https://api.unsplash.com/search/photos');
  url.search = new URLSearchParams({ query, per_page: '30', page: String(page) });
  const res = await fetch(url, {
    headers: { Authorization: `Client-ID ${API_KEY}`, 'Accept-Version': 'v1' },
  });
  if (res.status === 401) throw new Error('UNSPLASH_ACCESS_KEY tidak valid.');
  if (res.status === 403) throw new Error('Kena rate limit Unsplash (50 request/jam). Coba lagi satu jam lagi.');
  if (!res.ok) throw new Error(`Unsplash error ${res.status}`);
  const data = await res.json();
  console.log(`  "${query}" hal.${page}: ${data.results.length} foto (sisa kuota jam ini: ${res.headers.get('x-ratelimit-remaining') ?? '?'})`);
  const utm = 'utm_source=solea&utm_medium=referral';
  return data.results.map((p) => ({
    id: p.id,
    alt: p.alt_description ?? p.description ?? '',
    photographer: p.user?.name ?? 'Unknown',
    url: `${p.links.html}?${utm}`,
    // URL harus dipakai langsung dari CDN Unsplash dan parameter ixid
    // jangan dihapus (aturan hotlinking Unsplash).
    image: p.urls.regular,
    imageLarge: p.urls.regular,
  }));
}
function hash(s) { let h = 0; for (const c of s) h = (Math.imul(31, h) + c.charCodeAt(0)) | 0; return h; }

const score = (p) => {
  const alt = p.alt ?? '';
  return (SHOE_WORDS.test(alt) ? 2 : 0) - (PEOPLE_WORDS.test(alt) ? 1 : 0);
};

// ---------- main ----------
if (!MOCK && !API_KEY) {
  console.error(`Set dulu ${KEY_ENV}, atau jalankan dengan --mock.`);
  process.exit(1);
}

const usedPhotoIds = new Set();
const usedNames = new Set();
const products = [];

// jatah produk per kategori (total harus pas TOTAL)
const entries = Object.entries(CATEGORIES);
const quotas = entries.map(([, c]) => Math.floor(c.share * TOTAL));
for (let i = 0; quotas.reduce((a, b) => a + b, 0) < TOTAL; i = (i + 1) % quotas.length) quotas[i]++;

for (const [idx, [category, cfg]] of entries.entries()) {
  const need = quotas[idx];
  console.log(`\n${category}: butuh ${need} foto`);

  // kumpulkan foto unik dari semua query kategori ini
  const pool = [];
  for (const query of cfg.queries) {
    for (let page = 1; page <= 3 && pool.length < need * 1.5; page++) {
      const photos = await fetchPage(query, page);
      for (const p of photos) {
        if (!usedPhotoIds.has(p.id) && !pool.some((x) => x.id === p.id)) pool.push(p);
      }
    }
  }
  pool.sort((a, b) => score(b) - score(a));
  const chosen = pool.slice(0, need);
  if (chosen.length < need) console.warn(`  ! ${category}: hanya dapat ${chosen.length} dari ${need} foto.`);

  for (const photo of chosen) {
    usedPhotoIds.add(photo.id);

    // nama unik
    let name, tries = 0;
    do {
      const suffix = pick(SUFFIXES);
      name = `${pick(cfg.prefixes)} ${pick(cfg.models)}${suffix ? ' ' + suffix : ''}`;
      if (++tries > 30) name += ` ${Math.floor(between(4, 99))}`;
    } while (usedNames.has(name));
    usedNames.add(name);

    // harga berakhiran ...49.000 / ...99.000
    const raw = between(cfg.price[0], cfg.price[1]);
    const price = Math.round(raw / 50000) * 50000 - 1000;

    // ukuran: 5-6 dari 39..44
    const sizes = [39, 40, 41, 42, 43, 44].filter((s) => s !== 39 + Math.floor(rand() * 8) || rand() > 0.5);

    products.push({
      name,
      category,
      price,
      rating: Math.round(between(4.2, 5.0) * 10) / 10,
      imageUrl: photo.image,
      images: [photo.imageLarge],
      description: pick(cfg.descriptions),
      sizes: sizes.length >= 5 ? sizes : [39, 40, 41, 42, 43],
      // untuk atribusi fotografer (wajib di Unsplash, dianjurkan di Pexels)
      photographer: photo.photographer,
      photoUrl: photo.url,
    });
  }
}

// acak urutan supaya kategori tidak berkelompok di beranda
for (let i = products.length - 1; i > 0; i--) {
  const j = Math.floor(rand() * (i + 1));
  [products[i], products[j]] = [products[j], products[i]];
}

await mkdir(path.dirname(OUT), { recursive: true });
await writeFile(OUT, JSON.stringify(products, null, 2), 'utf8');
console.log(`\nSelesai: ${products.length} produk -> ${path.relative(ROOT, OUT)}`);
