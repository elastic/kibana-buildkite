#!/bin/bash

cd packer

echo --- Building agent cache image
packer build ./agent-cache.pkr.hcl
