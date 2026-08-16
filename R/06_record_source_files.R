# Record each source file, publisher, URL, time saved locally, size and SHA-256
#
# Run with --check to compare the downloaded files with the existing record

source("R/01_imd2025_calculations.R")  # Loads the shared source addresses, folders and ONS service address

# Build the recorded ONS address from the service name, selected fields and row order
ons_query_url <- function(service, fields, order_by = "LSOA21CD") {  # Defines how to build an ONS lookup address for the source-file record
  sprintf(  # Inserts the service, fields and row order into the ONS address
    paste0(  # Joins the two parts of the ONS address
      "%s/%s/FeatureServer/0/query?where=1=1&outFields=%s&",  # Requests every row and the selected geography fields
      "returnGeometry=false&orderByFields=%s&f=json"  # Omits boundary shapes and records the row order and response format
    ),  # Finishes the ONS address text
    ONS_GEOGRAPHY_URL,  # Supplies the main ONS Open Geography address
    service,  # Supplies the selected ONS lookup service
    paste(fields, collapse = ","),  # Lists the fields included in the saved lookup
    order_by  # Supplies the unique field used to order the lookup rows
  )  # Finishes the recorded ONS lookup address
}  # Finishes the ONS address function

# Details of the ten published files and ONS lookups recorded by this script
# Values in every column must remain in the same file order
SOURCE_FILES <- data.frame(  # Records the filename, purpose, publisher, collection method and source address for each input
  file = c(  # Lists the filenames used for the saved source copies
    "File_6_Population_Denominators.xlsx",  # Names the saved File 6 population dataset
    "File_7_IoD2025.csv",  # Names the saved File 7 LSOA score dataset
    "File_10_LAD_lower.xlsx",  # Names the saved lower-tier local-authority comparison dataset
    "File_11_LAD_upper.xlsx",  # Names the saved upper-tier local-authority comparison dataset
    "File_13_ICB_Summaries.xlsx",  # Names the saved ICB comparison dataset
    "lookup_lsoa21_sicbl23.csv",  # Names the saved 2023 LSOA-to-Sub-ICB lookup
    "lookup_lsoa21_sicbl24.csv",  # Names the saved 2024 LSOA-to-Sub-ICB lookup
    "lookup_lsoa21_sicbl25.csv",  # Names the saved 2025 LSOA-to-Sub-ICB lookup
    "lookup_lsoa21_sicbl26.csv",  # Names the saved 2026 LSOA-to-Sub-ICB lookup
    "lookup_lad24_utla24.csv"  # Names the saved lower-to-upper-tier local-authority lookup
  ),  # Finishes the ten saved source filenames
  role = c(  # Describes how each source contributes to the calculations or checks
    "File 6 - population denominators (all 5 bands)",  # Provides all five LSOA population measures
    "File 7 - all ranks, deciles, scores and denominators (primary input)",  # Provides the LSOA deprivation scores and four weighting populations
    "File 10 v2 - lower-tier LAD summaries (used for comparison)",  # Provides published lower-tier scores used to check the calculations
    "File 11 v2 - upper-tier LA summaries (used for comparison)",  # Provides published upper-tier scores used to check the calculations
    "File 13 - ICB summaries (used for comparison)",  # Provides published ICB scores used to check the calculations
    "LSOA21 to SICBL/ICB lookup, 2023 vintage",  # Assigns each 2021 LSOA to its 2023 Sub-ICB and ICB
    "LSOA21 to SICBL/ICB lookup, 2024 vintage",  # Assigns each 2021 LSOA to its 2024 Sub-ICB and ICB
    "LSOA21 to SICBL/ICB lookup, 2025 vintage",  # Assigns each 2021 LSOA to its 2025 Sub-ICB and ICB
    "LSOA21 to SICBL/ICB lookup, 2026 vintage",  # Assigns each 2021 LSOA to its 2026 Sub-ICB and ICB
    "LAD 2024 to UTLA 2024 lookup (assigns the upper tier)"  # Assigns each lower-tier authority to its 2024 upper-tier authority
  ),  # Finishes the descriptions of how the ten sources are used
  publisher = c(  # Records which organisation supplied each source
    rep("MHCLG", 5),  # Records MHCLG as the publisher of Files 6, 7, 10, 11 and 13
    rep("ONS Open Geography Portal", 5)  # Records ONS as the publisher of the five geography lookups
  ),  # Finishes the source publishers
  collection_method = c(  # Records how each source was obtained
    rep("Download", 5),  # Records the five MHCLG files as direct downloads
    rep("ONS query", 5)  # Records the five geography lookups as results obtained from ONS
  ),  # Finishes the source collection methods
  source = c(  # Records the published address used to obtain each source
    FILE_6_URL,  # Records the published address for File 6 population measures
    FILE_7_URL,  # Records the published address for File 7 LSOA scores
    FILE_10_URL,  # Records the published address for lower-tier local-authority scores
    FILE_11_URL,  # Records the published address for upper-tier local-authority scores
    FILE_13_URL,  # Records the published address for ICB scores
    ons_query_url(  # Records the ONS request for the 2023 Sub-ICB lookup
      "LSOA21_SICBL23_ICB23_LAD23_EN_LU",  # Selects the 2023 LSOA-to-Sub-ICB service
      c("LSOA21CD", "SICBL23CD", "SICBL23CDH", "SICBL23NM", "ICB23CD", "ICB23NM")  # Requests the LSOA, Sub-ICB and ICB identifiers
    ),  # Finishes the recorded 2023 ONS request
    ons_query_url(  # Records the ONS request for the 2024 Sub-ICB lookup
      "LSOA21_SICBL24_ICB24_CAL24_LAD24_EN_LU",  # Selects the 2024 LSOA-to-Sub-ICB service
      c("LSOA21CD", "SICBL24CD", "SICBL24CDH", "SICBL24NM", "ICB24CD", "ICB24NM")  # Requests the LSOA, Sub-ICB and ICB identifiers
    ),  # Finishes the recorded 2024 ONS request
    ons_query_url(  # Records the ONS request for the 2025 Sub-ICB lookup
      "LSOA21_SICBL25_ICB25_CAL25_LAD25_EN_LU",  # Selects the 2025 LSOA-to-Sub-ICB service
      c("LSOA21CD", "SICBL25CD", "SICBL25CDH", "SICBL25NM", "ICB25CD", "ICB25NM")  # Requests the LSOA, Sub-ICB and ICB identifiers
    ),  # Finishes the recorded 2025 ONS request
    ons_query_url(  # Records the ONS request for the 2026 Sub-ICB lookup
      "LSOA21_SICBL26_ICB26_CAL26_LAD26_EN_LU",  # Selects the 2026 LSOA-to-Sub-ICB service
      c("LSOA21CD", "SICBL26CD", "SICBL26CDH", "SICBL26NM", "ICB26CD", "ICB26NM")  # Requests the LSOA, Sub-ICB and ICB identifiers
    ),  # Finishes the recorded 2026 ONS request
    ons_query_url(  # Records the ONS request for the local-authority lookup
      "WD24_PCON24_LAD24_UTLA24_UK_LU",  # Selects the 2024 lower-to-upper-tier authority service
      c("WD24CD", "LAD24CD", "UTLA24CD", "UTLA24NM"),  # Requests the ward and required authority identifiers
      order_by = "WD24CD"  # Orders the returned records by ward code
    )  # Finishes the recorded local-authority ONS request
  )  # Finishes the ten published source addresses
)  # Finishes the source-file details table

# Set whether to check the existing record or create a new one

check_only <- "--check" %in% commandArgs(trailingOnly = TRUE)  # Records whether this run should only check the existing hashes
source_log_csv <- file.path(RESULTS_DIR, "source_file_record.csv")  # Sets the location of the CSV source-file record
source_log_markdown <- "SOURCE_FILES.md"  # Sets the location of the readable source-file record

# Check that all ten source files have already been downloaded or collected

source_paths <- file.path(SOURCE_DATA_DIR, SOURCE_FILES$file)  # Constructs the expected location of each source file
missing_files <- SOURCE_FILES$file[!file.exists(source_paths)]  # Identifies required source files that are not present

if (length(missing_files) > 0) {  # Checks whether all ten required source files are present
  stop(  # Reports which source files must be obtained first
    "source files missing from ", SOURCE_DATA_DIR,  # Identifies the source-data folder
    "; run the calculation scripts first: ",  # Explains how the missing files are normally obtained
    paste(missing_files, collapse = ", ")  # Lists the missing source filenames
  )  # Finishes constructing the missing-source message
}  # Finishes checking the required source files

# Report how many source files will be recorded or checked

msg(sprintf("checking %d source files", nrow(SOURCE_FILES)))  # Reports the number of required source files

# Record the size, local save time and hash of each source file

source_rows <- lapply(seq_len(nrow(SOURCE_FILES)), function(i) {  # Repeats the file checks for each required source
  source_details <- SOURCE_FILES[i, , drop = FALSE]  # Selects this source's filename, purpose, publisher and address
  path <- source_paths[i]  # Uses this source file's checked location in the source-data folder
  file_details <- file.info(path)  # Reads the local file size and last-written time
  data.frame(  # Records the details and SHA-256 hash for this source file
    file = source_details$file,  # Records the saved source filename
    role = source_details$role,  # Records how the source file is used
    publisher = source_details$publisher,  # Records the source publisher
    collection_method = source_details$collection_method,  # Records how the source was collected
    source = source_details$source,  # Records the source address
    collected_utc = format(  # Records when the local source copy was last saved
      as.POSIXct(file_details$mtime, tz = "UTC"),  # Converts the local file's last-written time to UTC
      "%Y-%m-%dT%H:%M:%SZ",  # Uses an unambiguous year-month-day UTC format
      tz = "UTC"  # Writes the recorded time in UTC
    ),  # Finishes recording the local save time
    bytes = file_details$size,  # Records the source-file size in bytes
    sha256 = digest::digest(file = path, algo = "sha256")  # Calculates the source file's SHA-256 hash
  )  # Finishes this source-file record
})  # Finishes recording all ten source files
source_log <- do.call(rbind, source_rows)  # Combines the ten source-file records
source_log <- source_log[  # Orders the source-file records consistently
  order(source_log$collection_method, source_log$file),  # Orders rows by collection method and filename
]  # Finishes ordering the source-file records

# Compare the current hashes with the saved record when --check is requested

if (check_only) {  # Runs the comparison without rewriting either source-file record
  if (!file.exists(source_log_csv)) {  # Checks that the existing CSV record is available
    stop("no existing source-file record at ", source_log_csv)  # Stops because there are no recorded hashes to compare
  }  # Finishes checking for the existing CSV record

  recorded_log <- utils::read.csv(  # Reads the existing source-file record
    source_log_csv, colClasses = "character"  # Reads every recorded value as text
  )  # Finishes reading the existing source-file record

  file_comparison <- merge(  # Matches each current source file to its recorded hash
    recorded_log[, c("file", "sha256")],  # Supplies the recorded filenames and hashes
    source_log[, c("file", "sha256")],  # Supplies the current filenames and hashes
    by = "file",  # Matches the two records by saved filename
    all = TRUE,  # Retains files appearing in only the recorded or current list
    suffixes = c("_recorded", "_current")  # Labels the recorded and current hash columns
  )  # Finishes matching the recorded and current hashes

  changed_files <- file_comparison[  # Selects missing files and files whose contents changed
    is.na(file_comparison$sha256_recorded) |  # Finds current files absent from the existing record
      is.na(file_comparison$sha256_current) |  # Finds recorded files absent from the current source folder
      file_comparison$sha256_recorded != file_comparison$sha256_current,  # Finds files whose current and recorded hashes differ
  ]  # Finishes selecting missing or changed source files

  if (nrow(changed_files) > 0) {  # Checks whether any source file is missing or changed
    print(changed_files, row.names = FALSE)  # Displays the affected filenames and hashes
    stop(nrow(changed_files), " source files differ from the recorded SHA-256")  # Stops because the current sources do not match the record
  }  # Finishes checking for missing or changed source files

  cat(sprintf(  # Reports that every required source file passed the hash check
    "PASS: all %d source files match their recorded SHA-256\n",  # Sets the successful source-file message
    nrow(file_comparison)  # Supplies the number of source files checked
  ))  # Finishes reporting the successful hash check

  quit(save = "no", status = 0)  # Ends the check-only run without rewriting the records
}  # Finishes the check-only path

# Save the complete source-file record as a CSV file

utils::write.csv(  # Writes the source-file details in a format that R can read directly
  source_log,  # Supplies the ten current source-file records
  source_log_csv,  # Sets the CSV output location
  row.names = FALSE,  # Prevents R row numbers being written as a column
  na = ""  # Writes any unavailable values as blank cells
)  # Finishes saving the CSV source-file record

# Define how source-file sizes are displayed in the readable record

format_file_size <- function(bytes) {  # Defines how to display a source-file size clearly
  ifelse(  # Chooses megabytes or kilobytes according to the file size
    bytes >= 1024^2,  # Checks whether the file is at least one megabyte
    sprintf("%.1f MB", bytes / 1024^2),  # Reports larger files in megabytes
    sprintf("%.0f KB", bytes / 1024)  # Reports smaller files in kilobytes
  )  # Finishes conditional value
}  # Ends the format file size definition

# Build the readable source-file record before writing it

markdown_lines <- c(  # Starts the heading and explanation for the readable record
  "# Source files used",  # Adds the source-file record title
  "",  # Separates the title from the introduction
  "This record identifies every source file used to calculate and check the",  # Explains which files the record covers
  "results, including its publisher, source URL, local save time, size and",  # Lists the recorded source details
  "SHA-256.",  # Finishes the list of recorded source details
  "",  # Separates the introduction from the generation details
  paste0(  # Records when and how this readable file was created
    "Generated by `R/06_record_source_files.R` on ",  # Identifies the script that created the record
    format(Sys.time(), "%Y-%m-%d %H:%M:%S", tz = "UTC"),  # Supplies the current UTC date and time
    " UTC. Machine-readable copy: ",  # Introduces the CSV version of the record
    "[`data/source_file_record.csv`](data/source_file_record.csv)."  # Links to the CSV source-file record
  ),  # Finishes the generation details
  "",  # Separates the generation details from the checking instructions
  "Check the downloaded files against this record:",  # Introduces the check-only command
  "",  # Separates the instruction from the command
  "```bash",  # Starts the command example
  "Rscript R/06_record_source_files.R --check",  # Gives the command that compares current and recorded hashes
  "```",  # Ends the command example
  "",  # Separates the command from the field explanations
  "## How to read this record",  # Starts the explanation of the recorded fields
  "",  # Separates the heading from the explanations
  "- **Local copy saved (UTC)** is when the downloaded or collected file was last written.",  # Explains the recorded local file time
  "- **Download** identifies a file supplied directly by the publisher.",  # Explains the direct-download collection method
  "- **ONS query** identifies a lookup table collected from the ONS service.",  # Explains the ONS collection method
  "  The recorded URL gives the selected fields; the R script collects every row.",  # Explains how the complete ONS lookup is assembled
  "",  # Separates the field explanations from the source tables
  "## IoD2025",  # Starts the source tables for this edition
  ""  # Separates the edition heading from the first publisher
)  # Finishes the introductory Markdown lines

# Add one source-file table and URL list for each publisher

for (publisher in unique(source_log$publisher)) {  # Repeats the Markdown section for each source publisher
  publisher_rows <- source_log[  # Selects the source files supplied by this publisher
    source_log$publisher == publisher,  # Keeps rows for the current publisher
  ]  # Finishes selecting this publisher's source files

  markdown_lines <- c(  # Adds this publisher's table and source addresses
    markdown_lines,  # Retains the Markdown lines already assembled
    paste0("### ", publisher),  # Adds the publisher heading
    "",  # Separates the heading from the source-file table
    "| File | Purpose | Local copy saved (UTC) | Size | SHA-256 |",  # Adds the source-file table headings
    "|---|---|---|---|---|",  # Adds the Markdown table alignment
    sprintf(  # Creates one source-file table row for each file from this publisher
      "| `%s` | %s | %s | %s | `%s` |",  # Sets the source-file table row layout
      publisher_rows$file,  # Supplies each saved source filename
      publisher_rows$role,  # Supplies how each source file is used
      publisher_rows$collected_utc,  # Supplies when each local copy was last saved
      format_file_size(publisher_rows$bytes),  # Supplies each source-file size in KB or MB
      publisher_rows$sha256  # Supplies each source-file SHA-256 value
    ),  # Finishes this publisher's source-file table rows
    "",  # Separates the table from the source-address list
    "<details><summary>Source URLs</summary>",  # Starts the expandable source-address section
    "",  # Separates the expandable heading from the addresses
    sprintf(  # Creates one source-address entry for each file from this publisher
      "- `%s`\n  <%s>",  # Sets the filename and address layout
      publisher_rows$file,  # Supplies each saved source filename
      publisher_rows$source  # Supplies each publisher or ONS address
    ),  # Finishes this publisher's source-address entries
    "",  # Separates the addresses from the closing marker
    "</details>",  # Closes the expandable source-address section
    ""  # Separates this publisher from the next section
  )  # Finishes adding this publisher's Markdown section
}  # Finishes adding all publisher sections

# Add the licence and publication notes to the readable record

markdown_lines <- c(  # Adds the final explanatory sections
  markdown_lines,  # Retains the source tables and addresses already assembled
  "## Licence",  # Starts the source-data licence section
  "",  # Separates the heading from the licence text
  "Every source listed above is Crown copyright and available under the",  # Introduces the source-data licence
  "[Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).",  # Links to the Open Government Licence
  "The derived files in `data/` remain under OGL v3 and require attribution.",  # States the licence applying to the derived files
  "See [DATA_LICENCE.md](DATA_LICENCE.md) for the required wording.",  # Links to the required attribution wording
  "",  # Separates the licence from the publication notes
  "## Publication notes",  # Starts the publication notes
  "",  # Separates the heading from the notes
  "- The Indices of Deprivation 2025 were published on **30 October 2025**.",  # Records the IoD2025 publication date
  "- Files 10 and 11 are the corrected v2 files.",  # Identifies the corrected local-authority files
  "- File 7 omits `Population aged 16-59: mid 2022`, so File 6 is also used.",  # Explains why both population files are required
  "- ONS may revise a geography service without changing its URL."  # Explains why the saved ONS extracts are hashed
)  # Finishes the complete Markdown source-file record

# Write the complete readable source-file record in one operation

writeLines(markdown_lines, source_log_markdown)  # Saves the completed Markdown record without risking a partial series of writes

# Report the source-file records created by this run

msg("wrote", source_log_csv, "and", source_log_markdown)  # Reports the two source-file record locations
print(  # Displays the source files and their recorded sizes and times
  source_log[, c("file", "collection_method", "collected_utc", "bytes")],  # Selects the source details shown after writing the record
  row.names = FALSE  # Prevents R row numbers being displayed
)  # Finishes displaying the recorded source files
cat(sprintf(  # Reports the number and combined size of the recorded files
  "\n%d files recorded, %s total\n",  # Sets the final source-file summary
  nrow(source_log),  # Supplies the number of recorded source files
  format_file_size(sum(source_log$bytes))  # Supplies their combined size in KB or MB
))  # Finishes reporting the source-file summary
