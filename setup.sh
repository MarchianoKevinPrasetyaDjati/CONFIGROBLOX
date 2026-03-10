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
PS_CODE=$(echo "$RAW_PS" | grep -oP '(?<=code=)[^&]+')
[ -z "$PS_CODE" ] && err "Format PS link tidak valid! Pastikan ada ?code= di URL"

DEEPLINK="roblox.com/share-links?code=${PS_CODE}&type=Server&pid=Server&is_retargeting=false&deep_link_value=roblox%3A%2F%2Fnavigation%2Fshare_links%3Fcode%3D${PS_CODE}%26type%3DServer"

log "PS Code: ${PS_CODE}"
log "Deeplink siap"

# Update auto_rejoin.conf dengan PS link baru
CONF="/sdcard/Download/WinterHub/auto_rejoin.conf"
[ -f "$CONF" ] || err "File auto_rejoin.conf tidak ditemukan!"

sed -i "s|^shared_link_1=.*|shared_link_1=${DEEPLINK}|" "$CONF"
sed -i "s|^deeplink=.*|deeplink=${DEEPLINK}|" "$CONF"
log "PS link berhasil diupdate di auto_rejoin.conf"

# ── STEP 6: INPUT COOKIES ────────────────────────────────────────
line
echo ""
echo -e "${BOLD}${YELLOW}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${YELLOW}║   STEP 6: MASUKKAN COOKIES ROBLOX                ║${NC}"
echo -e "${BOLD}${YELLOW}║                                                  ║${NC}"
echo -e "${BOLD}${YELLOW}║   1. Buka browser di Redfinger cloud #${CLOUD_NUM}          ║${NC}"
echo -e "${BOLD}${YELLOW}║   2. Login Roblox & copy cookies (_ROBLOSECURITY) ║${NC}"
echo -e "${BOLD}${YELLOW}║   3. Paste di bawah ini lalu tekan ENTER          ║${NC}"
echo -e "${BOLD}${YELLOW}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -ne "${CYAN}Paste cookies → ${NC}"
read -r COOKIES_INPUT

[ -z "$COOKIES_INPUT" ] && err "Cookies tidak boleh kosong!"

# Konversi ke UTF-8 lalu timpa cookie.txt
echo "$COOKIES_INPUT" | python3 -c "
import sys
raw = sys.stdin.buffer.read()
converted = raw.decode('latin-1').encode('utf-8').decode('utf-8').strip()
print(converted)
" > /sdcard/Download/cookie.txt
log "Cookies dikonversi ke UTF-8 dan disimpan ke /sdcard/Download/cookie.txt"

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
lua /sdcard/Download/winter-rejoin.lua </dev/null
