#!/data/data/com.termux/files/usr/bin/bash

# ================================================================
#  WINTER-REJOIN AUTO SETUP - ALL IN ONE
#  Usage: bash <(curl -sL https://raw.githubusercontent.com/MarchianoKevinPrasetyaDjati/CONFIGROBLOX/main/setup.sh) NOMOR_CLOUD
#  Contoh: bash <(curl -sL ...) 1   → cloud 1 (PS baris 1)
#          bash <(curl -sL ...) 3   → cloud 3 (PS baris 2)
# ================================================================

# ── KONFIGURASI ──────────────────────────────────────────────────
GITHUB_RAW="https://raw.githubusercontent.com/MarchianoKevinPrasetyaDjati/CONFIGROBLOX/main"
PS_FILE_URL="${GITHUB_RAW}/ps_links.txt"
# ────────────────────────────────────────────────────────────────

CLOUD_NUM=${1:-1}
case "$CLOUD_NUM" in
    ''|*[!0-9]*) err "Nomor cloud harus berupa angka positif (contoh: 1, 2, 3)" ;;
esac
[ "$CLOUD_NUM" -ge 1 ] || err "Nomor cloud minimal 1"

PS_LINE=$(( (CLOUD_NUM - 1) / 3 + 1 ))   # 3 cloud per PS: cloud 1-3=baris1, 4-6=baris2, dst

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $1"; }
info() { echo -e "${CYAN}[→]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗] ERROR: $1${NC}"; exit 1; }
line() { echo -e "${CYAN}────────────────────────────────────────${NC}"; }

clear
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║      WINTER-REJOIN AUTO SETUP            ║"
printf "║      Cloud #%-2s  │  Grup PS Baris %-2s      ║\n" "$CLOUD_NUM" "$PS_LINE"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ── STEP 0: BUKA DEVELOPER OPTIONS ──────────────────────────────
line
info "Step 0: Membuka Developer Options..."
if command -v am >/dev/null 2>&1; then
    am start -a android.settings.APPLICATION_DEVELOPMENT_SETTINGS >/dev/null 2>&1         || am start -n com.android.settings/.DevelopmentSettings >/dev/null 2>&1         || warn "Gagal membuka Developer Options otomatis. Buka manual di Settings."
else
    warn "Perintah am tidak tersedia. Buka Developer Options manual."
fi

warn "Di Developer Options lakukan ini dulu:"
warn "1) Matikan semua Animation scale (Window/Transition/Animator)."
warn "2) Aktifkan Enable freeform windows."
warn "3) Aktifkan Enable resizable windows."

info "Mencoba set DPI ke 600..."
if command -v wm >/dev/null 2>&1; then
    wm density 600 >/dev/null 2>&1 \
        && log "DPI berhasil diset ke 600" \
        || warn "Gagal set DPI ke 600 otomatis. Set manual jika perlu."
else
    warn "Perintah wm tidak tersedia. Set DPI 600 manual jika diperlukan."
fi

echo -e "${YELLOW}Tekan Enter setelah selesai setting Developer Options...${NC}"
read -r

# ── STEP 1: STORAGE PERMISSION ──────────────────────────────────
line
info "Step 1: Setup storage permission..."
termux-setup-storage 2>/dev/null || true
sleep 3
[ -d "/sdcard/Download" ] || err "/sdcard/Download tidak ditemukan. Berikan permission storage dulu!"
log "Storage OK"

# ── STEP 2: INSTALL PACKAGES ────────────────────────────────────
line
info "Step 2: Install packages..."
pkg update -y -o Dpkg::Options::="--force-confnew" 2>/dev/null | tail -1
pkg install -y lua53 sqlite termux-api unzip 2>/dev/null | tail -3
log "Packages OK"

# ── STEP 3: EXTRACT ZIP CONFIG ──────────────────────────────────
line
info "Step 3: Extract config.zip dari /sdcard/..."
[ -f "/sdcard/config.zip" ] || err "File config.zip tidak ditemukan di /sdcard/! Upload dulu via Redfinger."
unzip -o /sdcard/config.zip -d /sdcard/ > /dev/null 2>&1 || err "Gagal extract zip!"
log "Extract selesai - folder Download/ dan RonixExploit/ sudah ditimpa"

# ── STEP 4: INSTALL 8 CLONE APK ROBLOX ─────────────────────────
line
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║   STEP 4: INSTALL 6 CLONE APK ROBLOX             ║${NC}"
echo -e "${BOLD}${CYAN}║   Mendownload & install semua clone Roblox...    ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
info "Menjalankan installer.lua (pilih 1-8 otomatis)..."
cd /sdcard/Download || err "Gagal masuk ke /sdcard/Download"
echo "1-6" | lua installer.lua
if [ $? -ne 0 ]; then
    warn "installer.lua selesai dengan error — cek apakah semua APK berhasil terinstall"
else
    log "Semua 6 clone APK Roblox berhasil diinstall!"
fi
echo ""

# ── STEP 5: AMBIL PS LINK DARI GITHUB ───────────────────────────
line
info "Step 5: Ambil Private Server link dari GitHub (baris ${PS_LINE})..."
RAW_PS=$(curl -sf "$PS_FILE_URL" | grep -v '^#' | grep -v '^$' | sed -n "${PS_LINE}p")

if [ -z "$RAW_PS" ]; then
    warn "Gagal ambil PS link dari GitHub!"
    echo -e "${YELLOW}Masukkan PS link manual (https://www.roblox.com/share?code=...):${NC}"
    read -r RAW_PS
    [ -z "$RAW_PS" ] && err "PS link tidak boleh kosong!"
fi

# Konversi ke deeplink format
PS_CODE=$(printf '%s\n' "$RAW_PS" | sed -n 's/.*[?&]code=\([^&]*\).*/\1/p')
[ -z "$PS_CODE" ] && err "Format PS link tidak valid! Pastikan ada ?code= di URL"

DEEPLINK="https://www.roblox.com/share-links?code=${PS_CODE}&type=Server&pid=Server&is_retargeting=false&deep_link_value=roblox%3A%2F%2Fnavigation%2Fshare_links%3Fcode%3D${PS_CODE}%26type%3DServer"
DEEPLINK_ESCAPED=$(printf '%s\n' "$DEEPLINK" | sed 's/[&|]/\\&/g')

log "PS Code: ${PS_CODE}"
log "Deeplink siap"

# Update auto_rejoin.conf dengan PS link baru
CONF="/sdcard/Download/WinterHub/auto_rejoin.conf"
[ -f "$CONF" ] || err "File auto_rejoin.conf tidak ditemukan!"

sed -i "s|^shared_link_1=.*|shared_link_1=${DEEPLINK_ESCAPED}|" "$CONF"
sed -i "s|^deeplink=.*|deeplink=${DEEPLINK_ESCAPED}|" "$CONF"
log "PS link berhasil diupdate di auto_rejoin.conf"

# ── STEP 6: PROSES COOKIES ───────────────────────────────────────
line
info "Step 6: Memproses cookies untuk cloud #${CLOUD_NUM}..."

COOKIE_FILE="/sdcard/Download/cookie.txt"
[ -f "$COOKIE_FILE" ] || err "cookie.txt tidak ditemukan di /sdcard/Download/!"

START_LINE=$(( (CLOUD_NUM - 1) * 6 + 1 ))
END_LINE=$(( CLOUD_NUM * 6 ))

COOKIES_INPUT=$(sed -n "${START_LINE},${END_LINE}p" "$COOKIE_FILE")
[ -z "$COOKIES_INPUT" ] && err "Akun untuk cloud #${CLOUD_NUM} (baris ${START_LINE}-${END_LINE}) tidak ditemukan di cookie.txt!"

# Cek jumlah baris yang didapat
GOT_LINES=$(echo "$COOKIES_INPUT" | grep -c '.')
if [ "$GOT_LINES" -lt 6 ]; then
    warn "Peringatan: cloud #${CLOUD_NUM} hanya mendapat ${GOT_LINES} akun (kurang dari 6)!"
    warn "Baris ${START_LINE}-${END_LINE} di cookie.txt tidak lengkap."
fi

# Timpa cookie.txt hanya dengan 6 baris akun untuk cloud ini
printf '%s\n' "$COOKIES_INPUT" > "$COOKIE_FILE"
log "cookie.txt diupdate dengan akun baris ${START_LINE}-${END_LINE} untuk cloud #${CLOUD_NUM}"
log "Cookies disimpan ke /sdcard/Download/cookie.txt"

# ── STEP 7: JALANKAN WINTER-REJOIN ──────────────────────────────
line
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║   STEP 7: MENJALANKAN WINTER-REJOIN              ║${NC}"
echo -e "${BOLD}${GREEN}║   Cloud #${CLOUD_NUM} - Auto Rejoin Aktif                 ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
sleep 1

cd /sdcard/Download || err "Gagal masuk ke /sdcard/Download"
info "Download winter-rejoin.lua terbaru..."
curl -L -o /sdcard/Download/winter-rejoin.lua https://raw.githubusercontent.com/FnDXueyi/roblog/refs/heads/main/winter-rejoin.lua || err "Gagal download winter-rejoin.lua!"
log "Download selesai"
info "Menjalankan winter-rejoin.lua..."
lua /sdcard/Download/winter-rejoin.lua
