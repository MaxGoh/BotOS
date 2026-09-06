# BotOS model-access feasibility notes

Status: requirements research, not an implemented integration.

First-release targets approved: Claude subscriptions, Codex subscriptions, BYOK. Local inference deferred.

## Parent-verified findings

- Codex App Server documents managed ChatGPT authentication, API-key authentication, and experimental externally managed ChatGPT tokens. The external mode supplies an accessToken to app-server; external refresh ownership is not a no-credential-in-engine guarantee. Source: https://developers.openai.com/codex/app-server
- Claude SDK overview says third-party products may not offer claude.ai login/rate limits without prior approval. Source: https://code.claude.com/docs/en/agent-sdk/overview
- Claude help page update dated June 15 says proposed SDK usage changes are paused and SDK, headless CLI and third-party app usage continue to count against subscription limits. This billing statement does not establish approval for BotOS's particular integration. Source: https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan

## Open issues

- Verify a supported per-provider path with engines inside workstations and all underlying provider credentials outside them. Do not represent gateway injection as subscription-compatible merely because API-key proxying works.
- The operator explicitly confirmed that temporary provider-issued access tokens, long-lived API keys and refresh tokens must all remain outside workstations. Validate routes against that boundary.
- Resolve Claude product-integration eligibility using applicable official guidance; do not assert blanket legality or illegality based on a researcher summary.
- Validate cancellation, private takeover and recovery independently of model authentication.

## Research review

The Claude specialist returned broader policy claims and older documentation pointers than the parent-verified sources support. Those claims are not accepted as established facts for BotOS. No authenticated provider requests or credential-file reads were performed.

## Local schema evidence — 2026-09-06

Installed Codex CLI 0.153.4 generated an experimental login schema requiring
`accessToken` for `chatgptAuthTokens`, with an internal-use-only warning. The
public app-server documentation describes the same token-delivery mechanism
as experimental for host applications. This version/documentation mismatch
requires verification before adoption; both paths deliver the token to the
engine and therefore fail the current boundary when used inside a workstation.
See the [captured schema observation](../../experiments/provider-boundary/codex-schema-observation.json).
