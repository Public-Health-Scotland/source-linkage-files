#!/usr/bin/bash
set -x #echo on

# Set folders
input_folder=/conf/sourcedev/Source_Linkage_File_Updates
output_folder=/conf/hscdiip/01-Source-linkage-files

# Create a file to alert anyone
echo "DON'T PANIC!" >$output_folder/Update-In-Progress.txt

# Take the years from the input e.g. ./copy_slf.sh 1718 1819
years=$@
for year in $years; do
	# Set the files to be writeable
	chmod 640 $output_folder/*$year.*

	# Copy the files for the given year
	cp -vt $output_folder/ \
		$input_folder/$year/source-episode-file-20$year.zsav \
		$input_folder/$year/source-episode-file-20$year.fst \
		$input_folder/$year/source-individual-file-20$year.zsav \
		$input_folder/$year/source-individual-file-20$year.fst

	# Set the files back to read-only
	chmod 440 $output_folder/*$year.*
done

# Remove the warning message
rm $output_folder/Update-In-Progress.txt
