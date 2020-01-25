# Artifactory Scrapping
# ---------------------

In this repo I have created three files:
- get_latest.py
- latest_artifactory.bat
- latest_artifactory.sh

# ---------------------

## get_latest.py

After having given the necessary variables in the cli, executing get_latest.py lets us find the latest build of a half-given filename in Artifactory and download it. We can specify the download location, such the logfile location as well. The logfile keeps track of all our actions with the program.

## latest_artifactory.bat

It lets us automate the process of downloading the latest build from Artifactory and copying it into a specified folder (in Windows), by using get_latest.py.

## latest_artifactory.sh

It lets us automate the process of downloading the latest build from Artifactory and copying it into a specified folder (in Linux), by using get_latest.py. 
