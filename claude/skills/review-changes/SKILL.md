---
name: review-changes
description: "Multi-agent review of staged or unstaged git changes, the current branch, or the last N commits, for bugs, functionality, related code outside the diff that must change too, over-complexity, best practices, repo practice adherence, and style and naming adherence. Can apply the verified fixes."
when_to_use: "Use when the user asks to spin up or launch a number of agents to review the staged or unstaged changes, the current branch, or the last few commits, for example \"Please spin up 3 agents and review the staged changes. Apply the changes you feel relevant.\" or \"Spin up 4 agents and review the last 2 commits.\""
argument-hint: "[agent-count] [staged|unstaged|branch|HEAD~N] [apply]"
allowed-tools: Bash(git diff *) Bash(git status *) Bash(git ls-files *) Bash(git log *) Bash(git rev-parse *) Bash(git symbolic-ref *)
---

# Review changes

Reviewer agents with fresh context read the diff, each one for its assigned areas. You verify what they find, and apply the fixes if the user asks for it.

## Current state

Staged:
!`git diff --cached --stat`

Unstaged:
!`git diff --stat`

Untracked:
!`git ls-files --others --exclude-standard`

## Step 1: Read the request

Arguments: $ARGUMENTS

Get these values from the arguments or from the user's message:

- `AGENT_COUNT`: the number of agents. If there is no number, use 3.
- `SCOPE`: `staged`, `unstaged`, `branch`, or `HEAD~N`. "The last N commits" means `HEAD~N`. If there is none of these, use `both` and say so in the report.
- `APPLY`: true only when the user tells you to apply changes. Otherwise false.

| Scope | Diff command | Commit range | Also in scope |
|---|---|---|---|
| staged | `git diff --cached` | None | Nothing |
| unstaged | `git diff` | None | All untracked files, read in full. Skip binary files. |
| both | `git diff HEAD` | None | All untracked files, read in full. Skip binary files. |
| branch | `git diff {base}...HEAD` | `{base}..HEAD` | Nothing |
| HEAD~N | `git diff HEAD~N HEAD` | `HEAD~N..HEAD` | Nothing |

For the branch scope, find `{base}`:

1. Run `git symbolic-ref --short refs/remotes/origin/HEAD`.
2. If that fails, use the first of `main` and `master` that `git rev-parse --verify` finds.
3. If neither exists, ask the user for the base branch.

For the HEAD~N scope, run `git rev-parse --verify HEAD~N`. If it fails, the repo has too few commits, so stop here and tell the user.

For the branch and HEAD~N scopes, run `git log --oneline {commit range}` to get the commit list. "Current state" shows only uncommitted changes, which are not in these scopes. If it shows uncommitted changes, say in the report that the review does not include them. Record each file that is in the diff and also has uncommitted changes.

Done when all three values are set and the scope has changes. For the staged, unstaged, and both scopes, use "Current state". For the branch and HEAD~N scopes, use the commit list. If the scope has no changes, stop here and tell the user, before you launch any agent.

## Step 2: Write the requirements

Write the requirements of the change as a numbered list. Use these sources, in this order:

1. A spec, issue, or file that the user gave.
2. What the user asked for in this conversation.
3. For the branch and HEAD~N scopes, the commit messages. Get them with `git log --format=%B {commit range}`.

State what the change must do, in the user's terms. Leave out how you built it, the trade-offs you chose, and why the code looks the way it does. The reviewers must judge the code without your reasoning.

If there is no source, write "No requirements available." Requirements that you infer from the diff are not requirements.

Done when each item is a requirement from a source, or the list says "No requirements available."

## Step 3: Assign areas to agents

The areas are in "Review areas" below. They are in two groups:

- Code group: Bugs, Over-complexity, Best practices, Style. Each code reviewer gets all four areas. The code reviewers do the same review independently.
- Other group: Functionality, Related code, Repo practice. The other reviewers split these areas.

Use this table exactly.

| Agents | Code reviewers | Other reviewers |
|---|---|---|
| 1 | One agent does all seven areas | |
| 2 | 1 | A: Functionality, Related code, Repo practice |
| 3 | 2 | A: Functionality, Related code, Repo practice |
| 4 | 2 | A: Functionality. B: Related code, Repo practice |
| 5 | 3 | A: Functionality. B: Related code, Repo practice |
| 6+ | Agents minus 3 | A: Functionality. B: Related code. C: Repo practice |

The diff is large when it has more than 15 changed files or more than 1000 changed lines. Use the last line of `{diff command} --stat`, and add each untracked file in scope with its line count.

Put the changed files in file groups for the code reviewers:

- Small diff, or fewer than 4 code reviewers: one group with all changed files.
- Large diff with 4 or more code reviewers: divide the number of code reviewers by 2 and round down. Make that number of groups. Put files of the same feature or directory in the same group, and give the groups about the same number of changed lines. Assign the code reviewers to the groups in turn, so that each group gets at least 2 code reviewers.

Give each code reviewer the files of its group in a different order. Rotate the list so that each reviewer starts at a different file.

In each file group, give the code reviewers start methods 1, 2, and 3 in turn, then start again at 1. The start methods are in Step 4.

## Step 4: Launch the agents

Launch all agents in one message so they run in parallel. Use `subagent_type: "general-purpose"`, because it loads CLAUDE.md (Explore and Plan do not).

Fill in each placeholder in this template. Copy the full text of each assigned area from "Review areas", with its smells.

Use one of these for `{team line}`:
- The only agent: "No other agents review this change."
- A code reviewer when there are other code reviewers: "{number of other code reviewers} other reviewers review the same areas independently. Report each finding that you have evidence for. Do not leave a finding out because another reviewer can find it."
- All other agents: "Other agents review the other areas."

Use one of these for `{file line}`:
- A code reviewer when there is one file group: "Read the changed files in this order: {file list}."
- A code reviewer when there is more than one file group: "Your files, in this order: {file list}. Read these files in full and trace their callers. Use the rest of the diff only for context. Report findings only in your files and in code that your files affect."
- All other agents: "Review all changed files."

Use one of these for `{start line}`:
- A code reviewer with start method 1: "Start with the diff, and read it from top to bottom."
- A code reviewer with start method 2: "Start at the code that calls the changed code, such as routes, handlers, and public functions. Follow the data into the change."
- A code reviewer with start method 3: "Start at the edges of the changed code: bad input, error paths, empty values, and concurrent calls."
- All other agents: remove this line.

Use one of these for `{disk line}`:
- Branch or HEAD~N scope, when files in the diff have uncommitted changes: "These files have uncommitted changes that are not in scope: {file list}. Read each of them with `git show HEAD:` and the file path, not from disk."
- All other cases: remove this line.

```
You are one of {AGENT_COUNT} reviewers of code changes in {repo path}. Review only for the areas below. {team line}

Do the review yourself. Do not start the review-changes skill or any other review skill, and do not launch agents.

Requirements:
{numbered requirements, or "No requirements available."}

Changes to review:
- Run `{diff command}` to get the diff.
- {list of untracked files, or "No untracked files are in scope."}
- {file line}
- {start line}
- {disk line}

Your areas:
{area text}

Rules:
- You are read-only. Use only commands that read: file reads, searches, `git diff`, `git log`, `git show`, `git blame`, and web searches. Leave files, the git index, databases, and containers as they are.
- Read the full changed files, not only the diff hunks. Read callers, callees, and similar existing code to confirm each finding.
- Report problems in the changed code, problems that the change causes in other code, and code outside the diff that must change with it.
- Each finding needs evidence: a concrete failure scenario, a rule and the file it is written in, a requirement number, a named smell, or existing code that the change differs from. A finding with no evidence is not a finding.
- CLAUDE.md and documented repo standards override the smells. If the repo accepts a pattern, the smell does not apply.
- Skip what the linter, formatter, or type checker already catches.
- A documented rule that the code breaks is a violation. A smell or a preference is a judgement call.
- If you find nothing, return "No findings."

Return only this list, most severe first. Keep each finding under 80 words, not counting the quoted code:

### {n}. {short title}
- Area: {area}
- Kind: violation | judgement call
- Severity: high | medium | low
- Location: {file_path:line}
- Code: {the quoted lines}
- Problem: {what is wrong}
- Evidence: {see the rules above}
- Fix: {the specific change}

If "Related code" is one of your areas, add the coverage table from that area after the findings. Return the table also when you have no findings.
```

Done when every agent has returned.

## Step 5: Verify and merge

1. Merge duplicate findings. Record each area that found each one. For a code group finding, also record how many code reviewers found it, for example "found by 2 of 3". Count only the code reviewers that had the file of the finding. A finding that only one reviewer found stays in. The count does not replace step 2.
2. Open the cited code for each finding and confirm that the problem is real at that location. Agent findings are claims, not facts. Remove each finding that you cannot confirm.
3. You wrote this code, so you are biased toward it. A finding is still valid when the code does what you meant it to do. Skip a finding for a deliberate choice only when the user agreed to that choice in this conversation, and say where.
4. If two findings conflict, choose one and give the reason.
5. Check the "Related code" coverage table. Open each peer with the status "missed", and each peer with the status "not needed" that has a weak reason or no reason. If a "not needed" reason is wrong, change the row to "missed" and add a finding. If a peer that you know about is not in the table, add it. The table is for your check only. Do not put it in the report. A missed peer becomes a normal finding, so nothing from the table is lost.
6. Give each finding a verdict:
   - **Apply**: a real bug, a missing or wrong requirement, a violation of a documented rule, a mismatch with nearby code style, an unclear name as described in "Style adherence", a related code peer that must get the same change, or a simplification with the same behavior.
   - **Skip**: a judgement call that nearby code does not support, a speculative risk, work outside the requirements (a missed related code peer is not outside them), or a fix that costs more than the problem.
   - **Ask**: a fix that CLAUDE.md says needs the user's confirmation, or a fix that needs a product decision.

Done when each finding has a verdict and a one-line reason.

## Step 6: Report, and apply if APPLY is true

If APPLY is false, leave all files as they are.

If APPLY is true:

1. Apply each finding with the verdict Apply. Follow CLAUDE.md and match nearby code.
2. Leave your edits unstaged, and do not commit or amend. For the staged scope, this keeps your edits separate from the user's staged work. For the branch and HEAD~N scopes, this keeps the user's commits as they are.
3. Run the verification commands in CLAUDE.md. Fix failures that your edits caused. Report failures that were there before your edits.
4. Review once. The user decides if another review is necessary. Each pass finds new judgement calls, so repeated passes do not reach a clean result.

Report the findings grouped by area, in the order of "Review areas", so a clean area does not hide a failing one. Number the findings across the full report so the user can select them by number. For each finding, give the number, file:line, verdict, and a one-line reason. If there is more than one code reviewer, also give the count from Step 5 for each code group finding. Put the Ask findings together at the end, each with its question. If APPLY is true, add the verification result (pass, or the failing output). End with one line for each area: its finding count and its worst finding.

## Review areas

The first four areas are the code group. The last three areas are the other group.

**Bugs**: Defects that make the code do the wrong thing. Crashes, wrong results, null and undefined cases, off-by-one errors, race conditions, missing awaits, unhandled rejections, incorrect error handling, data loss, security holes (injection, missing auth or ownership checks, data that leaks between users), and resource leaks.

**Over-complexity**: Code that is more complex than the problem needs. Existing repo helpers that the change does not use, dead code, unused parameters or options, deep nesting that early returns can remove, and stored state that can be derived. Each fix must keep the same behavior. Smells (judgement calls):
- Duplicated Code: the same logic in more than one hunk or file. Fix: extract it and call it from each place.
- Speculative Generality: abstractions, parameters, or hooks for needs that the requirements do not have. Fix: remove them and inline.
- Middle Man: a function or class that mostly passes calls on. Fix: call the real target directly.
- Repeated Switches: the same `switch` or `if` chain on the same value in more than one place. Fix: one shared map or function.
- Message Chains: long `a.b().c().d()` navigation that the caller must know. Fix: one method on the first object.
- Doesn't make sense: "why shouldn't this be another way?", "what the heck?" type things, where something could be done another way to be slightly better, cleaner, or simpler

**Best practices**: Good practice for the languages, frameworks, and libraries in use. Type safety, correct use of framework APIs and lifecycles, performance (N+1 queries, missing indexes, heavy work in hot paths, extra change detection), transactions where data must stay consistent, input validation at trust boundaries, accessibility, and deprecated APIs. If a claim depends on current library behavior, do a web search to confirm it. Smells (judgement calls):
- Feature Envy: a function that uses the data of another module more than its own. Fix: move it to that data.
- Data Clumps: the same group of fields or parameters that always travel together. Fix: one type for the group.
- Primitive Obsession: a string or number that stands for a domain concept. Fix: a small type for the concept.
- Shotgun Surgery: one logical change that needs edits spread across many files. Fix: put what changes together in one module.
- Divergent Change: one file that changes for many unrelated reasons. Fix: split it so each part has one reason to change.
- Refused Bequest: a subclass or implementation that ignores most of what it inherits. Fix: composition in place of inheritance.

**Style adherence**: Whether the new code looks like the code around it. Formatting that tools do not fix, idioms, function and file structure, error and log message style, comment rules, and text rules from CLAUDE.md. Compare with nearby files in the same package, not with general preference. Names are the exception:

Names must be direct, clear, and descriptive. A reader who is new to the code, and who possibly does not speak English as a first language, must know from the name only what the thing is, holds, or does. A slightly longer name in plain words is better than an abbreviation or a clever word. This applies to each name that the change adds or changes: variables, parameters, functions, types, files, i18n keys, database columns, routes, procedures, jobs, settings, CSS classes, and test names. Unclear names in nearby code do not make a new unclear name acceptable. Keep the terms that the repo already uses for its own concepts. Do not report names that the change did not add or change. Never suggest a shorter name only to make it shorter. For each finding, give the name to use. If no clear name fits, the design is not clear, so say that.

**Functionality**: Whether the change does what the requirements say, from start to end. Report:
- Requirements that are missing or partial. Give the requirement number.
- Requirements that look implemented but are wrong. Give the requirement number.
- Behavior that no requirement asked for (scope creep).
- Gaps in the flow: a backend change with no frontend path (or the reverse), callers that were not updated, missing i18n keys, missing migrations or generated types, platforms the code runs on that the change does not handle, and UI states that are not handled (loading, empty, error, offline).
If there are no requirements, report only the gaps in the flow, and say "No requirements available."

**Related code**: Code outside the diff that is similar to the changed code and must change with it, so that the codebase stays consistent. This applies to internal code and to user-facing code. Usually no import or call connects this code to the change, so you will not find it if you only follow references out from the diff. Do these steps:
1. List each item that the change adds or changes. Examples: a field, type, enum value, parameter, option, function, procedure, route, job handler, setting, error behavior, UI action, text string, or rule.
2. For each item, find its peers of these kinds:
   - Parallel: other things of the same kind. Sibling procedures or routes, other handlers of the same queue, other methods on the same service, other implementations of the same interface, other options of the same set. For a new field, choose an existing field of the same model and search for each place that handles it.
   - Counterpart: the other half of a pair. Import and export, serialize and parse, create and update, read and write, client and server, schema and migration, code and its tests, code and its docs.
   - Copy: the same knowledge kept in another place. A list, enum, schema, type, validation rule, default value, or text in another package or file.
   - Contract: code that expects a convention that the change affects. Error format, response shape, pagination, auth and ownership checks, naming.
   - Surface: each place where a user or a caller meets the changed area, also where no similar code exists yet. Examples: view, edit, print, share, export, import, search, public API, each platform the code runs on, emails, and background jobs.
3. For each peer, decide if it must get the same change. Report each missed peer as a finding. The evidence is the peer, and how it differs from the changed code.

Return this coverage table, with one row for each peer that you checked:

| Item | Peer (file:line) | Kind | How you found it | Status |
|---|---|---|---|---|

Status is one of: "changed", "not needed: {reason}", or "missed: finding {n}".

**Repo practice adherence**: Rules in CLAUDE.md, other documented standards (for example `CONTRIBUTING.md`), and patterns that the repo sets. File placement, package boundaries, import paths, file names and exports, areas where new code must not go, i18n rules, typecast rules, and the patterns of similar existing features (find them and compare). A broken documented rule is a violation. A difference from an undocumented pattern is a judgement call.
