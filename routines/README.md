# Cloud Routine Prompts

These are the production path. Each `.md` here is pasted **verbatim** into a
Claude Code cloud routine (Routines → New Routine). Do not paraphrase — the
env-var check block and the commit-and-push step are load-bearing.

## The five cron schedules (set timezone to America/Chicago, or your market TZ)

| Routine        | Cron          | When (CT)                          |
|----------------|---------------|------------------------------------|
| pre-market     | `0 6 * * 1-5` | 6:00 AM weekdays                   |
| market-open    | `30 8 * * 1-5`| 8:30 AM weekdays (market opens)    |
| midday         | `0 12 * * 1-5`| noon weekdays                      |
| daily-summary  | `0 15 * * 1-5`| 3:00 PM weekdays (market closes)   |
| weekly-review  | `0 16 * * 5`  | 4:00 PM Fridays only               |

> Alpaca timestamps are UTC. Your crons run in whatever timezone you set on
> the routine. Convert carefully.

## Per-routine setup (do once each)

1. Routines → New Routine. Name it (e.g. "Trading bot pre-market").
2. Select this repo, branch `main` (requires the Claude GitHub App on the repo).
3. Add the environment variables (see `env.template` — the same keys, set on
   the routine itself, NOT in a `.env` file).
4. Toggle ON **"Allow unrestricted branch pushes"** — without this, `git push`
   silently fails. This is the #1 reason first-time setups break.
5. Set the cron + timezone from the table above.
6. Paste the matching `routines/<name>.md` into the prompt field, verbatim.
7. Save, then click **Run now** once to smoke-test before relying on the cron.

## Important: cloud runs on a feature branch, not `main`

Claude Code cloud starts each run on an auto-generated branch (e.g.
`claude/kind-euler-pwcmwx`), **not** `main`. A plain `git push origin main`
therefore pushes the unchanged local `main` ref ("Everything up-to-date") and
your memory never reaches the real `main` — silently breaking the git-as-memory
model on the next run.

The routine prompts handle this by pushing with **`git push origin HEAD:main`**,
which fast-forwards remote `main` to whatever the agent just committed on its
feature branch. Keep that form — do not "simplify" it back to `git push origin
main`. (The "Allow unrestricted branch pushes" permission is still required for
HEAD:main to be accepted.)

## Cron is UTC

The cron field is interpreted in **UTC**; the UI preview converts to your local
timezone. The table above is already converted to UTC for US market hours
(Chicago, CDT/summer). When US clocks fall back in November, add +1 hour to each.
