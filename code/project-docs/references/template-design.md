# DESIGN.md — how {PROJECT_NAME} works

Technical map for agents and humans. For *why* choices were made, see
[`DECISIONS.md`](DECISIONS.md). For *what* ships when, see [`ROADMAP.md`](ROADMAP.md).

## Overview

{ONE_PARAGRAPH_ARCHITECTURE}

## Data on disk / layout

```
{LAYOUT_TREE_OR_DESCRIPTION}
```

## Core flows

### {FLOW_NAME}

{FLOW_DESCRIPTION}

## State machine / sync model

{IF_APPLICABLE}

## Interfaces & boundaries

| Component | Responsibility | Must never |
|-----------|----------------|------------|
| {NAME} | {DOES} | {MUST_NOT} |

## Extension points

{FUTURE_SEAMS}
