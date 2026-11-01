# Upstream sync — 2026-11-01 (post-publication state)

This file records the public-repo state after the event submission was
published, so the event repo does not contradict the public Core repo.

## Core repo (https://github.com/Amitakshya333/maos.git)
- refs/heads/main: advanced to `f54dd7e6db33b0683ff2f2583516bca5dc3f6ce3` on 2026-11-01.
  - `d324129` Reconcile GUI selection binding and REST cancellation (FIX-16 + muted engine-status tone)
  - `f54dd7e` Remove unused simple-git dependency
- refs/tags/event-core-2cfdf9b: `ee569a1b67507c37cf6e968895405a6bd36d0181` (unchanged). Peels to `2cfdf9b`.
- The 9-commit pinned range ending at `2cfdf9b` is unchanged and anonymously fetchable.

## Event submission (unchanged)
The submission still pins the Core base `f9525055c56a7f7771dd2fa029c147c2960a98a3` and applies
0001 → 0002 → 0003 to reconstruct tree `53305f48e6a7fb039bcf72fa38ab102bcccb9cb8` (the tree of
`2cfdf9b`). Reviewers follow README.md §2–§3 and UPSTREAM.md. The advance of public
`main` does not change the judged build.

## Order note
`UPSTREAM.md` describes the pre-advance state (main was `256befbb`). This file is the
later record. Where they disagree, this file wins.
