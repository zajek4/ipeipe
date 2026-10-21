# Companion 1.0.8 → može li se sve ažurirati **bez** ažuriranja teme?

**Tema:** Companion – Corporate Business WordPress Theme (ThemeForest `39413480`, StylemixThemes)
**Verzija na siteu:** 1.0.8
**Datum analize:** 21.10.2026.
**Cilj koji ste zadali:** WordPress, dodaci i WooCommerce na najnovije

---

## 0. Odgovor

**Da — update se može odraditi bez ažuriranja teme.** WordPress, WooCommerce i Elementor ne ovise o temi; tema je *potrošač* njihovih API-ja. Ali to nije bezuvjetno, i zato ide ovako:

| | Preporuka |
|---|---|
| **Može li bez teme?** | Da, tehnički izvedivo |
| **Uz koje uvjete?** | (1) audit teme pokaže **0 blokirajućih nalaza**, (2) **cap na WP 7.0.7 + WC 10.9.4** umjesto 7.1.3/11.2.1, (3) prihvaćate da tema **više nikad neće dobiti sigurnosnu zakrpu** |
| **Što NE preporučam?** | “Sve na apsolutno najnovije” (WP 7.1.3 + WC 11.2.1 + PHP 8.4) uz zamrznutu temu iz travnja 2024. |

**Najveći rizik nije WordPress ni WooCommerce — nego Elementor.** Tri stvari su uklonjene iz Elementora između verzije s kojom je tema testirana (3.7.x, 2022.) i današnje 4.3.5, a tema iz travnja 2024. nije mogla biti testirana na njih: **Scheme klase**, **Swiper 5** i **Waypoints.js**.

---

## 1. Što je Companion 1.0.8 (i zašto je ovo drugačije od Uoma)

| Stavka | Podatak |
|---|---|
| Autor | StylemixThemes (ThemeForest, Power Elite) |
| Izdanje 1.0.8 | **4. travnja 2024.** |
| Zadnja objava na ThemeForstu | **4. travnja 2024.** → **~2,5 godine bez ijednog izdanja** |
| Deklarirana podrška | WordPress **6.1 – 6.5**, WooCommerce **6.x – 7.x**, Elementor / Elementor Pro, WPML, Bootstrap 5 |
| “Tested up to” | WordPress 6.5.x (u travnju 2024. aktualan je bio 6.5) |
| Bundlani dodaci | **Companion Elementor Widgets 1.0.5**, **Companion Configurations 1.0.6** |
| Gdje se ti dodaci ažuriraju | **samo s temom** — nisu na wordpress.org (provjereno), dakle nema zasebnog kanala |

Razlika prema Uomu iz prve analize: Uomo **jest** aktivan (2.0.37, 05/2026), samo nije bio ažuriran na siteu. Companion **nije** aktivan — 1.0.8 je zadnja verzija. To mijenja prirodu odluke:

- kod Uoma je “update teme” bio jednostavan i besplatan korak → uvijek prvi,
- kod Companion-a “update teme” **ne postoji** (nema novije verzije), pa je pitanje koje postavljate jedino relevantno: *može li se bez nje*.

Stylemix na stranici proizvoda navodi *“lifetime updates”* i vlastiti updater u adminu (*Companion → Dashboard / Updates*), ali stvarnih izdanja nema od 04/2024. **To je vrijedno provjeriti na siteu** — ako updater ponudi nešto novije od 1.0.8, cijela analiza se pojednostavljuje (vidi poglavlje 7, opcija B).

---

## 2. Zašto tema ne blokira update sustava

WP, WooCommerce i Elementor razvijaju se neovisno o temi. Update redoslijedom “core → dodaci → tema” je standard; tema je zadnja jer samo ona može “pasti” bez posljedica na podatke (najgore što se dogodi je ružan/pokvaren izgled, ne gubitak narudžbi).

Ono što tema **može** izgubiti bez svog updatea:

| Sloj | Što se dogodi ako tema ostane 1.0.8 |
|---|---|
| Baza podataka / sadržaj | ništa — sadržaj je u bazi, ne u temi |
| Theme Options / Customizer | rade (dok ih core ili Elementor ne dotaknu) |
| Elementor widgeti iz teme | **mogu puknuti** (Scheme / Swiper / Waypoints) |
| Metaboxi i admin paneli teme | **mogu puknuti na WP 7.1** (uvijek iframed editor) |
| WooCommerce predlošci (ako ih tema ima) | “outdated templates” — vizualne razlike, rijetko fatalno |
| Sigurnost | **nema više zakrpa** — to je trajno, ne prolazno |

---

## 3. Elementor: što je stvarno uklonjeno (provjereno u kodu 4.3.5)

Ovo je srce odgovora. Provjerio sam izvorni kod Elementora **4.3.5** i službenu listu deprecacija, pa razlikujem “puca” od “samo log”:

| element | Status | Posljedica za Companion 1.0.8 |
|---|---|---|
| **`Elementor\Core\Schemes\*`** | **uklonjeno u 3.26** | 🔴 **fatal** u editoru ako widgeti teme koriste `scheme` u kontrolama (klasa ne postoji → `Error: Class not found`) |
| **Swiper 5 → 8** (`swiper-container`, stare opcije) | **uklonjeno u 3.26** | 🔴 karuseli teme (case/testimonial/team carousel) mogu ostati prazni ili nepokretni |
| **Waypoints.js** (`elementor-waypoints`) | **uklonjen u 3.24** | 🟠 scroll animacije / countdown trigeri prestaju |
| **`_register_controls()`, `_render()`, `_content_template()`** | deprecated; **u 4.3.5 još RADE** (provjereno: `includes/base/controls-stack.php:2230` i `:2437`) | 🟢 samo deprecation u `debug.log` — **ne puca** |
| **`register_widget_type()` / `elementor/controls/controls_registered`** | deprecated; **još rade** (delegiraju) | 🟢 deprecation u logu |
| **`.elementor-widget-container`** | uklonjen za **Elementorove vlastite** widgete kad je *Optimized Markup* aktivan (default od 3.32, u core od 3.33). Za **tuđe (third-party) widgete se još ispisuje** — `element-base.php` `has_widget_inner_wrapper()` vraća `true` | 🟠 CSS teme koji targetira *Elementorove* widgete (npr. `.elementor-widget-image .elementor-widget-container`) može izgubiti stilove; CSS za **vlastite** widgete teme je siguran |
| **Elementor 4.0 Atomic Editor** | V3 widgeti se i dalje rendaju; API za V4 još nije stabilan | 🟢 ne treba nam — ne gradimo V4 elemente |

**Praktični zaključak:** sve ovisi o **tri grepa** nad kodom teme i dva bundlana dodatka. Ako nema `Core\Schemes`, nema Swiper 5 oznaka i nema Waypointsa — Elementor 4.3.5 je siguran. Ako ima — update **bez** teme nije dobra ideja, nego se ide na lokalni patch, novu verziju od Stylemixa ili zamjenu teme.

To je točno ono što radi skripta iz priloga (`tools/audit-theme-compat.sh`, sekcija 5).

---

## 4. WordPress 7.x bez updatea teme

| Promjena | Utjecaj na Companion 1.0.8 |
|---|---|
| **WP 7.0** — minimum PHP 7.4, MySQL 5.5.5 | nema utjecaja na temu (vi ste ionako na 8.2+) |
| **WP 7.1** — post editor je **uvijek** u iframeu | 🟠 meta-boxevi i admin skripte koje hvataju `document`/`window` mogu prestati raditi — tipično pogađa **Theme Options panele i metaboxe teme** (Companion Configurations) |
| jQuery 3.7.1 + Migrate 3.4.1 | još u core-u → legacy JS teme radi |
| Klasične (ne-blok) teme | podržane; Companion nema `theme.json` → nema novih mogućnosti, ali ni problema |

Zato je realan plan: **WP 7.0.7 prvo** (to je zadnja 7.0 zakrpa i grana koja još dobiva sigurnosne popravke), a **7.1.3 nakon** što se potvrdi da admin paneli teme rade u iframed editoru.

---

## 5. WooCommerce i PHP

**WooCommerce** — ovisi o tome koristi li ovaj site uopće Woo. Dvije grane:

- **Ne koristi se** → WooCommerce se ne dira, tema nema `woocommerce/` direktorij ili ga ima praznog; cijeli rizik iz ove analize svodi se na Elementor i WP.
- **Koristi se** → audit skripta uspoređuje svaki override s instaliranim WooCommerceom (kao kod Uoma). Tema deklarira WC **do 7.x**, a aktualni je **11.2.1**; WC 10.9.4 i 11.x zahtijevaju WP 6.9/7.0+, što je uvjet koji se rješava u istom valu.

**PHP** — tema je iz travnja 2024., dakle pisana za PHP 8.1/8.2 eru:

| Korak | Ocjena |
|---|---|
| 8.2 → **8.3** | ✅ realno sigurno nakon što sve proradi (8.2 EOL je 31.12.2026.) |
| 8.3 → **8.4** | ⏳ rizik — nema tko zakrpati temu ako nešto zasmeta |
| 8.5 | ⏳ ne bez updatea/zamjene teme |

---

## 6. Cijena opcije “bez updatea teme”: sigurnosni dug

Nije tehnička, ali je važnija od svega: **tema 1.0.8 više neće dobiti nijednu zakrpu.** Iz changeloga se vidi da je tema povijesno *imala* sigurnosnih problema — u 1.0.6 (28.08.2023.) stoji *„Fixed: Broken Access Control vulnerability“*. Takva vrsta ranjivosti (nedostatna provjera ovlasti) tipično pogađa AJAX/`admin-ajax` endpointe teme.

Ako je site korporativni/brošura (javne stranice, kontakt forma, bez korisničkih računa i bez e-trgovine), izloženost je **niska**. Ako ima registraciju, članstva, Woo, uploade ili više urednika — **srednja do visoka**, i tada “update svega osim teme” nije dugoročno rješenje, samo odgoda.

Neutralizacija rizika bez updatea teme:
1. **Wordfence** (ili Imunify na hostu) s virtual patchingom — blokira exploit i bez zakrpe u temi;
2. **ukloniti nepotrebne dijelove teme** (npr. nekoristene widgete/`admin-ajax` handlere) ili ih onemogućiti `mu-pluginom`;
3. **WAF pravila** za `admin-ajax.php` (rate limit, IP allowlist za akcije koje ne trebaju gostima);
4. **child tema** za sve prilagodbe — da eventualna buduća verzija ne pregazi vaše izmjene.

---

## 7. Tri opcije

### Opcija A — Update bez teme (ono što ste pitali)

**Cilj:** WP 7.0.7 · WooCommerce 10.9.4 (ako se koristi) · Elementor 4.3.5 · PHP 8.3 · **tema ostaje 1.0.8**
**Uvjet:** audit teme = 0 FAIL.
**Trajanje:** 1–2 dana pripreme + 2 h prozora.
**Plus:** nema rizika od gubitka dizajna; sve sigurnosne zakrpe sustava i dodataka dolaze.
**Minus:** tema ostaje bez zakrpa; WP 7.1.x, WC 11.x i PHP 8.4 čekaju.

### Opcija B — Prvo provjeriti ima li Stylemix išta novije

Prije bilo čega otvoriti **Companion → Dashboard / Updates** u adminu i pogledati nudi li updater novu verziju. Ako nudi → to je najbolji scenarij (update teme pa sve na najnovije). Ako ne nudi → poslati upit Stylemixu: *“Is there a compatibility release for WordPress 7.x / Elementor 4.x?”* Uz *lifetime updates* politiku, često postoji beta ili patch za kupce.

### Opcija C — Zamjena teme

Tek ako audit pokaže `Core\Schemes`, Swiper 5 ili Waypoints u temi **i** Stylemix nema rješenje. Tada: nova tema (GeneratePress/Astra/Kadence + Elementor), rebuild ~8 demo šablona, 2–4 tjedna.

**Preporuka:** **A**, s tim da prije njega napravite dvije provjere iz B (5 minuta) — ako ima novije verzije teme, radite B jer je jeftinije od A.

---

## 8. Plan za opciju A (redoslijed je obavezan)

```
0. Preflight      audit teme + backup + staging + PHP memorija/upload
1. Higijena       nepotrebni dodaci, dupli cache/consent, maintenance.php
2. Elementor      3.11.x → 4.3.5  (PRVO, jer tema ovisi o njemu)
3. WooCommerce    7.4.2 → 8.x → 9.x → 10.9.4  (samo ako se koristi)
4. WordPress      6.x → 6.7 → 7.0.7   (7.1.3 kasnije)
5. Dodaci        ostali, jedan po jedan
6. PHP            8.2 → 8.3
7. Produkcija    noćni prozor + 48 h monitoring
```

### Korak 0 — Preflight (obavezno prije ijednog updatea)

```bash
# 1) verzije i okruženje
wp core version; wp theme list --fields=name,version,status
wp plugin list --fields=name,version,status

# 2) AUDIT TEME — kljucni korak (0 FAIL = idemo dalje)
bash tools/audit-theme-compat.sh wp-content/themes/companion wp-content/plugins/woocommerce "" 7.0.7

# 3) ima li tema/i dodaci novije verzije
wp plugin list --update=available --fields=name,version,update_version
wp theme list  --update=available --fields=name,version,update_version

# 4) backup + staging (Duplicator ili host snapshot) — i TESTIRAJ restore
```

> Skripta u sekciji 5 ispisuje upravo tri stvari koje odlučuju: `Core\Schemes`, Swiper 5, Waypoints — plus CSS koji targetira V3 Elementor klase i deprecated metode.

### Korak 2 — Elementor 4.3.5 (najkritičniji)

1. Sačuvati ZIP trenutne verzije (rollback).
2. Update → *Elementor → Alati → Regenerate CSS & Data*.
3. Otvoriti **editor** (ne samo frontend) na svakoj vrsti stranice koja koristi Companion widgete.
4. Testirati: case/testimonial/team **karusel**, countdown, portfolio grid, animacije na scroll, tabs/accordion.
5. `debug.log`: deprecationi su OK; `Fatal error` nije.

### Korak 4 — WordPress 7.0.7 (u koracima)

Nakon svake stepenice (6.4 → 6.7 → 7.0.7): login, admin, **Theme Options panel**, metabox na stranici, editor, frontend.
Ako Theme Options puknu na 7.0 — problem je gotovo sigurno u iframed editoru (7.1) i tada se 7.1 **ne dira** do rješenja.

### Verifikacija prije produkcije

- [ ] frontend svih tipova stranica (desktop + mobile)
- [ ] Elementor editor otvara sve Companion widgete bez greške
- [ ] Theme Options / Customizer rade i spremaju
- [ ] kontakt forma, pretraga, 404
- [ ] (ako Woo) košarica → checkout → plaćanje → potvrda
- [ ] `debug.log` bez fatala; WP → Alati → Zdravlje sajta bez novih crvenih stavki

### Rollback

| Situacija | Postupak | Vrijeme |
|---|---|---|
| Elementor editor pukne | vratiti stari ZIP Elementora + Regenerate CSS | 10–15 min |
| Tema vizualno pukne | vratiti temu iz backupa (ista verzija) + obrisati Elementorov CSS cache | 10 min |
| WP core problem | snapshot baze + `wp core update --version=<stara> --force` | 20–30 min |
| Nejasno | **cijeli site** iz snapshot-a | 30–60 min |

---

## 9. Što mi treba da potvrdim odgovor za *vaš* site

Nemam kod teme (za razliku od Uoma), pa su gornji rizici procjena iz dokumentacije. To se zatvara u 5 minuta:

1. `bash tools/audit-theme-compat.sh wp-content/themes/companion` — izlaz (posebno sekcije 3, 5, 8b)
2. `wp plugin list --status=active --fields=name,version` — koji su dodaci u igri
3. `wp theme list` — postoji li child tema (`companion-child`)
4. Sadržaj *Companion → Dashboard/Updates* (nudi li novu verziju)

Uz to pošaljite i Site Health izvještaj (Alati → Zdravlje sajta → Info → Copy) i mogu napisati isti tip dokumenta kao za Uomo — s točnim popisom zastarjelih predložaka i konkretnim koracima.

---

## 10. Sažetak

1. **Da, može bez updatea teme** — ali s capom: **WP 7.0.7 + WC 10.9.4 + Elementor 4.3.5 + PHP 8.3**, ne “sve na apsolutno najnovije”.
2. **Odluka visi o tri grepa** (`Core\Schemes`, Swiper 5, Waypoints). Ako su čisti — Elementor 4.3.5 je siguran i to sam potvrdio u kodu Elementora.
3. **Prvo provjerite nudi li Stylemix novu verziju** (5 minuta). Ako nudi — uzmite je, jer uklanja cijeli problem.
4. **Sigurnosni dug ostaje**: tema 1.0.8 nema više zakrpa; neutralizira se WAF-om/Wordfenceom i uklanjanjem nepotrebnih dijelova.
5. **WP 7.1.3, WC 11.2.1 i PHP 8.4** — drugi val, nakon potvrde da Theme Options i metaboxi teme rade na 7.0.

---

## 11. Izvori

- ThemeForest — Companion (item 39413480), “Last Update 4 April 2024”, deklarirana kompatibilnost: https://themeforest.net/item/companion-corporate-business-wordpress-theme/39413480
- Stylemix dokumentacija — Changelog (1.0.8 = 4.4.2024., 1.0.6 = fix Broken Access Control): https://docs.stylemixthemes.com/companion-theme-documentation/extra-materials/changelog
- Stylemix dokumentacija — How to update Companion (lifetime updates, child tema): https://docs.stylemixthemes.com/companion-theme-documentation/getting-started/how-to-update-companion
- Elementor — Recent Deprecations (Schemes → 3.26, Swiper 5 → 3.26, Waypoints → 3.24, `.elementor-widget-container` → 3.36): https://developers.elementor.com/recent-deprecations/
- Elementor 3.26 developers update (uklanjanje Scheme metode, Swiper 8): https://developers.elementor.com/elementor-3-26-developers-update/
- Provjera koda Elementor **4.3.5** (GitHub, tag 4.3.5): `includes/base/controls-stack.php` (`_register_controls` još se poziva, deprecation), `includes/base/element-base.php::has_widget_inner_wrapper()` (default `true` → third-party widgeti zadržavaju `.elementor-widget-container`), `includes/base/widget-base.php` (ispis wrappera)
- WordPress 7.1 Field Guide (uvijek iframed editor): https://make.wordpress.org/core/2026/08/05/wordpress-7-1-field-guide/
- WordPress 7.1 server compatibility (PHP 7.4+, 8.2 EOL 31.12.2026.): https://make.wordpress.org/hosting/handbook/compatibility/version/7-1/
- WooCommerce izdanja (11.2.1 zahtijeva WP 7.0; 10.9.4 zahtijeva WP 6.9): https://github.com/woocommerce/woocommerce
