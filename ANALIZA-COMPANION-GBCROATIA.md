# Companion @ gbccroatia (staging) — može li sve na najnovije bez diranja teme?

**Site:** `dev.michel.hr/gbccroatia` (`/home/michelwe/public_html/dev/gbccroatia`)
**Okruženje:** staging · WordPress **6.8.1** · PHP **8.2.34** · MySQL **8.4.11** · LiteSpeed
**Tema:** Companion **1.0.8** + `companion-child-theme` 1.0.0
**Dodataka:** 36 aktivnih + 4 neaktivna
**Datum analize:** 21.10.2026.

---

## 0. Odgovor

**Da — i pitanje je zapravo lakše nego što izgleda: tema je već na zadnjoj verziji.**

Companion 1.0.8 je ujedno **zadnje izdanje na ThemeForstu** (4. travnja 2024.). Nema novije verzije teme koju biste mogli instalirati — dakle “update bez updatea teme” nije kompromis, nego **jedini mogući put** (osim zamjene teme).

Ali postoje **dvije stvari koje se moraju odmah**:

| # | Nalaz | Zašto je hitno |
|---|---|---|
| **1** | **`Companion Configurations` je 1.0.3** (zadnja 1.0.6) | Tema 1.0.6 (28.08.2023.) donijela je *„Fixed: Broken Access Control vulnerability“* i podigla Configurations na **1.0.4**. Vaša 1.0.3 je **starija od te zakrpe** → vjerojatno ste još izloženi (provjeriti changelog u adminu) |
| **2** | **`Companion Elementor Widgets` je 1.0.4** (zadnja 1.0.5) | Widgeti koje Elementor koristi; 1.0.5 je iz paketa 1.0.8 → mora se poklopiti s temom |

Oba se ažuriraju **bez** diranja teme (WordPress vam ih sam nudi — vidi “latest version” u izvještaju). To je najjeftinija i najkorisnija akcija u cijelom projektu.

**Preporučeni cilj:** WP **7.0.7** → kasnije **7.1.3** · Elementor + Pro **4.3.5** · PHP **8.3** · tema **ostaje 1.0.8** + njeni dodaci na 1.0.6 / 1.0.5.

---

## 1. Dobra vijest: Elementor rizik je manji nego što se činilo

U prethodnoj (generičkoj) analizi tri stvari su bile crvene: **Scheme klase**, **Swiper 5** i **Waypoints** — sve uklonjeno u Elementoru 3.26 / 3.24. Ključni podatak iz vašeg izvještaja:

> **Elementor i Elementor Pro su 3.28.4** — dakle **već su prošli 3.26**.

To znači da su Companion widgeti (1.0.4) **već dokazali** da ne ovise o uklonjenim Scheme klasama ni o Swiperu 5 — inače editor danas ne bi radio. Rizik se time svodi na ono što dolazi **poslije 3.28**:

| Promjena | Od 3.28 → 4.3.5 | Utjecaj | Kako provjeriti |
|---|---|---|---|
| **Optimized Markup** (uklanja `.elementor-widget-container` Elementorovim widgetima) | default od **3.32**, u core od **3.33** | 🟠 CSS koji targetira te klase može izgubiti stilove | vizualna usporedba stranica; audit skripta (5.5) |
| **Atomic Editor / V4** | 4.0 (03/2026.) | 🟢 V3 widgeti se i dalje rendaju; za tuđe widgete wrapper ostaje | otvoriti editor i sve Companion widgete |
| **Elementor Pro 4.x** | 4.x | 🟠 Pro widgeti (forms, loop, theme builder header/footer) — test obavezno | svaka Pro funkcionalnost koju koristite |
| **UAE 2.3.0 → 2.9.5** | — | 🟠 UAE 2.9.5 je **eksplicitno kompatibilan s Elementorom i Pro 4.3** (izdan 25.09.2026.) | update UAE **prije** Elementora |

> **Zaključak:** Elementor 4.3.5 je izvediv bez updatea teme. Redoslijed je bitan: **UAE → Elementor Pro → Elementor** (ili sve tri u istom prozoru, ali UAE prvi).

---

## 2. Matrica dodataka (36 aktivnih)

“Cilj” = zadnja verzija prema vašem izvještaju + provjere s weba (21.10.2026.).

### 2.1. Prvo (blokira sve ostalo ili je sigurnosno)

| Dodatak | Instalirano | Cilj | Rizik | Napomena |
|---|---|---|---|---|
| **Companion Configurations** | **1.0.3** | **1.0.6** | 🔴 | BAC ranjivost; dolazi iz paketa teme 1.0.8 |
| **Companion Elementor Widgets** | **1.0.4** | **1.0.5** | 🟠 | mora pratiti temu 1.0.8 |
| **Ultimate Addons for Elementor Lite** | 2.3.0 | **2.9.5** | 🟠 | 2.9.5 = kompatibilno s Elementor 4.3; **prije** Elementora |
| **Elementor Pro** | 3.28.4 | **4.3.5** | 🔴 | treba **valjana licenca** (vidi 4.2) |
| **Elementor** | 3.28.4 | **4.3.5** | 🔴 | nakon Pro-a ili istovremeno |
| **Slider Revolution** | 6.5.21 | ~6.7.x | 🔴 | više sigurnosnih popravaka od 6.5.x; **vlastita licenca** |
| **Really Simple Security** | 9.5.11 | 9.8.3 | 🟠 | sigurnosni dodatak → uvijek zadnji |
| **ACF PRO** | 6.8.10 | (aktivirati licencu) | 🟠 | **licenca nije aktivirana** → nema auto-updatea |

### 2.2. Sadržaj / funkcionalnost (testirati nakon)

| Dodatak | Instalirano | Cilj | Rizik | Što testirati |
|---|---|---|---|---|
| **Category Ajax Filter** | 2.8.4 | **3.1.2** | 🔴 | **3.0 je redizajn s novim React builderom** — filtri se možda moraju ponovno postaviti. Raditi odvojeno, uz backup |
| **E2Pdf** | 1.32.18 | 1.32.59 | 🔴 | generirani PDF-ovi (predlošci, fontovi, potpisi) — **najveći skok** |
| **Generate PDF using CF7** | 4.1.6 | 4.2.2 | 🟠 | PDF iz kontakt forme |
| **Contact Form 7** | 6.1.3 | 6.1.3 ✅ | 🟢 | trenutno je zadnji |
| **ProfilePress** | 4.16.7 | 4.17.7 | 🟠 | registracija/prijava — provjeriti koristi li se (`user_registration: 0`) |
| **ACF Photo Gallery Field** | 3.1 | — | 🔴 | **napušten od 10/2024.** → migrirati na **ACF Galerie 4** ili na ACF PRO nativno Gallery polje |
| **Advanced Custom Fields Multilingual** | 5.1.0 | 5.1.0 ✅ | 🟢 | WPML kompatibilnost |
| **WPML CMS / String Translation / CF7** | 5.1.0 | 5.1.0 ✅ (5.2 danas) | 🟢 | najsvježiji dio stacka — ne dirati u istom valu |
| **Yoast SEO** | 28.1 | ✅ | 🟢 | sitemap, schema nakon WP updatea |
| **Redirection** | 5.9.0 | 5.10.1 | 🟠 | izvoz pravila prije updatea |
| **TablePress** | 3.3.3 | 3.4.1 | 🟢 | tablice |
| **Breadcrumb NavXT** | 7.4.1 | 7.5.2 | 🟢 | |
| **Simple Download Counter** | 2.3.2 | 2.3.3 | 🟢 | |
| **Custom Icons for Elementor** | 1.0.6 | 1.0.7 | 🟢 | ikone nakon Elementor updatea |
| **Custom links in Elementor Image Carousel** | 1.1.1 | ? | 🟠 | mali dodatak, provjeriti radi li s Elementor 4 |
| **Widget Options** | 4.2.5 | ? | 🟢 | |
| **Adminimize** | 1.11.14 | ? | 🟠 | admin UI — osjetljivo na WP 7.1 |
| **Admin Bar & Dashboard Control** | 1.2.9 | ? | 🟠 | preklapa se s Adminimize |
| **Duplicate Page** | 4.5.9 | ? | 🟢 | dev alat |
| **Add From Server** | 3.4.5 | ? | 🟠 | dev alat, star; **isključiti na produkciji** |
| **Classic Editor / Classic Widgets** | 1.7.0 / 0.3 | ✅ | 🟢 | smanjuje izloženost WP 7.1 iframed editoru |
| **Duplicator Pro** | 4.5.20.1 | ? | 🟠 | **backup 10,4 GB** — provjeriti licencu i mjesto |
| **Envato Market** | 2.0.14 | ✅ | 🟢 | kanal za temu/dodatke s ThemeForsta |
| **Imunify Security** | 4.1.3 | host | 🟢 | |
| **ACF (free)** | 6.8.0 (neaktivan) | — | ⚪ | **obrisati** — dvije ACF instalacije u plugins folderu |
| **Loco Translate / OTGS Installer / SMTP Mailer** | neaktivni | — | ⚪ | SMTP Mailer se koristi? ako je aktivan u produkciji — provjeriti |

---

## 3. Nalazi iz Site Healtha koje treba popraviti (prije ili uz update)

| # | Nalaz | Zašto je važno | Akcija |
|---|---|---|---|
| 1 | **ACF PRO nije aktiviran** (`activated: false`, `license_type: undefined`) | nema auto-updatea ni podrške; ACF je temelj 4 field grupe + 1 CPT + 2 taksonomije | aktivirati licencu (*ACF → Updates*) ili prihvatiti ručne update |
| 2 | **Dvije ACF instalacije** (`advanced-custom-fields` 6.8.0 neaktivan + `advanced-custom-fields-pro` 6.8.10) | zbunjuje update kanal, zauzima prostor | obrisati free ACF |
| 3 | **`uploads` = 9,42 GB**, baza **503 MB** | Duplicator arhiva ~10 GB; backup traje i troši prostor | snapshot na hostu + provjeriti kvotu; razmisliti o isključivanju `uploads` iz arhive |
| 4 | **`advanced-cache.php` drop-in postoji, a `WP_CACHE` = false** | ostatak uklonjenog cache dodatka; može raditi “ništa” ili nešto nepredvidivo | pregledati sadržaj i obrisati ako je orphan |
| 5 | **Elementor Safe Mode mu-plugin** | netko je aktivirao sigurni mod (dijagnostika ranijeg problema) | ostaviti (bezopasno) ili obrisati nakon stabilizacije |
| 6 | `max_input_vars` = **10000** | Elementor/WPML stranice s puno polja mogu se “odsjeći” pri spremanju | po potrebi 20000 |
| 7 | `WP_ENVIRONMENT_TYPE: staging`, `blog_public: 0` | ✅ ispravno za staging — **ne smije se prenijeti na produkciju** | checklist pri migraciji |
| 8 | `WP_DEBUG: true`, `WP_DEBUG_DISPLAY: false`, log: on | ✅ idealno za staging | na produkciji: DEBUG false |
| 9 | PHP `memory_limit` 10 GB / `WP_MEMORY_LIMIT` 1024M | ✅ nema rizika za update | — |
| 10 | `WP_SITEURL` definiran (`dev.michel.hr/gbccroatia`), `WP_HOME` nije | migracija na produkciju zahtijeva izmjenu wp-config | zapisati u plan migracije |

### Provjera autoload opcija (baza 503 MB — najčešći krivac za spore updatee)

```sql
SELECT SUM(LENGTH(option_value))/1024/1024 AS mb_autoload, COUNT(*) AS opcija
FROM wp_options WHERE autoload = 'yes';

SELECT option_name, LENGTH(option_value)/1024 AS kb
FROM wp_options WHERE autoload = 'yes'
ORDER BY LENGTH(option_value) DESC LIMIT 20;
```

Ako je autoload > ~1 MB, uklonite/smanjite: `wp transient delete --expired`, Redirection logovi, WPML `icl_*` cache, Elementor `_elementor_*` tranzijenti.

---

## 4. Plan (staging je već tu — radimo na njemu)

### Faza 0 — priprema (30 min)

```bash
# backup prije svega (10 GB — koristiti host snapshot ako je moguć)
wp db export ~/gbc-pre-update-$(date +%F).sql
# snapshot na razini hostinga (preporučeno)

wp core version; wp theme list; wp plugin list --fields=name,version,status
wp plugin list --update=available --fields=name,version,update_version
bash tools/audit-theme-compat.sh wp-content/themes/companion wp-content/plugins/woocommerce "" 6.8.1
bash tools/audit-theme-compat.sh wp-content/plugins/companion-elementor-widgets
bash tools/audit-theme-compat.sh wp-content/plugins/companion-configurations
```

### Faza 1 — Companion dodaci (15 min, odmah)

```bash
wp plugin update companion-configurations   # 1.0.3 -> 1.0.6
wp plugin update companion-elementor-widgets # 1.0.4 -> 1.0.5
```
→ testiraj: otvori bilo koju stranicu s Companion widgetima u Elementor editoru.

### Faza 2 — Elementor obitelj (1 h)

1. `UAE Lite 2.3.0 → 2.9.5`
2. `Elementor Pro 3.28.4 → 4.3.5` (provjeri licencu prije)
3. `Elementor 3.28.4 → 4.3.5`
4. *Elementor → Alati → Regenerate CSS & Data*
5. Test: header/footer (theme builder), sve Companion widgete, UAE widgete, Pro forme i loop.

### Faza 3 — ostali dodaci (pojedinačno, uz test)

Prije svega **ne dirati u istom danu**: Category Ajax Filter (major 3.x), E2Pdf (veliki skok), ProfilePress.
Preporučeni redoslijed: sigurnosni i infrastrukturni (Really Simple Security, Redirection, Yoast, TablePress) → sadržajni (Breadcrumb, Simple Download Counter, Custom Icons) → **posebno** CAF → **posebno** E2Pdf + CF7 PDF.

### Faza 4 — WordPress

```bash
wp core update --version=6.9.4 --force && wp core update-db   # međukorak
wp core update --version=7.0.7 --force && wp core update-db
# 7.1.3 tek nakon što je 7.0.7 stabilan i Theme Options/metaboxi provjereni
```

Nakon svake stepenice: login, admin, **Theme Options**, metabox na stranici, Elementor editor, frontend, `debug.log`.

### Faza 5 — PHP 8.3

Tek kad je sve stabilno. 8.2 EOL je **31.12.2026.** → ima vremena, ali ne previše.

### Faza 6 — produkcija

Isti slijed, noćni prozor, uz: `blog_public` na 1, `WP_ENVIRONMENT_TYPE` na production, `WP_DEBUG` false, provjera `WP_SITEURL`/`WP_HOME`.

---

## 5. Acceptance checklist

- [ ] Elementor editor: **svaka** stranica koja koristi Companion widgete — bez greške, bez “widget nije dostupan”
- [ ] UAE widgeti + header/footer (theme builder)
- [ ] Pro forme → CF7 → PDF (E2Pdf i “Generate PDF”)
- [ ] Category Ajax Filter: filtriranje + paginacija + “load more”
- [ ] WPML: prebacivanje jezika, stringovi, ACF polja po jeziku
- [ ] ACF: sve 4 field grupe, CPT i 2 taksonomije; **galerija** (Photo Gallery Field)
- [ ] ProfilePress (ako se koristi): prijava/registracija/profil
- [ ] Redirection: stara pravila i dalje rade
- [ ] `debug.log`: bez `Fatal error`; deprecationi zabilježeni
- [ ] WP → Alati → Zdravlje sajta: nema novih crvenih stavki
- [ ] Vizualna usporedba 5 ključnih stranica (desktop + mobile)

---

## 6. Rollback

| Situacija | Postupak | Vrijeme |
|---|---|---|
| Companion dodatak pukne | `wp plugin install companion-configurations --version=1.0.3 --force` | 5 min |
| Elementor editor pukne | vratiti Elementor/Pro na 3.28.4 (ZIP) + Regenerate CSS | 15 min |
| UAE/CAF problem | vratiti prethodnu verziju ZIP-om | 10 min |
| WP core problem | host snapshot ili `wp core update --version=6.8.1 --force` + restore baze | 30 min |
| Nejasno | **cijeli site** iz snapshot-a | 30–60 min |

---

## 7. Otvorena pitanja za vas

1. **Elementor Pro licenca** vrijedi? (bez nje nema 4.3.5)
2. **Slider Revolution licenca** — 6.5.21 je star; kako se ažurira?
3. Koriste li se **ProfilePress** i **Simple Download Counter**? (ako ne — isključiti, manje površine)
4. **ACF Photo Gallery Field** — koliko galerija ga koristi? (migracija na ACF Galerie 4 ili ACF PRO Gallery)
5. **Category Ajax Filter** — koliko filtera je konfigurirano? (3.x je redizajn)
6. `WP_SITEURL` u wp-configu — je li produkcija isto tako “zaključana”?

---

## 8. Sažetak

1. **Tema je već zadnja (1.0.8)** → nema što ažurirati; pitanje je suvišno, ali odgovor je “da, može bez teme”.
2. **Odmah:** Companion Configurations 1.0.3 → **1.0.6** (sigurnosna zakrpa koju nemate) i Elementor Widgets 1.0.4 → **1.0.5**.
3. **Elementor rizik je manji** nego u generičkoj analizi — jer ste već na 3.28.4, dakle Scheme/Swiper problemi su “prošli vatru”. Ostaje Optimized Markup CSS + Pro 4.x.
4. **WPML je najsvježiji dio stacka** (5.1.0, 29.09.2026.) — ne dirati ga u istom valu.
5. **Tri odvojena, rizična updatea:** Category Ajax Filter 3.x (redizajn), E2Pdf (veliki skok), Elementor 4.x.
6. **WP 7.0.7 prvo**, 7.1.3 nakon provjere; **PHP 8.3** do kraja godine.

---

## 9. Izvori

- Vaš Site Health izvještaj (21.10.2026., staging)
- ThemeForest Companion (item 39413480) — zadnja objava 04.04.2024.: https://themeforest.net/item/companion-corporate-business-wordpress-theme/39413480
- Stylemix changelog Companion (1.0.6: *Broken Access Control*, Configurations 1.0.4): https://docs.stylemixthemes.com/companion-theme-documentation/extra-materials/changelog
- UAE changelog — 2.9.5 kompatibilan s Elementor/Pro 4.3: https://ultimateelementor.com/whats-new/
- WPML verzije — 5.1.0 (29.09.2026.), 5.2 (21.10.2026.): https://wpml.org/version/
- Elementor deprecations (Optimized Markup, `.elementor-widget-container`): https://developers.elementor.com/recent-deprecations/
- ACF Photo Gallery Field — “no longer maintained as of October 2024”, preporuka ACF Galerie 4: https://wordpress.org/plugins/navz-photo-gallery/
- Category Ajax Filter 3.0 = novi builder: https://wordpress.org/plugins/category-ajax-filter/
- WP 7.1 (iframed editor): https://make.wordpress.org/core/2026/08/05/wordpress-7-1-field-guide/
