#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./run_all.sh <xml_file> <project_name>"
    exit 1
fi

XML_FILE=$1
PROJECT_NAME=$2

# Paths to the dataset directory
DATASET_DIR="../tracking_buggy_files_${PROJECT_NAME}_dataset"

# Activate Python 2 environment
source ./env3/bin/activate

./process_bug_reports.py "$XML_FILE" "$DATASET_DIR" "${PROJECT_NAME}_base.json"

deactivate
source ./env2/bin/activate

./fix_and_augment.py "${PROJECT_NAME}_base.json" "$DATASET_DIR" > "${PROJECT_NAME}_aug.json"
./pick_bug_freq.py "${PROJECT_NAME}_aug.json" "$DATASET_DIR" > "${PROJECT_NAME}.json"

deactivate
source ./env3/bin/activate

./create_ast_cache.py "$DATASET_DIR" "${PROJECT_NAME}.json" "$PROJECT_NAME"
./vectorize_ast.py "${PROJECT_NAME}.json" "$PROJECT_NAME"
./vectorize_enriched_api.py "${PROJECT_NAME}.json" "$PROJECT_NAME"
./convert_tf_idf.py "${PROJECT_NAME}.json" "$PROJECT_NAME"
./calculate_feature_3.py "${PROJECT_NAME}.json" "$PROJECT_NAME"
./retrieve_features_5_6.py "${PROJECT_NAME}.json" "$PROJECT_NAME"
./calculate_notes_graph_features.py "${PROJECT_NAME}.json" "$PROJECT_NAME" "$DATASET_DIR"
./calculate_vectorized_features.py "${PROJECT_NAME}.json" "$PROJECT_NAME"
./save_normalized_fold_dataframes.py "${PROJECT_NAME}.json" "$PROJECT_NAME"

./load_data_to_joblib_memmap.py "$PROJECT_NAME"
./train_adaptive.py "$PROJECT_NAME"

deactivate
