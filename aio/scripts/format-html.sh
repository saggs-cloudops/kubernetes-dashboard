#!/usr/bin/env bash
# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Import config.
ROOT_DIR="$(cd $(dirname "${BASH_SOURCE}")/../.. && pwd -P)"
source "${ROOT_DIR}/aio/scripts/conf.sh"

# Define variables.
CHECK=false
CHECK_FAILED=0

function format::html {
  ${BEAUTIFY_BIN} ${BEAUTIFY_OPTS} --replace 'src/app/frontend/**/*.html' > /dev/null
}

function check::html {
  local needsFormat=false
  local files=($(find ${FRONTEND_SRC} -type f -name '*.html'))
  for file in "${files[@]}"; do
    local fileContent=$(cat ${file})
    local formattedFile=$(${BEAUTIFY_BIN} ${BEAUTIFY_OPTS} -f ${file})
    local isFormatted=$(diff <(echo "${formattedFile}") <(echo "${fileContent}"))
    if [[ ! -z "${isFormatted}" ]] ; then
      needsFormat=true
    fi
  done

  if [ "${needsFormat}" = true ] ; then
    return 1
  fi

  return 0
}

function parse::args {
  POSITIONAL=()
  while [[ $# -gt 0 ]]; do
    key="$1"
    case ${key} in
      --check)
      CHECK=true
      shift
      ;;
    esac
  done
  set -- "${POSITIONAL[@]}" # Restore positional parameters.
}

# Execute script.
parse::args "$@"

if [ "${CHECK}" = true ] ; then
  check::html
  CHECK_FAILED=$?
  if [ "${CHECK_FAILED}" -gt 0 ]; then
    saye "HTML code is not properly formatted. Please run 'npm run fix:frontend'.";
    exit 1
  fi
  say "HTML is properly formatted!"
  exit 0
fi

format::html
