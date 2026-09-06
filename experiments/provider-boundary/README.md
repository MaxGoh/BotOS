# Provider boundary probe

This directory contains generated protocol evidence, not a production adapter.

With Codex CLI 0.153.4, generate the experimental schema into a temporary directory:

```bash
codex --version
botos_schema_dir=$(mktemp -d)
codex app-server generate-json-schema --experimental --out "$botos_schema_dir"
cat "$botos_schema_dir/v2/LoginAccountParams.json"
```

No login or inference request is needed. The captured schema is in
[codex-0.153.4-login-schema.json](codex-0.153.4-login-schema.json); the
[observation](codex-schema-observation.json) records the required fields and interface warning.

The `chatgptAuthTokens` branch requires a provider access token supplied to the
engine. That candidate violates BotOS's current boundary if the engine runs
inside the workstation. The schema also labels the interface for internal use.
This finding does not establish that every possible supported route fails.

Do not use an existing CLI login or copy its credential files to pursue the experiment.
Authenticated provider testing and isolated engine visibility checks remain outstanding.
