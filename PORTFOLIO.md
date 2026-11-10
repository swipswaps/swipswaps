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

## Portfolio showcase

The index that ties these together:
[swipswaps-portfolio-showcase](https://swipswaps.github.io/swipswaps-portfolio-showcase/) ·
[source](https://github.com/swipswaps/swipswaps-portfolio-showcase).

It is a 3D repository index, and it demonstrates the same capability discipline as the instruments: the page picks
its API base from the host (`github.io` → the local HTTPS proxy, `localhost` → local HTTP), probes `/api/health`,
shows **Server: Online / Offline (fallback)**, and falls back to the GitHub API when no local backend is present.
Detect the environment, expose the state, gate the strong path, label the fallback.

Application letters are tailored per employer from these instruments and their live `matrix.json`; they are not
published here.

## Reproduce in five minutes

```bash
git clone https://github.com/swipswaps/<artefact>
cd <artefact>
npm ci && npm run review      # prints the discrimination matrix and "sound: yes"
npm run build && npx playwright test
```

## Limits I will defend, not hide

- Each reviewer demonstrates a *method* on four cases; it is not a benchmark.
- The non-calibration meta-scores are authored, not measured from live raters.
- Hidden cases are not exhaustive; `edge-case-solution-reviewer` now runs candidates in a bounded child process,
  but `node:vm` is still not a security boundary (documented in that repo).
- The review artefacts are English-only.

---

Source for every claim: the linked repo README and the live `matrix.json`. If a claim here is not backed by one of
those, treat it as a bug in this page.
