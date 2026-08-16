# Save all five IoD 2025 mid-2022 population measures at Sub-ICB level
#
# File 6 contains all five population measures, while File 7 omits ages 16–59
# File 7 is used to align the LSOAs and check the four measures shared by both files

# Load the shared source addresses, population definitions and reading functions

source("R/01_imd2025_calculations.R")  # Loads the shared settings and functions used by this population script

# Load File 7 as the reference LSOA dataset

msg("loading IoD2025 File 7")  # Reports that the File 7 LSOA dataset is being loaded
lsoa_scores <- read_lsoa_scores()  # Downloads if needed, then reads and checks the File 7 LSOA data

# Load all five LSOA population measures from File 6

msg("loading File 6 population measures")  # Reports that the complete population dataset is being loaded
lsoa_population <- read_population_denominators(lsoa_scores)  # Reads File 6 and checks its LSOAs and shared measures against File 7

# Report the number of LSOAs and population measures loaded

msg(sprintf(  # Reports the dimensions and coverage of the File 6 population data
  "File 6: %d LSOAs x %d population measures (File 7 contains %d)",  # Sets the population-data summary message
  nrow(lsoa_population),  # Reports the number of LSOAs in File 6
  length(POPULATION_COLUMNS),  # Reports the five population measures in File 6
  sum(POPULATION_COLUMNS %in% names(lsoa_scores))  # Reports the four population measures also present in File 7
))  # Finishes reporting the population-data summary


# Check that the three published age groups exactly reproduce total population

age_band_population <-  # Starts the sum of the three non-overlapping age groups
  lsoa_population$children_0_15 +  # Adds children aged 0–15
  lsoa_population$aged_16_59 +  # Adds people aged 16–59
  lsoa_population$older_60_plus  # Adds people aged 60 or over

age_partition_difference <- max(  # Finds the largest LSOA population difference
  abs(lsoa_population$total - age_band_population)  # Compares total population with the three-age-group sum
)  # Finishes calculating the largest age-partition difference

msg(sprintf(  # Reports the result of the age-partition check
  "children + ages 16-59 + ages 60+ vs total: maximum difference %.3g",  # Sets the age-partition result message
  age_partition_difference  # Reports the largest difference across all LSOAs
))  # Finishes reporting the age-partition result

if (age_partition_difference > 0) {  # Checks whether any LSOA age groups fail to reproduce its total population
  stop("the three age groups do not sum to the total population")  # Stops because the published population groups are inconsistent
}  # Finishes the age-partition check

# Sum each LSOA population measure within every Sub-ICB

sum_population_by_subicb <- function(  # Defines the Sub-ICB population calculation
  area_codes,  # Accepts the Sub-ICB code assigned to each LSOA
  area_names,  # Accepts the corresponding Sub-ICB name for each LSOA
  boundary_year) {  # Accepts the Sub-ICB boundary year

  population_by_measure <- lapply(  # Repeats the Sub-ICB summation for all five population measures
    names(POPULATION_COLUMNS),  # Supplies the short names of the five population measures
    function(measure) {  # Calculates Sub-ICB totals for one population measure
      area_population <- tapply(  # Sums this LSOA population measure within each Sub-ICB
        lsoa_population[[measure]],  # Supplies the selected LSOA population measure
        area_codes,  # Groups LSOAs by their Sub-ICB code
        sum  # Adds the LSOA populations within each Sub-ICB
      )  # Finishes calculating this measure’s Sub-ICB totals

      data.frame(  # Creates one result row per Sub-ICB for this population measure
        sicbl_vintage = boundary_year,  # Records the Sub-ICB boundary year
        sicbl_code = names(area_population),  # Records the Sub-ICB code
        sicbl_name = area_names[match(names(area_population), area_codes)],  # Records the corresponding Sub-ICB name
        denominator = measure,  # Records which population measure was summed
        population = as.numeric(area_population)  # Records the Sub-ICB population total
      )  # Finishes this measure’s Sub-ICB population table
    }  # Finishes calculating one population measure
  )  # Finishes calculating all five population measures

  do.call(rbind, population_by_measure)  # Combines the five population-measure tables
}  # Finishes the Sub-ICB population function

# Calculate all five population totals for each Sub-ICB boundary year

subicb_population_by_year <- list()  # Creates a list to hold one Sub-ICB population table for each boundary year

for (lookup_details in SUBICB_LOOKUPS) {  # Repeats the population calculation for each boundary year
  lookup <- read_subicb_lookup(lookup_details, lsoa_scores)  # Reads and checks this year’s LSOA-to-Sub-ICB assignments

  subicb_population_by_year[[as.character(lookup_details$year)]] <-  # Stores the result under its boundary year
    sum_population_by_subicb(  # Sums all five LSOA population measures within each Sub-ICB
      lookup$sicbl_code,  # Supplies the Sub-ICB assigned to each LSOA
      lookup$sicbl_name,  # Supplies the corresponding Sub-ICB name
      lookup_details$year  # Records the Sub-ICB boundary year
    )  # Finishes calculating this boundary year’s Sub-ICB populations
}  # Finishes calculating all four boundary-year population tables

# Combine and order the four Sub-ICB population tables

subicb_population <- do.call(  # Combines the four boundary-year tables
  rbind,  # Places the four result tables underneath one another
  subicb_population_by_year  # Supplies the population table for each boundary year
)  # Finishes creating the combined Sub-ICB population table

subicb_population <- subicb_population[  # Orders the combined Sub-ICB population results
  order(  # Creates the required row order
    subicb_population$sicbl_vintage,  # Orders first by Sub-ICB boundary year
    subicb_population$sicbl_code,  # Orders next by Sub-ICB code
    subicb_population$denominator  # Orders finally by population measure
  ),  # Finishes creating the required row order
]  # Finishes ordering the Sub-ICB population table

# Check that every Sub-ICB boundary year retains the complete England population

england_total <- sum(lsoa_population$total)  # Calculates England’s total population from all File 6 LSOAs

total_rows <- subicb_population[  # Selects the total-population rows from the Sub-ICB results
  subicb_population$denominator == "total",  # Keeps only the total-population measure
]  # Finishes selecting the total-population rows

total_by_year <- tapply(  # Calculates the England population represented by each boundary year
  total_rows$population,  # Supplies the total population of each Sub-ICB
  total_rows$sicbl_vintage,  # Groups Sub-ICBs by their boundary year
  sum  # Adds the Sub-ICB populations within each boundary year
)  # Finishes calculating the population represented by each boundary year

if (any(total_by_year != england_total)) {  # Checks whether any boundary year loses or duplicates population
  stop(  # Stops because the Sub-ICB assignments do not cover England exactly once
    "a Sub-ICB boundary year does not sum to the England total of ",  # Introduces the expected England total
    format(england_total, big.mark = ",")  # Displays the expected total with thousands separators
  )  # Finishes the population-coverage error message
}  # Finishes checking all four boundary years

# Save all five population measures by Sub-ICB and boundary year

utils::write.csv(  # Writes the derived Sub-ICB population table
  subicb_population,  # Supplies all five population measures for every Sub-ICB boundary year
  file.path(RESULTS_DIR, "population_denominators_subicb.csv"),  # Saves the results in the project data folder
  row.names = FALSE  # Prevents R row numbers from being written to the CSV
)  # Finishes saving the Sub-ICB population results

# Report the successful England-total check and saved Sub-ICB output

msg(sprintf(  # Reports completion of the Sub-ICB population calculation
  "all boundary years sum to the England total of %s; %d rows written to %s",  # Sets the completion-message format
  format(england_total, big.mark = ","),  # Reports England’s total population
  nrow(subicb_population),  # Reports the number of saved Sub-ICB population rows
  RESULTS_DIR  # Reports the folder containing the saved results
))  # Finishes reporting completion
