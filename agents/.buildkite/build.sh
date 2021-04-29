#!/usr/bin/env bash

set -euo pipefail

echo --- Building image

cd agents

docker run -it --rm --init --volume "$(pwd)":/app --workdir /app hashicorp/packer:latest build .

echo --- Deleting images older than 30 days

IMAGES=$(gcloud compute images list --format="value(name)" --filter="creationTimestamp < -P30D AND family:kibana-bk-dev-agents")

for IMAGE in $IMAGES
do
  echo "Deleting image $IMAGE"
  gcloud compute images delete "$IMAGE" --quiet
done

