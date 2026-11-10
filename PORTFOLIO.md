# Reviewer portfolio — swipswaps

I build small, deterministic review artefacts. Each one starts from a shortcut verdict — *the output passed*,
*the longer answer wins*, *the code runs* — and shows, with a reproducible matrix, exactly where that shortcut
fails. The method is the same across all of them: score 0–2 on named dimensions, derive the verdict from the
scores, publish the evidence, and state the limits.

Target role: **GoMeasure — Prompt Quality Reviewer**
https://www.gomeasure.ai/talent-network/roles/prompt-quality-reviewer

Every artefact below is live, has a machine-readable `matrix.json`, and reports its own commit as `buildId`, so
the claim can be checked rather than trusted.

## The four review artefacts

| Artefact | Live demo | Shortcut it defeats | Posting requirement |
|---|---|---|---|
| **gomeasure-rubric-reviewer** | [live](https://swipswaps.github.io/gomeasure-rubric-reviewer/) · [source](https://github.com/swipswaps/gomeasure-rubric-reviewer) · [matrix](https://swipswaps.github.io/gomeasure-rubric-reviewer/matrix.json) | "the output passed, so the rubric is sound" | review rubrics and measurable criteria; calibrate (#1, #2, #5) |
| **edge-case-solution-reviewer** | [live](https://swipswaps.github.io/edge-case-solution-reviewer/) · [source](https://github.com/swipswaps/edge-case-solution-reviewer) · [matrix](https://swipswaps.github.io/edge-case-solution-reviewer/matrix.json) | "it passes every test you showed it, so it is correct" | surface the edge cases the model misses (#3) |
| **coding-agent-interaction-reviewer** | [live](https://swipswaps.github.io/coding-agent-interaction-reviewer/) · [source](https://github.com/swipswaps/coding-agent-interaction-reviewer) · [matrix](https://swipswaps.github.io/coding-agent-interaction-reviewer/matrix.json) | "the code runs, so the interaction is strong" | consistent rubric over outcomes; evidence, not vibes (#2) |
| **micro1-write-like-human-eval** | [live](https://swipswaps.github.io/micro1-write-like-human-eval/) · [source](https://github.com/swipswaps/micro1-write-like-human-eval) · [matrix](https://swipswaps.github.io/micro1-write-like-human-eval/matrix.json) | "it is fluent and longer, so it is better writing" | analytical scores with detailed rationales (#2, #4) |

What they share:

- **Derived verdicts.** The verdict is computed from the dimension scores, not asserted. A dimension at 0 means
  *defective/misleading*, so the defect class is mechanical rather than editorial.
- **A discrimination matrix.** Each case pairs a tempting *shortcut* verdict with the *measured* verdict; the
  "sound" flag is true only when the rubric rejects the shortcut on every case where it is wrong.
- **Evidence with provenance.** `matrix.json` is committed to the repo, regenerated in CI, and carries the commit
  as `buildId`; the deploy fails if the committed matrix is stale.
- **Stated limits.** Four cases per rubric, authored meta-scores, and non-exhaustive hidden cases are named in each
  README rather than hidden.

## What each artefact proves against the posting

- **Review prompts, constraints, rubrics and criteria** — `gomeasure-rubric-reviewer` reviews the *rubric*, not the
  output: five dimensions (measurability, coverage, discrimination, specificity, calibration), each cited to HELM,
  Diataxis, Concrete Problems in AI Safety, NIST AI RMF, and Cohen's kappa.
- **Apply clear, consistent rubrics; explain with concrete evidence** — every case carries the evidence for the
  measured verdict, and `gomeasure` names the exact replacement criterion in its proposed fix.
- **Surface errors, risks and edge cases** — `edge-case-solution-reviewer` separates *visible tests passed* from
  *hidden constraint cases passed*; `coding-agent-interaction-reviewer` catches the plausible fix that would break
  in production (e.g. `trust proxy: true`).
- **Recommend improvements** — `gomeasure` emits a concrete `replace`/`add` fix per defective rubric; `micro1`
  scores against the posting's own scope (clarity, tone, helpfulness, adherence, substance).
- **Calibrate with other reviewers** — `gomeasure` derives calibration from two independent reviewers
  (0 disagreements → 2, every criterion disputed → 0); `micro1` is pairwise by construction.

## Advanced systems — the receipts-ocr family (connected mode)

These are the engineering-heavy pieces. They are **local-first**: the GitHub Pages site is the interface, and the
intelligence runs on your machine. That is deliberate — evidence and data stay local — but it means the advanced
features unlock only when the page is **connected** to the local backend.

| Project | Live frontend | Connect the backend | What unlocks when connected | Without a backend |
|---|---|---|---|---|
| **receipts-ocr** | [live](https://swipswaps.github.io/receipts-ocr/) · [source](https://github.com/swipswaps/receipts-ocr) | `docker compose up -d`, then open the Pages URL (frontend calls `localhost:5001`) | PaddleOCR v3+ with column-first layout analysis, smart block grouping into addresses/items/tables, orientation auto-correction, HEIC/EXIF handling, 5 exports (Text/JSON/CSV/XLSX/SQL), live backend logs over SSE, SQLite persistence, LAN/phone access | automatic **Tesseract.js** fallback (works anywhere, lower accuracy) |
| **receipts-ocr-rag** | [live](https://swipswaps.github.io/receipts-ocr-rag/) · [source](https://github.com/swipswaps/receipts-ocr-rag) | `docker compose up -d`; FastAPI on `:5001` | ingest chat/terminal/receipt logs; extract code blocks, errors, commands and success indicators; semantic search (sentence-transformers); patterns (repeated errors, common commands, working code, error→solution); `/rag/graph` evidence graph; hashes + spans + verification states | static shell; no ingestion or search |
| **receipts-ocr-rag-v2** | [live](https://swipswaps.github.io/receipts-ocr-rag-v2/) · [source](https://github.com/swipswaps/receipts-ocr-rag-v2) | `docker compose up -d`; backend on `:5001` (`/api/health`) | v2.0.5 of the same contract, rebuilt frontend; the same extract → search → patterns flow | static shell; no ingestion or search |

**Why this matters for a reviewer role.** The RAG work encodes the same principle as the rubrics: *never trust a
model's self-reported confidence; require deterministic evidence.* The README models each extracted item as
`source → observation → evidence → claim → entity`, with a content hash, a source span, timestamps, and a
verification state (`PROPOSED → EXECUTED → VERIFIED → CORROBORATED / REJECTED`). The roadmap is an agentic knowledge
CRM over MCP + LiteLLM, with the model swappable and the evidence model fixed.

**Honest caveat for anyone evaluating this.** If you click the receipts live links without starting the backend you
will see a frontend shell (and the RAG v1 page is limited by the browser's Private Network Access rules). The full
system is one command away locally. If you will not run Docker, ask me for a recorded walkthrough — do not judge the
OCR/RAG work from the static page alone.

## Reproduce in five minutes

```bash
# Any reviewer artefact
git clone https://github.com/swipswaps/<artefact>
cd <artefact>
npm ci && npm run review      # prints the discrimination matrix and "sound: yes"
npm run build && npx playwright test

# Receipts OCR, full mode
git clone https://github.com/swipswaps/receipts-ocr && cd receipts-ocr
docker compose up -d          # ~2 GB first run; wait for "PaddleOCR initialized successfully"
# then open https://swipswaps.github.io/receipts-ocr/
```

## Limits I will defend, not hide

- Each reviewer demonstrates a *method* on four cases; it is not a benchmark.
- The non-calibration meta-scores are authored, not measured from live raters.
- Hidden cases are not exhaustive; `edge-case-solution-reviewer` now runs candidates in a bounded child process,
  but `node:vm` is still not a security boundary (documented in that repo).
- The receipts systems are local-first prototypes; the hosted pages require a local backend for full behaviour.
- The review artefacts are English-only.

---

Source for every claim: the linked repo README and the live `matrix.json`. If a claim here is not backed by one of
those, treat it as a bug in this page.
