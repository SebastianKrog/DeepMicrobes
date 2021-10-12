#!/bin/bash --login

# This script ensures that the docker container:
# - acts as if run in the DeepMicrobes folder 
# - has conda is activated.

# It is required because of how conda sets environment variables.

set -e

cd /root/DeepMicrobes

conda activate base

exec "$@"
