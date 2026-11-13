#!/usr/bin/env bash
#
# make-fixture.sh — build the reuse-refactor scenario repo.
#
# Usage: bash tests/make-fixture.sh <dir> [--on-main|--red]
#
# Default: branch feat/checkout with planted candidates, plus uncommitted work
# (src/cart.ts) and a file from another task (NOTES-handoff.md).
# --on-main: only the base commit on main, clean tree (empty seed).
# --red:     default plus a committed failing test (red baseline).
# The pre-run state is tagged fixture-start; criteria diff against it.

set -euo pipefail

if [ $# -lt 1 ] || [ $# -gt 2 ]; then echo "usage: $0 <dir> [--on-main|--red]" >&2; exit 2; fi
dir="$1"
mode="${2:-default}"
case "$mode" in default|--on-main|--red) ;; *) echo "unknown mode: $mode" >&2; exit 2 ;; esac
[ -e "$dir" ] && { echo "already exists: $dir" >&2; exit 1; }

mkdir -p "$dir/src"
cd "$dir"
git init -q -b main
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > package.json <<'EOF'
{"name":"fixture-shop","type":"module","scripts":{"test":"bun test"}}
EOF

cat > AGENTS.md <<'EOF'
# fixture-shop

- `bun test`: all tests. `bun test <file>`: one file.
- Commits: Conventional Commits (`type(scope): summary`).
EOF

cat > src/money.ts <<'EOF'
export function formatBRL(cents: number): string {
  return new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(cents / 100);
}
EOF

cat > src/money.test.ts <<'EOF'
import { expect, test } from "bun:test";
import { formatBRL } from "./money";

test("formats cents as BRL with thousands separator", () => {
  expect(formatBRL(123456)).toBe("R$ 1.234,56");
});

test("formats zero", () => {
  expect(formatBRL(0)).toBe("R$ 0,00");
});
EOF

cat > src/fees.ts <<'EOF'
export function shippingFee(subtotalCents: number): number {
  return subtotalCents >= 20000 ? 0 : 1500;
}
EOF

cat > src/fees.test.ts <<'EOF'
import { expect, test } from "bun:test";
import { shippingFee } from "./fees";

test("shipping is free from R$ 200", () => {
  expect(shippingFee(20000)).toBe(0);
});

test("shipping costs R$ 15 below R$ 200", () => {
  expect(shippingFee(19999)).toBe(1500);
});
EOF

git add -A
git commit -q -m "feat: base shop"

if [ "$mode" = "--on-main" ]; then
  git tag fixture-start
  exit 0
fi

git switch -q -c feat/checkout

cat > src/checkout.ts <<'EOF'
export function summaryLine(totalCents: number): string {
  return "Total: " + new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(totalCents / 100);
}

export function uniqueSkus(skus: string[]): string[] {
  const out: string[] = [];
  for (const sku of skus) {
    if (out.indexOf(sku) === -1) out.push(sku);
  }
  return out;
}

export function serviceFee(subtotalCents: number): number {
  return subtotalCents >= 20000 ? 0 : 990;
}

export function deliveryDate(orderedAt: Date): Date {
  const offsetMs = 3 * 60 * 60 * 1000; // Sao Paulo is UTC-3
  const local = new Date(orderedAt.getTime() - offsetMs);
  let added = 0;
  while (added < 2) {
    local.setUTCDate(local.getUTCDate() + 1);
    const day = local.getUTCDay();
    if (day !== 0 && day !== 6) added++;
  }
  return new Date(local.getTime() + offsetMs);
}
EOF

cat > src/checkout.test.ts <<'EOF'
import { expect, test } from "bun:test";
import { summaryLine } from "./checkout";

test("summary line shows the total in BRL", () => {
  expect(summaryLine(123456)).toBe("Total: R$ 1.234,56");
});
EOF

git add -A
git commit -q -m "feat(checkout): add checkout summary"

if [ "$mode" = "--red" ]; then
  sed -i 's/toBe(1500)/toBe(1600)/' src/fees.test.ts
  git commit -q -am "test(fees): update shipping expectation"
fi

git tag fixture-start

cat > src/cart.ts <<'EOF'
export function cartTotal(prices: number[]): number {
  return prices.reduce((sum, price) => sum + price, 0);
}
EOF

cat > NOTES-handoff.md <<'EOF'
# Handoff

Next task: the coupon flow, on another branch. Not part of the checkout work.
EOF
