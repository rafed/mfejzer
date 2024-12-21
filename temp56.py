from unqlite import UnQLite
import pickle 
import sys

data_prefix = sys.argv[1]

bug_report_files_collection_db = UnQLite(data_prefix + "_bug_report_files_collection_db", flags=0x00000100 | 0x00000001)
current_files = pickle.loads(bug_report_files_collection_db["2da51603f2d6030f7033631325da6e48cef455e2"])
# bug_report_files_collection_db.close()

# shas = current_files['shas']
# sha_to_file_name = current_files['sha_to_file_name']

# print(current_files)

keys = bug_report_files_collection_db.keys()

# Print the keys
for key in keys:
    print(key)