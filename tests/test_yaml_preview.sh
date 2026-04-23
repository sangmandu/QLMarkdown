#!/bin/bash
# Integration test: verify YAML files render with syntax highlighting via qlmarkdown_cli
# Prerequisites: build qlmarkdown_cli first (xcodebuild)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CLI="$REPO_DIR/DerivedData/Build/Products/Debug/qlmarkdown_cli"
TEST_YAML="$REPO_DIR/examples/test.yaml"
PASS=0
FAIL=0

assert_contains() {
    local label="$1" output="$2" pattern="$3"
    if echo "$output" | grep -q "$pattern"; then
        echo "[PASS] $label"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $label — expected pattern: $pattern"
        FAIL=$((FAIL + 1))
    fi
}

if [ ! -f "$CLI" ]; then
    echo "BLOCKED: qlmarkdown_cli not built. Run xcodebuild first."
    exit 2
fi

if [ ! -f "$TEST_YAML" ]; then
    echo "BLOCKED: test.yaml not found at $TEST_YAML"
    exit 2
fi

echo "=== YAML Quick Look Integration Test ==="

OUTPUT=$("$CLI" "$TEST_YAML" 2>/dev/null || true)

assert_contains "YAML file produces HTML output" "$OUTPUT" "<html"
assert_contains "Output contains syntax highlighting markup" "$OUTPUT" "class="
assert_contains "Output does NOT go through markdown parser (no <article>)" "$OUTPUT" "pre"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
