#!/bin/bash

set -eux

function add_canibump() {
  cat <<EOF > canibump
$(cat canibump)
canibump: curl -f -s https://canibump.cfapps.io | grep -q YES <(grep -A1 'id="can_i_bump"') && echo '{"result":true,"changing":false,"info":[],"url":"https://canibump.cfapps.io"}' || echo '{"result":false,"changing":false,"info":[],"url":"https://canibump.cfapps.io"}'
EOF
}

function main() {
  local pipelines
  pipelines=("canibump" "cf-release" "cf-release-final" "runtime-ci" "runtime-dev-envs" "build-docker-images" "nats-release" "cf-bosh-2-0")

  for pipeline in ${pipelines[@]}; do
    fly -t runtime-ci checklist -p "${pipeline}" > "${pipeline}"
  done

  add_canibump
}

main
