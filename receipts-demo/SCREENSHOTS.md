# Receipts family — evidence you can judge without Docker

The three receipts systems are local-first: the GitHub Pages URL is the client and the intelligence runs on a
local backend. That is the design, but it means a reviewer who only clicks the link sees a shell. This checklist
captures the connected behaviour **once**; commit the PNGs under `receipts-demo/shots/` so the portfolio shows
real evidence and nobody has to run Docker to judge it.

## Before you start

```bash
# Docker + compose must be installed.
npx playwright install chromium          # for the headless landing shots
export RECEIPTS_DIR=~/Documents/82ff64b4-acf6-4a50-95e1-9c474107cdf6
# or set OCR_DIR / RAG_DIR / RAG2_DIR individually.

./receipts-demo/demo.sh doctor           # shows which repos were found
```

**Port rule:** all three backends bind `:5001`, so `demo.sh` runs **one stack at a time** — it stops the others
before starting the next. Capture, then `./receipts-demo/demo.sh down`.

## The shot list

| # | File | Stack | What must be visible | Caption / what it proves |
|---|---|---|---|---|
| 01 | `shots/01-ocr-connected.png` | `demo.sh ocr` → OCR Pages URL | backend status healthy, engine **PaddleOCR**, database **PostgreSQL** | "The hosted UI is connected to the local PaddleOCR backend." |
| 02 | `shots/02-ocr-extracted.png` | same | uploaded `test_image.png`, extracted text + parsed fields | "PaddleOCR output on a real image, with layout preserved." |
| 03 | `shots/03-ocr-exports.png` | same | the five export choices (Text/JSON/CSV/XLSX/SQL) | "Results are exportable, not just displayed." |
| 04 | `shots/04-ocr-fallback.png` | `demo.sh down`, reload OCR Pages | **Tesseract.js fallback** notice | "The deployed page degrades gracefully with no backend." |
| 05 | `shots/05-rag-patterns.png` | `demo.sh rag` → `http://localhost:3000` | uploaded `samples/incident.log`; **Repeated Errors** and **Error to Solutions** | "Logs are parsed into errors, commands and fixes." |
| 06 | `shots/06-rag-search.png` | same | query "command that succeeded"; results with provenance and badges | "Search returns evidence, not a confidence score." |
| 07 | `shots/07-rag2-patterns.png` | `demo.sh rag2` → v2 Pages URL | backend online; uploaded sample; patterns/search | "v2 keeps the same extract → search → patterns contract." |
| 08 | `shots/08-rag-graph.json` | `demo.sh rag` | output of `/rag/graph` | "Every extracted item has provenance (the evidence graph)." |

## Steps in detail

### 01–03 — receipts-ocr (PaddleOCR)

```bash
./receipts-demo/demo.sh ocr
# open https://swipswaps.github.io/receipts-ocr/
# headless option (after the backend is healthy):
./receipts-demo/demo.sh shot https://swipswaps.github.io/receipts-ocr/ receipts-demo/shots/01-ocr-connected.png
```

Then, in the page:

1. Confirm the header shows the backend healthy and the engine as PaddleOCR (01).
2. Upload the repo's `test_image.png` (400×100). Click **Extract Text**. Wait for the result panel (02).
3. Open the export control and capture the five formats (03).
4. `./receipts-demo/demo.sh down`, reload the page, capture the Tesseract.js fallback banner (04).

### 05–06 — Dev Log RAG v1

```bash
./receipts-demo/demo.sh rag
# open http://localhost:3000/   (use the local frontend: the Pages site is PNA-restricted)
```

1. Upload `receipts-demo/samples/incident.log` with the file picker.
2. Click **Show Patterns**; capture the **Repeated Errors** and **Error to Solutions** tabs (05).
3. Search `command that succeeded`; capture the ranked results with their badges (06).
4. Save the graph data:

```bash
curl -s http://localhost:5001/rag/graph -o receipts-demo/shots/08-rag-graph.json
```

### 07 — Dev Log RAG v2

```bash
./receipts-demo/demo.sh rag2
# open https://swipswaps.github.io/receipts-ocr-rag-v2/
```

Upload the same sample, then capture the connected state, patterns and search (07).

### Stop

```bash
./receipts-demo/demo.sh down
```

## Embedding the shots

Put the PNGs in `receipts-demo/shots/` and reference them from the receipts section:

```markdown
![PaddleOCR backend connected](receipts-demo/shots/01-ocr-connected.png)
*Hosted UI connected to the local PaddleOCR backend (`receipts-ocr`, commit `…`).*
```

A short screen recording (10–20 s: upload → extract → result) is stronger than a still for 02 and 05; if you add
one, put it at `shots/ocr-demo.mp4` and link it.

## Honesty rule

If a shot was not captured against a running backend, do not ship it. A labelled "not captured" is better than a
screenshot that implies a connection that did not happen.
