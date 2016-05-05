#!/bin/bash

set -eux

function add_canibump() {
  cat <<EOF > canibump
$(cat canibump)
canibump: curl -f -s https://canibump.cfapps.io | grep -q YES <(grep -A1 'id="can_i_bump"') && echo '{"result":true,"changing":false,"info":[],"url":"https://canibump.cfapps.io"}' || echo '{"result":false,"changing":false,"info":[],"url":"https://canibump.cfapps.io"}'
EOF
}

function remove_rubbish_bin() {
  sed -i '' '/rubbish-bin/d' cf-release
  sed -i '' '/deploy-and-test-a1/d' cf-release
  sed -i '' '/a1-diego-deploy-and-test/d' cf-release
  sed -i '' '/deploy-and-test-vsphere/d' cf-release
}

function main() {
  local pipelines
  pipelines=("alfredo" "alfredo-canaries" "canibump" "cf-release" "cf-release-final" "multierror" "runtime-ci" "runtime-dev-envs" "build-docker-images")

  for pipeline in ${pipelines[@]}; do
    fly -t runtime-ci checklist -p "${pipeline}" > "${pipeline}"
  done

  add_canibump

  remove_rubbish_bin
}

main
