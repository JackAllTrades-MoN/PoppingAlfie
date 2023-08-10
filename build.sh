#!/bin/bash

set -eu

dune build && cp -f ./_build/default/bin/main.bc.js ./js/
