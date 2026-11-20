#!/usr/bin/env bash
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
#
# One-off migration helper: creates <app>-<site>/<version> tags from the
# legacy global main.<version> tags so that existing pins keep resolving to
# the same commit after switching to per-module tags.
#
#   * every legacy ref pinned in a deployments checkout (argument) gets a tag
#     for the module it pins
#   * every module gets a tag for the first legacy tag that contains its
#     latest change, so Renovate has a baseline
#
# Usage: backfill_module_tags.sh [path-to-deployments-repo]
# Environment:
#   DRY_RUN=1   print the tags that would be created without creating them

set -euo pipefail

deployments_repo="${1:-}"
dry_run="${DRY_RUN:-0}"
created=()

create_tag() {
    local tag="$1" commit="$2"
    if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
        return
    fi
    echo "${tag} -> ${commit}"
    if [[ "${dry_run}" != "1" ]]; then
        git tag "${tag}" "${commit}"
        created+=("${tag}")
    fi
}

if [[ -n "${deployments_repo}" ]]; then
    while IFS= read -r line; do
        module_path="${line%%\?ref=*}"
        version="${line##*\?ref=main.}"
        version="${version%%&*}"
        module="${module_path#deployments/}"
        module="${module//\//-}"
        commit="$(git rev-list -n 1 "main.${version}" 2>/dev/null || true)"
        if [[ -z "${commit}" ]]; then
            echo "error: legacy tag main.${version} not found (git fetch --tags?)" >&2
            exit 1
        fi
        create_tag "${module}/${version}" "${commit}"
    done < <(
        grep -rhoE 'deployments/[^/?]+/[^/?]+\?ref=main\.[0-9.]+' \
            --include='*.tf' "${deployments_repo}/deployments" | sort -u
    )
fi

for dir in deployments/*/*/; do
    dir="${dir%/}"
    module="${dir#deployments/}"
    module="${module//\//-}"
    last_change="$(git log -1 --format=%H -- "${dir}")"
    legacy_tag="$(git tag --contains "${last_change}" --list 'main.*' --sort=creatordate | head -n 1)"
    if [[ -z "${legacy_tag}" ]]; then
        echo "warning: no legacy tag contains the latest change of ${module}" >&2
        continue
    fi
    create_tag "${module}/${legacy_tag#main.}" "$(git rev-list -n 1 "${legacy_tag}")"
done

if [[ ${#created[@]} -gt 0 ]]; then
    git push origin "${created[@]/#/refs/tags/}"
fi
