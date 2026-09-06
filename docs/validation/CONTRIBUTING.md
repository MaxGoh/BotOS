# Contributing feasibility evidence

A contributor does not need the maintainer's computer, subscriptions or credentials.
Clone BotOS, install Git and make if missing, then run:

```bash
make bootstrap
make verify
make feasibility
```

CI runs `make verify` on Ubuntu 24.04 and macOS 14. These runner labels fix the
OS generation, not every package version. Record exact runtime versions for
integration evidence. Local verification in the current session covers Linux;
a configured macOS job is not an observed macOS pass.

The local probe creates only a temporary marker. It demonstrates that an empty
environment and same-user file permissions do not isolate an agent. It makes no
network requests, reads no model configuration and invokes no model CLI.

## Hardware and provider experiments

Run `make feasibility-host` to list host prerequisites. Exit status 2 means
integration remains unvalidated, even if all listed tools are installed. This
command neither installs software nor creates a VM.

The [feasibility plan](../plans/feasibility.md) defines G1–G3 cases. Contributors
may run these in their own disposable environments and submit sanitized evidence.
Use the JSON fields documented there, record actual commands, versions and exit
codes, and distinguish failure from an unavailable test. Never submit provider
secrets, authenticated browser profiles or private files.

- G1 needs an isolated engine environment and contributor-controlled test model
  connections. A schema or fake endpoint test is not proof of real authentication.
- G2 needs the actual managed desktop, engine and broker composition. They do not
  exist yet; no test here certifies private takeover.
- G3 needs a virtualization-capable macOS or Linux host and the managed VM/cluster
  experiment. A hosted CI runner's OS label alone does not prove nested VM support.

Real-account and virtualization jobs are not wired into pull-request CI. They
remain explicit release gates until the experiment implementations exist. Do not
add a workflow that reports them green by skipping their execution.

The historical blocked reports describe the earlier agent box, not a requirement
to use a particular personal machine. No maintainer-host access request is pending.
