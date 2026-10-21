# Plan nadogradnje — Uomo / WordPress / WooCommerce / Elementor

**Popratni dokument uz:** `ANALIZA-KOMPATIBILNOSTI-UOMO.md`
**Ciljani stack (1. val):** Uomo 2.0.37 · WordPress 7.0.7 · WooCommerce 10.9.4 · Elementor 4.3.5 · PHP 8.2 (pa 8.3)
**Način rada:** staging → verifikacija → produkcija u noćnom prozoru
**Procjena:** 3–5 radnih dana pripreme/testiranja + 2–3 h produkcijskog prozora

---

## Načela

1. **Nikad dvije velike promjene odjednom.** Nakon svake faze: test → zapis → sljedeća faza.
2. **Tema prije WooCommercea i Elementora. WooCommerce prije WordPressa. Elementor nakon teme. PHP na kraju.**
3. **Rollback je cijeli site, ne pojedinačna datoteka.** Zato staging i snapshot prije svake faze.
4. **Nula izmjena u child temi tijekom nadogradnje.** Child se dira samo ako audit pokaže konflikt, i to svjesno.

---

## Faza 0 — Preduvjeti (dan 1, prije svega ostalog)

### 0.1 Licence i paketi

- [ ] ThemeForest račun s kupnjom **item 31127579** → skinuti **Uomo 2.0.37** (uključuje *Apus Framework*, *RevSlider* i Apus dodatke)
- [ ] Provjeriti licence: **Duplicator Pro**, **CorvusPay**, **MBE eShip**, **Slider Revolution**, **YITH Wishlist**
- [ ] Zabilježiti serijske brojeve / račune u password manager

### 0.2 Sigurnosne kopije (3 sloja)

```bash
# 1) baza
wp db export ~/backup-$(date +%F)-pre-upgrade.sql

# 2) snapshot na razini hostinga (preporučeno, najbrži rollback)
#    LiteSpeed/cPanel: "Create Snapshot" ili ekvivalent

# 3) Duplicator Pro arhiva (puni site)
```

- [ ] **Testirati restore** na stagingu — backup koji nije testiran nije backup
- [ ] Zapisati `wp core version`, `wp plugin list`, `wp theme list` u tekstualnu datoteku

### 0.3 Staging

- [ ] Klon sitea (Duplicator ili host alat) na zaseban subdomain, **isti PHP 8.2**
- [ ] Blokirati indeksiranje (`blog_public = 0`) i pristup (`htpasswd` / IP allowlist)
- [ ] `search-replace` domene:

```bash
wp search-replace 'https://www.example.hr' 'https://staging.example.hr' --all-tables --precise --report-changed-only
```

- [ ] **Isključiti slanje e-mailova na stagingu** (npr. plugin za presretanje ili SMTP s „sandbox" načinom) — inače stvarni kupci dobiju testne potvrde

### 0.4 Serverske postavke (obavezno prije nadogradnje)

| Postavka | Sada | Postavi na | Zašto |
|---|---|---|---|
| `WP_MEMORY_LIMIT` | 40M | **256M** | sprječava „out of memory" tijekom updatea |
| `file_uploads` | Off | **On** | upload teme/dodataka, mediji, restore |
| `max_execution_time` | 60 | **300** (privremeno) | DB migracije, update dodataka |
| `WP_DEBUG` / `WP_DEBUG_DISPLAY` | false / true | staging: `true` / `false` + `WP_DEBUG_LOG=true` | greške u `debug.log`, ne na ekranu |
| `maintenance.php` | prisutan | pregledati i ukloniti ako je ostatak | može držati site u 503 |

### 0.5 Inventar prije diranja

```bash
# child tema — što stvarno overridea
find wp-content/themes/uomo-child -type f | sort

# audit trenutnog stanja
bash tools/audit-theme-compat.sh wp-content/themes/uomo wp-content/plugins/woocommerce wp-content/themes/uomo-child

# HPOS
wp wc hpos status

# veličine i stanje
wp db size --tables
wp plugin list --status=active --fields=name,version,update
```

- [ ] Zapisati: aktivni dodaci, HPOS status, child overridei, popis hookova koje child dodaje

---

## Faza 1 — Higijena (prije ijednog updatea)

- [ ] **Riješiti duplikat consent dodataka**: ostaviti **jedan** (Complianz *ili* CookieYes), drugi deaktivirati, provjeriti da barem jedan banner i dalje radi, obrisati preostale skripte iz headera
- [ ] Deaktivirati i **obrisati**: `MX WooCommerce HRK + EUR`, `WordPress Importer`
- [ ] Odlučiti o Apus Lookbook / Ourstores / Salespopup: ako se koriste — ažurirati iz novog paketa; ako ne — obrisati
- [ ] Provjeriti `maintenance.php` drop-in i ukloniti ako je ostatak
- [ ] Očistiti transijente i scheduled actions:

```bash
wp transient delete --all
wp cron event run --due-now
wp action-scheduler run --hooks=woocommerce_run_update_callback 2>/dev/null || true
```

---

## Faza 2 — Tema (najvažniji korak)

> Cilj: **tema 2.0.37 radi na starom WP-u 6.1 / WC 7.4 / Elementor 3.11**. Ne dirajte WP ni WooCommerce u ovoj fazi.

### 2.1 Postupak

1. [ ] Deaktivirati cache (LiteSpeed/objektni) i uključiti maintenance mode na **stagingu**
2. [ ] Backup `wp_options` i postova buildera:

```bash
wp db export ~/backup-options-$(date +%F).sql --tables=$(wp db tables 'wp_options' 'wp_posts' 'wp_postmeta' --all-tables-with-prefix | paste -sd,)
```

3. [ ] Zamijeniti **parent** temu: upload `uomo.zip` (2.0.37) kroz *Izgled → Teme → Dodaj novo → Prenesi*, ili FTP-om (sigurnija varijanta: preimenovati staru mapu u `uomo-2.0.9-backup`, pa raspakirati novu)
4. [ ] **Apus Framework**: deaktivirati stari, obrisati, instalirati verziju iz `wp-content/themes/uomo/inc/plugins/apus-framework.zip`
5. [ ] Isto za Apus dodatke koji se koriste (Sizeguides, Ourstores…)
6. [ ] **Ne dirati child temu**
7. [ ] `wp cache flush` + očistiti LiteSpeed cache

### 2.2 Verifikacija faze 2

- [ ] `bash tools/audit-theme-compat.sh wp-content/themes/uomo wp-content/plugins/woocommerce wp-content/themes/uomo-child`
      → očekivano: **FAIL = 0** (nema `Core\Schemes`), zastarjelih overridea **0–2** (jer je WC još 7.4.2)
- [ ] Admin: *Izgled → Prilagodi* radi; **Theme Options** (Redux) se otvaraju bez greške
- [ ] `debug.log` bez `Fatal error`, bez poplave deprecationa
- [ ] Header/footer builder: provjeriti da su `apus_header` / `apus_footer` predlošci još povezani (Elementor)
- [ ] Naslovnica, shop, produkt, košarica, checkout — vizualna usporedba sa screenshotovima prije updatea
- [ ] Mobilni prikaz (menu, mini-cart, filteri)

**Ako što pukne:** vratiti `uomo` mapu iz `uomo-2.0.9-backup` i stari `apus-framework` — to je 5 minuta. Ne nastavljati dalje s polomljenom temom.

---

## Faza 3 — WooCommerce (u koracima, ne preskakati)

Trenutno 7.4.2 → cilj 10.9.4. Preporučeni koraci: **7.4.2 → 8.9.x → 9.9.x → 10.9.4**.

Nakon **svakog** koraka:

```bash
wp plugin update woocommerce --version=<verzija>   # ili kroz admin, s ručno skinutim ZIP-om
wp wc update                                        # pokreće WC DB migracije
wp transient delete --all
```

- [ ] WooCommerce → **Status → Alati → „Ažuriraj bazu podataka"** (ako WP-CLI nije dostupan)
- [ ] WooCommerce → **Status → Predlošci**: cilj je **0 zastarjelih** (crvenih) predložaka
- [ ] WooCommerce → **Status → HPOS**: provjeriti da li svi aktivni dodaci deklariraju kompatibilnost (**CorvusPay**, **MBE eShip**, **YITH Wishlist**, **Variation Swatches** su kritični)
- [ ] `wp action-scheduler run` — dovršiti zaostale akcije
- [ ] Testna narudžba: košarica → kuponi → dostava → plaćanje → potvrda → e-mail

**Ako HPOS nije aktivan:** ne uključivati ga u istom valu. Prvo stabilizirati 10.9.4 na legacy storageu, HPOS u zasebnom koraku.

---

## Faza 4 — Elementor (tek sada)

- [ ] Update **3.11.4 → 4.3.5** (2026-10-13)
- [ ] *Elementor → Alati → **Regenerate CSS & Data***
- [ ] `wp eval 'Elementor\Plugin::$instance->files_manager->clear_cache();'`
- [ ] Testirati **svaki Apus widget** koji se koristi: Heading, Posts, Banner, Brands, Countdown, Features Box, Tabs, Testimonials, Team, Woo widgeti
- [ ] Otvoriti naslovnicu u editoru (ne samo frontend) — tu se `Schemes` problem manifestira
- [ ] Provjeriti `debug.log` na `register_widget_type` deprecatione (očekivano; nije blokada)

**Rollback:** Elementor se vraća na 3.11.4 ZIP-om (čuvajte ga prije updatea). Napomena: nakon što se predlošci spreme u novijem Elementoru, vraćanje na 3.11.4 može ostaviti nekompatibilne podatke — zato testirati na stagingu prije produkcije.

---

## Faza 5 — WordPress core (u koracima)

6.1.15 → **6.4.x** → **6.7.x** → **7.0.7**. Preskakanje 10 izdanja odjednom znači 10 skupova DB migracija u jednom zahtjevu — izbjegavati.

```bash
wp core update --version=<najnovija u grani> --force
wp core update-db
wp cache flush
wp rewrite flush --hard
```

Nakon svakog koraka: login, admin, Elementor editor, shop, checkout, `debug.log`.

> WP 7.0 podiže minimum PHP-a na 7.4 — vi ste na 8.2, uvjet zadovoljen.
> **WP 7.1.x** (trenutno 7.1.3) uvodi *uvijek iframed* editor — testirati **tek** kad 7.0.7 bude stabilan i kada ACF/CMB2 budu ažurirani.

---

## Faza 6 — Ostali dodaci (jedan po jedan)

Redoslijed po riziku (iz analize, poglavlje 6):

1. [ ] **Apus Framework** (već u fazi 2)
2. [ ] **CorvusPay 2.5.1 → 2.7.7** — pa odmah test plaćanja u sandboxu
3. [ ] **MBE eShip 2.7.2 → aktualno** — test izračuna dostave i ispisa naljepnice
4. [ ] **Variation Swatches 2.1.8 → 2.2.9**
5. [ ] **Ajax add to cart 2.0.2 → 2.6.7**
6. [ ] **YITH Wishlist 3.18 → aktualno** (paziti: tema overridea wishlist predloške)
7. [ ] **ACF 6.0.7 → aktualno** (prije WP 7.1!)
8. [ ] **CMB2 2.10.1 → 2.13.4**
9. [ ] **Contact Form 7 5.7.4 → aktualno**, **Flamingo 2.3**
10. [ ] **Yoast 20.2.1 → aktualno** (sitemap, schema, redirecti)
11. [ ] **Wordfence 8.2.2 → 9.0.2** (WAF pravila; očekuje se re-scan)
12. [ ] **Really Simple SSL 6.2.2 → aktualno** — na LiteSpeedu s ispravnim SSL-om razmotriti **uklanjanje** umjesto updatea
13. [ ] **Complianz / CookieYes** (onaj koji je ostao), **CAPTCHA 4WP**, **Loco Translate**
14. [ ] **Slider Revolution** — update ide s paketom teme; provjeriti da su slideri sačuvani
15. [ ] **Duplicator Pro** — provjeriti licencu, napraviti svježu arhivu
16. [ ] **Imunify** — kroz hosting

Nakon svakog: `debug.log`, osnovni klik kroz pogođenu funkcionalnost.

---

## Faza 7 — PHP (na kraju)

1. [ ] Staging: **8.2 → 8.3**, `WP_DEBUG=true` + `WP_DEBUG_LOG=true`
2. [ ] Proći cijeli acceptance checklist (niže) i pregledati `debug.log` 24 h
3. [ ] Produkcija: prebacivanje na 8.3 u noćnom prozoru
4. [ ] **8.4** planirati nakon potvrde ApusThemea i dodataka (8.2 EOL je 31.12.2026.)

---

## Faza 8 — Produkcija (prozor 2–3 h, npr. nedjelja 01:00)

1. [ ] Zamrznuti sadržaj (nema objava/izmjena proizvoda), pauzirati kampanje
2. [ ] Snapshot + `wp db export`
3. [ ] Maintenance mode (kratko)
4. [ ] Ponoviti **isti** slijed kao na stagingu (tema → WC → Elementor → WP → dodaci)
5. [ ] `wp cache flush`, `wp rewrite flush --hard`, regen. Elementor CSS-a
6. [ ] Testna narudžba s **pravim** plaćanjem na 1 €, pa refund
7. [ ] Isključiti maintenance, provjeriti `robots.txt`/`blog_public`
8. [ ] Uključiti auto-update za **niskorizične** dodatke (Loco, Importer ako ostaje, CAPTCHA) — ne za WooCommerce/Elementor

---

## Acceptance checklist (proći na stagingu, pa na produkciji)

**Katalog**
- [ ] Naslovnica: header, mega menu, slider, banneri, „sales popup"
- [ ] Shop: grid/list, broj proizvoda po stranici, sortiranje, paginacija, AJAX filtriranje
- [ ] Kategorije i potkategorije, breadcrumb
- [ ] Produkt: galerija (zoom/lightbox/slider), varijable (swatchevi), cijena, PDV, zaliha, tabovi, recenzije, povezani proizvodi
- [ ] Lookbook / Our stores (ako se koriste)
- [ ] Pretraga (autocomplete)

**Kupnja**
- [ ] „Dodaj u košaricu" s popisa (AJAX) i s produkta
- [ ] Mini-košarica: broj, uklanjanje, fragmenti nakon AJAX-a
- [ ] Košarica: količine, uklanjanje, kupon, cross-sells, izračun dostave
- [ ] Checkout: gost i registrirani, validacija polja, **sve metode dostave (MBE)**, **sve metode plaćanja (CorvusPay + ostalo)**, PDV, OIB polja ako ih ima
- [ ] Plaćanje: **uspješno**, **neuspješno**, **prekinuto** — sva tri scenarija
- [ ] Potvrda narudžbe (`thankyou`), e-mail kupcu i adminu, status narudžbe u adminu
- [ ] Moj račun: prijava, registracija, izgubljena lozinka, adrese, narudžbe, lista želja

**Sadržaj i sustav**
- [ ] Blog: arhiva, single, komentari
- [ ] Kontakt forma (CF7) + Flamingo zapis + CAPTCHA
- [ ] Cookie banner (jedan!), pohrana privole
- [ ] 404, pretraga bez rezultata, stranica održavanja
- [ ] Mobilni: menu, košarica, checkout
- [ ] `debug.log` čist; WooCommerce → Status → Logs bez novih fatala
- [ ] Core Web Vitals / LCP na naslovnici i produktu (usporediti s baselineom)
- [ ] `wp db check` — bez greške

---

## Rollback

| Situacija | Postupak | Vrijeme |
|---|---|---|
| Tema vizualno/functionalno pukla | vratiti mapu `uomo` + `apus-framework` iz backupa | 5–10 min |
| WooCommerce update pukao | restore snapshot baze + mapa dodataka | 15–30 min |
| Elementor editor pukao | vratiti Elementor ZIP na prethodnu verziju + regen. CSS | 10–15 min |
| WP core pukao (bijeli ekran) | vratiti snapshot + `wp core update --version=<stara> --force` | 20–30 min |
| Nešto nejasno, kupci prijavljuju greške | **cijeli site** iz snapshota, pa analiza na stagingu | 30–60 min |

---

## Triage: najčešće posljedice i prvi korak

| Simptom | Najvjerojatniji uzrok | Prvi korak |
|---|---|---|
| Bijeli ekran nakon updatea | nedovoljna memorija ili fatal u dodatku | `WP_MEMORY_LIMIT=256M`, pa `debug.log` |
| „The theme is missing the style.css" | nepotpuno raspakiran ZIP | ponovno raspakirati `uomo/` |
| Elementor editor bijel / widget nestao | `Core\Schemes` (stara tema) | vratiti Elementor, update teme |
| Checkout bez metode plaćanja | CorvusPay nekompatibilan s WC 10 | update CorvusPay, provjeriti HPOS |
| „Your theme has outdated templates" | zastarjeli overridei | `tools/audit-theme-compat.sh` |
| Dostava ne izračunava | MBE eShip vs WC shipping API | update MBE, provjeriti zone |
| Swatchevi nestali | Variation Swatches vs WC 10 | update dodatka |
| Dupli cookie banner | Complianz + CookieYes | deaktivirati jedan |
| Slike se ne učitavaju (lazy) | jQuery `.load()` + Migrate | update teme (2.0.29+) |

---

## Komunikacija i dokumentacija

- [ ] Zapisati **svaku** promjenu verzije s datumom i vremenom (jednostavan changelog u repozitoriju)
- [ ] Nakon završetka: `wp plugin list`, `wp theme list`, `wp core version` → u dokumentaciju projekta
- [ ] Postaviti kalendar: **mjesečna** provjera Updatea (tema, WP, WC, Elementor), **kvartalno** provjera PHP/MySQL EOL-a
- [ ] Uključiti Envato Market (ili ekvivalent) da tema više nikad ne „tiho" zaostane 3,5 godine

---

## Sažeti vremenski plan

| Dan | Aktivnost |
|---|---|
| 1 | Faza 0 + 1 (preduvjeti, backup, staging, higijena) |
| 2 | Faza 2 (tema 2.0.37) + verifikacija |
| 3 | Faza 3 (WooCommerce u koracima) + testna narudžba |
| 4 | Faza 4 + 5 (Elementor, WP core) |
| 5 | Faza 6 (dodaci) + puni acceptance checklist |
| 6 | PHP 8.3 na stagingu + 24 h promatranja |
| 7 | Produkcija (noćni prozor) + 48 h monitoring |
