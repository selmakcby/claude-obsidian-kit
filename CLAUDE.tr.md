# Vault Anayasası (CLAUDE.md) — 🇹🇷 Türkçe Şablon

> Bu dosya **şema** — vault'un anayasası. Ajanlar herhangi bir nota dokunmadan önce
> bunu okur. Bir şablondur: kendi vault köküne kopyala; amaç, klasörler ve naming'i
> kendi alanına göre uyarla. İçinde projeye özel hiçbir şey yok.
>
> İngilizce orijinali: [vault-template/CLAUDE.md](vault-template/CLAUDE.md)

## Amaç

Bu vault, projenin kalıcı ve paylaşılan bilgi grafıdır. Cevaplaması beklenen sorular:

- Bu karar neydi, neden böyle verildi?
- Bu servis / araç / kavram ne, nerelerde kullanılıyor?
- Geçmiş oturumlarda ne oldu, bugünkü oturumun neyi bilmesi gerekiyor?
- Ne bayatladı, ne çelişiyor, ne eksik?

## Üç katman

| Katman | Nerede | Kural |
|---|---|---|
| **Ham kaynak** | Projenin kendisi: kod, transkriptler, export'lar, dokümanlar | **Ajan için dokunulmaz.** Sadece okunur. Asla yazma, taşıma, yeniden adlandırma, silme yok. |
| **Wiki** | `vault/` + `index.md` + `log.md` | Ajanların malı. İnsan okur, ajan yazar. |
| **Şema** | Bu dosya | Birlikte evrilir. Bilinçli değiştir, değişikliği log'la. |

## Klasör yapısı

```
vault/
├── CLAUDE.md          ← bu anayasa
├── index.md           ← katalog — her ingest'te güncellenir
├── _schema/           ← template.md + conventions.md (ayrıntılı kural kitabı)
├── architecture/      ← sistem tasarım dokümanları
├── decisions/         ← her "neden X, Y değil" — tarihli, gerekçeli
├── design/            ← UI/UX tasarım kararları
├── entities/          ← servis, araç veya kişi başına bir sayfa
├── concepts/          ← kesişen kavramlar (rate-limiting, webhook, RAG…)
└── sessions/          ← tarihli oturum özetleri
```

Daha derin iç içe klasör yok — en fazla 2 seviye. İlişkiyi klasörle değil `[[link]]` ile anlat.

## Sayfa formatı

Her not frontmatter taşır (tam spek: `_schema/template.md`):

```yaml
---
type: decision | session | entity | concept | architecture | design
date: YYYY-MM-DD
tags: []
links: []
status: draft | accepted | deprecated
source: user | <ajan-adı> | <dış-kaynak>
---
```

Gövde: `# Başlık` → `## Context` (bu not neden var) → `## Content` (tek atomik fikir)
→ `## Related` (her `[[link]]` yanında *neden* bağlı olduğunu söyleyen bir ifade).

## Naming

- Dosya adları **ASCII kebab-case**: `rate-limiting.md`, `2026-04-23-auth-secimi.md`
- Tarihli türler (`decision`, `session`) `YYYY-MM-DD-` öneki alır
- Her varlık için tek kanonik sayfa — varyantlar yeni sayfa değil, bölüm olur

## Workflow: INGEST (yeni bilgi geldiğinde)

1. Kaynağı oku.
2. İlgili sayfayı **güncelle** — yoksa aç.
3. Geçen her varlık/kavramı `[[…]]` ile bağla; sayfası yoksa `entities/` veya
   `concepts/` altında aç.
4. Net bir karar varsa `decisions/` altına **gerekçesi ve tarihiyle** yaz.
5. `index.md`'yi güncelle.
6. Mevcut bir sayfayla çelişki varsa `> [!conflict]` callout'u ile **iki tarafı da**
   göster — asla sessizce üzerine yazma.
7. `log.md`'ye satır ekle: `## [YYYY-MM-DD] ingest | …`

## Workflow: QUERY (soru geldiğinde)

1. Önce `index.md`; sadece onun işaret ettiği sayfaları aç.
2. Wiki cevaplayamıyorsa ham kaynağa in.
3. Her iddiaya kaynak referansı vererek cevapla.
4. Cevap kalıcı değer taşıyorsa **atomik** sayfa olarak geri dosyala
   (tek sayfa = tek fikir; "oturum özeti" çöplüğü yok). `log.md`'ye `query` satırı ekle.

## Workflow: LINT (periyodik sağlık kontrolü)

Şunlara bak: sayfalar arası çelişki · yeni kaynakla geçersizleşen iddia · yetim sayfa
(hiç inbound link almayan) · metinde geçip sayfası olmayan kavram · kırık `[[link]]` ·
wiki'de karşılığı olmayan ham kaynak.

Bulguları `log.md`'ye `lint` satırıyla yaz. **Otomatik düzeltme sadece kırık link ve
eksik çapraz-referansta.** İçerik çelişkisi raporlanır; kararı insan verir.

## Yasaklar

1. Ham kaynağa yazma, taşıma, yeniden adlandırma, silme — **hiçbir koşulda.**
2. Kaynaksız iddia yok. Her önemli cümle bir dosyaya dayanır.
3. Sayfa silme yok. Bayatlayan sayfa `archive/` klasörüne taşınır; `index.md` güncellenir.
4. Çelişkiyi tek tarafı yazarak çözme — `> [!conflict]` ile iki tarafı da göster.
5. Spekülatif sayfa yok. Ham kaynakta karşılığı olmayan "ileride lazım olur" sayfası açılmaz.

## Evrim notu

Bu şema değişir. Bir kural işlemiyorsa bu dosyayı güncelle ve `log.md`'ye `schema`
satırı ekle. Değişiklik geriye dönük uygulanmaz — mevcut sayfalar bir sonraki
dokunuşta yeni kurala geçer.
