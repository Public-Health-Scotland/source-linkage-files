import os
from collections import defaultdict
import re

if __name__ == "__main__":
    base_dir = r"\\stats\sourcedev\Source_Linkage_File_Updates\Extracts Temp"

    print("Looking in '{}' for csv files.".format(base_dir))

    # Create a list of all the csv files
    all_extracts = [file for file in os.listdir(base_dir) if file.endswith(".csv")]

    # Set up a default dict
    files_by_year = defaultdict(list)

    # Set up the regEx
    # Look for files ending "-20...."
    pattern = re.compile(r"-20(\d\d\d\d).csv")

    # Create a dictionary as {'Year':[file1, file2]} etc.
    # match.group(1) will be the year e.g. 1718
    for file in all_extracts:
        match = pattern.search(file)
        if match:
            files_by_year[match.group(1)].append(file)
            
    n_files = files_by_year.__len__()

    if n_files == 0:
        print("No correctly named csv files found.")
    else:
        print("Found {} csv files to process.".format(n_files))

    # Loop through the dictionary by year
    for year in files_by_year.keys():
        # Create a string for the relevant year's directory
        year_dir = os.path.join(
            r"\\stats\sourcedev\Source_Linkage_File_Updates\{}\Extracts".format(year)
        )

        # First check if the year folder exists
        # if not create it
        if os.path.exists(year_dir) != True:
            os.makedirs(year_dir)
            print("Creating new folder for {}".format(year))

        for file in files_by_year[year]:
            # Create string for the 'old' and 'new' locations
            unsorted_file = os.path.join(base_dir, file)
            sorted_file = os.path.join(year_dir, file)

            # If a file already exists remove the old one first
            if os.path.exists(sorted_file):
                os.remove(sorted_file)
                print("Removed existing {} from {} folder".format(file, year))

            # Move to the sorted location
            os.rename(unsorted_file, sorted_file)
            print("Moved {} to {} folder\n".format(file, year))

    input("Press enter to close")
