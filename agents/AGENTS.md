## Communication

Be extremely (!!!) concise. Sacrifice grammar for concision.

Always reply in English, even when I write in German or another language.

In the CLI, print full URLs as plain text. Never hide them behind markdown link text; I can't see or click those.

When writing on my behalf (Slack, GitHub, commits, anywhere), sign with harness and model, e.g. `written with claude-opus-5 in opencode`.

## Product development

Learn through small, realistic implementations, not extended speculative design.

When architecture is uncertain, build the smallest reversible vertical slice and exercise it in the real runtime.

Never block implementation on a question a cheap experiment can answer. Never let exploratory code become production architecture without a conscious review.

## Code

Optimize for readability. Prefer descriptive names and small functions over comments; code should show WHAT it does. Add a comment only to explain WHY, when that isn't obvious.

## Tooling

- `work`: manages project processes (dev servers, watchers) and sets up worktrees via the configured setup hook. In a project with `work.config.js`, use it to run the app: in a fresh worktree (also ones made by T3, Codex, etc.), run `work setup --tailscale` before `work up --tailscale`; `work up` alone skips the setup hook and can silently run against shared state (e.g. another workspace's database). Always pass `--tailscale` to `work setup`, `work up` and `work run`, so the services are reachable over HTTPS from every tailnet device and setup writes the tailnet URLs. `work urls` lists the URLs; give the user the tailnet URL.
- `agent-browser`: the only browser to use, always in the background, unless told otherwise.
- iOS Safari (Appium + simulator): always run with a watchdog that kills Appium, the `xcodebuild` WebDriverAgent run and DeviceHub after a few minutes; on failure, kill them immediately. Cause of the DeviceHub pile-up: Appium reboots a headless simulator "with the window visible" on every session attempt (`open -Fn DeviceHub`), which also kills WDA. What works: build WDA once (`xcodebuild build-for-testing ... CODE_SIGNING_ALLOWED=NO`), run it with `test-without-building`, start Appium with `--default-capabilities '{"appium:webDriverAgentUrl":"http://127.0.0.1:8100","appium:isHeadless":true}'`, and drive Appium's WebDriver API directly. `agent-browser -p ios` opens a new session per command and silently falls back to Chrome. For long-press drags use `mobile: dragFromToWithVelocity` (W3C `pause` drifts). Trust local HTTPS with `xcrun simctl keychain <udid> add-root-cert`.

## Reference repositories

Read-only reference repos live in `.reference/` or `.references/`. When asked for examples or patterns not in this project, search there first.

- `jazz`: local-first synced database
- `tilly`: mobile-optimized PWA built with jazz and the AI SDK
- `alkalye`: offline-capable PWA built with jazz
- `blog`: my personal blog
