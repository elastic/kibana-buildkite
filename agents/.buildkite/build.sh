#!/usr/bin/env bash

set -euo pipefail

cd agents/ubuntu

echo --- Building packer builder docker image
docker build --progress plain -t packer-builder .

echo --- Building agent images
docker run -it --rm --init -e "VAULT_ADDR" --volume "$HOME/.vault-token:/root/.vault-token" --volume "$(pwd)":/app --workdir /app packer-builder ./packer_build.sh

echo --- Deleting base images older than 30 days

IMAGES=$(gcloud compute images list --format="value(name)" --filter="creationTimestamp < -P30D AND family:kb-ubuntu-base")

for IMAGE in $IMAGES
do
  echo "Deleting image $IMAGE"
  gcloud compute images delete "$IMAGE" --quiet
done

echo --- Deleting cache images older than 30 days

IMAGES=$(gcloud compute images list --format="value(name)" --filter="creationTimestamp < -P30D AND family:kb-ubuntu")

for IMAGE in $IMAGES
do
  echo "Deleting image $IMAGE"
  gcloud compute images delete "$IMAGE" --quiet
done

