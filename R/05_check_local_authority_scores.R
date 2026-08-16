# Check the calculated local-authority averages against MHCLG Files 10 and 11
#
# File 10 contains lower-tier local-authority averages and File 11 contains
# upper-tier local-authority averages

# Load the shared source addresses, index definitions and calculation functions

source("R/01_imd2025_calculations.R")  # Loads the shared settings and functions used for the local-authority checks

# Identify the File 7 columns containing each LSOA's 2024 local authority

LAD_CODE <- "Local Authority District code (2024)"  # Records the published lower-tier authority code column
LAD_NAME <- "Local Authority District name (2024)"  # Records the published lower-tier authority name column

# Load the LSOA deprivation scores and population measures from File 7

msg("loading IoD2025 File 7")  # Reports that the main LSOA deprivation dataset is being loaded
lsoa_scores <- read_lsoa_scores()  # Downloads if needed, then reads and checks the File 7 LSOA data

# Assign each File 7 lower-tier authority to its 2024 upper-tier authority

lad_to_utla <- read_lad_to_utla_lookup()  # Reads the checked lower-to-upper-tier authority lookup
utla_row <- match(  # Finds the upper-tier lookup row for each LSOA
  lsoa_scores[[LAD_CODE]],  # Supplies each LSOA's lower-tier authority code from File 7
  lad_to_utla$LAD24CD  # Supplies the lower-tier authority codes in the ONS lookup
)  # Finishes matching the File 7 authorities to the ONS lookup
utla_code <- lad_to_utla$UTLA24CD[utla_row]  # Assigns the corresponding upper-tier authority code to each LSOA
utla_name <- lad_to_utla$UTLA24NM[utla_row]  # Assigns the corresponding upper-tier authority name to each LSOA

# Define the lower- and upper-tier comparisons that use the same calculation

area_types <- list(  # Records the settings for the two local-authority comparisons
  list(  # Records the lower-tier File 10 comparison
    tier = "lower_tier_lad",  # Sets the name used for lower-tier results
    label = "Lower-tier LAD (File 10)",  # Sets the descriptive label for the File 10 comparison
    area_codes = lsoa_scores[[LAD_CODE]],  # Supplies the lower-tier authority code for each LSOA
    area_names = lsoa_scores[[LAD_NAME]],  # Supplies the lower-tier authority name for each LSOA
    read_published_scores = read_published_lad_scores  # Selects the function that reads File 10
  ),  # Finishes the lower-tier comparison settings
  list(  # Records the upper-tier File 11 comparison
    tier = "upper_tier_utla",  # Sets the name used for upper-tier results
    label = "Upper-tier UTLA (File 11)",  # Sets the descriptive label for the File 11 comparison
    area_codes = utla_code,  # Supplies the upper-tier authority code for each LSOA
    area_names = utla_name,  # Supplies the upper-tier authority name for each LSOA
    read_published_scores = read_published_utla_scores  # Selects the function that reads File 11
  )  # Finishes the upper-tier comparison settings
)  # Finishes defining the two local-authority comparisons

# Recalculate and check the lower- and upper-tier authority averages

comparisons_by_tier <- list()  # Starts a list to hold the two completed comparison tables

for (area_type in area_types) {  # Repeats the calculation for lower- and upper-tier authorities
  msg("checking", area_type$label)  # Reports which MHCLG local-authority file is being checked
  published_scores <- area_type$read_published_scores()  # Reads the published averages for this authority tier

  # Calculate all deprivation indices for this authority tier

  calculated_scores <- calculate_area_scores(  # Calculates population-weighted averages for every authority
    lsoa_scores,  # Supplies the LSOA deprivation scores and population measures
    area_type$area_codes,  # Supplies the authority code assigned to each LSOA
    area_type$area_names  # Supplies the authority name assigned to each LSOA
  )  # Finishes calculating the authority averages

  # Keep the ten indices with a published MHCLG comparison

  calculated_scores <- calculated_scores[  # Selects calculated values needed for the MHCLG comparison
    calculated_scores$mhclg_comparison_available,  # Keeps indices with a published higher-area average
    c(  # Selects the calculated columns needed in the detailed results
      "area_code", "area_name", "index", "index_label",  # Keeps the authority and deprivation-index details
      "avg_score", "weight_pop", "n_lsoa"  # Keeps the calculated average and its supporting information
    )  # Finishes listing the required calculated columns
  ]  # Finishes selecting the calculated values

  # Match each calculated authority-index value to its published value

  comparison <- merge(  # Joins the calculated and published local-authority averages
    calculated_scores,  # Supplies the recalculated authority averages
    published_scores,  # Supplies the published File 10 or File 11 averages
    by = c("area_code", "index"),  # Matches rows using the authority code and deprivation index
    all = TRUE  # Retains values found in only the calculated or published table
  )  # Finishes matching the calculated and published values

  # Check that every calculated and published authority has a match

  calculated_only_codes <- unique(  # Identifies authorities found only in the calculated results
    comparison$area_code[is.na(comparison$published_avg_score)]  # Selects authority codes without a published value
  )  # Finishes identifying calculated-only authorities
  published_only_codes <- unique(  # Identifies authorities found only in the published results
    comparison$area_code[is.na(comparison$avg_score)]  # Selects authority codes without a calculated value
  )  # Finishes identifying published-only authorities

  if (length(calculated_only_codes) > 0 || length(published_only_codes) > 0) {  # Checks that both tables contain the same authorities
    stop(sprintf(  # Reports incomplete authority coverage
      paste0(  # Joins the two parts of the coverage message
        "area coverage differs for %s: %d calculated authorities only, ",  # Reports calculated authorities without a published match
        "%d published authorities only"  # Reports published authorities without a calculated match
      ),  # Finishes constructing the coverage-message format
      area_type$tier,  # Identifies the affected authority tier
      length(calculated_only_codes),  # Supplies the number of calculated-only authorities
      length(published_only_codes)  # Supplies the number of published-only authorities
    ))  # Finishes constructing the incomplete-coverage message
  }  # Finishes checking authority coverage

  # Add the authority tier and calculate the agreement measures

  comparison$tier <- area_type$tier  # Records whether the comparison is lower or upper tier
  comparison <- add_validation_results(comparison)  # Calculates the differences and published-precision checks

  # Calculate the figures shown in the progress message

  n_areas <- length(unique(comparison$area_code))  # Counts the matched authorities
  n_indices <- length(unique(comparison$index))  # Counts the published deprivation indices
  n_comparisons <- nrow(comparison)  # Counts all matched authority-index comparisons
  maximum_difference <- max(comparison$abs_diff)  # Finds the largest absolute difference from MHCLG
  n_same_when_rounded <- sum(comparison$rounds_to_published)  # Counts values displaying identically at three decimal places

  # Report the comparison result for this authority tier

  msg(sprintf(  # Reports the size and agreement of this authority-tier comparison
    paste0(  # Joins the two parts of the progress message
      "%d areas x %d indices = %d comparisons; maximum difference %.3g; ",  # Reports the number of areas, indices and comparisons
      "%d/%d equal at 3 decimal places"  # Reports agreement at MHCLG's published precision
    ),  # Finishes constructing the progress-message format
    n_areas,  # Supplies the number of matched authorities
    n_indices,  # Supplies the number of published deprivation indices
    n_comparisons,  # Supplies the total number of comparisons
    maximum_difference,  # Supplies the largest absolute difference
    n_same_when_rounded,  # Supplies the number agreeing after rounding
    n_comparisons  # Supplies the total used as the rounded-agreement denominator
  ))  # Finishes reporting the authority-tier comparison

  # Store this authority-tier comparison for the combined results

  comparisons_by_tier[[area_type$tier]] <- comparison  # Stores the completed lower- or upper-tier comparison
}  # Finishes checking both local-authority tiers


# Combine the lower- and upper-tier comparisons and arrange the detailed evidence

detail <- do.call(rbind, comparisons_by_tier)  # Combines the lower- and upper-tier comparison tables
detail <- detail[  # Orders the comparisons and selects the columns to save
  order(detail$tier, -detail$abs_diff),  # Orders by authority tier and then largest absolute difference
  c(  # Selects the columns required in the detailed comparison file
    "tier", "area_code", "area_name", "area_name_published", "index",  # Keeps the authority tier, identity and deprivation index
    "index_label", "avg_score", "published_avg_score", "diff", "abs_diff",  # Keeps the index label, scores and their difference
    "rounds_to_published", "within_half_rounding_unit",  # Keeps the rounded agreement and half-unit check
    "within_one_rounding_unit",  # Keeps the one-unit check used to decide whether the comparison passes
    "weight_pop", "n_lsoa"  # Keeps the weighting population and number of LSOAs
  )  # Finishes listing the detailed comparison columns
]  # Finishes arranging the detailed comparison table

# Summarise the comparison separately for each local-authority tier

summary_by_tier <- lapply(area_types, function(area_type) {  # Repeats the summary for lower- and upper-tier authorities
  tier_detail <- detail[detail$tier == area_type$tier, ]  # Selects the comparisons for this authority tier
  n_comparisons <- nrow(tier_detail)  # Counts the authority-index comparisons for this tier
  maximum_difference <- if (n_comparisons > 0) max(tier_detail$abs_diff) else NA_real_  # Finds the largest absolute difference
  percentage_same <- if (n_comparisons > 0) round(100 * mean(tier_detail$rounds_to_published), 2) else NA_real_  # Calculates rounded agreement as a percentage

  data.frame(  # Creates one summary row for this authority tier
    tier = area_type$tier,  # Records whether the results are lower or upper tier
    source_file = area_type$label,  # Records whether File 10 or File 11 supplied the published values
    n_areas = length(unique(tier_detail$area_code)),  # Records the number of matched authorities
    n_comparisons = n_comparisons,  # Records the number of authority-index comparisons
    max_abs_diff = maximum_difference,  # Records the largest absolute difference from MHCLG
    n_same_when_rounded = sum(tier_detail$rounds_to_published),  # Records how many values display identically at three decimal places
    pct_same_when_rounded = percentage_same,  # Records the percentage displaying identically at three decimal places
    n_beyond_half_rounding_unit = sum(!tier_detail$within_half_rounding_unit),  # Records differences greater than half a published unit
    n_beyond_one_rounding_unit = sum(!tier_detail$within_one_rounding_unit),  # Records differences greater than one published unit
    pass = n_comparisons > 0 && all(tier_detail$within_one_rounding_unit)  # Passes only when comparisons exist and all meet the one-unit limit
  )  # Finishes the summary row for this authority tier
})  # Finishes summarising both authority tiers

# Combine the lower- and upper-tier summaries

summary_table <- do.call(rbind, summary_by_tier)  # Combines the two authority-tier summary rows

# Stop before saving if any comparison exceeds one published rounding unit

failed <- sum(!detail$within_one_rounding_unit)  # Counts comparisons greater than one published rounding unit
if (failed > 0) {  # Checks whether any local-authority comparison exceeds the permitted difference
  stop(sprintf(  # Reports how many comparisons failed
    "%d local-authority comparisons differ from MHCLG by more than one published rounding unit (%.4f)",  # Sets the failure message
    failed,  # Supplies the number of failed comparisons
    ONE_ROUNDING_UNIT  # Supplies the largest permitted difference
  ))  # Finishes constructing the failure message
}  # Finishes checking the local-authority differences

# Calculate the figures reported in the final pass message

n_comparisons <- nrow(detail)  # Counts all lower- and upper-tier authority-index comparisons
n_same_when_rounded <- sum(detail$rounds_to_published)  # Counts values displaying identically at three decimal places
percentage_same_when_rounded <- 100 * n_same_when_rounded / n_comparisons  # Calculates the percentage displaying identically
maximum_difference <- max(detail$abs_diff)  # Finds the largest absolute difference from Files 10 and 11

# Save every calculated-versus-published local-authority comparison

utils::write.csv(  # Saves the detailed local-authority comparison file
  detail,  # Supplies every lower- and upper-tier comparison
  file.path(RESULTS_DIR, "validation_vs_file1011_la_detail.csv"),  # Sets the detailed comparison filename
  row.names = FALSE,  # Prevents R row numbers being written as a column
  na = ""  # Writes any unavailable values as blank cells
)  # Finishes saving the detailed comparison file

# Save one comparison summary row for each local-authority tier

utils::write.csv(  # Saves the local-authority comparison summary
  summary_table,  # Supplies the lower- and upper-tier summary rows
  file.path(RESULTS_DIR, "validation_vs_file1011_la.csv"),  # Sets the summary filename
  row.names = FALSE,  # Prevents R row numbers being written as a column
  na = ""  # Writes any unavailable summary values as blank cells
)  # Finishes saving the comparison summary

# Display the lower- and upper-tier comparison summary

cat("\n--- Local authority comparison summary ---\n")  # Prints a heading above the comparison summary
print(summary_table, row.names = FALSE)  # Prints both authority-tier summary rows without R row numbers

# Report the overall result of the Files 10 and 11 comparisons

cat(sprintf(  # Prints the final local-authority comparison result
  paste0(  # Joins the three lines of the result message
    "\nPASS: all %d comparisons are within one published rounding unit (%.4f) of Files 10 and 11.\n",  # Reports the number passing and the permitted difference
    "  %d of %d (%.2f%%) give the same value at 3 decimal places.\n",  # Reports agreement at the published precision
    "  Largest absolute difference: %.3g\n"  # Reports the largest observed difference
  ),  # Finishes constructing the result-message format
  n_comparisons,  # Supplies the total number of local-authority comparisons
  ONE_ROUNDING_UNIT,  # Supplies the permitted difference
  n_same_when_rounded,  # Supplies the number agreeing after rounding
  n_comparisons,  # Supplies the total used as the rounded-agreement denominator
  percentage_same_when_rounded,  # Supplies the percentage agreeing after rounding
  maximum_difference  # Supplies the largest absolute difference
))  # Finishes printing the final result