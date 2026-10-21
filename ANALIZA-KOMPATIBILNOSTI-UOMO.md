# Analiza kompatibilnosti: Uomo tema vs. WordPress 7.x / WooCommerce 10–11 / PHP 8.2–8.4

**Predmet:** može li se postojeća tema (`uomo` + `uomo-child`) zadržati pri nadogradnji stacka, ili je potrebna zamjena teme
**Lokalitet:** hildegarda (LiteSpeed, PHP 8.2.34, MySQL 8.4.11)
**Datum analize:** 21.10.2026.
**Analizirani paket:** `uomo` v2.0.9 (ThemeForest ID 31127579, ApusTheme), child `uomo-child` v1.0.0

---

## 0. Odgovor u tri rečenice (TL;DR)

1. **Tema nije napuštena.** Uomo je i dalje u aktivnom razvoju — aktualna verzija je **2.0.37 (29.05.2026.)**, a na siteu je **2.0.9 od 07.11.2022.** Problem nije prestanak izdavanja verzija, nego **pokvaren/nepostojeći kanal nadogradnje** (tema s ThemeForesta nema auto-update bez Envato Market dodatka i valjane licence).
2. **Temu možete zadržati — ali ne u verziji 2.0.9.** Uz WP 7.x, WooCommerce 10–11 i Elementor 4.x, verzija 2.0.9 ima **24–25 zastarjelih WooCommerce predložaka** (uključujući checkout, plaćanje, košaricu i mini-košaricu) i **fatalnu grešku u Elementor editoru** (korištenje `Core\Schemes` klasa uklonjenih u Elementor 3.26).
3. **Preporuka:** prije svega ostalog **nadograditi temu na 2.0.37** (+ prateći *Apus Framework* iz novog paketa), pa tek onda ići na **WP 7.0.x + WooCommerce 10.9.4 + Elementor 4.3.5**. WP 7.1.x i WooCommerce 11.x su *izvan* deklarirane podrške verzije 2.0.37 — njih planirati u drugom valu, nakon potvrde proizvođača.

> **Zaključak:** zamjena teme **nije nužna**. Nužna je nadogradnja teme. Zamjenu razmatrati samo ako se ne može doći do licenciranog paketa 2.0.37 (vidi poglavlje 8).

---

## 1. Metodologija i izvori

Analiza je rađena na stvarnom kodu teme (v2.0.9, checkout u repozitoriju) i usporedbom s aktualnim izdanjima:

| Izvor | Što je korišteno |
|---|---|
| Kod teme (`uomo/`, 206 PHP datoteka, 81 WooCommerce datoteka) | statička analiza, usporedba predložaka, hookovi, PHP 8.x obrasci, JS |
| `woocommerce/woocommerce` (GitHub, tagovi 7.4.1 / 10.9.4 / 11.2.1) | usporedba `@version` svakog overridea, popis hookova, zahtjevi (PHP/WP) |
| `elementor/elementor` (tagovi 4.0.8 / 4.3.5) | provjera postojanja API-ja koje tema koristi (`register_widget_type`, `controls_registered`, `Core\Schemes`) |
| `WordPress/WordPress` (tag 7.1.3) | minimalni zahtjevi, jQuery/jQuery Migrate, `version.php` |
| ThemeForest stranica proizvoda (31127579) | changelog, deklarirana kompatibilnost, datum zadnje objave |
| WordPress 7.1 Field Guide / server requirements | promjene u 7.x seriji, PHP matrice |
| Site Health izvještaj koji ste dostavili | stanje servera, dodataka, konstanti |

Sve verzije i datumi navedeni su **na dan 21.10.2026.**

---

## 2. Ključni nalaz: tema se ažurira, ali vi ih ne dobivate

### 2.1. Stvarna vremenska crta Uomo teme (ThemeForest)

| Verzija | Datum | Napomena |
|---|---|---|
| 2.0.9 | 07.11.2022. | **verzija na siteu** |
| 2.0.10 – 2.0.16 | 12/2022 – 03/2024 | WooCommerce + RTL |
| **2.0.13** | 15.06.2023. | *„Updated PHP version"* — PHP 8.x prilagodbe **nakon** vaše verzije |
| 2.0.17 – 2.0.22 | 05/2024 – 11/2024 | WooCommerce |
| 2.0.23 | 17.12.2024. | Elementor |
| 2.0.24 – 2.0.32 | 12/2024 – 08/2025 | WooCommerce |
| **2.0.28 / 2.0.33** | 25.04.2025. / 01.10.2025. | *„Updated Security"* — **sigurnosne zakrpe koje nemate** |
| 2.0.34 – 2.0.37 | 24.10.2025 – 29.05.2026. | WooCommerce |
| **2.0.37** | **29.05.2026.** | aktualna verzija |

Ukupno: **28 izdanja / ~3,5 godine** razlike. U razdoblju od 2023. do 2026. tema je dobila **dva izričita sigurnosna izdanja** (2.0.28 — 25.04.2025., 2.0.33 — 01.10.2025.) i više iteracija PHP kompatibilnosti — nijedno nije na siteu.

### 2.2. Deklarirana kompatibilnost verzije 2.0.37

| Stavka | Deklarirano |
|---|---|
| WordPress | 6.2.x – **7.0.x** |
| WooCommerce | 6.x – **10.x** |
| Elementor / Elementor Pro | da (bez verzije) |
| WPML | da |
| Zadnja objava | 29.05.2026. |

To je **ključna informacija za planiranje**: proizvođač *nije* deklarirao WP 7.1.x ni WooCommerce 11.x. Realan, podržan cilj je **WP 7.0.7 + WooCommerce 10.9.4**; 7.1.3 i 11.2.1 idu u drugi val, nakon testiranja.

### 2.3. Zašto WordPress ne vidi nove verzije teme

Tema se prodaje isključivo na ThemeForstu i **u sebi nema vlastiti update checker** (provjereno: nema reference na Envato, `purchase_code` ni update API). Posljedice:

- WordPress.org update kanal ne postoji za komercijalne teme,
- bez dodatka **Envato Market** (ili ručne nadogradnje paketom) i **valjane kupovine** vezane na korisnički račun, „Ažuriranja" nikad ne pokaže novu verziju,
- `auto_update: Onemogućeno` za temu je posljedica, ne uzrok.

To je klasičan scenarij u kojem tema *izgleda* napušteno, a zapravo je kanal distribucije prekinut (promjena agencije, izgubljeni ThemeForest račun, preseljenje hostinga…).

**Akcijski punkt:** pronaći ThemeForest račun na kojem je kupljena licenca (item 31127579). Licenca uključuje *„Future updates"* — dakle **2.0.37 se može skinuti bez novog plaćanja**. Ako račun nije dostupan, vidi poglavlje 8.

### 2.4. Gdje se vidi licenca (i gdje se **ne** vidi)

**U WordPress administraciji je nema — nigdje.** Provjereno na kodu teme 2.0.9 i na bundlanom *Apus Frameworku* 2.2:

| Mjesto u WP-u | Ima li licence |
|---|---|
| *Izgled → Teme → Detalji teme* | ne — samo `Theme URI`, autor i GPL napomena iz `style.css` |
| *Apus Framework → Theme Options* (`uomo_theme_options`, Redux) | ne — nema polja `license` / `purchase_code` / `envato` |
| *Dodaci* | nema **Envato Market** (nije na popisu instaliranih) |
| *Alati → Zdravlje sajta* | ne |
| Kod teme | nema `theme-update-checker`, nema `pre_set_site_transient_update_themes`, nema reference na Envato/purchase code |

Dakle: **ne postoji „ključ" koji bi se negdje upisao.** Uomo se ne registrira i ne provjerava licencu — zato nema ni ekrana na kojem bi se vidjela.

**Gdje je stvarno:** na **Envato/ThemeForest računu** s kojeg je tema kupljena.

1. Prijava na https://themeforest.net → gore desno **Account → Downloads**
2. Nađi **Uomo – Multipurpose WooCommerce WordPress Theme** (item `31127579`) → gumb **Download**
3. Ispod gumba **„License certificate & purchase code"** → PDF/TXT — to je jedini dokument koji se naziva „licencom" (sadrži: kupca, datum, vrstu licence, *Item License Code*)
4. Za dokaz o kupnji: **Account → Statements** (računi)

**Što vam treba za nadogradnju:** samo pristup tom računu i **Download** (licenca uključuje *Future updates* neograničeno — podrška od 6 mjeseci je odvojena stvar i njeno istekom **ne** gubite pravo na nove verzije). „Purchase code" se **ne upisuje** u Uomo; koristi se samo kod Envato Market dodatka — a i on traži **Personal API token** (*Settings → API Keys*), ne purchase code.

**Ako se račun ne zna**, redom:

1. Pretražiti e-mail (vlasnik, bivši izvođač, `info@`) po: `ThemeForest`, `Envato`, `Uomo`, `31127579` — potvrda o kupnji dolazi na e-mail.
2. Pitati agenciju/developera koji je gradio site — kupnja je najčešće na **njihovom** računu; dovoljno je da vam pošalju ZIP 2.0.37 (ili da vas dodaju kao korisnika).
3. Pogledati stare backupe i dokumentaciju projekta (Duplicator arhive, `~/backup`, e-mail arhiva) — ZIP originala često je negdje pohranjen.
4. Kontaktirati **ApusTheme** (preko profila na ThemeForstu ili `apusthemes.com`) s dokazom o kupnji — mogu potvrditi kupca, ali ne mogu „vratiti" licencu bez računa.
5. Ako ništa ne uspije: nova **Regular** licenca je **59 USD** — i dalje jeftinije od zamjene teme.

**Provjera na serveru (WP-CLI):**

```bash
wp plugin list --field=name | grep -i envato        # je li Envato Market instaliran
wp theme list --fields=name,version,status          # verzija teme
wp option get uomo_theme_options --format=json | grep -iE "licen|purchase|envato"   # očekivano: prazno
```

**Napomena o vrsti licence:** za jedan webshop je dovoljna **Regular License** (jedan krajnji proizvod, korisnici ne plaćaju pristup). **Extended** (1.100 USD) treba samo ako se tema naplaćuje krajnjim korisnicima kao dio proizvoda — za vaš slučaj nije potrebna.

---

## 3. Stanje sustava i „crvene zastavice" iz Site Healtha

### 3.1. Verzije

| Komponenta | Instalirano | Aktualno (21.10.2026.) | Zaostajanje |
|---|---|---|---|
| WordPress | **6.1.15** | 7.1.3 (grana 7.0 → 7.0.7; grana 6.9 → 6.9.10) | **EOL grana** — više nema sigurnosnih zakrpa |
| PHP | 8.2.34 | 8.3 / 8.4 (8.2 EOL **31.12.2026.**) | nedostaje ~3 mjeseca do EOL-a |
| MySQL | 8.4.11 | OK (WP preporuka 8.0+) | — |
| Uomo (parent) | **2.0.9** (07.11.2022.) | 2.0.37 (29.05.2026.) | 28 izdanja |
| Uomo Child | 1.0.0 | — (child se ne ažurira) | — |
| WooCommerce | **7.4.2** | 11.2.1 (10.x → 10.9.4) | 3 glavne verzije |
| Elementor | **3.11.4** | 4.3.5 (3.x linija završila na 3.35.9) | 1 glavna + ~24 minor |
| Apus Framework | **2.2** (Redux 4.1.24) | u paketu 2.0.37 | 3,5 g |
| Slider Revolution | **6.5.31** | ~6.7.x | stariji od *bundlanog* 6.6.5 u vašoj temi (!) |
| Wordfence | 8.2.2 | 9.0.2 | 1 glavna |
| CMB2 | 2.10.1 | 2.13.4 | — |
| Complianz | 7.5.0 | 7.5.6 | — |
| CookieYes | 3.5.3 | 3.5.7 | — |
| CorvusPay | 2.5.1 | 2.7.7 | 2 minor, ali plaćanja |
| Variation Swatches | 2.1.8 | 2.2.9 | — |
| Ajax add to cart | 2.0.2 | 2.6.7 | — |
| CAPTCHA 4WP | 7.6.0 | 7.6.2 | — |
| WP Importer | 0.9.5 | 0.9.7 | — |

### 3.2. Serverske postavke koje će ugroziti nadogradnju

| Postavka | Sada | Zašto je problem | Preporuka |
|---|---|---|---|
| `WP_MEMORY_LIMIT` | **40M** | WooCommerce + Elementor + WP 7.x rutinski prelaze 40M → bijeli ekran / „out of memory" upravo tijekom nadogradnje | **256M** (min. 128M) |
| `file_uploads` | **Off** | onemogućuje medijske uploade, uvoz dema, *upload .zip teme kroz admin* i restore backupa | **On** (potvrditi s hostingom) |
| `max_execution_time` | **60** | DB migracije WP-a, WC update i regeneracija sličica padaju na timeoutu | 300 (barem tijekom nadogradnje) |
| `maintenance.php` drop-in | **prisutan** | ako sadrži `$upgrading`, posjetitelji vide 503; ako je ostao od stare nadogradnje — smeće | pregledati sadržaj i ukloniti |
| `WP_DEBUG_DISPLAY` | On / `WP_DEBUG` Off | ako se debug uključi, PHP greške idu *posjetiteljima* u HTML | `WP_DEBUG_DISPLAY=false`, `WP_DEBUG_LOG=true` na stagingu |
| `WP_CACHE` | false | nema full-page cachea (LiteSpeed hosting) | opcionalno uvesti nakon stabilizacije |
| Auto-update | **Onemogućeno na svih 27+ zapisa** | sigurnosne zakrpe ne dolaze | nakon stabilizacije upaliti za niskorizične dodatke |

### 3.3. Sadržajne/konfiguracijske anomalije

- **Dva aktivna dodatka za kolačiće** — Complianz **i** CookieYes. Dvostruki banneri, dvostruki zapisi privola, konfliktni JS. Ovo treba riješiti **prije** nadogradnje (GDPR rizik, a i otežava dijagnostiku JS grešaka).
- **Dva sigurnosna sloja** — Wordfence 8.2.2 + Imunify 4.1.3 (+ Imunify mu-plugin). Kombinacija je legitimna (host + aplikacija), ali Wordfence 8.2.2 je 2024. verzija.
- **Neaktivan `MX WooCommerce HRK + EUR` 3.2** — Hrvatska je u eurima od 2023.; dodatak obrisati (mrtvi kod, potencijalni konflikt pri budućem aktiviranju).
- **Neaktivni Apus dodaci** (Lookbook, Ourstores, Salespopup) i **WordPress Importer** — produkcijski site ne treba ni jedno; ukloniti ili eksplicitno dokumentirati.
- 244 korisnika, komentari otvoreni — provjeriti spam površinu, ali nije blokada za nadogradnju.

---

## 4. Tehnička kompatibilnost verzije 2.0.9 s ciljnim stackom

### 4.1. WooCommerce: 24 od 40 overridea je zastarjelo

Tema nosi **81 WooCommerce datoteku**, od čega se **40** preklapa s core predlošcima. Usporedba `@version` zaglavlja:

| Ciljni WooCommerce | Zastarjelih overridea | Napomena |
|---|---|---|
| **7.4.1** (današnje stanje) | **2** (`cart/cart.php`, `order/form-tracking.php`) | sustav trenutno radi; odstupanja su kozmetička |
| **10.9.4** (preporučeni cilj) | **24** | ozbiljno |
| **11.2.1** (najnoviji) | **25** | ozbiljno |

Najkritičnije (tema → core):

| Predložak | Tema | WC 10.9.4 | Rizik |
|---|---|---|---|
| `checkout/form-checkout.php` | **3.5.0** | 9.4.0 | struktura checkouta, redoslijed hookova |
| `checkout/payment.php` | 7.0.1 | 9.8.0 | **plaćanje** (CorvusPay!) |
| `checkout/thankyou.php` | 3.7.0 | 8.1.0 | potvrda narudžbe, analitika |
| `cart/cart.php` | 7.0.1 | 10.8.0 | košarica |
| `cart/mini-cart.php` | 5.2.0 | 10.0.0 | AJAX fragmenti mini-košarice |
| `single-product/product-image.php` | 3.5.1 | 10.5.0 | galerija, zoom, varijable |
| `single-product/product-thumbnails.php` | 3.5.1 | 9.8.0 | galerija |
| `single-product/meta.php` | 3.0.0 | 9.7.0 | SKU/kategorije |
| `single-product-reviews.php` | 4.3.0 | 9.7.0 | recenzije |
| `myaccount/*` (5 datoteka) | 2.6.0–7.0.1 | 7.8.0–10.5.0 | moj račun, prijava, adrese |
| `content-product.php` | 3.6.0 | 9.4.0 | prikaz u petlji (list/grid) |
| `loop/add-to-cart.php`, `orderby.php`, `pagination.php` | 3.3–3.6.0 | 9.2–9.7.0 | filteri, sortiranje |
| `single-product/related.php`, `up-sells.php`, `tabs.php`, `cart/cross-sells.php` | 3.0–4.4.0 | 9.6–10.3.0 | preporuke, tabovi |

**Što to konkretno znači:** override u temi *zamjenjuje* core predložak. Dok se ne uskladi, WooCommerce 10.x/11.x ponašat će se po pravilima iz 2022. — bez novih filtera, bez novih hookova, bez promjena u načinu ispisa cijena/poreza i bez novih sigurnosnih provjera (nonce/escaping) koje je core u međuvremenu dodao.

### 4.2. Hookovi koje core poziva, a override ne

Ovo je ono što „tiho" lomi dodatke — dodatak se zakači na hook koji u vašem predlošku **ne postoji**, pa se njegov output nikad ne ispiše:

| Predložak | Hookovi koji nedostaju |
|---|---|
| `cart/cart.php` | `woocommerce_before_cart_collaterals` |
| `cart/mini-cart.php` | `woocommerce_before_mini_cart_contents`, `woocommerce_mini_cart_contents`, `woocommerce_mini_cart_item_class` |
| `checkout/form-checkout.php` | `woocommerce_checkout_before_order_review_heading` |
| `checkout/thankyou.php` | `woocommerce_before_thankyou`, `woocommerce_thankyou_order_failed_text` |
| `single-product/product-image.php` | `woocommerce_product_thumbnails_columns`, `woocommerce_single_product_video_thumbnail_html` |
| `single-product/meta.php` | `woocommerce_product_meta_category_orderby` |
| `single-product/related.php` / `up-sells.php` / `cross-sells.php` | `*_products_heading` (4 hooka) |
| `myaccount/form-edit-account.php` | `woocommerce_edit_account_form_fields`, `woocommerce_edit_account_form_tag` |
| `myaccount/my-address.php` | `woocommerce_my_account_after_my_address` |
| `single-product-reviews.php` | `woocommerce_reviews_title` |
| `single-product/review.php` | 6 review hookova |
| `single-product.php` | `woocommerce_before_main_content`, `woocommerce_after_main_content`, `woocommerce_sidebar` |

Kod `single-product.php` tema je svjesno zamijenila standardni wrapper s `woocommerce_content()`, pa se npr. breadcrumb, sidebar i wrapper dodataka hookani na `woocommerce_before_main_content` **ne izvršavaju na stranici proizvoda**. To nije novo (tako je od 1.6.4), ali je važno znati kada testirate nove dodatke.

> Napomena: predlošci `archive-product.php` i `content-product.php` također „izgledaju" kao da im nedostaju hookovi, ali oni delegiraju na `archive-product-full.php` / `item-product/*.php`, gdje hookovi **postoje**. Alat u prilogu to ispravno preskače.

### 4.3. PHP 8.2 / 8.3 / 8.4

Dobra vijest: u kodu teme i u bundlanom *Apus Frameworku* **nema** tvrdih PHP 8 breakera — nema `create_function`, `each()`, `ereg*`, `mysql_*`, `utf8_encode/decode`, `strftime`, `FILTER_SANITIZE_STRING`. Alat u prilogu to potvrđuje na svakom novom paketu.

Loša vijest: to je nužan, ali ne i dovoljan uvjet. Praktični rizici su drugi:

1. **Verzija 2.0.13 (06/2023) eksplicitno je „Updated PHP version"** — dakle PHP 8.x prilagodbe su došle *poslije* vaše verzije. Vaša 2.0.9 je iz listopada 2022., a site već sada radi na **PHP 8.2**, koji je u vrijeme WP 6.1 bio tek u beta podršci (puna podrška došla je kroz kasnija izdanja). To danas „radi" jer je `WP_DEBUG` isključen i deprecation poruke se ne prikazuju — one i dalje postoje.
2. **Apus Framework 2.2** (unutar njega Redux 4.1.24) je najstariji dio stacka i glavni kandidat za deprecation poplavu na PHP 8.3/8.4. Framework je u TGM konfiguraciji označen kao `required` i nosi *Theme Options* — ako pukne, puca admin.
3. **Ostali dodaci** (ACF 6.0.7, Elementor 3.11.4, CMB2 2.10.1, RevSlider 6.5.31, Yoast 20.2.1) stariji su od PHP 8.3/8.4 podrške. PHP 8.3/8.4 dolazi **tek nakon** što se ovi dodaci ažuriraju.

**Preporuka:** PHP podizati u dva koraka — 8.2 tijekom nadogradnje WP/WC/teme (najmanje varijabli), pa 8.3 nakon što sve radi (8.2 EOL je 31.12.2026.). 8.4 tek kad proizvođači potvrde.

### 4.4. Elementor — ovdje je pravi blokator

Elementor je u međuvremenu **uklonio `Elementor\Core\Schemes\*` klase** (najavljeno 2020., uklonjeno u **3.26**, potvrđeno da ih nema ni u 4.0.8 ni u 4.3.5). Tema 2.0.9 ih koristi:

```
inc/vendors/elementor/widgets/heading.php:235-249   Core\Schemes\Color::get_type(), Core\Schemes\Typography::TYPOGRAPHY_1
inc/vendors/elementor/widgets/team.php:139-140      Core\Schemes\Color::get_type()
```

Te reference se izvršavaju u `_register_controls()`, tj. **kada Elementor gradi kontrole widgeta**. Posljedica na Elementor ≥ 3.26:

- otvaranje **Apus Heading** ili **Apus Team** widgeta u editoru → `Error: Class "Elementor\Core\Schemes\Color" not found` (bijeli ekran editora / „Widget je uklonjen"),
- frontend obično ostaje dostupan (jer se kontrole ne grade pri renderu), ali svaka operacija koja gradi kontrole (editor, dinamički CSS u nekim postavkama) pada.

Ostali Elementor API-ji koje tema koristi **još postoje** u 4.3.5, pa nema drugih tvrdih padova:

| API | Status u Elementor 4.3.5 |
|---|---|
| `widgets_manager->register_widget_type()` | postoji, **deprecated od 3.5** → delegira na `register()`, puni `debug.log` |
| `elementor/elements/categories_registered` | postoji |
| `elementor/controls/controls_registered` | postoji (i dalje se izvršava) |
| `Controls_Manager::get_control()` | postoji |
| `Elementor\Core\Files\CSS\Post` | postoji |

Dodatno, **Elementor 4.0 (04/2026) je arhitektonska promjena** (Atomic Editor): legacy V3 widgeti se i dalje renderiraju, ali CSS koji targetira V3 klase (`.elementor-widget-container`) postaje rizik — Elementor ga je označio deprecated s najavom uklanjanja u 3.36. Provjereno: **tema ne targetira te klase**, pa je taj rizik nizak.

**Zaključak:** verzija 2.0.9 i Elementor 4.x **ne idu zajedno**. Elementor se ne smije ažurirati prije teme.

### 4.5. WordPress 7.x

WP 7.x donosi (relevantno za ovu temu):

- **7.0** je podigao minimum PHP-a na 7.4 (vi ste na 8.2 — OK),
- **7.1** (19.08.2026.) uvodi *uvijek iframed* post editor; to pogađa meta-boxeve i skripte koje ciljaju editor canvas — relevantno za **ACF 6.0.7** i **CMB2 2.10.1**, ne za samu temu,
- jQuery **3.7.1 + Migrate 3.4.1** su još uvijek u core-u (potvrđeno u 7.1.3), pa legacy JS radi,
- preporuka WP-a: **PHP 8.3+**, MySQL 8.0+ (vi ste na MySQL 8.4 — OK).

Sama tema je klasična (ne blok) tema i nema `theme.json`, što na WP 7.x nije problem — ali znači i da neće koristiti nove mogućnosti (responsive styles i sl.).

### 4.6. JavaScript

Dva legacy jQuery poziva u `js/functions.js` (linije ~388 i ~400):

```js
$(this).load(function() { ... });   // uklonjeno u jQuery 3.0
```

Radi **isključivo zahvaljujući jQuery Migrate** koji WordPress još isporučuje. WP je uklanjanje Migratea najavljivao više puta — kada se to dogodi, „lazy load" slika prestaje označavati učitane slike. Popravak je trivijalan (`$(this).on('load', function(){...})`), ali ga **ne treba raditi u child temi** — u 2.0.37 je vjerojatno već riješen (changelog 2.0.29: *„Updated JavaScript"*). Provjeriti alatom nakon nadogradnje.

### 4.7. Bundlani dodaci — najveći „skriveni" dio teme

Tema u `inc/plugins/` nosi ZIP-ove i TGM ih nudi kao **required**:

| Bundlano | Verzija u temi 2.0.9 | Napomena |
|---|---|---|
| Apus Framework | **2.2** (Redux 4.1.24) | nosi Theme Options; *required*; mora doći iz paketa 2.0.37 |
| Slider Revolution | **6.6.5** (u ZIP-u) | na siteu je **6.5.31** — dakle *starije od onoga što tema već nosi* |
| Apus Lookbook / Ourstores / Salespopup / Sizeguides | 1.0.0 | neaktivni; 2021. kod |

Dvije važne implikacije:

1. **RevSlider se ne može ažurirati neovisno** — to je komercijalni dodatak vezan na licencu; bundlana kopija se osvježava samo s temom. Verzije 6.5.x/6.6.x imaju bogatu povijest sigurnosnih popravaka — ovo je jedan od jačih argumenata za nadogradnju teme.
2. **Apus Framework 2.2 + WP 7.x** je kombinacija koju nitko nije testirao. Novi paket teme nosi novi framework; **stari framework se mora zamijeniti**, ne samo „ostaviti".

---

## 5. Matrica: što s čim radi

| Kombinacija | Ocjena | Obrazloženje |
|---|---|---|
| **Danas:** WP 6.1.15 + WC 7.4.2 + EL 3.11.4 + tema 2.0.9 | ⚠️ radi, nesigurno | 2 zastarjela overridea; sve komponente izvan sigurnosne podrške |
| Tema **2.0.9** + WP 7.0/7.1 + WC 10/11 + EL 4.x | ❌ **ne** | 24–25 zastarjelih overridea + Elementor `Schemes` fatal |
| Tema **2.0.37** + WP 7.0.7 + WC 10.9.4 + EL 4.3.5 | ✅ **preporučeno** | unutar deklarirane podrške proizvođača (WP ≤ 7.0, WC ≤ 10) |
| Tema 2.0.37 + WP **7.1.3** + WC **11.2.1** | ⚠️ rizično | izvan deklarirane podrške; WC 11 traži WP 7.0+ i nije deklariran |
| Tema 2.0.37 + PHP 8.3 | ✅ nakon testiranja | tema deklarira PHP kroz izdanja 2023+, provjeriti alatom |
| Tema 2.0.37 + PHP 8.4 | ⏳ kasnije | 8.4 traži potvrdu ApusThemea |

Napomena: **WC 11.2.1 zahtijeva WP 7.0+**, a **WC 10.9.4 zahtijeva WP 6.9+** (oba traže PHP 7.4+). To znači i da „ostanak na WP 6.1" dugoročno nije opcija ako želite aktualni WooCommerce.

---

## 6. Dodaci: matrica rizika (23 aktivna + 4 neaktivna)

| # | Dodatak | Instalirano | Aktualno | Rizik | Što konkretno provjeriti |
|---|---|---|---|---|---|
| 1 | **WooCommerce** | 7.4.2 | 11.2.1 (cilj 10.9.4) | 🔴 visok | DB migracije, HPOS, status predložaka, blok košarica/checkout |
| 2 | **Apus Framework** | 2.2 | iz paketa 2.0.37 | 🔴 visok | Theme Options (Redux), megamenu, header/footer builder |
| 3 | **Elementor** | 3.11.4 | 4.3.5 | 🔴 visok | Apus widgeti, header/footer predlošci, regen. CSS-a |
| 4 | **CorvusPay Gateway** | 2.5.1 | 2.7.7 | 🔴 visok | **plaćanje** — test u sandboxu, HPOS, blok checkout |
| 5 | **MBE eShip** | 2.7.2 | provjeriti | 🔴 visok | izračun dostave, export naljepa, HPOS |
| 6 | **Slider Revolution** | 6.5.31 | ~6.7.x | 🟠 srednji | sigurnosne zakrpe; update ide s temom |
| 7 | **Wordfence** | 8.2.2 | 9.0.2 | 🟠 srednji | skok na 9.x (WAF pravila, scan) |
| 8 | **Really Simple SSL** | 6.2.2 | 9.x | 🟠 srednji | skok 3 glavne verzije; na LiteSpeedu s ispravnim SSL-om razmisliti o uklanjanju |
| 9 | **ACF** | 6.0.7 | provjeriti | 🟠 srednji | polja u header/footer builderu, iframed editor u WP 7.1 |
| 10 | **Yoast SEO** | 20.2.1 | provjeriti | 🟠 srednji | sitemap, schema, redirecti nakon promjene permalinka |
| 11 | **Ajax add to cart** | 2.0.2 | 2.6.7 | 🟠 srednji | konflikt s WC AJAX-om, varijable, mini-cart |
| 12 | **Variation Swatches** | 2.1.8 | 2.2.9 | 🟠 srednji | prikaz swatcheva u petlji i na produktu |
| 13 | **YITH Wishlist** | 3.18.0 | provjeriti (4.x?) | 🟠 srednji | tema overridea `wishlist-view-*.php` po YITH 3.0 predlošku |
| 14 | **Complianz** | 7.5.0 | 7.5.6 | 🟠 srednji | **duplikat s CookieYesom — riješiti prije** |
| 15 | **CookieYes** | 3.5.3 | 3.5.7 | 🟠 srednji | isto |
| 16 | **CAPTCHA 4WP** | 7.6.0 | 7.6.2 | 🟢 nizak | CF7 forme |
| 17 | **Contact Form 7** | 5.7.4 | provjeriti | 🟠 srednji | 5.7 → 6.x; provjeriti forme i `wpcf7` markup |
| 18 | **Flamingo** | 2.3 | provjeriti | 🟢 nizak | spremanje poruka |
| 19 | **CMB2** | 2.10.1 | 2.13.4 | 🟢 nizak | meta boxevi u iframed editoru |
| 20 | **Duplicator Pro** | 4.5.20.1 | provjeriti licencu | 🟠 srednji | **backup prije svega**; provjeriti valjanost licence za update |
| 21 | **Imunify Security** | 4.1.3 | host | 🟢 nizak | update kroz hosting |
| 22 | **Loco Translate** | 2.6.4 | provjeriti | 🟢 nizak | hrvatski prijevodi teme/dodataka nakon updatea |
| 23 | **WP Importer** | 0.9.5 | 0.9.7 | ⚪ | nepotreban na produkciji |
| — | Apus Lookbook / Ourstores / Salespopup | 1.0.0 | — | 🟠 | neaktivni; ukloniti ili ažurirati iz novog paketa |
| — | MX WooCommerce HRK + EUR | 3.2 | — | ⚪ | **obrisati** (HRK napušten 2023.) |

---

## 7. Verdikt — 3 scenarija

### Scenarij A — Nadogradnja postojeće teme (PREPORUČENO)

**Što:** skinuti Uomo 2.0.37 (licenca), zamijeniti parent temu i **Apus Framework**, zadržati child temu, uskladiti WooCommerce predloške, zatim WP 7.0.7 + WC 10.9.4 + Elementor 4.3.5, potom PHP 8.3.

**Prednosti:** čuva dizajn, Elementor predloške, header/footer builder, sve prilagodbe; proizvođač je aktivan (zadnja objava 05/2026); minimalan rizik za SEO i konverzije; trošak = radno vrijeme, bez nove licence.

**Rizici:** child tema može sadržavati zastarjele kopije predložaka (moraju se pregledati); Theme Options (Redux) mogu zahtijevati ponovno spremanje; moguće kozmetičke razlike nakon promjene CSS-a.

**Trajanje:** ~3–5 radnih dana pripreme i testiranja + 2–3 h noćnog prozora za produkciju.

### Scenarij B — Zamjena teme

**Kada ima smisla:** ako se **ne može doći do licencirane 2.0.37**, ako se ionako planira redizajn, ili ako rezultati staging testova pokažu da 2.0.37 ne pokriva vaš stack.

**Što zahtijeva:** izbor nove teme (GeneratePress/Astra/Kadence/OceanWP ili neki Woo-specifičan), rebuild **svih** Elementor predložaka (header, footer, megamenu, 12 home pageova, lookbook, our stores), ponovno mapiranje ACF polja, ponovni rad na child temi, QA cijelog checkouta.

**Trajanje:** 3–6 tjedana. **Trošak:** nova licenca + značajan rad. **Rizik:** veći nego A.

### Scenarij C — Status quo (ne dirati)

**Ocjena:** kratkoročno tehnički moguće, strateški neodrživo. WP 6.1, WC 7.4 i Elementor 3.11 su izvan sigurnosne podrške; PHP 8.2 istječe 31.12.2026.; svaki novi dodatak (npr. novi način plaćanja) riskira da ne radi s ovim verzijama. Za webshop s plaćanjima to je otvorena izloženost.

### Preporuka

**A**, s jasnim uvjetom: **paket 2.0.37 mora biti dostupan s valjanom licencom**. Ako nije — prije bilo kakve odluke o scenariju B, kupiti novu licencu (59 USD, regular) jer je to najjeftiniji put do podržanog koda.

---

## 8. Slijed nadogradnje (sažetak — detalji u `PLAN-AZURIRANJA-UOMO.md`)

```
0. Preduvjeti      backup + snapshot, staging kopija, file_uploads=On, WP_MEMORY_LIMIT=256M
1. Higijena        ukloniti CookieYes ILI Complianz, MX HRK, WP Importer, maintenance.php
2. Tema            Uomo 2.0.9 → 2.0.37 + Apus Framework iz paketa → test (bez WP/WC updatea!)
3. WooCommerce     7.4.2 → 8.9.x → 9.9.x → 10.9.4 (u koracima), status predložaka = 0 zastarjelih
4. Elementor       3.11.4 → 4.3.5 (nakon teme!), regen. CSS-a, test svih Apus widgeta
5. WordPress       6.1.15 → 6.4 → 6.7 → 7.0.7 (u koracima), pa 7.1.x tek nakon potvrde
6. Ostali dodaci   po matrici iz poglavlja 6, jedan po jedan, s testom
7. PHP             8.2 → 8.3 (nakon stabilizacije), 8.4 kasnije
8. Produkcija      ponoviti isti slijed u noćnom prozoru + pushevi narudžbi u praznom hodu
9. Verifikacija    48 h monitoring, WooCommerce Status, log greške, testna narudžba
```

**Ključno pravilo redoslijeda:** **tema prije WooCommercea i Elementora; WooCommerce prije WordPressa; Elementor nakon teme; PHP na kraju.**

---

## 9. Rizici i mitigacije

| Rizik | Vjerojatnost | Utjecaj | Mitigacija |
|---|---|---|---|
| Checkout/plaćanje pukne nakon WC updatea | srednja | 🔴 gubitak prodaje | staging + sandbox CorvusPay + testna narudžba prije prebacivanja |
| Elementor editor „bijeli ekran" | **visoka** ako se preskoči redoslijed | 🟠 blokira uređivanje | tema prije Elementora; `Schemes` grep u auditu |
| Child tema „pregazi" novu parent temu | srednja | 🟠 neočekivan izgled | inventar child overridea prije updatea |
| Nedostatak memorije (40M) tijekom updatea | **visoka** | 🔴 prekid nadogradnje | `WP_MEMORY_LIMIT=256M` prije svega |
| Restore backupa nemoguć zbog `file_uploads=Off` | srednja | 🔴 otežan rollback | uključiti `file_uploads` i **testirati restore** prije početka |
| Gubitak Theme Options / header-footera | srednja | 🟠 vizualni lom | export Redux opcija + backup `wp_options`, `apus_header`/`apus_footer` postova |
| SEO pad zbog izmjene URL-ova/šablona | niska | 🟠 promet | ne dirati permalink strukturu; Yoast redirecti; sitemap provjera |
| Dupli consent banneri | već prisutno | 🟠 GDPR | riješiti u koraku 1 |

**Rollback:** host-level snapshot (preporučeno) + Duplicator arhiva + `wp db export` prije svake faze. Rollback se radi na razini **cijelog sitea**, ne pojedinačno — zato staging.

---

## 10. Što nije bilo moguće provjeriti bez pristupa (i kako to zatvoriti)

| Stavka | Zašto | Kako provjeriti |
|---|---|---|
| Sadržaj **child teme** `uomo-child` | nije u repozitoriju (samo parent) | `find wp-content/themes/uomo-child -type f` + `tools/audit-uomo-compat.sh` |
| Stvarni kod **2.0.37** | plaćeni paket | nakon skidanja: `tools/audit-uomo-compat.sh` na novi paket |
| **HPOS** status (High-Performance Order Storage) | nije u Site Healthu | `wp wc hpos status` / WooCommerce → Status |
| Licence (Duplicator Pro, CorvusPay, MBE, RevSlider) | nije vidljivo iz izvještaja | administracija dodataka |
| Sadržaj `maintenance.php` drop-ina | nije prikazan | `cat wp-content/maintenance.php` |
| Realno ponašanje nakon updatea | zahtijeva okruženje | staging s istom kopijom baze |

---

## 11. Prilog: alat za vlastitu provjeru

Uz ovaj dokument ide skripta **`tools/audit-uomo-compat.sh`** koja na bilo kojem paketu teme (stara verzija, nova 2.0.37, child tema) ponavlja ovu analizu:

```bash
# na serveru, iz korijena WordPressa
bash tools/audit-uomo-compat.sh wp-content/themes/uomo wp-content/plugins/woocommerce
# s child temom
bash tools/audit-uomo-compat.sh wp-content/themes/uomo wp-content/plugins/woocommerce wp-content/themes/uomo-child
```

Provjerava: deklarirane verzije, **zastarjele WooCommerce predloške** (usporedba `@version` s instaliranim WC-om), **hookove koji nedostaju**, korištenje **uklonjenih Elementor klasa**, deprecated Elementor API, PHP 8.x obrasce, legacy jQuery, overridee u child temi. Izlazni kod je `1` ako postoji blokirajući nalaz — pogodno za CI ili za „gate" prije puštanja na produkciju.

Rezultat na vašoj trenutnoj temi (v2.0.9) uz WC 10.9.4: **24 zastarjela overridea, 2 FAIL (Elementor Schemes), 13 upozorenja na hookove.**

---

## 12. Sažeta preporuka

1. **Temu zadržati.** Nije napuštena — samo nije ažurirana na siteu.
2. **Odmah osigurati paket 2.0.37** putem ThemeForest licence (bez novog plaćanja) ili, ako licence nema, kupiti (59 USD).
3. **Nadograditi temu + Apus Framework prvo**, na stagingu, i pokrenuti audit skriptu — cilj: 0 zastarjelih overridea, 0 `Schemes` referenci.
4. Zatim **WooCommerce 10.9.4** (u koracima) i **Elementor 4.3.5**, pa **WP 7.0.7**.
5. **WP 7.1.x, WooCommerce 11.x i PHP 8.3/8.4** u drugi val, nakon potvrde proizvođača i stabilnog rada.
6. Prije svega: `WP_MEMORY_LIMIT` 256M, `file_uploads` On, testiran rollback, jedan (ne dva) consent dodatka.

Ako se u koraku 3 pokaže da 2.0.37 ima nove blokade (npr. i dalje koristi `Schemes`), tada — i samo tada — otvara se **scenarij B (zamjena teme)** s procjenom 3–6 tjedana.

---

## 13. Izvori

- ThemeForest — Uomo (item 31127579), changelog i deklarirana kompatibilnost: https://themeforest.net/item/uomo-multipurpose-woocommerce-wordpress-theme/31127579
- WooCommerce izvorni kod i predlošci (tagovi 7.4.1, 10.9.4, 11.2.1): https://github.com/woocommerce/woocommerce
- Elementor izvorni kod (4.0.8, 4.3.5) — provjera `register_widget_type`, `controls_registered`, uklanjanje `Core\Schemes`: https://github.com/elementor/elementor
- WordPress core (7.1.3) — `wp-includes/version.php` (PHP 7.4+, MySQL 5.5.5+), jQuery 3.7.1 + Migrate 3.4.1: https://github.com/WordPress/WordPress
- WordPress 7.1 Field Guide: https://make.wordpress.org/core/2026/08/05/wordpress-7-1-field-guide/
- WordPress 7.1 — kompatibilnost servera i PHP matrica (8.2 EOL 31.12.2026.): https://make.wordpress.org/hosting/handbook/compatibility/version/7-1/
- Elementor — deprecations (`.elementor-widget-container`, uklanjanje Schemes): https://developers.elementor.com/recent-deprecations/
- Elementor 4.0 developers update: https://developers.elementor.com/elementor-editor-4-0-developers-update/
- Site Health izvještaj (dostavio naručitelj, 21.10.2026.)
