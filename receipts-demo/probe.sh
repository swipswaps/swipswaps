#!/usr/bin/env bash
# probe.sh — record the capability signal the clients use to turn advanced
# features on. This is the evidence for the *technique*: probe -> state ->
# gate -> labelled fallback. It does not care what the OCR/RAG does.
#
#   ./receipts-demo/probe.sh            # JSONL, one record per target
#   ./receipts-demo/probe.sh > receipts-demo/shots/probe-up.jsonl
#
# Run it once with the backend down and once with it up; commit both files.
set -o pipefail

probe_one() {
    local name="$1" url="$2" gate="$3" code state body tmp
    tmp="$(mktemp)"
    code="$(curl -s -m 3 -o "$tmp" -w '%{http_code}' "$url")"
    body="$(python3 -c 'import sys;print(" ".join(open(sys.argv[1],errors="replace").read().split())[:200])' "$tmp")"
    rm -f "$tmp"
    if [ "$code" = "200" ]; then state="connected"; else state="unavailable"; fi
    python3 - "$name" "$url" "$code" "$state" "$gate" "$body" <<'PY'
import datetime, json, sys
name, url, code, state, gate, body = sys.argv[1:7]
print(json.dumps({
    "at": datetime.datetime.now(datetime.timezone.utc).isoformat(timespec="seconds"),
    "target": name,
    "url": url,
    "http": code,
    "state": state,
    "client_gate": gate,
    "body_excerpt": body,
}, separators=(",", ":")))
PY
}

printf '{"at":"%s","event":"probe-start"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
probe_one ocr  "http://localhost:5001/health"   "backendHealth.status === 'healthy'"
probe_one rag  "http://localhost:5001/"          "status = 'Online - N entries indexed'"
probe_one rag2 "http://localhost:5001/api/health" "status === 'online'"
printf '{"at":"%s","event":"probe-end"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
