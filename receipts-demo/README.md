# receipts-demo

Evidence for the **technique** the receipts systems use, not for OCR or RAG quality:

> probe the environment → derive a connection state → gate advanced features on it → show a labelled fallback →
> re-probe.

- `demo.sh` — start/stop one backend at a time (all bind `:5001`), health-check it, or take a headless screenshot.
- `probe.sh` — emits JSONL: one record per target with the HTTP code, derived state (`connected`/`unavailable`), and
  the client gate that depends on it. Run it once with the backend down and once up.
- `SCREENSHOTS.md` — the annotated evidence set: offline/online pairs for all three systems plus the raw probes and
  the code branch.
- `samples/incident.log` — a synthetic log if you also want a connected RAG interaction; not required for the
  capability-gating evidence.
- `shots/` — commit captured PNGs and `probe-*.jsonl` here.

```bash
export RECEIPTS_DIR=...            # or OCR_DIR / RAG_DIR / RAG2_DIR
./receipts-demo/demo.sh doctor
./receipts-demo/demo.sh down
./receipts-demo/probe.sh > receipts-demo/shots/probe-down.jsonl
./receipts-demo/demo.sh ocr
./receipts-demo/probe.sh > receipts-demo/shots/probe-up.jsonl
```

The point: the live Pages URLs are clients, not the system. Show that the strong path is gated on a verified probe
and that the fallback is labelled — and mark anything not captured honestly.
