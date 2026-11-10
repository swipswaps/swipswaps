#!/usr/bin/env bash
# receipts-demo/demo.sh — control the local backend that the hosted clients detect.
# All three stacks bind :5001, so this runs one at a time.
#
#   demo.sh doctor
#   demo.sh state            # one reachability sample (see probe.sh)
#   demo.sh probe <args>     # passthrough: probe.sh <args>
#   demo.sh ocr | rag | rag2
#   demo.sh down
#   demo.sh shot <url> [out.png]
#
# Repos are found at $RECEIPTS_DIR/<name>, then ~/Documents/<name>.
set -o pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="${RECEIPTS_DIR:-$HOME/Documents}"
SHOTS="$HERE/shots"

find_repo() {
    local name="$1" override="$2" c
    for c in "$override" "$BASE/$name" "$HOME/Documents/$name"; do
        [ -n "$c" ] || continue
        [ -f "$c/docker-compose.yml" ] && { printf '%s' "$c"; return 0; }
    done
    return 1
}

OCR_DIR="$(find_repo receipts-ocr "${OCR_DIR:-}")" || OCR_DIR="${OCR_DIR:-$BASE/receipts-ocr}"
RAG_DIR="$(find_repo receipts-ocr-rag "${RAG_DIR:-}")" || RAG_DIR="${RAG_DIR:-$BASE/receipts-ocr-rag}"
RAG2_DIR="$(find_repo receipts-ocr-rag-v2 "${RAG2_DIR:-}")" || RAG2_DIR="${RAG2_DIR:-$BASE/receipts-ocr-rag-v2}"

OCR_SITE="https://swipswaps.github.io/receipts-ocr/"
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
    say "backend: healthy (this is the state the client detects)"
    say "open:    $site"
    say "record:  ./receipts-demo/probe.sh up"
    say "stop:    ./receipts-demo/demo.sh down"
}

doctor() {
    say "docker:  $(have docker && docker --version || printf missing)"
    say "compose: $(docker compose version 2>&1 | head -1)"
    say "ocr:     $OCR_DIR $([ -f "$OCR_DIR/docker-compose.yml" ] && printf '[ok]' || printf '[missing]')"
    say "rag:     $RAG_DIR $([ -f "$RAG_DIR/docker-compose.yml" ] && printf '[ok]' || printf '[missing]')"
    say "rag2:    $RAG2_DIR $([ -f "$RAG2_DIR/docker-compose.yml" ] && printf '[ok]' || printf '[missing]')"
    say "playwright: $(have npx && printf 'npx available (run: npx playwright install chromium)' || printf missing)"
    say ""
    say "Repos default to \$RECEIPTS_DIR/<name> then ~/Documents/<name>."
    say "On this host they are at ~/Documents/<name>, so: export RECEIPTS_DIR=~/Documents"
}

case "${1:-doctor}" in
    doctor) doctor ;;
    state) bash "$HERE/probe.sh" state ;;
    probe) shift; bash "$HERE/probe.sh" "$@" ;;
    ocr) up_one "$OCR_DIR" "http://localhost:5001/health" "$OCR_SITE" ;;
    rag) up_one "$RAG_DIR" "http://localhost:5001/" "$RAG_LOCAL (local; Pages is PNA-restricted)" ;;
    rag2) up_one "$RAG2_DIR" "http://localhost:5001/health" "$RAG2_SITE" ;;
    down) down_all; say "stopped all receipts stacks" ;;
    shot)
        url="${2:-$OCR_SITE}"; out="${3:-$SHOTS/connected.png}"
        mkdir -p "$SHOTS"
        npx --yes playwright screenshot --wait-for-timeout 4000 --viewport-size "1440,1000" "$url" "$out" \
            || die "screenshot failed; run: npx playwright install chromium"
        say "wrote $out" ;;
    *)
        say "usage: demo.sh [doctor|state|probe <args>|ocr|rag|rag2|down|shot <url> <out.png>]" >&2
        exit 2 ;;
esac
