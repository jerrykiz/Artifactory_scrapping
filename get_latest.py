#!/usr/bin/python3

import json
import requests, zipfile, io
import traceback
import argparse
import logging
import os
import datetime
import sys
import platform

# Get the arguments from CLI
parser = argparse.ArgumentParser()
parser.add_argument('-u', '--user', required=True, help="Inserts the user's name\n e.g. kzg8fe")
parser.add_argument('-a', '--apikey', required=True, help="Inserts the user's Artifactory Api Key")
parser.add_argument('-r', '--repo', required=True, help="Inserts the repository's name\n e.g. etas-etk-binary-snapshot-local")
parser.add_argument('-p', '--path', required=True, help="Inserts the path\n e.g. FETK/HDC/FETK-S2.0A_Work")
parser.add_argument('-f', '--file', required=True, help="Inserts the file's name\n e.g. FETK-S2.0A_Work_VERSION_+trunk.zip or \nFETK-S2.0A_Work_VERSION_BETA+trunk.zip")
parser.add_argument('-l', '--logfile', help="Inserts the logfile's path")
parser.add_argument('-d', '--download', help="Downloads the latest artifact into a given path")
args = parser.parse_args()

# Save the arguments in variables
repo = args.repo
path = args.path
name_of_file_part1 = args.file[:args.file.find("_VERSION_")]
name_of_file_part2 = args.file[args.file.find("_VERSION_") + 9:]
logfile_path = ""
if args.logfile:
	logfile_path = args.logfile
download_path = ""
if args.download:
	download_path = args.download

# Headers for the API request
headers = {
    'Content-Type': 'text/plain'
}

# Credentials for the API request
user = args.user
key = args.apikey
url = 'https://rb-artifactory.bosch.com:/artifactory/api/search/aql'

# Get the latest artifact
def get_latest_artifact():
	if "BETA" not in name_of_file_part2:
		aql = f'''items.find({{
		\"repo\" : {{\"$match\" : \"{repo}\"}},
		\"path\" : {{\"$match\" : \"{path}\"}},
		\"name\" : {{\"$match\" : \"{name_of_file_part1}*{name_of_file_part2}\"}},
		\"name\" : {{\"$nmatch\": \"*BETA*\"}}
		}})
		.sort({{\"$desc\" : [\"updated\"]}})
		.limit(1)
		'''
	else:
		aql = f'''items.find({{
		\"repo\" : {{\"$match\" : \"{repo}\"}},
		\"path\" : {{\"$match\" : \"{path}\"}},
		\"name\" : {{\"$match\" : \"{name_of_file_part1}*{name_of_file_part2}\"}}
		}})
		.sort({{\"$desc\" : [\"updated\"]}})
		.limit(1)
		'''
	r = requests.post(url=url, headers=headers, data=aql, auth=(user, key))
	assert r.status_code == 200
	rj = json.loads(r.text)
	return rj["results"]

# Download latest artifact
def download_latest(download_path, item_path, file):
	downloaded_foldername = file[:file.rfind(".")]
	r = requests.get(url=item_path, auth=(user, key), stream=True)
	assert r.status_code == 200
	z = zipfile.ZipFile(io.BytesIO(r.content))
	download_path_and_file = f"{download_path}{path_separator()}{downloaded_foldername}"
	z.extractall(download_path_and_file)
	return download_path_and_file

# Get the path of the latest artifact		
def get_path(artifact):
	name = artifact[0]["name"]
	path = artifact[0]["path"]
	repo = artifact[0]["repo"]
	artpath = f"{url[:45]}/{repo}/{path}/{name}"
	return artpath

# Write in logfile
def write_log(log_to_be_saved):
	logging_path = ""
	prefix = os.path.splitext(os.path.basename(__file__))[0]
	if logfile_path:
		logging_path = f"{logfile_path}{path_separator()}"
	f = open(logging_path + prefix + ".log","a")
	f.write(f"{log_to_be_saved}")
	f.close

def path_separator():
	os = platform.system()
	separator = "/" if os == "Linux" else "\\"
	return separator

# MAIN
if __name__ == "__main__":

	# Get the name of the latest build
	latest_artifact = get_latest_artifact()
	# print(latest_artifact)
	latest_artifact_path = get_path(latest_artifact)
	result_name = latest_artifact[0]["name"]
	downloaded = ""

	# Download file
	warning_message = None
	if download_path:
		if os.path.isdir(download_path):
			download_path_file = download_latest(download_path, latest_artifact_path, result_name)
			downloaded = f"\n\t- Download location: {download_path}"
		else:
			warning_message = f"\n\n\tWARNING: {download_path} isn't a valid path\n\n"

	# CLI Output
	output = ""
	if download_path:
		if warning_message:
			output = warning_message
		else:
			output = f"{download_path_file}{path_separator()}"
	else:
		output = f"{result_name}"
	print(output)
	
	if not warning_message:
		# Create logfile
		if logfile_path:
			logfile_variable = f"\n\t- Logfile's location: {logfile_path}"
		else:
			logfile_variable = ""
		
		input_parameters = f"INPUT OF PARAMETERS: \n\t- Repository: {repo}\n\t- Path: {path}\n\t- File: {args.file}{logfile_variable}{downloaded}\n"	

		longest_message = f"COMPLETE PATH IN ARTIFACTORY:\n\t- {latest_artifact_path}\n"
		length_of_longest_seperator = len(longest_message) - 25
		write_log(f"{length_of_longest_seperator * '#'}\n")
		write_log(f"{42 * '*'}\n")
		write_log("* NEW SEARCH OF LATEST ARTIFACTORY BUILD *\n")
		write_log(f"{42 * '*'}\n")
		write_log(input_parameters)
		write_log(f"DATE:\n\t- {datetime.datetime.now().strftime('%b %d %Y %H:%M:%S')}\n\n")
		write_log(f"{longest_message[:111]}\n")
		write_log(f"\t  {longest_message[111:]}\n")
		write_log(f"NAME OF FILE:\n\t- {result_name}\n")
		write_log(f"{length_of_longest_seperator * '#'}\n")