#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# audit-uomo-compat.sh
#
# Provjera kompatibilnosti Uomo (ApusTheme) teme s instaliranim
# WooCommerce / Elementor / PHP / WordPress stackom.
#
# Pokreće se NA SERVERU (ili lokalno na kopiji) i ne mijenja ništa —
# samo čita datoteke i ispisuje nalaze.
#
# Primjena:
#   ./audit-uomo-compat.sh <putanja-do-teme> [putanja-do-woocommerce]
#   ./audit-uomo-compat.sh wp-content/themes/uomo wp-content/plugins/woocommerce
#
# Opcionalno: 3. argument = putanja do child teme (npr. uomo-child)
# ---------------------------------------------------------------------------

set -u

THEME_DIR="${1:-}"
WC_DIR="${2:-}"
CHILD_DIR="${3:-}"

RED=$'\033[0;31m'; YEL=$'\033[0;33m'; GRN=$'\033[0;32m'; BLD=$'\033[1m'; NC=$'\033[0m'
[ -t 1 ] || { RED=""; YEL=""; GRN=""; BLD=""; NC=""; }

FAILED=0; WARNED=0

section() { printf '\n%s\n%s\n' "${BLD}== $1 ==${NC}" "------------------------------------------------------------"; }
fail() { FAILED=$((FAILED+1)); printf '  %sFAIL%s  %s\n' "$RED" "$NC" "$1"; }
warn() { WARNED=$((WARNED+1)); printf '  %sWARN%s  %s\n' "$YEL" "$NC" "$1"; }
ok()   { printf '  %sOK%s    %s\n' "$GRN" "$NC" "$1"; }
info() { printf '        %s\n' "$1"; }

if [ -z "$THEME_DIR" ] || [ ! -d "$THEME_DIR" ]; then
  echo "Upotreba: $0 <putanja-do-teme> [putanja-do-woocommerce] [putanja-do-child-teme]"
  echo "Primjer:  $0 wp-content/themes/uomo wp-content/plugins/woocommerce wp-content/themes/uomo-child"
  exit 2
fi

THEME_DIR="${THEME_DIR%/}"

# ---------- helperi --------------------------------------------------------
hdr_version() { # $1 = datoteka, $2 = kljuc (Version, Requires at least...)
  sed -n '1,40p' "$1" 2>/dev/null | grep -i -m1 "^[ *]*$2:" | sed 's/.*: *//' | tr -d '\r'
}
tmpl_version() { # izvlaci @version iz zaglavlja predloska
  sed -n '1,40p' "$1" 2>/dev/null | grep -m1 -o '@version[[:space:]]*[0-9][0-9.]*' \
    | grep -o '[0-9][0-9.]*'
}
ver_gt() { # vraca 0 ako je $1 > $2
  awk -v a="$1" -v b="$2" 'BEGIN{
    na=split(a,A,"."); nb=split(b,B,".");
    n=(na>nb?na:nb);
    for(i=1;i<=n;i++){ x=(i<=na?A[i]:0)+0; y=(i<=nb?B[i]:0)+0;
      if(x>y){exit 0} if(x<y){exit 1} }
    exit 1 }'
}
ver_eq() { [ "$1" = "$2" ]; }

# ---------- 1. identifikacija ---------------------------------------------
section "1. Identifikacija paketa"

THEME_VERSION="$(hdr_version "$THEME_DIR/style.css" Version)"
THEME_NAME="$(hdr_version "$THEME_DIR/style.css" 'Theme Name')"
[ -z "$THEME_VERSION" ] && THEME_VERSION="(nepoznato)"
echo "  Tema:        ${THEME_NAME:-?}  v${THEME_VERSION}"
echo "  Putanja:     $THEME_DIR"

if grep -qi "^Template:" "$THEME_DIR/style.css" 2>/dev/null; then
  warn "Ovaj direktorij je CHILD tema (Template: $(hdr_version "$THEME_DIR/style.css" Template)) — izvještaj se odnosi na nju."
  if [ -z "$CHILD_DIR" ]; then
    info "Savjet: proslijedi i putanju do parent teme kako bi provjera predložaka bila točna."
  fi
fi

if [ -n "$WC_DIR" ] && [ -f "$WC_DIR/woocommerce.php" ]; then
  WC_VERSION="$(hdr_version "$WC_DIR/woocommerce.php" Version)"
  echo "  WooCommerce: v${WC_VERSION}"
else
  WC_VERSION=""
  warn "WooCommerce nije pronađen na zadanoj putanji — preskačem usporedbu predložaka."
fi

php -v >/dev/null 2>&1 && echo "  PHP (CLI):   $(php -r 'echo PHP_VERSION;' 2>/dev/null)"

# ---------- 2. deklarirana kompatibilnost ---------------------------------
section "2. Deklarirana kompatibilnost (style.css / readme)"
REQ_WP="$(hdr_version "$THEME_DIR/style.css" 'Requires at least')"
TESTED_WP="$(hdr_version "$THEME_DIR/style.css" 'Tested up to')"
REQ_PHP="$(hdr_version "$THEME_DIR/style.css" 'Requires PHP')"
echo "  Requires at least: ${REQ_WP:-nije deklarirano}"
echo "  Tested up to:      ${TESTED_WP:-nije deklarirano}"
echo "  Requires PHP:      ${REQ_PHP:-nije deklarirano}"
info "ApusTheme deklaracije objavljuje na ThemeForest stranici proizvoda, ne u style.css."

# ---------- 3. WooCommerce predlošci --------------------------------------
if [ -n "$WC_VERSION" ]; then
  section "3. WooCommerce template override audit (tema vs instalirani WC)"
  CORE_TPL="$WC_DIR/templates"
  STALE=0; TOTAL=0; DEAD=0; STALE_LIST=""

  while IFS= read -r rel; do
    tf="$THEME_DIR/woocommerce/$rel"
    cf="$CORE_TPL/$rel"
    tv="$(tmpl_version "$tf")"
    cv="$(tmpl_version "$cf")"
    TOTAL=$((TOTAL+1))
    if ver_gt "$cv" "$tv"; then
      STALE=$((STALE+1))
      STALE_LIST="${STALE_LIST}    ${rel}|${tv}|${cv}\n"
    fi
  done < <(cd "$THEME_DIR/woocommerce" 2>/dev/null && find . -type f -name '*.php' | sed 's|^\./||' | while read -r f; do [ -f "$CORE_TPL/$f" ] && echo "$f"; done)

  if [ "$STALE" -eq 0 ]; then
    ok "Svi usporedivi overridei (${TOTAL}) su na razini instaliranog WooCommercea."
  else
    fail "${STALE} od ${TOTAL} overridea je starije od instaliranog WooCommercea v${WC_VERSION}"
    printf "%b" "$STALE_LIST" | sort -t'|' -k1,1 | while IFS='|' read -r f tv cv; do
      printf '        %-42s tema: %-8s WC: %s\n' "$f" "${tv:-?}" "${cv:-?}"
    done
  fi

  # overridei kojih više nema u core-u (mrtvi / theme-only)
  DEAD_LIST=""
  while IFS= read -r rel; do
    [ -f "$CORE_TPL/$rel" ] || DEAD_LIST="${DEAD_LIST}    ${rel}\n"
  done < <(cd "$THEME_DIR/woocommerce" 2>/dev/null && find . -type f -name '*.php' | sed 's|^\./||')
  DEAD=$(printf "%b" "$DEAD_LIST" | grep -c . || true)
  info "Datoteka koje nema u WooCommerce core-u (theme-only ili uklonjene): ${DEAD}"
  [ "$DEAD" -gt 0 ] && printf "%b" "$DEAD_LIST" | head -15

  # ---------- 4. nedostajuci hookovi u overrideima ------------------------
  section "4. Hookovi koje core ima, a override u temi ne poziva"
  MISSING=0; DELEGATED=0
  while IFS= read -r rel; do
    tf="$THEME_DIR/woocommerce/$rel"; cf="$CORE_TPL/$rel"
    [ -f "$cf" ] || continue
    # predlosci koji samo delegiraju na drugi predlozak ili na woocommerce_content()
    if grep -qE 'wc_get_template|woocommerce_content\(' "$tf" 2>/dev/null; then
      DELEGATED=$((DELEGATED+1)); continue
    fi
    MISS="$(comm -23 \
      <(grep -oE "(do_action|apply_filters)\(\s*['\"][a-z0-9_]+" "$cf" | grep -oE "['\"][a-z0-9_]+$" | tr -d "'\"" | grep -v '_$' | sort -u) \
      <(grep -oE "(do_action|apply_filters)\(\s*['\"][a-z0-9_]+" "$tf" | grep -oE "['\"][a-z0-9_]+$" | tr -d "'\"" | grep -v '_$' | sort -u) \
      | tr '\n' ' ')"
    if [ -n "${MISS// /}" ]; then
      MISSING=$((MISSING+1))
      printf '        %-40s %s\n' "$rel" "$MISS"
    fi
  done < <(cd "$THEME_DIR/woocommerce" 2>/dev/null && find . -type f -name '*.php' | sed 's|^\./||' | while read -r f; do [ -f "$CORE_TPL/$f" ] && echo "$f"; done)

  [ "$DELEGATED" -gt 0 ] && info "${DELEGATED} overridea samo delegira na drugi predložak / woocommerce_content() — preskočeno."
  [ "$MISSING" -eq 0 ] && ok "Nema razlika u hookovima." || \
    warn "${MISSING} overridea ne poziva sve hookove core predloška (utječe na dodatke koji se kače na njih)."
fi

# ---------- 5. Elementor ---------------------------------------------------
section "5. Elementor kompatibilnost"
SCHEMES="$(grep -rl 'Core\\Schemes' "$THEME_DIR" --include='*.php' 2>/dev/null | sed "s|$THEME_DIR/||")"
if [ -n "$SCHEMES" ]; then
  fail "Korištenje uklonjenih Elementor Scheme klasa (uklonjeno u Elementor 3.26+, fatal u editoru):"
  printf '%s\n' "$SCHEMES" | sed 's/^/        /'
else
  ok "Nema referenci na uklonjene Core\\Schemes klase."
fi

DEPR="$(grep -rl 'register_widget_type\|widgets_registered\|controls_registered' "$THEME_DIR" --include='*.php' 2>/dev/null | sed "s|$THEME_DIR/||")"
if [ -n "$DEPR" ]; then
  warn "Korištenje deprecated Elementor API-ja (radi, ali puni debug.log deprecationima):"
  printf '%s\n' "$DEPR" | sed 's/^/        /'
else
  ok "Nema deprecated Elementor API poziva."
fi

# ---------- 6. PHP 8.x -----------------------------------------------------
section "6. PHP 8.x (uklonjene funkcije / obrasci)"
PATTERNS='\bcreate_function\s*\(|\b(ereg|eregi|ereg_replace|eregi_replace|split|spliti)\s*\(|\bmysql_[a-z_]+\s*\(|\bmcrypt_[a-z_]+\s*\(|\bget_magic_quotes_(gpc|runtime)\s*\(|\bmoney_format\s*\(|\bset_magic_quotes_runtime\s*\(|\butf8_(en|de)code\s*\(|\bstrftime\s*\(|\bgmstrftime\s*\(|FILTER_SANITIZE_STRING|\$HTTP_RAW_POST_DATA'
HITS="$(grep -rInE "$PATTERNS" "$THEME_DIR" --include='*.php' 2>/dev/null | grep -v '/inc/vendors/' | sed "s|$THEME_DIR/||" | head -20)"
if [ -n "$HITS" ]; then
  fail "Pronađeni obrasci uklonjeni/odbačeni u PHP 8.x:"
  printf '%s\n' "$HITS" | sed 's/^/        /'
else
  ok "Nema očitih PHP 8.x breakera u temi (bez vendor biblioteka)."
fi

EXTR="$(grep -rIln 'extract( *\$' "$THEME_DIR" --include='*.php' 2>/dev/null | wc -l | tr -d ' ')"
[ "$EXTR" -gt 0 ] && info "extract(): ${EXTR} datoteka (radi i na PHP 8.x, ali je loša praksa — ne dirati bez potrebe)."

# ---------- 7. Frontend JS ------------------------------------------------
section "7. jQuery / frontend JS"
JS_HITS="$(grep -rInE '\.load\(\s*function|\.live\(|\.die\(|\.size\(\)|\.andSelf\(|\.browser\.' "$THEME_DIR" --include='*.js' 2>/dev/null | grep -v '\.min\.js' | head -10)"
if [ -n "$JS_HITS" ]; then
  warn "Legacy jQuery pozivi (rade samo zahvaljujući jQuery Migrate):"
  printf '%s\n' "$JS_HITS" | sed "s|$THEME_DIR/||;s/^/        /"
else
  ok "Nema legacy jQuery poziva u ne-kompresiranim JS datotekama."
fi

# ---------- 8. Child tema -------------------------------------------------
section "8. Child tema"
if [ -n "$CHILD_DIR" ] && [ -d "$CHILD_DIR" ]; then
  echo "  Child:        $(hdr_version "$CHILD_DIR/style.css" 'Theme Name') v$(hdr_version "$CHILD_DIR/style.css" Version)"
  if [ -d "$CHILD_DIR/woocommerce" ]; then
    CNT="$(find "$CHILD_DIR/woocommerce" -type f -name '*.php' | wc -l | tr -d ' ')"
    warn "Child tema sadrži ${CNT} WooCommerce overridea — oni pobjeđuju nad parentom i moraju se provjeriti zasebno."
    find "$CHILD_DIR/woocommerce" -type f -name '*.php' | sed "s|$CHILD_DIR/||" | head -20 | sed 's/^/        /'
  else
    ok "Child tema nema vlastite WooCommerce predloške."
  fi
  [ -f "$CHILD_DIR/functions.php" ] && info "Provjeri i child/functions.php na pozive funkcija koje su u novoj verziji teme preimenovane/uklonjene."
else
  info "Child tema nije proslijeđena kao 3. argument — preskočeno."
  info "Preporuka: uvijek provjeri i child temu, njena pravila imaju prednost."
fi

# ---------- 9. Sažetak ----------------------------------------------------
section "9. Sažetak"
echo "  FAIL: ${FAILED}    WARN: ${WARNED}"
if [ "$FAILED" -gt 0 ]; then
  echo "  Zaključak: tema NIJE spremna za ciljni stack bez intervencije (vidi FAIL stavke)."
  exit 1
elif [ "$WARNED" -gt 0 ]; then
  echo "  Zaključak: tema je načelno upotrebljiva, ali s rizicima — obavezno testirati na stagingu."
  exit 0
else
  echo "  Zaključak: nema blokirajućih nalaza."
  exit 0
fi
