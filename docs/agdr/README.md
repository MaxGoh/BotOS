# Agent Decision Records (AGDR)

An AGDR captures **why** a decision was made, in the moment it was made. Code
and git history show what changed; they rarely survive the reasoning. When a
future agent asks "can I change this?", the AGDR is the answer.

## When to write one

Write an AGDR when a decision is non-obvious or expensive to reverse:

- choosing a language, framework, runtime, or datastore
- adding a runtime dependency
- fixing a public interface or wire format
- a structural refactor, or deliberately *not* doing one
- a security, licensing, or privacy decision

Skip it for routine work — a typo fix or a straightforward bug fix needs no record.

## How

1. Copy `AGDR-0000-template.md` to `AGDR-<YYYY-MM-DD>-<NNN>-<short-title>.md`,
   where `NNN` is the next free sequence number for that date.
2. Fill every section. "Alternatives Considered" may be omitted only when there
   genuinely were none.
3. Commit it alongside the change it describes, not afterwards.

Records are append-only. A decision that gets reversed is not deleted — write a
new AGDR that supersedes it and link the two under **Related**.
