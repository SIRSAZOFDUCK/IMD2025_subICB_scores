# Calculate population-weighted IoD 2025 scores for Sub-ICB Locations
#
# File 7 provides deprivation scores and population measures for 2021 LSOAs
# ONS lookups assign each LSOA to one Sub-ICB Location for each 2023–2026 boundary year
# Each deprivation index uses the population measure specified in the Technical Report

source("R/01_imd2025_calculations.R")  # Loads the shared source addresses, index definitions and calculation functions

msg("loading IoD2025 File 7")  # Reports that the main LSOA deprivation dataset is being loaded
lsoa_scores <- read_lsoa_scores()  # Downloads if needed, then reads and checks the File 7 LSOA data
scores_by_year <- list()  # Creates a list to hold one Sub-ICB result table for each boundary year

# Calculate all deprivation scores for each Sub-ICB boundary year

for (lookup_details in SUBICB_LOOKUPS) {  # Repeats the calculation for each Sub-ICB boundary year
  lookup <- read_subicb_lookup(lookup_details, lsoa_scores)  # Reads and checks this year’s LSOA-to-Sub-ICB lookup

  year_scores <- calculate_area_scores(  # Calculates all 16 deprivation scores for each Sub-ICB
    lsoa_scores,  # Supplies the File 7 LSOA scores and population measures
    lookup$sicbl_code,  # Supplies the Sub-ICB assigned to each LSOA
    lookup$sicbl_name  # Supplies the corresponding Sub-ICB name
  )  # Finishes calculating this boundary year’s Sub-ICB scores

  names(year_scores)[names(year_scores) == "area_code"] <- "sicbl_code"  # Renames the general area-code column
  names(year_scores)[names(year_scores) == "area_name"] <- "sicbl_name"  # Renames the general area-name column

  area_lookup_row <- match(year_scores$sicbl_code, lookup$sicbl_code)  # Finds a lookup row for each Sub-ICB result
  year_scores$sicbl_nhs_code <- lookup$sicbl_nhs_code[area_lookup_row]  # Adds the NHS three-character Sub-ICB code
  year_scores$icb_code <- lookup$icb_code[area_lookup_row]  # Adds the parent ICB code
  year_scores$icb_name <- lookup$icb_name[area_lookup_row]  # Adds the parent ICB name
  year_scores$sicbl_vintage <- lookup_details$year  # Records the Sub-ICB boundary year

  scores_by_year[[as.character(lookup_details$year)]] <- year_scores  # Stores this boundary year’s result table

  msg(sprintf(  # Reports the size of this boundary year’s result
    "%d: %d Sub-ICBs x %d indices",  # Sets the progress-message format
    lookup_details$year,  # Reports the Sub-ICB boundary year
    length(unique(year_scores$sicbl_code)),  # Reports the number of Sub-ICBs calculated
    nrow(index_definitions)  # Reports the number of deprivation indices calculated
  ))  # Finishes reporting this boundary year’s result
}  # Finishes the calculations for all boundary years

# Combine the Sub-ICB score tables from the four boundary years

subicb_scores <- do.call(rbind, scores_by_year)  # Combines the 2023–2026 Sub-ICB result tables

# Keep and order the columns included in the long-format Sub-ICB output

subicb_scores <- subicb_scores[, c(  # Selects the columns for the long-format Sub-ICB file
  "sicbl_vintage", "sicbl_code", "sicbl_nhs_code", "sicbl_name",  # Keeps the Sub-ICB boundary year, codes and name
  "icb_code", "icb_name", "index", "index_label", "scale",  # Keeps the parent ICB and deprivation-index descriptions
  "avg_score", "weight_pop", "n_lsoa", "mhclg_comparison_available"  # Keeps the score, weighting population, LSOA count and comparison flag
)]  # Finishes ordering the long-format output columns

# Round the Sub-ICB average scores to a consistent reporting precision
#
# Six decimal places retain the useful precision of the published LSOA scores
# and avoid immaterial differences between R installations

subicb_scores$avg_score <- round(subicb_scores$avg_score, 6)  # Rounds each population-weighted average score to six decimal places

# Save the main long-format Sub-ICB score file

utils::write.csv(  # Writes one row per Sub-ICB, index and boundary year
  subicb_scores,  # Supplies the completed long-format Sub-ICB results
  file.path(RESULTS_DIR, "imd2025_subicb_scores_long.csv"),  # Saves the results in the project data folder
  row.names = FALSE  # Prevents R row numbers from being written to the CSV
)  # Finishes saving the long-format Sub-ICB results

# Create one row of supporting information for each deprivation index

index_metadata <- data.frame(  # Creates the index-information table
  index = index_definitions$index,  # Records the short index code
  label = index_definitions$label,  # Records the full index name
  scale = index_definitions$scale,  # Records the type of score scale
  weight_denominator = index_definitions$weight,  # Records the population measure used to weight the LSOA scores
  lsoa_min = vapply(  # Calculates the smallest published LSOA score for each index
    index_definitions$score,  # Supplies the File 7 score column for each index
    function(score_column) min(lsoa_scores[[score_column]]),  # Finds the smallest value in that score column
    numeric(1)  # Requires one numerical minimum for each index
  ),  # Finishes calculating the LSOA minimum scores
  lsoa_max = vapply(  # Calculates the largest published LSOA score for each index
    index_definitions$score,  # Supplies the File 7 score column for each index
    function(score_column) max(lsoa_scores[[score_column]]),  # Finds the largest value in that score column
    numeric(1)  # Requires one numerical maximum for each index
  ),  # Finishes calculating the LSOA maximum scores
  mhclg_comparison_available = !is.na(index_definitions$published_sheet)  # Records whether MHCLG publishes a comparable area score
)  # Finishes creating the index-information table

# Save the deprivation-index information

utils::write.csv(  # Writes the index-information table
  index_metadata,  # Supplies the scale, weighting population and LSOA range for each index
  file.path(RESULTS_DIR, "index_metadata.csv"),  # Saves the index information in the project data folder
  row.names = FALSE  # Prevents R row numbers from being written to the CSV
)  # Finishes saving the index-information table

# Report completion of the Sub-ICB score outputs

msg("done -", nrow(subicb_scores), "long-format rows and index information written to", RESULTS_DIR)  # Reports the number and location of the saved results
