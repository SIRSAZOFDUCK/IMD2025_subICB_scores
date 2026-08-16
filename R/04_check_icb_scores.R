# Check the Sub-ICB calculation method against MHCLG's published ICB averages
#
# MHCLG does not publish Sub-ICB averages, so the same population-weighted
# calculation is repeated for ICBs and compared with the values in File 13

# Load the shared source addresses, index definitions and calculation functions

source("R/01_imd2025_calculations.R")  # Loads the shared settings and functions used for the ICB comparison

# Load the LSOA scores and population measures used to recalculate the ICB averages

msg("loading IoD2025 File 7")  # Reports that the main LSOA deprivation dataset is being loaded
lsoa_scores <- read_lsoa_scores()  # Downloads if needed, then reads and checks the File 7 LSOA data

# Load MHCLG's published ICB average scores from File 13

msg("loading MHCLG ICB summaries from File 13")  # Reports that the published ICB comparison data are being loaded
published_scores <- read_published_icb_scores()  # Downloads if needed, then reads the 10 published ICB average-score worksheets

# Report the amount of published ICB data available for comparison

msg(sprintf(  # Reports the size of the File 13 comparison dataset
  "File 13: %d ICBs x %d indices = %d published values",  # Sets the File 13 summary message
  length(unique(published_scores$icb_code)),  # Reports the number of published ICBs
  length(unique(published_scores$index)),  # Reports the number of published deprivation indices
  nrow(published_scores)  # Reports the total number of published ICB-index values
))  # Finishes reporting the File 13 dataset size

# Recalculate ICB averages for each boundary year and compare them with File 13

comparisons_by_year <- list()  # Starts a list to hold the four boundary-year comparison tables

# Repeat the ICB calculation using each available boundary-year lookup

for (lookup_details in SUBICB_LOOKUPS) {  # Repeats the comparison for each boundary year
  lookup <- read_subicb_lookup(lookup_details, lsoa_scores)  # Reads and checks the LSOA-to-ICB assignments for this year

  # Calculate population-weighted ICB averages from the LSOA data

  calculated_scores <- calculate_area_scores(  # Calculates every deprivation index for each ICB
    lsoa_scores,  # Supplies the LSOA deprivation scores and population measures
    lookup$icb_code,  # Supplies the ICB code assigned to each LSOA
    lookup$icb_name  # Supplies the ICB name assigned to each LSOA
  )  # Finishes calculating the ICB averages

  # Give the general area columns ICB-specific names

  names(calculated_scores)[names(calculated_scores) == "area_code"] <- "icb_code"  # Renames the calculated area-code column
  names(calculated_scores)[names(calculated_scores) == "area_name"] <- "icb_name"  # Renames the calculated area-name column

  # Keep the ten indices for which MHCLG publishes a comparable ICB average

  calculated_scores <- calculated_scores[  # Selects the calculated values needed for the File 13 comparison
    calculated_scores$mhclg_comparison_available,  # Keeps indices with a published MHCLG ICB average
    c(  # Selects the calculated columns needed in the comparison table
      "icb_code", "icb_name", "index", "index_label",  # Keeps the ICB and deprivation-index details
      "avg_score", "weight_pop", "n_lsoa"  # Keeps the calculated average and its supporting information
    )  # Finishes listing the required columns
  ]  # Finishes selecting the calculated values

  # Match each calculated ICB-index value to its published File 13 value

  comparison <- merge(  # Joins the calculated and published ICB averages
    calculated_scores,  # Supplies the recalculated ICB averages
    published_scores,  # Supplies the published File 13 ICB averages
    by = c("icb_code", "index"),  # Matches rows using the ICB code and deprivation index
    all.x = TRUE  # Retains calculated ICBs whose codes are not present in File 13
  )  # Finishes matching the calculated and published values

  # Add the boundary year and calculate the agreement measures

  comparison$icb_vintage <- lookup_details$year  # Records the ICB boundary year used for the calculation
  comparison <- add_validation_results(comparison)  # Calculates differences and the three-decimal-place agreement checks
  comparisons_by_year[[as.character(lookup_details$year)]] <- comparison  # Stores this year's comparison table

  # Separate matched values from ICB codes that are absent from File 13

  matched <- comparison[!is.na(comparison$published_avg_score), ]  # Keeps calculated values with a published File 13 match
  unmatched_codes <- unique(  # Identifies calculated ICB codes that have no File 13 match
    comparison$icb_code[is.na(comparison$published_avg_score)]  # Selects ICB codes with no published average
  )  # Finishes identifying unmatched ICB codes

  # Calculate the figures shown in the progress message

  n_matched_icbs <- length(unique(matched$icb_code))  # Counts ICBs with at least one File 13 match
  n_calculated_icbs <- length(unique(comparison$icb_code))  # Counts all ICBs calculated for this boundary year
  n_comparisons <- nrow(matched)  # Counts the matched ICB-index comparisons
  maximum_difference <- if (n_comparisons > 0) max(matched$abs_diff) else NA_real_  # Finds the largest matched difference
  all_same_when_rounded <- n_comparisons > 0 && all(matched$rounds_to_published)  # Checks whether all matched values display identically at three decimal places

  # Report the number of matches and the largest difference for this boundary year

  msg(sprintf(  # Reports the comparison results for this boundary year
    paste0(  # Joins the two parts of the progress message
      "%d: %d/%d ICBs matched to File 13; %d comparisons; ",  # Reports the year, matched ICBs and number of comparisons
      "maximum difference %.3g; all equal at 3 decimal places: %s"  # Reports the largest difference and rounded agreement
    ),  # Finishes constructing the progress-message format
    lookup_details$year,  # Supplies the ICB boundary year
    n_matched_icbs,  # Supplies the number of matched ICBs
    n_calculated_icbs,  # Supplies the total number of calculated ICBs
    n_comparisons,  # Supplies the number of matched ICB-index comparisons
    maximum_difference,  # Supplies the largest absolute difference
    all_same_when_rounded  # Supplies the result of the three-decimal-place check
  ))  # Finishes reporting the comparison results

  # Report ICB codes that cannot be matched because File 13 uses 2024 codes

  if (length(unmatched_codes) > 0) {  # Checks whether any calculated ICB codes are absent from File 13
    msg(sprintf(  # Reports the ICB codes that could not be matched
      "%d ICB codes are absent from File 13, which uses 2024 codes: %s",  # Sets the unmatched-code message
      length(unmatched_codes),  # Supplies the number of unmatched ICB codes
      paste(unmatched_codes, collapse = ", ")  # Supplies the unmatched ICB codes as a comma-separated list
    ))  # Finishes reporting the unmatched ICB codes
  }  # Finishes the unmatched-code check

  # Check that the 2024 lookup matches every value in the official 2024 publication

  if (lookup_details$year == 2024 && nrow(matched) != nrow(published_scores)) {  # Checks that all 2024 File 13 values have a match
    stop(  # Reports an incomplete 2024 match
      "the 2024 lookup matches ", nrow(matched), " of ",  # Reports the number of File 13 values matched
      nrow(published_scores), " published File 13 values"  # Reports the total number of published values
    )  # Finishes the incomplete-match message
  }  # Finishes checking the 2024 matches
}  # Finishes comparing all four boundary years

# Combine the four boundary-year comparisons and arrange the detailed evidence table

detail <- do.call(rbind, comparisons_by_year)  # Combines the four yearly ICB comparison tables
detail <- detail[  # Orders the comparisons and selects the columns to save
  order(detail$icb_vintage, -detail$abs_diff),  # Orders by boundary year and then largest absolute difference
  c(  # Selects the columns required in the detailed comparison file
    "icb_vintage", "icb_code", "icb_name", "index", "index_label",  # Keeps the boundary year, ICB and deprivation-index details
    "avg_score", "published_avg_score", "diff", "abs_diff",  # Keeps the calculated score, published score and their difference
    "rounds_to_published", "within_half_rounding_unit",  # Keeps the rounded agreement and half-unit check
    "within_one_rounding_unit",  # Keeps the one-unit check used to decide whether the comparison passes
    "weight_pop", "n_lsoa"  # Keeps the weighting population and LSOA count
  )  # Finishes listing the detailed comparison columns
]  # Finishes arranging the detailed comparison table

# Summarise the matched File 13 comparisons for each ICB boundary year

summary_by_year <- lapply(SUBICB_LOOKUPS, function(lookup_details) {  # Repeats the summary for each boundary year
  year_detail <- detail[  # Selects the matched comparisons for this boundary year
    detail$icb_vintage == lookup_details$year &  # Keeps comparisons calculated with this year's ICB boundaries
      !is.na(detail$published_avg_score),  # Excludes ICB codes that are absent from File 13
  ]  # Finishes selecting this year's matched comparisons

  n_comparisons <- nrow(year_detail)  # Counts the matched ICB-index comparisons for this year
  maximum_difference <- if (n_comparisons > 0) max(year_detail$abs_diff) else NA_real_  # Finds the largest matched difference
  percentage_same <- if (n_comparisons > 0) round(100 * mean(year_detail$rounds_to_published), 2) else NA_real_  # Calculates the percentage displaying the same three-decimal value

  data.frame(  # Creates one summary row for this boundary year
    icb_vintage = lookup_details$year,  # Records the ICB boundary year
    n_icb_matched = length(unique(year_detail$icb_code)),  # Records the number of ICBs found in File 13
    n_comparisons = n_comparisons,  # Records the number of matched ICB-index values
    max_abs_diff = maximum_difference,  # Records the largest absolute difference from File 13
    n_same_when_rounded = sum(year_detail$rounds_to_published),  # Records how many values display identically at three decimal places
    pct_same_when_rounded = percentage_same,  # Records the percentage displaying identically at three decimal places
    n_beyond_half_rounding_unit = sum(!year_detail$within_half_rounding_unit),  # Records differences greater than half a published unit
    n_beyond_one_rounding_unit = sum(!year_detail$within_one_rounding_unit),  # Records differences greater than one published unit
    pass = n_comparisons > 0 && all(year_detail$within_one_rounding_unit)  # Passes only when matched values exist and all are within one published unit
  )  # Finishes the summary row for this boundary year
})  # Finishes summarising all four boundary years

# Combine the four boundary-year summaries into one table

summary_table <- do.call(rbind, summary_by_year)  # Combines the four yearly summary rows

# Keep only ICB comparisons that have a published File 13 value

matched_detail <- detail[  # Selects calculated values with a published ICB comparison
  !is.na(detail$published_avg_score),  # Excludes ICB codes that are absent from File 13
]  # Finishes selecting the matched comparisons

# Stop if no calculated ICB value could be matched to File 13

if (nrow(matched_detail) == 0) {  # Checks that at least one published comparison is available
  stop("no calculated ICB value matched a published File 13 value")  # Stops because the calculation cannot be checked
}  # Finishes checking that published comparisons are available

# Stop before saving if any value differs by more than one published rounding unit

failed <- sum(!matched_detail$within_one_rounding_unit)  # Counts differences greater than one published rounding unit
if (failed > 0) {  # Checks whether any ICB comparison exceeds the permitted difference
  stop(sprintf(  # Reports how many comparisons failed
    "%d ICB comparisons differ from File 13 by more than one published rounding unit (%.4f)",  # Sets the failure message
    failed,  # Supplies the number of failed comparisons
    ONE_ROUNDING_UNIT  # Supplies the largest permitted difference
  ))  # Finishes constructing the failure message
}  # Finishes checking the ICB differences

# Calculate the figures reported in the final pass message

n_comparisons <- nrow(matched_detail)  # Counts all matched ICB-index comparisons
n_same_when_rounded <- sum(matched_detail$rounds_to_published)  # Counts values that display identically at three decimal places
percentage_same_when_rounded <- 100 * n_same_when_rounded / n_comparisons  # Calculates the percentage displaying identically
maximum_difference <- max(matched_detail$abs_diff)  # Finds the largest absolute difference from File 13

# Save every calculated-versus-published ICB comparison

utils::write.csv(  # Saves the detailed ICB comparison file
  detail,  # Supplies every calculated ICB-index comparison
  file.path(RESULTS_DIR, "validation_vs_file13_icb_detail.csv"),  # Sets the detailed comparison filename
  row.names = FALSE,  # Prevents R row numbers being written as a column
  na = ""  # Writes unavailable File 13 values as blank cells
)  # Finishes saving the detailed comparison file

# Save one summary row for each ICB boundary year

utils::write.csv(  # Saves the yearly ICB comparison summary
  summary_table,  # Supplies the four boundary-year summary rows
  file.path(RESULTS_DIR, "validation_vs_file13_icb.csv"),  # Sets the summary filename
  row.names = FALSE,  # Prevents R row numbers being written as a column
  na = ""  # Writes any unavailable summary values as blank cells
)  # Finishes saving the yearly comparison summary

# Display the yearly ICB comparison summary after the script runs

cat("\n--- ICB comparison summary ---\n")  # Prints a heading above the comparison summary
print(summary_table, row.names = FALSE)  # Prints the four boundary-year summary rows without R row numbers

# Report the overall result of the File 13 comparison

cat(sprintf(  # Prints the final ICB comparison result
  paste0(  # Joins the three lines of the result message
    "\nPASS: all %d matched comparisons are within one published rounding unit (%.4f) of File 13.\n",  # Reports the number passing and the permitted difference
    "  %d of %d (%.2f%%) give the same value at 3 decimal places.\n",  # Reports agreement after rounding
    "  Largest absolute difference: %.3g\n"  # Reports the largest observed difference
  ),  # Finishes constructing the result-message format
  n_comparisons,  # Supplies the number of matched comparisons
  ONE_ROUNDING_UNIT,  # Supplies the permitted difference
  n_same_when_rounded,  # Supplies the number agreeing after rounding
  n_comparisons,  # Supplies the total number of matched comparisons
  percentage_same_when_rounded,  # Supplies the percentage agreeing after rounding
  maximum_difference  # Supplies the largest absolute difference
))  # Finishes printing the final result
