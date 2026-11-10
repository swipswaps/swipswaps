# receipts-demo

Helpers to make the receipts-ocr family judgeable, and to capture its connected behaviour so reviewers do not need
Docker.

- `demo.sh` — start one backend at a time (all bind `:5001`), health-check it, stop all, or take a headless
  screenshot.
- `SCREENSHOTS.md` — the annotated shot list and exact steps.
- `samples/incident.log` — a synthetic dev log with an error, a failing command, a fix, and a success, for the RAG
  upload demo.
- `shots/` — commit the captured PNGs here.

```bash
export RECEIPTS_DIR=~/Documents/82ff64b4-acf6-4a50-95e1-9c474107cdf6
./receipts-demo/demo.sh doctor
./receipts-demo/demo.sh ocr
# open https://swipswaps.github.io/receipts-ocr/ and follow SCREENSHOTS.md
./receipts-demo/demo.sh down
```

The point of this folder: the live Pages URLs are clients, not the system. Capture the connected state once so the
portfolio evidences the real behaviour, and mark anything not captured honestly.
