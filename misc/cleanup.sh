#!/bin/bash

# Usage: ./cleanup_datasets.sh [prefix]
# Default prefix is 'dataflow_demo'

PREFIX="${1:-dataflow_demo}"

DATASETS=(
  "${PREFIX}_marts"
  "${PREFIX}_raw_data"
  "${PREFIX}_staging"
  "${PREFIX}_marts__dev"
  "${PREFIX}_staging__dev"
)

PROJECT=$(gcloud config get-value project)

for DATASET in "${DATASETS[@]}"; do
  echo "Deleting dataset: ${PROJECT}:${DATASET}"
  bq rm -r -f "${PROJECT}:${DATASET}"
done