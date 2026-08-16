# Shared source settings and calculations for creating IoD2025 Sub-ICB scores
#
# The Sub-ICB, ICB and local authority scripts all use calculate_area_scores()
# The published-area checks therefore differ only in the geography used to
# group LSOAs

SOURCE_DATA_DIR <- "data-raw"  # Sets the downloaded source data folder
RESULTS_DIR <- "data"  # Sets the results folder
dir.create(SOURCE_DATA_DIR, showWarnings = FALSE, recursive = TRUE)  # Creates the required folder if it is absent
dir.create(RESULTS_DIR, showWarnings = FALSE, recursive = TRUE)  # Creates the required folder if it is absent

# MHCLG File 7 contains IoD2025 scores, ranks, deciles and four population measures for every 2021 LSOA
FILE_7_URL <- paste0(  # Records the address of the main LSOA source file
  "https://assets.publishing.service.gov.uk/media/691ded56d140bbbaa59a2a7d/",  # Adds the GOV.UK file location
  "File_7_IoD2025_All_Ranks_Scores_Deciles_Population_Denominators.csv"  # Adds the published filename
)  # Finishes the File 7 address

# MHCLG File 13 contains published ICB scores used to check the calculation method
FILE_13_URL <- paste0(  # Records the address of the ICB comparison file
  "https://assets.publishing.service.gov.uk/media/68ff7ed00f801e57b5bef928/",  # Adds the GOV.UK file location
  "File_13_-_IoD2025_Integrated_Care_Board__ICB__Summaries.xlsx"  # Adds the published filename
)  # Finishes the File 13 address

# MHCLG File 6 contains all five mid-2022 population measures for every 2021 LSOA
FILE_6_URL <- paste0(  # Records the address of the population source file
  "https://assets.publishing.service.gov.uk/media/691ded46513046b952c500be/",  # Adds the GOV.UK file location
  "File_6_IoD2025_Population_Denominators.xlsx"  # Adds the published filename
)  # Finishes the File 6 address

# MHCLG File 10 contains published scores for lower-tier local authorities
FILE_10_URL <- paste0(  # Records the address of the lower-tier local-authority comparison file
  "https://assets.publishing.service.gov.uk/media/6917412ebc34c86ce4e6e7fc/",  # Adds the GOV.UK file location
  "File_10_-_IoD2025_Local_Authority_District_Summaries__lower-tier__v2.xlsx"  # Adds the published filename
)  # Finishes the File 10 address

# MHCLG File 11 contains published scores for upper-tier local authorities
FILE_11_URL <- paste0(  # Records the address of the upper-tier local-authority comparison file
  "https://assets.publishing.service.gov.uk/media/6917414ab49cc44345161802/",  # Adds the GOV.UK file location
  "File_11_-_IoD2025_Local_Authority_District_Summaries__upper-tier__v2.xlsx"  # Adds the published filename
)  # Finishes the File 11 address

# ONS Open Geography supplies the lookups assigning each 2021 LSOA to a Sub-ICB and ICB
ONS_GEOGRAPHY_URL <-  # Records the main address of the ONS geography service
  "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services"  # Specifies the ONS service address

# These four ONS lookups provide the Sub-ICB boundaries used for each year
SUBICB_LOOKUPS <- list(  # Records the required Sub-ICB lookup services

  # Assigns each 2021 LSOA to its 2023 Sub-ICB and ICB
  list(year = 2023, service = "LSOA21_SICBL23_ICB23_LAD23_EN_LU"),  # Records the 2023 lookup

  # Assigns each 2021 LSOA to its 2024 Sub-ICB and ICB
  list(year = 2024, service = "LSOA21_SICBL24_ICB24_CAL24_LAD24_EN_LU"),  # Records the 2024 lookup

  # Assigns each 2021 LSOA to its 2025 Sub-ICB and ICB
  list(year = 2025, service = "LSOA21_SICBL25_ICB25_CAL25_LAD25_EN_LU"),  # Records the 2025 lookup

  # Assigns each 2021 LSOA to its 2026 Sub-ICB and ICB
  list(year = 2026, service = "LSOA21_SICBL26_ICB26_CAL26_LAD26_EN_LU")  # Records the 2026 lookup
)  # Finishes the list of Sub-ICB lookup services

# Population measures follow IoD2025 Technical Report section 3.8.8

# This File 7 column is used to weight the overall IMD and most domain scores
TOTAL_POPULATION <- "Total population: mid 2022"  # Records the total-population column name

# This File 7 column is used to weight the IDACI score
CHILD_POPULATION <- "Dependent Children aged 0-15: mid 2022"  # Records the child-population column name

# This File 7 column is used to weight the IDAOPI score
OLDER_POPULATION <- "Older population aged 60 and over: mid 2022"  # Records the older-population column name

# This File 7 column is used to weight the Employment Deprivation Domain score
WORKING_AGE_POPULATION <- "Working age population 18-66 (for use with Employment Deprivation Domain): mid 2022"  # Records the working-age column name

# Settings for the 16 deprivation indices included in the Sub-ICB results
# Each row gives the output name, File 7 score column, population weight, score scale and MHCLG comparison worksheet
# Values in every column must remain in the same index order

index_definitions <- data.frame(  # Records how each deprivation index should be processed
  index = c(  # Lists the index values
    "imd", "income", "employment", "education", "health", "crime", "barriers",  # Adds the published index codes
    "living_env", "idaci", "idaopi", "sub_children_yp", "sub_adult_skills",  # Adds an index code
    "sub_geo_barriers", "sub_wider_barriers", "sub_indoors", "sub_outdoors"  # Adds an index code
  ),  # Finishes the index
  label = c(  # Lists the label values
    "Index of Multiple Deprivation",  # Adds an index label
    "Income",  # Adds an index label
    "Employment",  # Adds an index label
    "Education, Skills and Training",  # Adds an index label
    "Health Deprivation and Disability",  # Adds an index label
    "Crime",  # Adds an index label
    "Barriers to Housing and Services",  # Adds an index label
    "Living Environment",  # Adds an index label
    "IDACI (supplementary)",  # Adds an index label
    "IDAOPI (supplementary)",  # Adds an index label
    "Children and Young People sub-domain",  # Adds an index label
    "Adult Skills sub-domain",  # Adds an index label
    "Geographical Barriers sub-domain",  # Adds an index label
    "Wider Barriers sub-domain",  # Adds an index label
    "Indoors sub-domain",  # Adds an index label
    "Outdoors sub-domain"  # Adds an index label
  ),  # Finishes the label
  score = c(  # Lists the LSOA scores for this index values
    "Index of Multiple Deprivation (IMD) Score",  # Adds an index label
    "Income Score (rate)",  # Adds a published score column name
    "Employment Score (rate)",  # Adds a published score column name
    "Education, Skills and Training Score",  # Adds a published score column name
    "Health Deprivation and Disability Score",  # Adds a published score column name
    "Crime Score",  # Adds a published score column name
    "Barriers to Housing and Services Score",  # Adds a published score column name
    "Living Environment Score",  # Adds a published score column name
    "Income Deprivation Affecting Children Index (IDACI) Score (rate)",  # Adds a published score column name
    "Income Deprivation Affecting Older People (IDAOPI) Score (rate)",  # Adds a published score column name
    "Children and Young People Sub-domain Score",  # Adds an index label
    "Adult Skills Sub-domain Score",  # Adds an index label
    "Geographical Barriers Sub-domain Score",  # Adds an index label
    "Wider Barriers Sub-domain Score",  # Adds an index label
    "Indoors Sub-domain Score",  # Adds an index label
    "Outdoors Sub-domain Score"  # Adds an index label
  ),  # Finishes the LSOA scores for this index
  weight = c(  # Lists the weight values
    TOTAL_POPULATION,  # Supplies the total-population column name
    TOTAL_POPULATION,  # Supplies the total-population column name
    WORKING_AGE_POPULATION,  # Supplies the working-age population column name
    rep(TOTAL_POPULATION, 5),  # Repeats the stated value for the required indices
    CHILD_POPULATION,  # Supplies the child-population column name
    OLDER_POPULATION,  # Supplies the older-population column name
    rep(TOTAL_POPULATION, 6)  # Repeats the stated value for the required indices
  ),  # Finishes the weight
  scale = c(  # Records how the published score for each index is expressed
    "imd_composite",  # Describes the overall IMD composite score
    "rate_0_1",  # Describes the Income score as a rate from 0 to 1
    "rate_0_1",  # Describes the Employment score as a rate from 0 to 1
    "exponential_0_100",  # Describes the transformed Education score
    "standardised",  # Describes the standardised Health score
    "standardised",  # Describes the standardised Crime score
    "exponential_0_100",  # Describes the transformed Barriers score
    "exponential_0_100",  # Describes the transformed Living Environment score
    "rate_0_1",  # Describes IDACI as a rate from 0 to 1
    "rate_0_1",  # Describes IDAOPI as a rate from 0 to 1
    rep("untransformed_subdomain", 6)  # Describes all six sub-domain scores
  ),  # Finishes the score-scale descriptions
  published_sheet = c(  # Lists the published sheet values
    "IMD", "Income", "Employment", "Education", "Health", "Crime", "Barriers",  # Adds the published index codes
    "Living", "IDACI", "IDAOPI", rep(NA_character_, 6)  # Adds an MHCLG worksheet name
  )  # Finishes the published sheet
)  # Finishes the index definitions

# Exact File 7 population column names used to weight the deprivation scores
# Employment, IDACI and IDAOPI use different population groups from the other indices
POPULATION_COLUMNS <- c(  # Sets the five population column names
  total = TOTAL_POPULATION,  # Names the total-population measure
  children_0_15 = CHILD_POPULATION,  # Names the population aged 0–15 measure
  aged_16_59 = "Population aged 16-59: mid 2022",  # Names the population aged 16–59 measure
  older_60_plus = OLDER_POPULATION,  # Names the population aged 60 and over measure
  working_age_18_66 = WORKING_AGE_POPULATION  # Names the working-age 18–66 measure
)  # Finishes the five population column names

# Define how to print short progress messages
msg <- function(...) cat(..., "\n")  # Prints a progress message followed by a new line

# Define how to standardise spaces in published column names
collapse_whitespace <- function(x) {  # Defines how to replace line breaks and repeated spaces in published column names
  trimws(gsub("[[:space:]]+", " ", x))  # Returns column names with standard spacing
}  # Ends the collapse whitespace definition

# Repeat failed downloads because the ONS service occasionally drops a request
retry_request <- function(description, request) {  # Defines how to repeat an interrupted source request
  max_attempts <- 5L  # Allows five attempts before reporting a failed request
  for (attempt in seq_len(max_attempts)) {  # Repeats for each request attempt
    result <- tryCatch(request(), error = identity)  # Runs the request and keeps any error for the retry check
    if (!inherits(result, "error")) return(result)  # Checks whether the request succeeded
    if (attempt == max_attempts) {  # Checks whether all request attempts were used
      stop(  # Stops because an analysis check failed
        description, " failed after ", max_attempts, " attempts: ",  # Reports how many attempts were made
        conditionMessage(result)  # Adds the source-request error message
      )  # Finishes error message
    }  # Ends this check
    wait_seconds <- 2^attempt  # Increases the wait before each repeated request
    msg(sprintf(  # Reports analysis progress
      "%s failed (attempt %d/%d), trying again in %d seconds: %s",  # Adds text to the progress message
      description, attempt, max_attempts, wait_seconds, conditionMessage(result)  # Adds the source-request error message
    ))  # Finishes progress message
    Sys.sleep(wait_seconds)  # Waits before repeating the source request
  }  # Finishes this request attempt
}  # Ends the retry request definition

# Use a previously downloaded source file when available, or download it when missing
# Save new downloads under a temporary name so an interrupted download is not mistaken for a complete file

download_if_missing <- function(url, destination) {  # Accepts the published address and the location for the saved source file
  if (file.exists(destination)) {  # Checks whether a saved copy of the source file is already available
    return(destination)  # Returns the saved file location without downloading it again
  }  # Finishes the check for an existing source file

  msg("downloading", basename(destination))  # Reports which published source file is being downloaded
  temporary_file <- paste0(destination, ".part")  # Gives the incomplete download a temporary filename
  on.exit(if (file.exists(temporary_file)) unlink(temporary_file), add = TRUE)  # Deletes an incomplete temporary file if the download fails

  retry_request(  # Makes up to five attempts to download the source file
    paste("download of", basename(destination)),  # Names the file in any download error message
    function() {  # Defines the download to repeat if an attempt fails
      utils::download.file(  # Downloads the published source file
        url,  # Supplies the published source address
        temporary_file,  # Saves the download under its temporary filename
        mode = "wb",  # Preserves the source file exactly, including Excel files
        quiet = TRUE  # Hides the standard download progress display
      )  # Finishes this download attempt
    }  # Finishes the download instructions
  )  # Finishes the repeated download attempts

  if (!file.rename(temporary_file, destination)) {  # Moves the completed download to its permanent filename
    stop("could not save ", destination)  # Stops if the completed file cannot be saved
  }  # Finishes the check that the completed download was saved

  destination  # Returns the location of the complete source file
}  # Finishes the source-file download function


# Read an ONS geography lookup and save it as a CSV for later use
# Use the saved CSV when available; otherwise obtain all ONS rows in groups of 1,000
# Order each request by a unique geography code so rows are not repeated or skipped

read_geography_lookup <- function(  # Defines how to obtain a complete ONS geography lookup
  service,  # Accepts the name of the required ONS geography service
  fields,  # Accepts the geography columns to obtain from ONS
  destination,  # Accepts the location for the saved lookup CSV
  order_by = "LSOA21CD") {  # Uses the 2021 LSOA code to order rows unless another code is specified

  if (file.exists(destination)) {  # Checks whether this ONS lookup has already been saved
    return(utils::read.csv(  # Reads and returns the saved lookup instead of contacting ONS
      destination,  # Supplies the location of the saved lookup CSV
      colClasses = "character",  # Reads geography codes and names as text
      check.names = FALSE  # Retains the original ONS column names
    ))  # Finishes reading the saved ONS lookup
  }  # Finishes the check for a saved lookup

  msg("fetching lookup", service)  # Reports which ONS geography lookup is being obtained
  rows_per_request <- 1000L  # Sets the number of lookup rows requested from ONS at one time
  lookup_parts <- list()  # Creates an empty list for the successive groups of ONS rows
  starting_row <- 0L  # Starts the first ONS request at the first lookup row

  repeat {  # Repeats the ONS request until every lookup row has been obtained
    url <- sprintf(  # Inserts the service, fields and row numbers into the ONS request address
      paste0(  # Joins the three sections of the ONS request address
        "%s/%s/FeatureServer/0/query?where=1%%3D1&outFields=%s&",  # Requests all records and only the required geography columns
        "returnGeometry=false&orderByFields=%s&resultOffset=%d&",  # Omits boundary shapes, orders rows and specifies the first required row
        "resultRecordCount=%d&f=json"  # Requests 1,000 rows in a format that R can read
      ),  # Finishes the ONS request address
      ONS_GEOGRAPHY_URL,  # Supplies the main ONS Open Geography address
      service,  # Supplies the required ONS lookup service
      paste(fields, collapse = ","),  # Combines the required column names for the ONS request
      order_by,  # Supplies the unique geography code used to order rows
      starting_row,  # Supplies the first row required in this request
      rows_per_request  # Supplies the number of rows required in this request
    )  # Finishes constructing the ONS request address

    ons_result <- retry_request(  # Repeats this ONS request up to five times if it fails
      paste0(service, " rows starting at ", starting_row),  # Identifies the service and rows in any error message
      function() {  # Defines how to read one group of rows from ONS
        returned_data <- jsonlite::fromJSON(  # Reads the response supplied by the ONS service
          url,  # Supplies the address for this group of lookup rows
          simplifyVector = TRUE  # Converts the returned fields into ordinary R columns where possible
        )  # Finishes reading this ONS response

        if (!is.null(returned_data$error)) {  # Checks whether ONS returned an error instead of lookup rows
          stop(  # Stops this attempt so the request can be repeated
            "Open Geography service error: ",  # Introduces the error reported by ONS
            returned_data$error$message  # Includes the ONS explanation in the error message
          )  # Finishes the ONS error message
        }  # Finishes the check for an ONS error

        returned_data  # Returns this group of lookup rows
      }  # Finishes the instructions for one ONS request
    )  # Finishes obtaining this group of lookup rows

    lookup_rows <- ons_result$features$attributes  # Extracts the geography columns from the ONS response

    if (is.null(lookup_rows) || nrow(lookup_rows) == 0L) {  # Checks whether ONS returned no further rows
      break  # Ends the requests because the complete lookup has been obtained
    }  # Finishes the check for further lookup rows

    lookup_parts[[length(lookup_parts) + 1L]] <- lookup_rows  # Adds these ONS rows to the previously obtained rows
    starting_row <- starting_row + nrow(lookup_rows)  # Moves the next request past the rows just obtained

    if (nrow(lookup_rows) < rows_per_request) {  # Checks whether ONS returned fewer than the requested 1,000 rows
      break  # Ends the requests because this was the final group of rows
    }  # Finishes the check for the final group of rows
  }  # Finishes obtaining all groups of ONS lookup rows

  if (!length(lookup_parts)) {  # Checks that ONS returned at least one group of lookup rows
    stop("no records returned for ", service)  # Stops because the requested geography lookup is empty
  }  # Finishes the check for an empty lookup

  lookup <- do.call(rbind, lookup_parts)  # Combines all groups of ONS rows into one lookup table
  lookup[] <- lapply(lookup, as.character)  # Stores all geography codes and names as text
  utils::write.csv(  # Saves the complete lookup so later runs do not need to contact ONS
    lookup,  # Supplies the complete ONS geography lookup
    destination,  # Supplies the filename for the saved lookup
    row.names = FALSE,  # Omits R row numbers from the saved CSV
    na = ""  # Writes any missing lookup values as blank cells
  )  # Finishes saving the ONS lookup

  lookup  # Returns the complete ONS geography lookup to the calling script
}  # Finishes the ONS geography lookup function



# Read File 7 and check that all LSOA scores and weighting populations required by the analysis are complete
# Retain a consistently named LSOA code for matching File 7 to the geography and population datasets

read_lsoa_scores <- function() {  # Defines how to obtain and check the main LSOA deprivation dataset
  file_7 <- download_if_missing(  # Uses the saved File 7 copy or downloads it when missing
    FILE_7_URL,  # Supplies the published File 7 address
    file.path(SOURCE_DATA_DIR, "File_7_IoD2025.csv")  # Supplies the location for the saved File 7 copy
  )  # Finishes locating File 7

  lsoa_scores <- utils::read.csv(  # Reads the File 7 LSOA scores and population measures
    file_7,  # Supplies the saved File 7 location
    check.names = FALSE  # Retains the published File 7 column names
  )  # Finishes reading File 7

  names(lsoa_scores) <- collapse_whitespace(names(lsoa_scores))  # Replaces line breaks and repeated spaces in published column names with single spaces

  analysis_columns <- unique(  # Lists every score and population column required by the calculations
    c(  # Combines the score and weighting-population column names
      index_definitions$score,  # Includes the File 7 score column for each deprivation index
      index_definitions$weight  # Includes the File 7 population column used to weight each index
    )  # Finishes combining the required File 7 columns
  )  # Removes population column names that are used by more than one index

  required_columns <- c(  # Lists all File 7 columns that must be available
    "LSOA code (2021)",  # Includes the code used to identify and match each LSOA
    analysis_columns  # Includes all deprivation scores and weighting populations
  )  # Finishes the required File 7 column list

  missing_columns <- setdiff(  # Identifies required columns that are absent from File 7
    required_columns,  # Supplies the columns required by the analysis
    names(lsoa_scores)  # Supplies the columns present in File 7
  )  # Finishes identifying missing File 7 columns

  if (length(missing_columns)) {  # Checks whether File 7 is missing any required columns
    stop(  # Stops because the required scores or populations cannot be calculated
      "File 7 columns not found: ",  # Introduces the missing-column error message
      paste(missing_columns, collapse = " | ")  # Lists the missing File 7 column names
    )  # Finishes the missing-column error message
  }  # Finishes the required-column check

  lsoa_codes <- lsoa_scores[["LSOA code (2021)"]]  # Selects the published 2021 LSOA code for every File 7 row

  if (anyNA(lsoa_codes) || anyDuplicated(lsoa_codes)) {  # Checks for missing or repeated LSOA codes
    stop("File 7 contains missing or duplicated LSOA codes")  # Stops because File 7 must contain one identifiable row per LSOA
  }  # Finishes the LSOA-code check

  if (anyNA(lsoa_scores[, analysis_columns])) {  # Checks all deprivation scores and weighting populations for missing values
    stop("File 7 contains missing scores or population measures")  # Stops because every weighted average requires complete scores and populations
  }  # Finishes the score and population completeness check

  lsoa_scores$lsoa21cd <- lsoa_codes  # Adds a short, consistent LSOA-code column for matching with other datasets
  lsoa_scores  # Returns the checked File 7 LSOA dataset
}  # Finishes the File 7 reading and checking function


# Read and check the ONS lookup assigning each 2021 LSOA to a Sub-ICB and parent ICB
# Return the lookup in the same LSOA order as File 7 so scores and area codes align correctly

read_subicb_lookup <- function(lookup_details, lsoa_scores) {  # Defines how to obtain and check one year’s Sub-ICB lookup
  year_suffix <- substr(  # Extracts the two-digit year used in the ONS column names
    lookup_details$year,  # Supplies the four-digit Sub-ICB boundary year
    3,  # Starts with the third character of the four-digit year
    4  # Ends with the fourth character of the four-digit year
  )  # Finishes creating the two-digit year

  fields <- c(  # Lists the ONS lookup columns required for this boundary year
    "LSOA21CD",  # Includes the 2021 LSOA code used to match File 7
    paste0(  # Constructs the three year-specific Sub-ICB column names
      "SICBL",  # Supplies the ONS prefix for Sub-ICB Location fields
      year_suffix,  # Supplies the two-digit boundary year
      c("CD", "CDH", "NM")  # Requests the full code, NHS short code and Sub-ICB name
    ),  # Finishes the Sub-ICB column names
    paste0(  # Constructs the two year-specific ICB column names
      "ICB",  # Supplies the ONS prefix for ICB fields
      year_suffix,  # Supplies the two-digit boundary year
      c("CD", "NM")  # Requests the parent ICB code and name
    )  # Finishes the ICB column names
  )  # Finishes the required ONS lookup column list

  lookup <- read_geography_lookup(  # Uses the saved lookup or obtains the complete lookup from ONS
    lookup_details$service,  # Supplies the ONS service for the selected boundary year
    fields,  # Requests the required LSOA, Sub-ICB and ICB columns
    file.path(  # Constructs the location for the saved lookup CSV
      SOURCE_DATA_DIR,  # Places the lookup with the other downloaded source files
      sprintf(  # Inserts the boundary year into the saved lookup filename
        "lookup_lsoa21_sicbl%s.csv",  # Sets the common lookup filename
        year_suffix  # Adds the two-digit boundary year to the filename
      )  # Finishes the saved lookup filename
    )  # Finishes the saved lookup location
  )  # Finishes reading the LSOA-to-Sub-ICB lookup

  missing_fields <- setdiff(  # Identifies required fields that are absent from the ONS lookup
    fields,  # Supplies the expected LSOA, Sub-ICB and ICB fields
    names(lookup)  # Supplies the fields returned by ONS
  )  # Finishes identifying missing lookup fields

  if (length(missing_fields)) {  # Checks whether the ONS lookup is missing any required fields
    stop(  # Stops because LSOAs cannot be assigned to the required areas
      lookup_details$year,  # Identifies the affected boundary year
      " lookup fields not found: ",  # Introduces the missing-field list
      paste(missing_fields, collapse = ", ")  # Lists the missing ONS lookup fields
    )  # Finishes the missing-field error message
  }  # Finishes the required-field check

  if (anyNA(lookup[, fields]) || anyDuplicated(lookup$LSOA21CD)) {  # Checks for missing lookup values or repeated LSOA codes
    stop(  # Stops because each LSOA must have one complete area assignment
      lookup_details$year,  # Identifies the affected boundary year
      " lookup contains missing or duplicated values"  # Explains why the lookup cannot be used
    )  # Finishes the incomplete-lookup error message
  }  # Finishes the lookup completeness check

  if (!setequal(lookup$LSOA21CD, lsoa_scores$lsoa21cd)) {  # Checks that the lookup and File 7 contain exactly the same LSOA codes
    stop(  # Stops because some LSOA scores would lack an area or some lookup rows would lack scores
      "LSOA codes differ between File 7 and the ",  # Explains the mismatch between the two sources
      lookup_details$year,  # Identifies the affected boundary year
      " lookup"  # Finishes the mismatch message
    )  # Finishes the LSOA-set error message
  }  # Finishes the check that both sources contain the same LSOAs

  # Put the lookup in File 7 order and use the same column names for every boundary year

  lookup <- lookup[  # Selects the required lookup rows and columns
    match(  # Finds the lookup row corresponding to each File 7 LSOA
      lsoa_scores$lsoa21cd,  # Supplies the required File 7 LSOA order
      lookup$LSOA21CD  # Supplies the current ONS lookup order
    ),  # Finishes matching File 7 rows to lookup rows
    fields,  # Keeps the required LSOA, Sub-ICB and ICB fields
    drop = FALSE  # Keeps the selected lookup as a table
  ]  # Finishes ordering the lookup and selecting its fields

  names(lookup) <- c(  # Gives all boundary years the same internal column names
    "lsoa21cd", "sicbl_code", "sicbl_nhs_code", "sicbl_name",  # Names the LSOA and Sub-ICB fields
    "icb_code", "icb_name"  # Names the parent ICB fields
  )  # Finishes naming the checked lookup fields

  lookup  # Returns the checked lookup with consistent column names
}  # Finishes the Sub-ICB lookup function

# Calculate MHCLG’s Average score by weighting each LSOA score by the population specified for that index
# Apply the same calculation to every deprivation index and return one result for each area and index
# The weighting population is total population for most indices but differs for Employment, IDACI and IDAOPI

calculate_weighted_mean <- function(  # Defines the population-weighted average calculation for one deprivation index
  score,  # Accepts one published LSOA score for every LSOA
  weighting_population,  # Accepts the relevant weighting population for every LSOA
  area_code) {  # Accepts the area containing each LSOA

  score_population_total <- tapply(  # Calculates the numerator of the weighted average for each area
    score * weighting_population,  # Multiplies each LSOA score by its weighting population
    area_code,  # Groups the LSOAs by Sub-ICB, ICB or local authority
    sum  # Adds the population-weighted LSOA scores within each area
  )  # Finishes the area-specific weighted totals

  population_total <- tapply(  # Calculates the denominator of the weighted average for each area
    weighting_population,  # Supplies the relevant LSOA weighting population
    area_code,  # Groups the LSOAs by Sub-ICB, ICB or local authority
    sum  # Adds the weighting populations within each area
  )  # Finishes the area-specific population totals

  data.frame(  # Returns the weighted score and population for each area
    area_code = names(score_population_total),  # Records the code identifying each area
    avg_score = as.numeric(score_population_total) / as.numeric(population_total),  # Divides the weighted score total by the weighting-population total
    weight_pop = as.numeric(population_total)  # Records the population used as the denominator for this index
  )  # Finishes the area-level weighted-score table
}  # Finishes the population-weighted average function


calculate_area_scores <- function(  # Defines how to calculate all deprivation indices for a set of areas
  lsoa_scores,  # Accepts the checked File 7 LSOA scores and population measures
  area_codes,  # Accepts the Sub-ICB, ICB or local-authority code for each LSOA
  area_names) {  # Accepts the corresponding area name for each LSOA

  if (  # Checks that every File 7 LSOA has one area code and one area name
    length(area_codes) != nrow(lsoa_scores) ||  # Checks that the number of area codes equals the number of LSOAs
    length(area_names) != nrow(lsoa_scores)  # Checks that the number of area names equals the number of LSOAs
  ) {  # Starts the response to an incomplete LSOA-to-area assignment
    stop("area codes and names must have one value per LSOA")  # Stops because scores and area assignments would not align
  }  # Finishes the check of the number of area assignments

  if (anyNA(area_codes) || anyNA(area_names)) {  # Checks whether any LSOA lacks an area code or name
    stop("area codes or names are missing")  # Stops because every LSOA must be assigned to a named area
  }  # Finishes the check for missing area information

  lsoa_counts <- table(area_codes)  # Counts how many LSOAs contribute to each area

  scores_by_index <- lapply(  # Repeats the weighted-average calculation for every deprivation index
    seq_len(nrow(index_definitions)),  # Supplies one position for each index listed in the settings
    function(i) {  # Defines the calculation performed for one deprivation index
      definition <- index_definitions[i, ]  # Selects the score, population, scale and label for this index

      area_scores <- calculate_weighted_mean(  # Calculates the weighted average for this index in every area
        lsoa_scores[[definition$score]],  # Supplies the published File 7 LSOA score for this index
        lsoa_scores[[definition$weight]],  # Supplies the index-specific LSOA weighting population
        area_codes  # Supplies the area containing each LSOA
      )  # Finishes calculating this index for every area

      data.frame(  # Adds the area and index descriptions to the calculated scores
        area_code = area_scores$area_code,  # Records the Sub-ICB, ICB or local-authority code
        area_name = area_names[match(area_scores$area_code, area_codes)],  # Adds the name corresponding to each area code
        index = definition$index,  # Records the short index name used in the output
        index_label = definition$label,  # Records the full deprivation-index name
        scale = definition$scale,  # Records how the published score is expressed
        avg_score = area_scores$avg_score,  # Records the population-weighted average score
        weight_pop = area_scores$weight_pop,  # Records the index-specific population used as the denominator
        n_lsoa = as.integer(lsoa_counts[area_scores$area_code]),  # Records the number of LSOAs contributing to the area
        mhclg_comparison_available = !is.na(definition$published_sheet)  # Records whether MHCLG publishes a comparable higher-area score for this index
      )  # Finishes the results for this deprivation index
    }  # Finishes the calculation for one deprivation index
  )  # Finishes calculating all deprivation indices

  do.call(rbind, scores_by_index)  # Combines all area-by-index results into one table
}  # Finishes the calculation of all deprivation indices

# Read MHCLG’s published area scores used to check the ICB and local-authority calculations
# Files 10, 11 and 13 have one worksheet per index, with the area code and name in the first two columns
# Read only the indices for which MHCLG publishes a comparable area average

read_published_scores <- function(url, destination) {  # Defines how to read the common worksheet structure in Files 10, 11 and 13
  published_file <- download_if_missing(url, destination)  # Uses the saved MHCLG workbook or downloads it when missing

  published_indices <- which(  # Identifies indices with a published MHCLG area average
    !is.na(index_definitions$published_sheet)  # Excludes the six sub-domains because MHCLG provides no comparison worksheet
  )  # Finishes selecting indices with published area scores

  scores_by_index <- lapply(  # Reads the published average scores one index at a time
    published_indices,  # Supplies the positions of indices with MHCLG worksheets
    function(i) {  # Defines how to read one index worksheet
      definition <- index_definitions[i, ]  # Selects the worksheet name and output code for this index

      worksheet <- as.data.frame(  # Stores the selected MHCLG worksheet as an ordinary R table
        readxl::read_excel(  # Reads the worksheet for this deprivation index
          published_file,  # Supplies File 10, 11 or 13
          sheet = definition$published_sheet  # Selects the worksheet named for this index
        )  # Finishes reading the MHCLG worksheet
      )  # Finishes creating the worksheet table

      average_columns <- grep(  # Finds columns ending with MHCLG’s published Average score wording
        "Average score$",  # Excludes columns such as Rank of average score
        names(worksheet),  # Supplies the column names in this index worksheet
        value = TRUE  # Returns the matching column name rather than its position
      )  # Finishes the Average score column search

      if (length(average_columns) != 1L) {  # Checks that the worksheet contains exactly one Average score column
        stop(  # Stops because the published comparison values cannot be read
          "expected one 'Average score' column in sheet ",  # Introduces the unexpected-column message
          definition$published_sheet,  # Identifies the affected deprivation-index worksheet
          " of ",  # Connects the worksheet and workbook names
          basename(destination)  # Identifies the affected MHCLG workbook
        )  # Finishes the missing-column error message
      }  # Finishes the Average score column check

      average_column <- average_columns[[1]]  # Selects the single published Average score column

      data.frame(  # Retains the area identifiers and published score needed for comparison
        area_code = as.character(worksheet[[1]]),  # Reads the area code from the first worksheet column
        area_name_published = as.character(worksheet[[2]]),  # Reads the published area name from the second worksheet column
        index = definition$index,  # Adds the short index code used in the calculated results
        published_avg_score = as.numeric(worksheet[[average_column]])  # Reads MHCLG’s published area Average score
      )  # Finishes the published results for this index
    }  # Finishes reading one index worksheet
  )  # Finishes reading all available index worksheets

  do.call(rbind, scores_by_index)  # Combines the separate index worksheets into one area-by-index table
}  # Finishes the common MHCLG published-score reader


read_published_icb_scores <- function() {  # Defines how to read the published ICB scores from File 13
  published_scores <- read_published_scores(  # Reads the comparable index worksheets from File 13
    FILE_13_URL,  # Supplies the published File 13 address
    file.path(SOURCE_DATA_DIR, "File_13_ICB_Summaries.xlsx")  # Supplies the location for the saved File 13 workbook
  )  # Finishes reading the published ICB scores

  names(published_scores)[  # Selects the general area-code column
    names(published_scores) == "area_code"  # Identifies the column returned by the common reader
  ] <- "icb_code"  # Renames it for matching with the calculated ICB scores

  names(published_scores)[  # Selects the general published area-name column
    names(published_scores) == "area_name_published"  # Identifies the name column returned by the common reader
  ] <- "icb_name_published"  # Renames it as the published ICB name

  published_scores  # Returns the published ICB scores ready for comparison with calculated ICB scores
}  # Finishes the File 13 ICB-score reader


read_published_lad_scores <- function() {  # Defines how to read published lower-tier local-authority scores from File 10
  read_published_scores(  # Reads the comparable index worksheets from File 10
    FILE_10_URL,  # Supplies the published File 10 address
    file.path(SOURCE_DATA_DIR, "File_10_LAD_lower.xlsx")  # Supplies the location for the saved File 10 workbook
  )  # Returns the published lower-tier scores with general area-code and area-name columns
}  # Finishes the File 10 lower-tier score reader


read_published_utla_scores <- function() {  # Defines how to read published upper-tier local-authority scores from File 11
  read_published_scores(  # Reads the comparable index worksheets from File 11
    FILE_11_URL,  # Supplies the published File 11 address
    file.path(SOURCE_DATA_DIR, "File_11_LAD_upper.xlsx")  # Supplies the location for the saved File 11 workbook
  )  # Returns the published upper-tier scores with general area-code and area-name columns
}  # Finishes the File 11 upper-tier score reader


# Read all five LSOA population measures from File 6 and arrange them in the same order as File 7
# Check that the four population measures appearing in both files contain the same values

read_population_denominators <- function(lsoa_scores) {  # Defines how to read and check the File 6 LSOA populations
  file_6 <- download_if_missing(  # Uses the saved File 6 workbook or downloads it when missing
    FILE_6_URL,  # Supplies the published File 6 address
    file.path(SOURCE_DATA_DIR, "File_6_Population_Denominators.xlsx")  # Supplies the location for the saved File 6 workbook
  )  # Finishes locating File 6

  source_population <- as.data.frame(  # Stores the published File 6 worksheet as an ordinary R table
    readxl::read_excel(  # Reads the worksheet containing the five LSOA population measures
      file_6,  # Supplies the File 6 workbook
      sheet = "ID 2025 Population Denominators"  # Selects the published population worksheet
    )  # Finishes reading the File 6 worksheet
  )  # Finishes creating the File 6 population table

  names(source_population) <- collapse_whitespace(names(source_population))  # Standardises spaces and line breaks in the published column names

  required_columns <- c(  # Lists the File 6 columns required for the population outputs
    "LSOA code (2021)",  # Includes the code used to match each LSOA with File 7
    unname(POPULATION_COLUMNS)  # Includes all five published mid-2022 population measures
  )  # Finishes the required File 6 column list

  missing_columns <- setdiff(  # Identifies required population columns that are absent from File 6
    required_columns,  # Supplies the File 6 columns required by the analysis
    names(source_population)  # Supplies the columns present in the File 6 worksheet
  )  # Finishes identifying missing File 6 columns

  if (length(missing_columns)) {  # Checks whether File 6 is missing any required population columns
    stop(  # Stops because the complete population outputs cannot be produced
      "File 6 columns not found: ",  # Introduces the missing-column message
      paste(missing_columns, collapse = " | ")  # Lists the missing File 6 column names
    )  # Finishes the missing-column error message
  }  # Finishes the required-column check

  lsoa_codes <- source_population[["LSOA code (2021)"]]  # Selects the published 2021 LSOA code from File 6

  if (anyNA(lsoa_codes) || anyDuplicated(lsoa_codes)) {  # Checks for missing or repeated File 6 LSOA codes
    stop("File 6 contains missing or duplicated LSOA codes")  # Stops because File 6 must contain one identifiable row per LSOA
  }  # Finishes the File 6 LSOA-code check

  population <- data.frame(lsoa21cd = lsoa_codes)  # Starts a simpler population table with a consistently named LSOA code

  for (measure in names(POPULATION_COLUMNS)) {  # Repeats for total population and each of the four population groups
    population[[measure]] <- as.numeric(  # Adds this population measure under its shorter output name
      source_population[[POPULATION_COLUMNS[[measure]]]]  # Selects the corresponding published File 6 column
    )  # Finishes adding this population measure
  }  # Finishes copying all five population measures

  if (anyNA(population)) {  # Checks the LSOA codes and all five population measures for missing values
    stop("File 6 contains missing population values")  # Stops because complete LSOA population totals are required
  }  # Finishes the population completeness check

  if (!setequal(population$lsoa21cd, lsoa_scores$lsoa21cd)) {  # Checks that Files 6 and 7 contain exactly the same LSOA codes
    stop("LSOA codes differ between Files 6 and 7")  # Stops because the population rows cannot be aligned with the score rows
  }  # Finishes the File 6 and File 7 LSOA comparison

  file_6_order <- match(lsoa_scores$lsoa21cd, lsoa_codes)  # Finds the File 6 row corresponding to each File 7 LSOA

  source_population <- source_population[  # Places the original File 6 rows in the same LSOA order as File 7
    file_6_order,  # Uses the matching row position for every File 7 LSOA
    ,  # Retains every File 6 column
    drop = FALSE  # Keeps the selected rows as a table
  ]  # Finishes ordering the original File 6 table

  population <- population[  # Places the simplified population rows in the same LSOA order as File 7
    file_6_order,  # Uses the same File 6 row order as the original population table
    ,  # Retains the LSOA code and all five population measures
    drop = FALSE  # Keeps the selected rows as a table
  ]  # Finishes ordering the simplified population table

  shared_columns <- intersect(  # Identifies the population measures published in both Files 6 and 7
    unname(POPULATION_COLUMNS),  # Supplies all five File 6 population column names
    names(lsoa_scores)  # Supplies the columns available in File 7
  )  # Finishes identifying the population measures shared by both files

  for (source_column in shared_columns) {  # Repeats the comparison for each population measure appearing in both files
    if (!isTRUE(all.equal(  # Checks that the File 6 and File 7 LSOA populations agree
      as.numeric(source_population[[source_column]]),  # Supplies this population measure from File 6
      as.numeric(lsoa_scores[[source_column]])  # Supplies the same population measure from File 7
    ))) {  # Starts the response when the two published files disagree
      stop(  # Stops because the population output would be inconsistent with the score weights
        "Files 6 and 7 disagree on population measure: ",  # Introduces the population disagreement message
        source_column  # Identifies the population measure that differs
      )  # Finishes the population disagreement message
    }  # Finishes the comparison of this population measure
  }  # Finishes comparing all population measures shared by Files 6 and 7

  population  # Returns the five checked population measures in the same LSOA order as File 7
}  # Finishes the File 6 population reader


# File 7 identifies each LSOA’s lower-tier local authority but not its upper-tier authority
# Use the ONS ward lookup to obtain one 2024 lower-to-upper-tier authority relationship for each English authority
# This relationship is used only to check calculated upper-tier scores against MHCLG File 11

read_lad_to_utla_lookup <- function() {  # Defines how to obtain the 2024 lower-to-upper-tier local-authority relationships
  ward_lookup <- read_geography_lookup(  # Uses the saved ONS lookup or obtains all ward-level rows from ONS
    "WD24_PCON24_LAD24_UTLA24_UK_LU",  # Selects the ONS service linking 2024 wards to lower- and upper-tier authorities
    c(  # Requests the fields needed to identify and order the authority relationships
      "WD24CD",  # Includes the ward code used to order successive ONS requests
      "LAD24CD",  # Includes the 2024 lower-tier local-authority code
      "UTLA24CD",  # Includes the corresponding 2024 upper-tier authority code
      "UTLA24NM"  # Includes the corresponding 2024 upper-tier authority name
    ),  # Finishes the required ONS lookup fields
    file.path(  # Constructs the location for the saved ONS lookup
      SOURCE_DATA_DIR,  # Places the lookup with the other downloaded source files
      "lookup_lad24_utla24.csv"  # Names the saved lower-to-upper-tier authority lookup
    ),  # Finishes the saved lookup location
    order_by = "WD24CD"  # Orders the ONS requests by unique ward code so rows are not repeated or skipped
  )  # Finishes reading the ward-level authority lookup

  lad_lookup <- unique(  # Reduces the ward-level rows to one distinct lower-to-upper-tier relationship
    ward_lookup[, c(  # Selects the authority fields and removes the ward code
      "LAD24CD",  # Retains the lower-tier local-authority code
      "UTLA24CD",  # Retains the corresponding upper-tier authority code
      "UTLA24NM"  # Retains the corresponding upper-tier authority name
    )]  # Finishes selecting the lower- and upper-tier authority fields
  )  # Removes repeated authority relationships contributed by multiple wards

  lad_lookup <- lad_lookup[  # Restricts the lookup to English local authorities
    grepl("^E", lad_lookup$LAD24CD),  # Keeps lower-tier authority codes beginning with England’s E prefix
    ,  # Retains all lower- and upper-tier authority fields
    drop = FALSE  # Keeps a table even if only one row were selected
  ]  # Finishes selecting English local authorities

  if (anyNA(lad_lookup) || anyDuplicated(lad_lookup$LAD24CD)) {  # Checks for incomplete relationships or lower-tier codes linked more than once
    stop(  # Stops because every English lower-tier authority must identify one upper-tier authority
      "the LAD-to-upper-tier lookup is incomplete or has duplicated LAD codes"  # Explains the invalid relationship
    )  # Finishes the invalid-lookup error message
  }  # Finishes checking the lower-to-upper-tier relationships

  lad_lookup[  # Returns the checked relationship in a consistent order
    order(lad_lookup$LAD24CD),  # Orders rows by lower-tier local-authority code
    ,  # Retains all lower- and upper-tier authority fields
    drop = FALSE  # Keeps the ordered result as a table
  ]  # Finishes ordering and returning the authority relationships
}  # Finishes the lower-to-upper-tier authority lookup function

# Compare recalculated area scores with MHCLG averages published to three decimal places
# Report whether values round to the same result and whether they differ by no more than half or one published unit
# Use one published unit as the PASS limit because the LSOA source scores are themselves rounded to three decimal places

PUBLISHED_DECIMAL_PLACES <- 3  # Records the number of decimal places shown in MHCLG Files 10, 11 and 13
ROUNDING_UNIT <- 10^(-PUBLISHED_DECIMAL_PLACES)  # Calculates the smallest published unit, equal to 0.001
NUMERIC_TOLERANCE <- 1e-9  # Prevents boundary failures caused only by numerical representation
HALF_ROUNDING_UNIT <- 0.5 * ROUNDING_UNIT + NUMERIC_TOLERANCE  # Sets the half-unit comparison limit to 0.0005 with a tiny numerical allowance
ONE_ROUNDING_UNIT <- ROUNDING_UNIT + NUMERIC_TOLERANCE  # Sets the PASS limit to 0.001 with a tiny numerical allowance

add_validation_results <- function(comparison) {  # Adds agreement measures to calculated-versus-published score comparisons
  comparison$diff <-  # Calculates the signed difference for every area and index
    comparison$avg_score - comparison$published_avg_score  # Subtracts the MHCLG score from the recalculated score

  comparison$abs_diff <- abs(comparison$diff)  # Calculates the size of each difference without regard to direction

  comparison$rounds_to_published <-  # Records whether the two scores display the same value at three decimal places
    round(  # Rounds the recalculated score to MHCLG’s published precision
      comparison$avg_score,  # Supplies the recalculated area score
      PUBLISHED_DECIMAL_PLACES  # Uses three decimal places
    ) ==  # Compares the two rounded values
    round(  # Rounds the MHCLG score using the same rule
      comparison$published_avg_score,  # Supplies MHCLG’s published area score
      PUBLISHED_DECIMAL_PLACES  # Uses three decimal places
    )  # Finishes the comparison at the published precision

  comparison$within_half_rounding_unit <-  # Records whether the absolute difference is no more than approximately 0.0005
    comparison$abs_diff <= HALF_ROUNDING_UNIT  # Compares the absolute difference with half the smallest published unit

  comparison$within_one_rounding_unit <-  # Records whether the absolute difference meets the validation PASS limit
    comparison$abs_diff <= ONE_ROUNDING_UNIT  # Checks that the difference is no more than approximately 0.001

  comparison  # Returns the comparison table with the added agreement measures
}  # Finishes the published-score comparison function
