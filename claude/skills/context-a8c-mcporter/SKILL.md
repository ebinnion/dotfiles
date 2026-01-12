---
name: context-a8c-mcporter
description: Use when accessing Automattic work context (Linear, Slack, P2s, Zendesk, TeamCity, etc.). Triggers include questions about issues, messages, posts, tickets, builds, or any Automattic internal systems.
---

# Context A8C via mcporter

Access Automattic work context using mcporter CLI.

## Discovery

**First, discover available providers and their descriptions:**

```bash
mcporter list context-a8c
```

This returns the full tool schema including:
- Available providers (in the `provider` enum)
- What each provider does (in the description)
- Required and optional parameters

**Read this output carefully** - it tells you exactly which providers exist and when to use each one.

## Two-Step Pattern

Context-a8c uses a **load-then-execute** pattern:

### Step 1: Load Provider

```bash
mcporter call context-a8c.context-a8c-load-provider provider=<provider>
```

This returns the available tools for that provider and their parameters.

### Step 2: Execute Tool

```bash
mcporter call context-a8c.context-a8c-execute-tool provider=<provider> tool=<tool> params='<json>'
```

The `params` argument is optional JSON matching the tool's schema.

## Workflow

1. Run `mcporter list context-a8c` to see available providers
2. Load the relevant provider to discover its tools
3. Execute the specific tool with appropriate params
4. Parse JSON results

## Notes

- Always load a provider first to see exact tool names and parameters
- The `params` argument must be valid JSON when provided
- Auth is handled automatically; if it fails, direct user to `/ai/context-a8c` on Matticspace
