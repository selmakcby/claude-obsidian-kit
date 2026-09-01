# Videodaki Promptlar · Prompts from the video

> 🇹🇷 "Sıfırdan Ajan Hafızası" videosunda ekranda kullandığım promptların temiz,
> genelleştirilmiş hâli. Kendi klasörüne uyarlaman için kişisel kısımlar çıkarıldı.
> 🇬🇧 The exact prompts used in the (Turkish) video, cleaned up and generalized.

Hepsi Claude Code'da, vault klasörünün içinden çalıştırılır (`cd vault-klasorun && claude`).
Vault yapısının kendisi için: [vault-template/](vault-template/) · mevcut klasörünü
dönüştürmek için: [RETROFIT.md](RETROFIT.md)

---

## 1 · Arşivini gerçekten okuyor mu? (test sorusu)

Kurulumdan sonra sistemin çalıştığını kanıtlamak için. Obsidian kapalıyken sor —
eklenti yok, köprü yok, MCP yok; ajan sadece klasöre bakıyor:

```
Bu klasördeki arşivimde en çok linklenen üç sayfa hangisi ve neden merkezde duruyorlar?
Cevabını dosyalara bakarak ver.
```

---

## 2 · Granülerlik deneyi — tek dosya vs bölünmüş yapı

Aynı veriyi bir kere tek dev dosya, bir kere konu-başına-dosya olarak koy;
**birebir aynı promptu** iki kuruluma da ver. Deneyin tek değişkeni dosya yapısı olmalı:

```
raw/ klasöründeki kaynakları oku. En çok tekrar eden üç talep ne,
her birini kaç farklı yerde gördün, ve hangileri hiç cevaplanmamış?
Cevabında her iddia için hangi dosyadan geldiğini yaz.
```

Tek dosyada cevap genelleşir ve atıf zayıflar; bölünmüş yapıda ajan doğru dosyayı
açar, sayılar ve isimler doğru gelir.

---

## 3 · Sıfırdan vault iskeleti kurdurma

```
Bu klasörü bir LLM wiki olarak kur. Şunları yap:

1. CLAUDE.md yaz — üç cümle: bu klasör ne, içinde ne var, ne zaman buraya bakılmalı.
2. index.md yaz — şimdilik boş bir katalog, kategori başlıkları hazır olsun.
3. log.md yaz — append-only, tarih damgalı kayıt dosyası.
4. Şu klasörleri aç: raw/ (ham kaynaklar, sen asla yazmayacaksın), sources/ (her ham
   kaynak için bir özet sayfası), konular/ (kavram sayfaları).

Kurallar: tek konu tek dosya. Dosya adları küçük harf, tire ile ayrılmış, Türkçe karakter yok.
Bağlantılar dosyanın içinde [[köşeli-çift-parantez]] biçiminde. En fazla iki seviye derinlik.

Yazmadan önce ne yapacağını tek paragrafta söyle.
```

Son satır önemli: kurulumu sen denetliyorsun, ajan tek başına karar vermiyor.

---

## 4 · Mevcut dağınık notları wiki'ye dönüştürme

Boş klasöre değil, yıllardır biriken notların üstüne kuruyorsan:

```
Bu klasörde dağınık notlarım var. Bunları bir LLM wiki'ye dönüştür.

1. CLAUDE.md yaz — üç cümle: bu klasör ne, içinde ne var, ne zaman buraya bakılmalı.
2. index.md yaz — her sayfa için bir satır: [[bağlantı]] + tek cümle özet.
3. Mevcut notları düzenle: her dosyanın başına frontmatter koy (title, tags, date,
   status), gövdedeki ilgili kavramları [[köşeli-çift-parantez]] ile birbirine bağla.
4. Notların içinde çelişki varsa sessizce birini seçme — sayfada işaretle ve hangisinin
   geçerli olduğunu gerekçesiyle yaz.
5. raw/ klasörüne ASLA yazma. Orası dokunulmaz.

Dosya adları küçük harf, tire ile ayrılmış, Türkçe karakter yok.

Yazmadan önce ne yapacağını tek paragrafta söyle.
```

---

## 5 · INGEST — yeni kaynak işleme

Yeni ham malzemeyi `raw/` içine koyduktan sonra:

```
raw/ klasörüne yeni kaynaklar koydum.

Bunları işle:
1. Oku, önce bana en önemli çıkarımları söyle.
2. Her kaynak için sources/ altına bir özet sayfası yaz.
3. Konu sayfalarını aç ya da güncelle — tekrar eden talepleri kendi sayfası olacak
   şekilde ayır.
4. index.md'yi güncelle, yeni sayfaları kataloğa ekle.
5. log.md'ye tarih damgalı bir satır düş.
6. Sayfalar arasında çapraz bağlantı kur.

Bir kaynakta iddia edilen bir şey başka bir kaynakla çelişiyorsa sayfada işaretle,
sessizce birini seçme.
```

---

## 6 · QUERY — asıl numara son cümlede

```
Arşive soruyorum: [sorunu buraya yaz]

Cevabında her iddia için kaynak sayfayı göster.
Cevabı ürettikten sonra bunu bir sentez sayfası olarak wiki'ye yaz ve index.md'ye ekle —
bir dahaki sefere sıfırdan çalışma, üstüne koy.
```

Son cümle RAG ile aradaki farkın tamamı: RAG'da cevap üretilir ve uçar gider;
burada cevap arşivin kalıcı parçası olur.

---

## 7 · LINT — sağlık kontrolü

Düzenli bakım (haftalık yeterli — her gün aynı dosyaları yeniden okutmak token israfı):

```
Bu wiki'nin sağlık kontrolünü yap:
- Kırık [[bağlantı]] var mı?
- Hiçbir yerden link almayan yetim sayfa var mı?
- index.md'de listelenmeyen sayfa var mı?
- Sayfalar arasında çelişen iddia var mı?
- Bir sayfada geçen ama kendi sayfası olmayan kavram var mı?

Bulduklarını önce liste hâlinde göster. Ben onaylamadan düzeltme yapma.
```

Uzun süre bakımsız kalmış arşiv için daha hedefli sürüm:

```
Bu vault uzun süredir bakımsız. Sağlık kontrolü yap:

1. index.md'de hiç geçmeyen sayfaları listele.
2. Kırık [[bağlantı]]ları bul. Her biri için sebebini de yaz — dosya adı mı farklı,
   sayfa mı silinmiş?
3. Yetim sayfaları bul.

Üçünü de liste hâlinde göster, ben onayladıktan sonra index.md'yi yeniden yaz ve
kırık bağlantıları düzelt. Sayfa içeriklerine dokunma.
```

---

## 8 · Güvenlik testi — hafızaya yerleşen prompt injection

`raw/` içindeki bir kaynağa bilerek sahte bir "gerçek" ekle, ingest ettir,
**yeni oturumda** o bilgiyi sor. Ajan uydurmayı kendi hafızasından, emin bir tonla
verecektir — okuduğu her şey kalıcı gerçeğe dönüşür. Temizliği için:

```
raw/ içindeki sahte notu sil, bu iddiadan türeyen tüm wiki sayfalarını bul ve
temizle, log.md'ye ne temizlediğini yaz.
```

Ders: `raw/` klasörüne ne girdiğini bil; vault'a giren her iddia,
sonraki her cevabın zemini olur.
