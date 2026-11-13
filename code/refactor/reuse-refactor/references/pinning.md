# Pinning behavior

The proof that a refactor changed nothing is a set of tests that pass before and after it,
unchanged, and that would fail if the behavior changed.

1. **Find the covering tests:** the test next to the file, tests that import the symbol (grep),
   and higher-level tests (request, handler, page) that reach it. Run them. They cover the
   candidate only if they assert on the output the refactor could change.
2. **Missing: write characterization tests.**
   - At the highest level the project already uses, with its framework, file layout, naming and
     mocking style.
   - Assert observable outputs for normal input, edges (empty, zero, boundary values such as a
     threshold, the last item), and every input where the replacement could plausibly differ
     (formatting, ordering, duplicates, time zones).
   - Assert what the current code returns, even if it looks wrong; note a likely bug for the
     report.
3. **Green on the current code.** Red means you misread the behavior: fix the test, never the
   code. Cannot get green: skip the candidate.
4. **Prove each new test can fail.** Break the pinned code on purpose (flip a condition, return a
   constant, drop an element), run the test and see it red, then restore the file
   (`git restore <file>`) and see it green again. A test that stays green pins nothing:
   strengthen it; still green, skip the candidate. Record this for the report.
5. **Screens:** when the project has a browser check (e.g. Playwright screenshots), take "before"
   screenshots of each screen that renders the candidate, in the states, themes and widths the
   project's check uses. Keep them outside the repo. After the refactor, take "after" and open both.
6. **Existing tests are never edited or weakened.** You may add imports and new test cases to an
   existing test file.
