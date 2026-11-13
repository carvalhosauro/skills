---
name: pick-ui-library
description: Use when choosing, adding, or replacing a library in a React web frontend, when the user asks "which library should I use for X", or before hand-building a UI piece that a library or the project's design system already solves: toasts, dialogs, dropdowns, tooltips, command menus, OTP inputs, forms and validation, data tables, long lists, drag and drop, charts, animated numbers, dates, data fetching, routing, client state, conditional classNames.
---

# Pick UI Library

A lookup skill for React web. It answers "what should I use for X?" with one pick from the list
below, after checking what the project already has. The picks are deliberate: Emil Kowalski's
curated list plus the libraries I use day to day. Stay on the list. Leave it only when the user
asks for an alternative or the task is not covered.

If invoked without a task, ask which task needs a library and stop there.

## Procedure

1. **Name the task, not the library.** "I need a dropdown" is a UI-primitive task, whatever
   library the user mentioned.
2. **Check the project's design system.** Look for:
   - an in-house UI package: a workspace `packages/ui`, a `@<scope>/ui` dependency, or
     `src/components/ui/`. Read its index or exports;
   - a component kit in `package.json` (`@mui/material`, Chakra, Mantine, Ant) or shadcn
     (`components.json`);
   - project rules about UI and dependencies (`AGENTS.md`, `CLAUDE.md`, `.claude/rules/`).

   If the design system has the component (dialog, menu, snackbar, tooltip, text field, a class
   helper like `cx`), use it, even when the list names a library for that task. No new
   dependency. If it lacks a generic piece (a primitive not tied to one screen's data), add the
   piece to the design system, built on the list's pick, instead of inside one app.
3. **Check what's installed.** A listed library already in `package.json`: use it. A competitor
   that covers the task (react-window, `@tanstack/react-virtual`, notistack, swr,
   react-hot-toast...): keep using it, name the list's pick in one line, and change the
   dependency only if asked.
4. **Recommend one library**: its name, one sentence on what it does here, and the link. When the
   list has an answer, give that answer, not a menu.
5. **Install** with the lockfile's package manager: `bun.lock`/`bun.lockb` → `bun add`,
   `pnpm-lock.yaml` → `pnpm add`, `yarn.lock` → `yarn add`, `package-lock.json` → `npm install`.
   In a monorepo, add it to the workspace that uses it, not the root. If another workspace
   already depends on the library, use the same version.
   - If project rules require confirmation before adding a dependency: propose the command and
     wait. This holds even when the request says to wire it up.
   - Otherwise: install when the request includes wiring it up; when it only asks which
     library, answer and stop.
6. **Off the list?** Say so explicitly, then recommend from your own knowledge, flagged as
   off-list.

## The list

Each pick applies after steps 2 and 3: the design system and an installed competitor come first.

### UI components & primitives

| Task | Library |
| --- | --- |
| Unstyled, accessible primitives (dialog, popover, menu, select, tooltip, tabs...) | [base-ui](https://base-ui.com) |
| Command menus (⌘K palettes) | [cmdk](https://cmdk.paco.me) |
| Toasts / notifications | [Sonner](https://sonner.emilkowal.ski) |
| One-time password / verification code inputs | [input-otp](https://input-otp.rodz.dev) |
| Icons | [lucide-react](https://lucide.dev) |
| Control panels / tweak GUIs | [Leva](https://github.com/pmndrs/leva), with [dialkit](https://joshpuckett.me/dialkit) as an alternative |

### Forms & data

| Task | Library |
| --- | --- |
| Forms with validation (field state, submit, inline errors) | [react-hook-form](https://react-hook-form.com) |
| Schema validation (forms, API payloads, env) | [zod](https://zod.dev), wired to react-hook-form through `@hookform/resolvers/zod` |
| Server state: fetching, caching, mutations | [TanStack Query](https://tanstack.com/query) |
| Data tables (sort, filter, paginate, column visibility) | [TanStack Table](https://tanstack.com/table) |
| Date math, parsing, relative time, timezones | [dayjs](https://day.js.org) with the `relativeTime`, `utc` and `timezone` plugins and the `pt-br` locale |

A form with any validation rule goes through react-hook-form, even with three fields. A single
input with no validation (a search box) is plain state.

TanStack Table is headless: it owns the table logic and you write the markup. Past ~1,000 rows,
render it through Virtuoso's `TableVirtuoso`.

### Routing

| Task | Library |
| --- | --- |
| Client-side routing in a Vite SPA (type-safe params and search) | [TanStack Router](https://tanstack.com/router) |

In Next.js or Astro, use the framework's router.

### Motion & visuals

| Task | Library |
| --- | --- |
| General-purpose animation (springs, layout animations, enter/exit) | [motion](https://motion.dev). It was called framer-motion, so a `framer-motion` install counts. |
| Animating numbers (counters, prices, stats) | [NumberFlow](https://number-flow.barvian.me) |
| Animated text components | [torph](https://torph.lochie.me/) |
| 3D globes | [Cobe](https://cobe.vercel.app) |
| Dynamic OG images (HTML/CSS → SVG/PNG) | [Satori](https://github.com/vercel/satori) |
| Syntax highlighting | [shiki](https://shiki.style) |

Use motion for springs, layout animations, exit animations or gesture-driven values. A hover or
fade is a plain CSS transition.

### Charts

| Task | Library |
| --- | --- |
| Real-time / streaming charts | [Liveline](https://github.com/benjitaylor/liveline) |
| General charts (static or interactive dashboards) | [recharts](https://recharts.org) |

Data that arrives live, with the chart scrolling over time: Liveline. Everything else: recharts.

### Interaction & performance

| Task | Library |
| --- | --- |
| Drag and drop | [dnd kit](https://dndkit.com) |
| Virtualization (long lists, large tables) | [Virtuoso](https://virtuoso.dev): `Virtuoso` for lists, `TableVirtuoso` for `<table>` markup |

### State & styling

| Task | Library |
| --- | --- |
| Client state shared across components | [zustand](https://zustand.docs.pmnd.rs) |
| Building `className` strings conditionally | [clsx](https://github.com/lukeed/clsx) |
| Type-safe, variant-driven styling for Tailwind | [cva](https://cva.style) |
| Theme switching / dark mode without a flash on load, in Next.js | [next-themes](https://github.com/pacocoursey/next-themes) |

Data from the server lives in the TanStack Query cache, not in zustand. zustand holds state that
only exists in the browser (UI toggles, drafts, selections).

clsx is for ad-hoc conditional classes; cva is for a component with real variants (size, intent,
state) that deserve a typed API. They compose.

## Common mismatches to catch

| You see | Use |
| --- | --- |
| A library added for something the design system already ships | The design system component |
| Toasts built by hand or with a modal library | The design system's snackbar, else Sonner |
| A `<div>` dropdown or dialog with manual focus handling | The design system component, else base-ui |
| `useEffect` + `fetch` + loading and error `useState` | TanStack Query |
| Server data copied into zustand or context | TanStack Query's cache |
| One `useState` per field and a hand-rolled error map | react-hook-form + zod |
| Sort, filter and pagination hand-rolled over table rows | TanStack Table |
| Date math with milliseconds (adding days, diffing dates) | dayjs |
| A list of 1,000+ rows rendered directly | Virtuoso, before pagination hacks |
| A number animated by re-rendering text | NumberFlow |
| A web of props or per-component `useState` for shared client state | zustand |
| `className` template-literal ternaries three conditions deep | clsx (or the project's `cx`); cva if variant-shaped |
