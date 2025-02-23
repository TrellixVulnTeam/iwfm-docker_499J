#!/bin/sh

echo "Building container images..."
docker build . -t ashesfall/iwfm-base:latest --network=host
docker build . -f Dockerfile.manager -t ashesfall/iwfm-manager:latest
docker build . -f Dockerfile.agent -t ashesfall/iwfm-agent:latest
docker build . -f Dockerfile.pmgr -t ashesfall/iwfm-parallel-mgr:latest
docker build . -f Dockerfile.pagt -t ashesfall/iwfm-parallel-agt:latest

echo "Pushing container images..."
docker push ashesfall/iwfm-base:latest
docker push ashesfall/iwfm-manager:latest
docker push ashesfall/iwfm-agent:latest
docker push ashesfall/iwfm-parallel-mgr:latest
docker push ashesfall/iwfm-parallel-agt:latest