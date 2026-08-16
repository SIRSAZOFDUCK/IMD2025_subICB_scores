# Compare rebuilt CSV results with the versions committed in Git
#
# Text values, missing values, row order and column order must match exactly
# Numbers may differ by no more than 0.0000015 to allow harmless differences
# in the final decimal place between computers

# Set the permitted numerical difference and the Git version used for comparison

ALLOWED_NUMERICAL_DIFFERENCE <- 1.5e-6  # Allows a difference of up to 0.0000015 between rebuilt and committed numbers
REFERENCE <- "HEAD"  # Uses the files committed at the current local Git revision as the reference

# Copy one committed CSV result from Git into a temporary file

read_reference_file <- function(path) {  # Defines how to obtain a committed CSV without changing the working files
  temporary_file <- tempfile(fileext = ".csv")  # Creates a temporary location for the committed CSV
  git_status <- suppressWarnings(system2(  # Asks Git to write the committed file to the temporary location
    "git",  # Runs the local Git program
    c("show", paste0(REFERENCE, ":", path)),  # Selects this file from the current committed revision
    stdout = temporary_file,  # Writes the committed CSV contents to the temporary file
    stderr = FALSE  # Hides Git's error text so the script can give a clearer message
  ))  # Finishes asking Git for the committed CSV

  if (!identical(git_status, 0L)) {  # Checks whether Git found and copied the requested file
    unlink(temporary_file)  # Removes the unused temporary file after an unsuccessful Git request
    return(NULL)  # Reports that the committed file was unavailable
  }  # Finishes handling an unavailable committed file

  temporary_file  # Returns the temporary location of the committed CSV
}  # Finishes the committed-result file function

# Compare the structure and values of one rebuilt table with its committed version

compare_result_tables <- function(current, reference) {  # Defines the checks applied to one rebuilt and committed CSV pair
  issues <- character()  # Starts an empty character vector for difference messages

  if (!identical(names(current), names(reference))) {  # Checks that column names and their order are unchanged
    issues <- c(issues, sprintf(  # Records the rebuilt and committed column layouts
      "columns or column order differ (committed: %s | rebuilt: %s)",  # Sets the column-layout message
      paste(names(reference), collapse = ", "),  # Lists the committed columns in their saved order
      paste(names(current), collapse = ", ")  # Lists the rebuilt columns in their current order
    ))  # Finishes recording the column-layout difference
    return(list(issues = issues, max_difference = NA_real_))  # Stops because the two tables cannot be compared safely
  }  # Finishes checking the columns

  if (nrow(current) != nrow(reference)) {  # Checks that the number of saved result rows is unchanged
    issues <- c(issues, sprintf(  # Records the difference in row counts
      "row count changed from %d to %d",  # Sets the row-count message
      nrow(reference),  # Supplies the committed row count
      nrow(current)  # Supplies the rebuilt row count
    ))  # Finishes recording the row-count difference
    return(list(issues = issues, max_difference = NA_real_))  # Stops because the rows cannot be compared safely
  }  # Finishes checking the row count

  max_difference <- 0  # Starts the largest numerical difference at zero

  for (column in names(current)) {  # Repeats the comparison for every result column
    current_values <- current[[column]]  # Selects the rebuilt values in this column
    reference_values <- reference[[column]]  # Selects the committed values in the same column

    if (is.numeric(current_values) && is.numeric(reference_values)) {  # Uses the numerical allowance when both columns contain numbers
      difference <- abs(current_values - reference_values)  # Calculates the absolute difference in each row
      both_missing <- is.na(current_values) & is.na(reference_values)  # Identifies rows missing in both versions
      one_missing <- xor(is.na(current_values), is.na(reference_values))  # Identifies rows missing in only one version
      difference[both_missing] <- 0  # Treats two missing numerical values as equal
      difference[one_missing] <- Inf  # Makes a one-sided missing value fail the comparison

      column_max <- if (length(difference) > 0) max(difference) else 0  # Finds the largest difference in this numerical column
      max_difference <- max(max_difference, column_max)  # Updates the largest numerical difference found in the table

      if (column_max > ALLOWED_NUMERICAL_DIFFERENCE) {  # Checks whether this column exceeds the permitted numerical difference
        row <- which.max(difference)  # Identifies the row containing the largest difference
        issues <- c(issues, sprintf(  # Records the largest numerical difference in this column
          "%s: maximum difference %.3g at row %d (%s to %s)",  # Sets the numerical-difference message
          column,  # Identifies the affected column
          column_max,  # Supplies its largest absolute difference
          row,  # Supplies the affected row number
          format(reference_values[row], digits = 10),  # Shows the committed value
          format(current_values[row], digits = 10)  # Shows the rebuilt value
        ))  # Finishes recording the numerical difference
      }  # Finishes checking this numerical column
    } else {  # Compares non-numerical values without an allowance
      current_text <- as.character(current_values)  # Converts the rebuilt values to comparable text
      reference_text <- as.character(reference_values)  # Converts the committed values to comparable text
      equal <- (is.na(current_text) & is.na(reference_text)) |  # Treats two missing text values as equal
        (  # Combines the requirements for two matching recorded values
          !is.na(current_text) & !is.na(reference_text) &  # Requires a recorded value in both versions
            current_text == reference_text  # Requires those two text values to match exactly
        )  # Finishes the exact text comparison

      if (!all(equal)) {  # Checks whether any text or missing-value position changed
        issues <- c(issues, sprintf(  # Records how many text values differ in this column
          "%s: %d text values differ",  # Sets the text-difference message
          column,  # Identifies the affected column
          sum(!equal)  # Supplies the number of differing rows
        ))  # Finishes recording the text differences
      }  # Finishes checking this text column
    }  # Finishes choosing the numerical or exact text comparison
  }  # Finishes comparing all result columns

  list(  # Returns the messages and largest numerical difference for this table
    issues = issues,  # Returns every difference message recorded for this table
    max_difference = max_difference  # Returns the largest numerical difference found
  )  # Finishes the table-comparison result
}  # Finishes the result-table comparison function

# Define the seven calculated and comparison CSV files that must be checked

csv_file_pattern <- "\\.csv$"  # Matches filenames ending in .csv
expected_result_files <- c(  # Lists every calculated result that scripts 02–05 should produce
  "imd2025_subicb_scores_long.csv",  # Contains the Sub-ICB average scores from script 02
  "index_metadata.csv",  # Describes the deprivation indices included in the Sub-ICB results
  "population_denominators_subicb.csv",  # Contains the Sub-ICB population totals from script 03
  "validation_vs_file1011_la_detail.csv",  # Contains every local-authority comparison from script 05
  "validation_vs_file1011_la.csv",  # Summarises the local-authority comparisons from script 05
  "validation_vs_file13_icb_detail.csv",  # Contains every ICB comparison from script 04
  "validation_vs_file13_icb.csv"  # Summarises the ICB comparisons from script 04
)  # Finishes the list of required calculated results

# List the current result CSVs while leaving out the source-file record checked by script 06

current_files <- sort(setdiff(  # Lists the calculated CSV results currently present
  list.files("data", pattern = csv_file_pattern),  # Finds CSV files in the project data folder
  "source_file_record.csv"  # Excludes the source-file record produced and checked by script 06
))  # Finishes listing the current calculated results

# List the CSV files committed in the project data folder at the selected Git revision

reference_paths <- suppressWarnings(system2(  # Asks Git for the committed files under data
  "git",  # Runs the local Git program
  c("ls-tree", "-r", "--name-only", REFERENCE, "--", "data"),  # Lists every committed path under data at the selected revision
  stdout = TRUE  # Returns the committed paths to R
))  # Finishes obtaining the committed file list
reference_files <- sort(basename(  # Keeps the filenames without the preceding data folder
  grep(csv_file_pattern, reference_paths, value = TRUE)  # Keeps only committed paths ending in .csv
))  # Finishes listing the committed CSV filenames

# Check that all seven results exist now and in Git, with no additional current results

missing_current <- setdiff(expected_result_files, current_files)  # Finds required results missing from the current data folder
unexpected_current <- setdiff(current_files, expected_result_files)  # Finds current CSV results not included in the required list
missing_reference <- setdiff(expected_result_files, reference_files)  # Finds required results absent from the selected Git revision

if (length(missing_current) ||  # Checks for required results missing from the current data folder
    length(unexpected_current) ||  # Checks for unrecognised results in the current data folder
    length(missing_reference)) {  # Checks for required results missing from the selected Git revision
  stop(sprintf(  # Stops and reports every file-list problem found
    paste0(  # Joins the three parts of the file-list error message
      "saved result files differ (missing now: %s | ",  # Introduces the currently missing results
      "unexpected now: %s | missing from %s: %s)"  # Introduces unexpected and uncommitted results
    ),  # Finishes the file-list message
    paste(missing_current, collapse = ", "),  # Lists required results missing from the current data folder
    paste(unexpected_current, collapse = ", "),  # Lists unrecognised current CSV results
    REFERENCE,  # Identifies the Git revision being checked
    paste(missing_reference, collapse = ", ")  # Lists required results missing from that Git revision
  ))  # Finishes reporting the file-list problems
}  # Finishes checking the required result files

# Put the seven result files in a consistent order for comparison and reporting

current_files <- expected_result_files  # Uses the stated required-file order for all subsequent comparisons

# Report how many files will be compared and the permitted numerical difference

cat(sprintf(  # Prints the opening comparison message
  "Comparing %d result files with %s (tolerance %.1e)\n\n",  # Sets the comparison message
  length(current_files),  # Supplies the number of files being compared
  REFERENCE,  # Identifies the committed Git revision
  ALLOWED_NUMERICAL_DIFFERENCE  # Supplies the permitted numerical difference
))  # Finishes printing the opening comparison message

# Compare every current result table with its committed version

comparison_results <- list()  # Starts an empty list for the seven file-comparison results

for (result_file in current_files) {  # Repeats the comparison for each required result file
  current_path <- file.path("data", result_file)  # Sets the location of the current CSV result
  reference_file <- read_reference_file(current_path)  # Copies the committed CSV to a temporary file

  if (is.null(reference_file)) {  # Checks whether Git returned the requested committed CSV
    stop(current_path, " is not present in ", REFERENCE)  # Stops when the committed CSV cannot be obtained
  }  # Finishes checking that the committed CSV is available

  comparison <- compare_result_tables(  # Compares the current and committed tables
    utils::read.csv(current_path, stringsAsFactors = FALSE),  # Reads the current CSV without converting text columns
    utils::read.csv(reference_file, stringsAsFactors = FALSE)  # Reads the committed CSV without converting text columns
  )  # Finishes comparing the two tables
  unlink(reference_file)  # Removes the temporary copy of the committed CSV

  comparison_results[[result_file]] <- list(  # Records the comparison result under its filename
    status = if (length(comparison$issues)) "DIFFERS" else "match",  # Records whether any unacceptable differences were found
    issues = comparison$issues,  # Records descriptions of the differences found
    max_difference = comparison$max_difference  # Records the largest numerical difference in the file
  )  # Finishes recording this file comparison
}  # Finishes comparing all seven result files

# Display one summary row for each checked result file

summary_table <- data.frame(  # Creates the seven-file comparison summary
  file = names(comparison_results),  # Records each checked result filename
  status = vapply(  # Extracts the match status for each result file
    comparison_results,  # Supplies the seven stored comparison results
    function(result) result$status,  # Returns the status recorded for one result file
    character(1)  # Requires one text status for each result file
  ),  # Finishes extracting the file statuses
  max_abs_diff = vapply(  # Extracts the largest numerical difference for each result file
    comparison_results,  # Supplies the seven stored comparison results
    function(result) result$max_difference,  # Returns the largest difference recorded for one result file
    numeric(1)  # Requires one numerical value for each result file
  )  # Finishes extracting the largest differences
)  # Finishes the seven-file comparison summary

# Print the comparison summary without R row numbers

print(summary_table, row.names = FALSE, digits = 3)  # Shows the status and largest numerical difference for each result file

differences <- Filter(  # Keeps result files that did not match
  function(result) result$status == "DIFFERS",  # Defines the calculation applied to each item
  comparison_results  # Supplies the comparison results
)  # Finishes the differences
if (length(differences)) {  # Checks whether any result file differed
  cat("\n--- Differences ---\n")  # Prints an analysis heading or result
  for (file in names(differences)) {  # Repeats for each result file
    cat(file, "\n")  # Prints an analysis heading or result
    cat(paste0("  - ", differences[[file]]$issues, collapse = "\n"), "\n")  # Prints an analysis heading or result
  }  # Finishes this result file
  stop(sprintf(  # Stops because an analysis check failed
    "%d result files differ from %s beyond tolerance",  # Adds text to the error message
    length(differences),  # Counts the differences
    REFERENCE  # Supplies the Git version used for comparison
  ))  # Finishes error message
}  # Ends this check

cat(sprintf(  # Prints an analysis heading or result
  "\nPASS: all %d result files reproduce %s to within %.1e\n",  # Adds text to the printed report
  length(current_files),  # Counts the current files
  REFERENCE,  # Supplies the Git version used for comparison
  ALLOWED_NUMERICAL_DIFFERENCE  # Supplies the allowed numerical difference
))  # Finishes printed report
