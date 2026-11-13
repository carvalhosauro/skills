# Review request

Dispatch one fresh subagent (Agent tool). If the project has its own reviewer agent
(`.claude/agents/*review*`), use that subagent type; it may answer in its own format, which
SKILL.md step 4 maps. Otherwise a general-purpose one. Send only the text below, filled in: never
the conversation, your reasoning or your opinion of the code.

```text
Review a pure refactor. Intent: pure refactor, identical behavior.
Repo: <absolute path>
Target: <round 1: git diff <BASE>..HEAD, BASE recorded in SKILL.md step 1 |
  rounds 2 and 3: git diff <last reviewed sha>..HEAD>
Commits: <sha and subject of each test(...), refactor(...) and fix(...) commit in the target>

You are read-only: read code and use git diff, git show and git log only. You run no tests and no
command that changes state.

Check:
1. Behavior change: any input the code accepts (its types, validation and callers) whose output,
   error or side effect differs.
2. Error handling or validation lost in moved or merged code.
3. Abstraction over look-alikes: merged code that represents different business rules.
4. Existing tests edited or weakened: assertions changed or removed.
5. A new test that would stay green if the behavior changed.
6. Net diff growth without replacing hand-rolled code with an existing piece.
Also report any bug you see in the touched code.

For each finding: severity BLOCKER | HIGH | MEDIUM | LOW; state CONFIRMED | PLAUSIBLE; file:line;
pre-existing: yes | no (yes = the same bug existed before this diff); the concrete input that
shows it.
<rounds 2 and 3: Findings still open from earlier rounds: <list>. Say whether the delta resolves
each one.>

Answer only with the findings and a last line: "Verdict: converged" or "Verdict: not converged".
```

A finding without a concrete input counts as PLAUSIBLE, whatever state it claims.
