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
  pipelines=("canibump" "cf-release" "cf-release-final" "runtime-ci" "build-docker-images" "nats-release" "cf-deployment" "datadog" "a1-logsearch" "nats-gcp")

  for pipeline in ${pipelines[@]}; do
    fly -t runtime-ci checklist -p "${pipeline}" > "${pipeline}"
  done

  add_canibump
}

main
