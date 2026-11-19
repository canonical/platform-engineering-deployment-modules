#!/usr/bin/env bash
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
#
# Creates one tag per module (deployments/<app>/<site>) that changed between
# two commits. Tags look like <app>-<site>/<YYYY.MM.DD>.<n>, where <n> is the
# last build number of that module plus one.
#
# Usage: tag_modules.sh <before-sha> <after-sha>
# Environment:
#   DRY_RUN=1   print the tags that would be created without creating them
#   GH_TOKEN    when set (and `gh` is available), a GitHub release is created
#               for every new tag

set -euo pipefail

before="${1:?usage: $0 <before-sha> <after-sha>}"
after="${2:?usage: $0 <before-sha> <after-sha>}"
dry_run="${DRY_RUN:-0}"

if [[ "${before}" =~ ^0+$ ]]; then
    before="${after}~1"
fi

date_part="$(date +'%Y.%m.%d')"

mapfile -t modules < <(
    git diff --name-only "${before}" "${after}" \
        | sed -nE 's#^deployments/([^/]+)/([^/]+)/.*#\1-\2#p' \
        | sort -u
)

if [[ ${#modules[@]} -eq 0 ]]; then
    echo "No module changed, nothing to tag."
    exit 0
fi

for module in "${modules[@]}"; do
    # The app name can contain dashes, the site never does.
    site="${module##*-}"
    app="${module%-"${site}"}"
    if [[ ! -d "deployments/${app}/${site}" ]]; then
        echo "Skipping ${module}: module directory was removed."
        continue
    fi

    last_tag="$(git tag --list "${module}/*" --sort=-v:refname | head -n 1)"
    count=1
    if [[ -n "${last_tag}" ]]; then
        count=$(( ${last_tag##*.} + 1 ))
    fi
    tag="${module}/${date_part}.${count}"

    echo "${module}: ${last_tag:-<none>} -> ${tag}"
    if [[ "${dry_run}" == "1" ]]; then
        continue
    fi

    git tag "${tag}" "${after}"
    git push origin "${tag}"

    if [[ -n "${GH_TOKEN:-}" ]] && command -v gh >/dev/null 2>&1; then
        args=(--title "${tag}" --generate-notes --verify-tag)
        if [[ -n "${last_tag}" ]]; then
            args+=(--notes-start-tag "${last_tag}")
        fi
        gh release create "${tag}" "${args[@]}"
    fi
done
