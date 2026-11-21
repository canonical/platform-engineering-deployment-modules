#!/usr/bin/env bash
# Copyright 2026 Canonical Ltd.
# See LICENSE file for licensing details.
#
# Computes which modules (deployments/<app>/<site>) must be tested, grouped by
# the kind of controller the tests need. Results are written as JSON arrays to
# $GITHUB_OUTPUT (or stdout when unset) as `k8s` and `lxd_mixed`.
#
# All modules are selected when no base is given, or when the diff touches the
# test workflow or this script. Otherwise only the modules that changed are selected.
#
# Usage: changed_modules.sh [<base-sha> <head-sha>]
# Example (local): scripts/changed_modules.sh origin/main HEAD

set -euo pipefail

base="${1:-}"
head="${2:-HEAD}"

# Every module must be listed in exactly one group.
k8s_modules=(
    deployments/falcosidekick/ps7
    deployments/bingo/ps7
    deployments/gopkg/ps7
)
lxd_mixed_modules=(
    deployments/falco/ps7
    deployments/lego/ps6
    deployments/opencti/ps6
    deployments/wazuh/ps6
    deployments/mattermost/ps7
)

all_modules=("${k8s_modules[@]}" "${lxd_mixed_modules[@]}")

select_all=0
if [[ -z "${base}" || "${base}" =~ ^0+$ ]]; then
    select_all=1
    changed=()
else
    # Captured first so a failing diff aborts the script instead of selecting nothing.
    diff_output="$(git diff --name-only "${base}...${head}")"
    mapfile -t files <<< "${diff_output}"
    if printf '%s\n' "${files[@]}" | grep -qE '^(\.github/workflows/|scripts/changed_modules\.sh$)'; then
        select_all=1
    fi
    mapfile -t changed < <(
        printf '%s\n' "${files[@]}" \
            | sed -nE 's#^(deployments/[^/]+/[^/]+)/.*#\1#p' \
            | sort -u
    )
fi

contains() {
    local needle="$1" item
    shift
    for item in "$@"; do
        [[ "${item}" == "${needle}" ]] && return 0
    done
    return 1
}

# Fail on modules that exist but are not assigned to a test group.
for dir in deployments/*/*/; do
    dir="${dir%/}"
    if ! contains "${dir}" "${all_modules[@]}"; then
        echo "::error::${dir} is not assigned to a test group in scripts/changed_modules.sh" >&2
        exit 1
    fi
done

# Fail on modules listed in a test group that no longer exist.
for module in "${all_modules[@]}"; do
    if [[ ! -d "${module}" ]]; then
        echo "::error::${module} is listed in scripts/changed_modules.sh but does not exist" >&2
        exit 1
    fi
done

selected() {
    local module
    for module in "$@"; do
        if [[ "${select_all}" == "1" ]] || contains "${module}" "${changed[@]}"; then
            echo "${module}"
        fi
    done
}

to_json() {
    if [[ $# -eq 0 ]]; then
        echo "[]"
    else
        printf '%s\n' "$@" | jq -R . | jq -sc .
    fi
}

mapfile -t k8s < <(selected "${k8s_modules[@]}")
mapfile -t lxd_mixed < <(selected "${lxd_mixed_modules[@]}")

out="${GITHUB_OUTPUT:-/dev/stdout}"
echo "k8s=$(to_json "${k8s[@]}")" >> "${out}"
echo "lxd_mixed=$(to_json "${lxd_mixed[@]}")" >> "${out}"
