# G1 — provider credential isolation: unresolved

No authenticated integration has passed this gate. [Results](G1-results.json)
keep all four launch modes blocked pending isolated execution and a supported
route. No provider login, paid request or credential-file inspection was performed
by the parent validation probes.

## Findings checked on 2026-09-06

| Mode | Accepted evidence | Remaining work |
| --- | --- | --- |
| Codex subscription | Installed 0.153.4 external-token login requires a provider access token in the engine. This candidate fails BotOS's boundary. | Establish another supported route or return a concrete architecture incompatibility for an operator decision. |
| Claude subscription | Gateway documentation distinguishes using a saved subscription login from using a gateway credential; simply changing the base URL does not remove the client login. | Establish both eligible integration and a credential-free engine path; do not substitute dummy-token injection as a proven solution. |
| OpenAI BYOK | Codex documents proxy configuration and custom-provider authentication choices. | Prove a scoped BotOS connection, host-only upstream key custody, real requests, revocation and leakage tests. |
| Anthropic BYOK | Claude documents gateways holding provider credentials while clients hold gateway credentials. | Prove the actual BotOS gateway and engine isolation, including streaming, cancellation and expiry. |

The generated Codex schema labels `chatgptAuthTokens` internal-use-only, while
public app-server documentation describes it as experimental for host
applications. Record this version/documentation discrepancy rather than treating
either description as a settled integration guarantee. Both describe token
delivery into the engine. [Local observation](../../experiments/provider-boundary/codex-schema-observation.json).

Sources checked directly:

- [Codex app-server authentication](https://developers.openai.com/codex/app-server)
- [Codex authentication](https://developers.openai.com/codex/auth)
- [Codex proxy configuration](https://developers.openai.com/codex/config-advanced)
- [Claude gateway credential and subscription behavior](https://code.claude.com/docs/en/llm-gateway)

## Review of specialist claims

The research report called documented BYOK mechanisms proven end-to-end; that
claim is not accepted. Documentation establishes a candidate route, not a
successful BotOS experiment. Its blanket claims that subscription products
prohibit automation were not substantiated and are not adopted.

Likewise, changing a base URL alone does not demonstrate that a client avoids
all existing credential stores. A suggested unauthenticated proxy does not meet
BotOS's scoped-access boundary. Forwarding consumer OAuth tokens to a guessed
API endpoint is not an accepted supported subscription integration.

The next local request-capture probe must run with isolated configuration and
networking so it cannot load ambient agent credentials or accidentally send
real inference traffic. Do not run the specialist's supplied commands unchanged
in this authenticated agent box. Full P1–P6 validation still requires a suitable
isolated environment and explicitly configured test connections.
