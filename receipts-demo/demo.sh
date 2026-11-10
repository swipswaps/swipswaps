#!/usr/bin/env bash
# receipts-demo/demo.sh — run one receipts backend at a time, because all three
# bind :5001. The hosted Pages frontend is the client; the backend is local.
#
#   demo.sh doctor
#   demo.sh ocr      # PaddleOCR + Postgres, then open the receipts-ocr Pages URL
#   demo.sh rag      # Dev Log RAG v1, then open http://localhost:3000
#   demo.sh rag2     # Dev Log RAG v2, then open the v2 Pages URL
#   demo.sh down
#   demo.sh shot <url> [out.png]
#
# Locate the three repos with RECEIPTS_DIR (parent) or OCR_DIR / RAG_DIR / RAG2_DIR.
set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="${RECEIPTS_DIR:-$HOME/Documents}"
OCR_DIR="${OCR_DIR:-$BASE/receipts-ocr}"
RAG_DIR="${RAG_DIR:-$BASE/receipts-ocr-rag}"
RAG2_DIR="${RAG2_DIR:-$BASE/receipts-ocr-rag-v2}"
SHOTS="$HERE/shots"

OCR_SITE="https://swipswaps.github.io/receipts-ocr/"
RAG_SITE="https://swipswaps.github.io/receipts-ocr-rag/"
RAG_LOCAL="http://localhost:3000/"
RAG2_SITE="https://swipswaps.github.io/receipts-ocr-rag-v2/"

have() { command -v "$1" >/dev/null 2>&1; }
say() { printf '%s\n' "$*"; }
die() { printf '[error] %s\n' "$*" >&2; exit 2; }
compose() { [ -f "$1/docker-compose.yml" ] || die "missing $1/docker-compose.yml (set RECEIPTS_DIR or OCR_DIR/RAG_DIR/RAG2_DIR)"; ( cd "$1" && docker compose up -d ); }
down_one() { [ -f "$1/docker-compose.yml" ] && ( cd "$1" && docker compose down ); return 0; }

down_all() { down_one "$OCR_DIR"; down_one "$RAG_DIR"; down_one "$RAG2_DIR"; }

wait_health() {
    local url="$1" n=0 code
    while [ "$n" -lt 60 ]; do
        code="$(curl -s -o /dev/null -w '%{http_code}' "$url")"
        [ "$code" = "200" ] && return 0
        n=$((n + 1)); sleep 2
    done
    return 1
}

up_one() {
    local dir="$1" health="$2" site="$3"
    down_all
    say "--> docker compose up -d in $dir"
    compose "$dir" || die "compose up failed in $dir"
    say "--> waiting for $health"
    wait_health "$health" || die "backend did not become healthy at $health (docker compose logs)"
    say ""
    say "backend: healthy"
    say "open:    $site"
    say "keep this backend running while you capture; then run: demo.sh down"
}

doctor() {
    local d
    say "docker:  $(have docker && docker --version || printf missing)"
    say "compose: $(docker compose version 2>&1 | head -1)"
    say "ocr:     $OCR_DIR $([ -f "$OCR_DIR/docker-compose.yml" ] && printf '[ok]' || printf '[missing]')"
    say "rag:     $RAG_DIR $([ -f "$RAG_DIR/docker-compose.yml" ] && printf '[ok]' || printf '[missing]')"
    say "rag2:    $RAG2_DIR $([ -f "$RAG2_DIR/docker-compose.yml" ] && printf '[ok]' || printf '[missing]')"
    say "playwright: $(have npx && printf 'npx available (run: npx playwright install chromium)' || printf missing)"
    say ""
    say "If any repo is [missing], find it and set RECEIPTS_DIR, e.g.:"
    say "  find ~/Documents -maxdepth 4 -type d -name receipts-ocr"
}

case "${1:-doctor}" in
    doctor) doctor ;;
    ocr) up_one "$OCR_DIR" "http://localhost:5001/health" "$OCR_SITE" ;;
    rag) up_one "$RAG_DIR" "http://localhost:5001/" "$RAG_LOCAL (local; the Pages site is PNA-restricted)" ;;
    rag2) up_one "$RAG2_DIR" "http://localhost:5001/health" "$RAG2_SITE" ;;
    down) down_all; say "stopped all receipts stacks" ;;
    shot)
        url="${2:-$OCR_SITE}"; out="${3:-$SHOTS/connected.png}"
        mkdir -p "$SHOTS"
        npx --yes playwright screenshot --wait-for-timeout 4000 --viewport-size "1440,1000" "$url" "$out" \
            || die "screenshot failed; run: npx playwright install chromium"
        say "wrote $out" ;;
    *)
        say "usage: demo.sh [doctor|ocr|rag|rag2|down|shot <url> <out.png>]" >&2
        exit 2 ;;
esac
