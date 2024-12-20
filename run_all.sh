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

echo "[*] Running process_bug_reports.py"
./process_bug_reports.py "$XML_FILE" "$DATASET_DIR" "${PROJECT_NAME}_base.json" > "mew_pbr_${PROJECT_NAME}.txt"

deactivate
source ./env2/bin/activate 

echo "[*] Running fix_and_augment.py"
./fix_and_augment.py "${PROJECT_NAME}_base.json" "$DATASET_DIR" > "${PROJECT_NAME}_aug.json"

echo "[*] Running pick_bug_freq.py"
./pick_bug_freq.py "${PROJECT_NAME}_aug.json" "$DATASET_DIR" > "${PROJECT_NAME}.json"

deactivate
source ./env3/bin/activate

echo "[*] Running create_ast_cache.py"
./create_ast_cache.py "$DATASET_DIR" "${PROJECT_NAME}.json" "$PROJECT_NAME" > "mew_cast_${PROJECT_NAME}.txt"

echo "[*] Running vectorize_ast.py"
./vectorize_ast.py "${PROJECT_NAME}.json" "$PROJECT_NAME" > "mew_vast_${PROJECT_NAME}.txt"

echo "[*] Running vectorize_enriched_api.py"
./vectorize_enriched_api.py "${PROJECT_NAME}.json" "$PROJECT_NAME" > "mew_ve_${PROJECT_NAME}.txt"

echo "[*] Running convert_tf_idf.py"
./convert_tf_idf.py "${PROJECT_NAME}.json" "$PROJECT_NAME" > "mew_tfidf_${PROJECT_NAME}.txt"

echo "[*] Running calculate_feature_3.py"
./calculate_feature_3.py "${PROJECT_NAME}.json" "$PROJECT_NAME" > "mew_cf3_${PROJECT_NAME}.txt"

echo "[*] Running retrieve_features_5_6.py"
./retrieve_features_5_6.py "${PROJECT_NAME}.json" "$PROJECT_NAME" > "mew_56_${PROJECT_NAME}.txt"

echo "[*] Running calculate_notes_graph_features.py"
./calculate_notes_graph_features.py "${PROJECT_NAME}.json" "$PROJECT_NAME" "$DATASET_DIR" > > "mew_ng_${PROJECT_NAME}.txt"

echo "[*] Running calculate_vectorized_features.py"
./calculate_vectorized_features.py "${PROJECT_NAME}.json" "$PROJECT_NAME" > "mew_cvf_${PROJECT_NAME}.txt"

echo "[*] Running save_normalized_fold_dataframes.py"
./save_normalized_fold_dataframes.py "${PROJECT_NAME}.json" "$PROJECT_NAME" > "mew_snfd_${PROJECT_NAME}.txt"

echo "[*] Running load_data_to_joblib_memmap.py"
./load_data_to_joblib_memmap.py "$PROJECT_NAME"

echo "[*] Running train_adaptive.py"
./train_adaptive.py "$PROJECT_NAME" > "result_${PROJECT_NAME}.txt"

deactivate
