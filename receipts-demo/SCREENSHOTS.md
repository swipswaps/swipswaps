# Capability gating — evidence you can judge without Docker

The receipts systems exist to demonstrate a **technique**, not to show off OCR or RAG output:

> probe the environment → derive a connection state → gate the advanced path on that state → show a labelled
> fallback when the capability is absent → re-probe so the state cannot go stale.

That is *progressive enhancement with verified capability detection*. The domain features (PaddleOCR, semantic
search) are the payload; the thing worth reviewing is how the client decides it may use them.

Capture this once, commit the artifacts under `receipts-demo/shots/`, and a reviewer never has to run Docker.

## The pattern, and where it lives

| Step | receipts-ocr | Dev Log RAG v1 | Dev Log RAG v2 |
|---|---|---|---|
| **Probe** | `checkBackendHealth()` → `localhost:5001/health` | `fetch(API_BASE)` | `fetch(${API_BASE}/api/health)` every 15 s |
| **State** | `backendHealth.status: checking → healthy/unhealthy` | `#status` class `online/offline` | `status: checking → online/offline` |
| **Gate** | `backendHealth.status === 'healthy'` enables history/save/exports; else `processWithTesseract` | Online enables upload/search/patterns | `status !== 'online'` blocks upload, search, patterns |
| **Fallback** | log: *"Docker backend unavailable, using Tesseract.js fallback"* | text: *"Backend Offline"* | text: *"❌ Offline"* + *"Run backend locally for full features"* |
| **Reset** | manual re-check button | page reload | 15 s interval |

Base-URL selection is itself part of the technique: `receipts-ocr/src/config.ts` and
`receipts-ocr-rag-v2/src/config.ts` choose `API_BASE` from `window.location.hostname` (GitHub Pages → `localhost:5001`;
LAN → that host). The deployment fix for v2 (`fix-gh-pages-receipts-ocr-rag-v2.sh`) is the same concern: make the
hosted client look at the right local origin.

## Evidence set

Capture each **pair**, plus the raw probe. The pair is the proof: same page, different capability, different UI.

| # | File | State | What must be visible |
|---|---|---|---|
| 01 | `shots/01-ocr-offline.png` | backend stopped | fallback log line; history/save/exports disabled |
| 02 | `shots/02-ocr-online.png` | backend up | engine **PaddleOCR**, database **PostgreSQL**, advanced controls enabled |
| 03 | `shots/probe-down.jsonl` | backend stopped | `state:"unavailable"`, `http:"000"` for all three |
| 04 | `shots/04-rag1-offline.png` | backend stopped | `#status` = **Backend Offline** |
| 05 | `shots/05-rag1-online.png` | backend up | `#status` = **Online — N entries indexed** |
| 06 | `shots/06-rag2-offline.png` | backend stopped | **❌ Offline** + *"Run backend locally for full features"* |
| 07 | `shots/07-rag2-online.png` | backend up | **✅ Online**; upload/search/patterns enabled |
| 08 | `shots/probe-up.jsonl` | backend up | `state:"connected"`, `http:"200"`, health body excerpt |
| 09 | `shots/09-gate-code.png` | either | the exact branch: `config.ts` base choice + the `status === ...` gate |

Do **not** lead with OCR text or RAG result quality. A cropped screenshot of the condition and the resulting control
state is the evidence.

## Steps

```bash
export RECEIPTS_DIR=...            # or OCR_DIR / RAG_DIR / RAG2_DIR
./receipts-demo/demo.sh doctor
```

### Receipts OCR (States 01–03)

```bash
# State A: capability absent
./receipts-demo/demo.sh down
./receipts-demo/probe.sh > receipts-demo/shots/probe-down.jsonl

# State B: capability present
./receipts-demo/demo.sh ocr
./receipts-demo/probe.sh > receipts-demo/shots/probe-up.jsonl

# Headless screenshot of the connected page (after health is green)
./receipts-demo/demo.sh shot https://swipswaps.github.io/receipts-ocr/ receipts-demo/shots/02-ocr-online.png
```

Then capture `01-ocr-offline.png` after `demo.sh down` and a reload. In both cases capture the same region: connection
indicator, engine/database, and whether history/save are enabled.

### Dev Log RAG v1 (States 04–05)

```bash
./receipts-demo/demo.sh rag
# open http://localhost:3000/  (local frontend; the Pages site is PNA-restricted)
```

Capture `#status` online, then `demo.sh down` and reload for `#status` offline.

### Dev Log RAG v2 (States 06–07)

```bash
./receipts-demo/demo.sh rag2
# open https://swipswaps.github.io/receipts-ocr-rag-v2/
```

Capture ✅ Online with *"Run backend locally for full features"* absent, then stop the backend and capture the same
area showing ❌ Offline and the hint present.

### Code branch (State 09)

Open the file and screenshot the two lines that matter — the `API_BASE` branch in `config.ts` and the
`status === 'online'` / `backendHealth.status === 'healthy'` gate. This shows the technique is in the code, not just
the caption.

### Stop

```bash
./receipts-demo/demo.sh down
```

## Embedding

```markdown
| Capability absent | Capability present |
|---|---|
| ![offline](receipts-demo/shots/01-ocr-offline.png) | ![online](receipts-demo/shots/02-ocr-online.png) |

Raw probes: [`probe-down.jsonl`](receipts-demo/shots/probe-down.jsonl) ·
[`probe-up.jsonl`](receipts-demo/shots/probe-up.jsonl).
```

## Honesty rule

Every "present" shot must have its matching `probe-up.jsonl` record taken in the same session. If a state was not
captured against a running backend, label it "not captured" rather than shipping an implied connection.
