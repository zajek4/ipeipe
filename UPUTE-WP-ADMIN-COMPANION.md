# Companion / gbccroatia — update SAMO kroz WP admin

**Site:** `dev.michel.hr/gbccroatia` (staging) · WP 6.8.1 · tema Companion 1.0.8 (zadnja)
**Pravilo:** sve se radi u `wp-admin`. Jedina stvar izvan WP admina je PHP verzija (cPanel).
**Pravilo 2:** nikad „Select all → Update". Rizične stvari jedna po jedna, s testom.

---

## 0. Prije svega — zabilježi stanje (5 min)

1. **Alati → Zdravlje sajta → Info** → gumb **„Kopiraj podatke o sajtu"** → zalijepi u tekst datoteku i spremi.
2. **Dodaci → Instalirani dodaci** → na vrhu postavi „25 po stranici", napravi screenshot svih stranica (dokaz trenutnih verzija).
3. Otvori i screenshotaj 5 ključnih stranica (naslovnica, kontakt, stranica s filterom, stranica s PDF-om, stranica s galerijom).

---

## 1. Backup (obavezno, 10 min)

### 1a. Duplicator Pro
1. **Duplicator → Backups**
2. Gumb **„Create New Backup"** (ili „Create New")
3. Odaberi **Full Site** (baza + datoteke) → **Next**
4. Storage: **Default** (local) → **Next** → **Create Backup**
5. Pričekaj da status bude **Complete** (10,4 GB — može potrajati; ne zatvaraj karticu)
6. Klikni **Download** na gotovom backupu → spremi na svoje računalo (van servera)

> Ako Duplicator javi grešku zbog veličine: u **Duplicator → Settings → Backups** uključi isključivanje `uploads` mape iz arhive, ali tada radi i host snapshot.

### 1b. Snapshot na hostingu (paralelno, brži rollback)
cPanel → traži **„Snapshot"** ili **„Backup"** → Create. (Ovo je jedina stvar izvan WP admina uz PHP.)

### 1c. Provjeri da backup radi
Ne testiraj restore na produkciji — samo provjeri da se datoteka skinula i da je veličine ~10 GB. Ako je 0 MB ili 200 MB → backup nije dobar, ponovi.

---

## 2. Instaliraj „sigurnosnu mrežu" (5 min)

**Dodaci → Dodaj novi → traži `WP Rollback` → Instaliraj → Aktiviraj**

Zašto: daje gumb **„Rollback"** na svakom dodatku u adminu — vraćanje na prethodnu verziju bez terminala.

(Opcionalno, za kontrolu WP verzije: **`WP Downgrade | Specific Core Version`** — vidi korak 10.)

---

## 3. Companion Configurations 1.0.3 → 1.0.6 (5 min)

**Dodaci → Instalirani dodaci → Companion Configurations → „Ažuriraj sada"**

Provjera:
- [ ] Admin se učitava normalno
- [ ] **Companion → Theme Options** se otvara bez greške
- [ ] **Stranice → bilo koja stranica** → urednik + metaboxi se učitavaju
- [ ] Frontend naslovnice radi
- [ ] U popisu dodataka piše **1.0.6**

---

## 4. Companion Elementor Widgets 1.0.4 → 1.0.5 (5 min)

**Dodaci → Instalirani dodaci → Companion Elementor Widgets → „Ažuriraj sada"**

Provjera:
- [ ] Otvori stranicu u **Elementor editoru** (ne samo „Pregled")
- [ ] U lijevom panelu, kategorija **Companion** — widgeti su vidljivi
- [ ] Prevuci jedan Companion widget na stranicu → prikazuje se
- [ ] **Elementor → Alati → Regenerate CSS & Data** → klikni **Regenerate**
- [ ] Frontend 2–3 stranice rade
- [ ] Verzija je **1.0.5**

> Ako pukne: **Dodaci → WP Rollback → Companion Elementor Widgets → Rollback → 1.0.4**

---

## 5. Ultimate Addons for Elementor 2.3.0 → 2.9.5 (5 min)

**Dodaci → Instalirani dodaci → Ultimate Addons for Elementor Lite → „Ažuriraj sada"**

Provjera: otvori Elementor editor → UAE widgeti rade → **Regenerate CSS** → frontend.

> Redoslijed je važan: UAE **prije** Elementora, jer 2.9.5 nosi kompatibilnost s Elementorom 4.3.

---

## 6. Elementor Pro + Elementor → 4.3.5 (30 min) ⚠️ rizično

1. **Dodaci → Instalirani dodaci → Elementor Pro → „Ažuriraj sada"** (ako traži licencu, aktiviraj je prvo u **Elementor → License**)
2. **Elementor → „Ažuriraj sada"**
3. **Elementor → Alati → Regenerate CSS & Data → Regenerate**
4. **Elementor → Alati → Version Control** — ako je uključen, ne diraj
5. Test po redu:
   - [ ] **Elementor → Theme Builder** → header i footer se uređuju i prikazuju
   - [ ] Sve Companion widgete na jednoj testnoj stranici (dodaj → provjeri → obriši)
   - [ ] UAE widgeti
   - [ ] Pro: forme, loop grid, galerija
   - [ ] Frontend: naslovnica, kontakt, stranica s filterom, mobilni prikaz
6. **Alati → Zdravlje sajta → Status** → nema novih crvenih stavki

> Ako editor pukne: **Elementor → Alati → Safe Mode** (uključi) da dobiješ radni admin, pa **WP Rollback → Elementor → 3.28.4** i isto za Pro.

---

## 7. Sigurni dodaci — može odjednom (15 min)

**Dodaci → Instalirani dodaci** → označi **samo ove** → „Bulk actions → Update":

- [ ] Really Simple Security
- [ ] Redirection
- [ ] Yoast SEO
- [ ] TablePress
- [ ] Breadcrumb NavXT
- [ ] Simple Download Counter
- [ ] Custom Icons for Elementor and WPBakery
- [ ] Widget Options
- [ ] Duplicate Page
- [ ] Adminimize
- [ ] Admin Bar & Dashboard Control
- [ ] ProfilePress
- [ ] Really Simple CAPTCHA

Nakon: provjeri admin login, Yoast (SEO → Search Appearance), Redirection (popis preusmjerenja), ProfilePress (prijava/profil).

**Obriši, ne ažuriraj:** `Advanced Custom Fields` (free, 6.8.0, neaktivan) — **Dodaci → Deaktiviraj → Obriši**.

---

## 8. Category Ajax Filter 2.8.4 → 3.1.2 (20 min) ⚠️ rizično

1. Prije updatea: otvori **Category Filter → All Filters** i screenshotaj sve postojeće filtere
2. **Dodaci → Instalirani dodaci → Category Ajax Filter → „Ažuriraj sada"**
3. Otvori svaki filter → spremi (novi builder može zahtijevati ponovno spremanje)
4. Test na frontendu: klikanje kategorija, paginacija, „load more"
5. Ako izgled pukne: **WP Rollback → Category Ajax Filter → 2.8.4**

---

## 9. E2Pdf + PDF za CF7 (20 min) ⚠️ rizično

1. Prije: generiraj jedan PDF i spremi ga kao referencu
2. **Dodaci → Instalirani dodaci → E2Pdf → „Ažuriraj sada"**
3. **Generate PDF using Contact Form 7 → „Ažuriraj sada"**
4. **E2Pdf → Templates** → otvori svaki predložak → **Preview** (mora se renderirati)
5. Testiraj pravu formu: pošalji upit → provjeri PDF u e-mailu i na serveru
6. Ako ne radi: **WP Rollback** na oba dodatka

---

## 10. Slider Revolution 6.5.21 → 6.7.x (15 min) ⚠️ rizično

1. Prije: **Slider Revolution → Slider** → otvori svaki slider → screenshot
2. **Dodaci → Instalirani dodaci → Slider Revolution → „Ažuriraj sada"**
   - Ako traži registraciju: **Slider Revolution → Registration** (licenca ili „activate later")
3. **Slider Revolution → Overview** → svaki slider → **Preview** na frontendu
4. Provjeri mobilni prikaz slidera
5. Ako pukne: **WP Rollback → 6.5.21**

---

## 11. WordPress 6.8.1 → 7.0.7 (30 min) ⚠️ rizično

WP admin nudi **samo najnoviju** verziju (7.1.3). Za kontrolirani skok na 7.0.7:

1. **Dodaci → Dodaj novi → `WP Downgrade` → Instaliraj → Aktiviraj**
2. **Settings → WP Downgrade** → upiši **`7.0.7`** → Save
3. **Dashboard → Updates** → sada nudi 7.0.7 → klikni **„Update Now"**
4. Nakon updatea: **Dashboard → Updates** → „Update Database" ako se pojavi
5. Provjeri: admin login, **Theme Options**, metabox na stranici, Elementor editor, frontend, **Zdravlje sajta → Status**

> **7.1.3 ne sada.** Prvo nekoliko dana na 7.0.7 uz provjeru Adminimize / Admin Bar / ACF metaboxa (WP 7.1 mijenja uređivač).
> Ako želiš preskočiti WP Downgrade: dopusti da ode na 7.1.3, ali tada odmah testiraj te tri stvari.

---

## 12. PHP 8.2 → 8.3 (jedini korak izvan WP admina)

1. cPanel → **MultiPHP Manager** (ili „Select PHP Version")
2. Odaberi domenu `dev.michel.hr` → **PHP 8.3** → Apply
3. U WP-u: **Alati → Zdravlje sajta → Info → Server** → provjeri da piše 8.3
4. Prođi cijeli sajt + Elementor editor + `Zdravlje sajta → Status`

> 8.2 ima podršku do 31.12.2026. — nije hitno, ali ne ostavljaj za zadnji tjedan.
> Ako se pojave greške: vrati na 8.2 u cPanelu (30 sekundi).

---

## 13. Na kraju — čišćenje i kontrola

- [ ] **Dodaci → Instalirani dodaci** → deaktiviraj i obriši **WP Downgrade** (ostavi WP Rollback)
- [ ] Deaktiviraj/obriši **OTGS Installer** (neaktivan) i **SMTP Mailer** ako se ne koristi
- [ ] **Alati → Zdravlje sajta** → Status: nema novih crvenih
- [ ] **Dashboard → Updates** → provjeri da nema zaostalih
- [ ] Novi screenshot stanja (kao u koraku 0) → spremi kao dokaz

---

## Brzi pregled rizika

| Korak | Rizično? | Vrijeme | Rollback u adminu |
|---|---|---|---|
| 3–4 Companion dodaci | 🟢 | 10 min | WP Rollback |
| 5 UAE | 🟠 | 5 min | WP Rollback |
| 6 Elementor Pro + Elementor | 🔴 | 30 min | WP Rollback + Safe Mode |
| 7 sigurni dodaci | 🟢 | 15 min | WP Rollback |
| 8 Category Ajax Filter | 🔴 | 20 min | WP Rollback |
| 9 E2Pdf | 🔴 | 20 min | WP Rollback |
| 10 Slider Revolution | 🟠 | 15 min | WP Rollback |
| 11 WP core | 🔴 | 30 min | host snapshot |
| 12 PHP | 🟠 | 5 min | cPanel vrati 8.2 |

**Ukupno: ~2,5 h razvučeno kroz 2–3 dana.**

---

## Ako bilo što pukne — 3 poteza

1. **Elementor problem?** → **Elementor → Alati → Safe Mode → Enable** (admin proradi)
2. **Dodatak problem?** → **Dodaci → WP Rollback → [dodatak] → Rollback** na staru verziju
3. **Sve puklo?** → Duplicator **→ Backups → Restore** (ili cPanel snapshot) — vraća cijeli sajt

---

## Što NE dirati

| Stvar | Zašto |
|---|---|
| **Tema Companion** | 1.0.8 je zadnja — nema updatea. U **Izgled → Teme** ne klikaj „Ažuriraj" |
| **Child tema** | nikad se ne ažurira, ne diraj je |
| **WPML 3 dodatka** | već su najnoviji (5.1.0) — ne u istom valu |
| **ACF Photo Gallery Field** | napušten 10/2024. — zamjena kasnije, ne sada |
| **Elementor → Atomic Editor/V4** | ne uključuj dok sve ne bude stabilno |
