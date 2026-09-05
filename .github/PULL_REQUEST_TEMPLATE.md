## What

<!-- What does this change do? -->

## Why

<!-- The reasoning. If the decision was non-obvious or hard to reverse, link
     the AGDR in docs/agdr/ instead of arguing it here. -->

## Verification

<!-- Paste the relevant output. "It works" is not evidence. -->

```
$ make verify
```

## Checklist

- [ ] `make verify` passes
- [ ] Docs updated if this change made any of them wrong
- [ ] AGDR added if the decision was non-obvious or hard to reverse
- [ ] No secrets; `.env.example` documents any new variable by name only
- [ ] No new runtime dependency (or: an AGDR justifies it)
