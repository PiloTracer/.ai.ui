# Agent MCP surface (optional, Phase 7)

**Purpose:** Optional Model Context Protocol tooling that makes the designer agent more capable and easier to use — **opt-in, license-safe, nothing vendored**. The framework requires no installation; MCP servers run in the adopter's environment when the team configures them.

**Browser policy applies:** tools tagged `🌐 browser` are opt-in only (§8.2 — explicit operator authorization before any live browser use). Static tier stays the default.

---

## Tier table

| Tier | Tooling | Agent default |
|------|---------|---------------|
| **Static (preferred)** | token-lint, jest-axe, rubrics, DTCG schema, Storybook **build** | ✅ use without asking |
| **CI / project scripts** | repo-defined `REPLACE:UI_VISUAL_TEST`, Lighthouse, Playwright suites | Run only when the project defines them |
| **Agent browser control** | Playwright MCP, Chrome DevTools MCP, live navigate/screenshot | ❌ requires explicit operator authorization (§8.2) |

## Recommended MCP servers (license-safe)

| Server | License | Value | Config (`.mcp.json`) |
|--------|---------|-------|----------------------|
| **Storybook MCP** (official) | MIT ✓ | Agent queries existing primitives/props before generating; emits testable stories | `{"mcpServers": {"storybook": {"command": "npx", "args": ["-y", "storybook-mcp-server", "--stories", "<path-to-stories>"]}}}` |
| **Playwright MCP** | Apache-2.0 ✓ | Browser control via a11y-tree snapshots + screenshots — **opt-in §8.2** | `{"mcpServers": {"playwright": {"command": "npx", "args": ["-y", "@playwright/mcp@latest"]}}}` |
| **Chrome DevTools MCP** | Apache-2.0 ✓ | Post-build console/network/perf audit — **opt-in §8.2**; use `--slim` for low schema overhead | `{"mcpServers": {"chrome-devtools": {"command": "npx", "args": ["-y", "chrome-devtools-mcp@latest", "--slim"]}}}` |

## License notes

- **MPL-2.0 tools** (axe-core, @axe-core/playwright) are **consumer-side dependencies only** — never vendored into the framework; default a11y stays jest-axe (MIT).
- **Framelink (Figma)**: MIT OSS repo but a commercial product — reference-only, never a framework dependency.
- Verify each server's version + license on install (INTEGRATION_LICENSE_STANDARD).

## Guidance

- For coding agents, prefer CLI/skills over MCP when possible (`playwright-cli` invocations are far more token-efficient than loading accessibility trees into context).
- Never auto-launch a browser; state tool + scope and wait for operator confirmation (§8.2).
