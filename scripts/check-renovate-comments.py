#!/usr/bin/env python3
# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.
"""Ensure every charm ``revision = N`` line in deployment Terraform files is
immediately preceded by a ``# renovate: charm="..." ...`` comment.

Renovate relies on this comment to know which Charmhub package, track, risk,
base and architecture a given revision line refers to (see the
``customManagers`` entry in renovate.json). Without it, Renovate silently
stops tracking that revision for updates.

Usage:
    check-renovate-comments.py [FILE ...]

If no files are given, all ``deployments/**/main.tf`` files (excluding any
``tests/`` subpaths) are scanned.
"""
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

REVISION_PATTERN = re.compile(r"^\s*revision\s*=\s*\d+\s*$")
RENOVATE_COMMENT_PATTERN = re.compile(
    r'^\s*#\s*renovate:\s*charm="[^"]+"\s+track="[^"]*"\s+risk="[^"]+"\s+'
    r'base="[^"]+"\s+arch="[^"]+"\s*$'
)


def default_files() -> list[Path]:
    """Return all deployment main.tf files, excluding test fixtures."""
    return sorted(
        path
        for path in (REPO_ROOT / "deployments").rglob("main.tf")
        if "tests" not in path.relative_to(REPO_ROOT).parts
    )


def find_missing_comments(path: Path) -> list[int]:
    """Return 1-indexed line numbers of revision lines missing a comment."""
    lines = path.read_text().splitlines()
    missing = []
    for index, line in enumerate(lines):
        if not REVISION_PATTERN.match(line):
            continue
        preceding_line = lines[index - 1] if index > 0 else ""
        if not RENOVATE_COMMENT_PATTERN.match(preceding_line):
            missing.append(index + 1)
    return missing


def main(argv: list[str]) -> int:
    files = [Path(arg).resolve() for arg in argv] if argv else default_files()

    violations: list[tuple[Path, int]] = []
    for path in files:
        for line_number in find_missing_comments(path):
            violations.append((path, line_number))

    if violations:
        print("Missing renovate comment above the following revision lines:")
        for path, line_number in violations:
            try:
                display_path = path.relative_to(REPO_ROOT)
            except ValueError:
                display_path = path
            print(f"  {display_path}:{line_number}")
        print(
            '\nAdd a comment directly above each revision line, e.g.:\n'
            '  # renovate: charm="<name>" track="<track>" risk="<risk>" '
            'base="<base>" arch="<arch>"\n'
            "  revision = <n>"
        )
        return 1

    print(f"OK: checked {len(files)} file(s), all revision lines have a renovate comment.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
