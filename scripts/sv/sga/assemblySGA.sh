#!/bin/bash

set -eu

# either have the required variables set in the running environment, or provide them 
#  in command line
if [[ -z ${GATK_DIR+x} || -z ${CLUSTER_NAME+x} || -z ${FASTQ_DIR+x} || -z ${PROJECT_OUTPUT_DIR+x} ]]; then 
    if [[ "$#" -ne 4 ]]; then
        echo -e "Please provide:"
        echo -e "  [1] local directory of GATK build (required)"
        echo -e "  [2] cluster name (required)"
        echo -e "  [3] output directory on the cluster (required)"
        echo -e "  [4] directory of interleaved FASTQ files on the cluster (required)"
    exit 1
    fi
    GATK_DIR=$1
    CLUSTER_NAME=$2
    OUTPUT_DIR=$3
    FASTQ_DIR=$4
    MASTER_NODE="hdfs://""$CLUSTER_NAME""-m:8020"
    PROJECT_OUTPUT_DIR="$MASTER_NODE"/"$OUTPUT_DIR"
fi

"${GATK_DIR}/gatk-launch" RunSGAViaProcessBuilderOnSpark \
    --fullPathToSGA /usr/local/bin/sga \
    --inDir "$FASTQ_DIR" \
    --outDirPrefix "$PROJECT_OUTPUT_DIR"/assembly \
    --subStringToStrip assembly \
    -- \
    --sparkRunner GCS \
    --cluster "$CLUSTER_NAME" \
    --driver-memory 30G \
    --executor-memory 8G \
    --conf spark.yarn.executor.memoryOverhead=5000
