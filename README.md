# IMD 2025 average scores for Sub-ICB Locations

[![Code: MIT](https://img.shields.io/badge/code-MIT-blue.svg)](LICENSE)
[![Data: OGL v3](https://img.shields.io/badge/data-OGL%20v3-brightgreen.svg)](DATA_LICENCE.md)

> **Two licences.** The R code is MIT. The data — both the sources and the
> outputs in `data/` — is Crown copyright under the
> [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)
> and **requires attribution**. GitHub's sidebar shows only "MIT"; that refers to
> the code. See [DATA_LICENCE.md](DATA_LICENCE.md) for the wording you must
> reproduce.

This project provides population-weighted average **Index of Multiple
Deprivation 2025 (IoD2025)** scores for all **106 Sub-ICB Locations (SICBLs)**
in England. It covers the overall IMD, all seven domains, the IDACI and IDAOPI
supplementary indices, and all six sub-domains for the 2023, 2024, 2025 and 2026
Sub-ICB boundary sets.

These are scores only. Ranks and deciles are not provided.

> **Not an official statistic.** MHCLG does not publish IoD2025 summaries for
> Sub-ICB Locations. These figures were calculated independently using MHCLG's
> published method. For official local authority or ICB figures, use Files 10,
> 11 and 13 from the [English indices of deprivation 2025
> release](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2025).

## If you only need the data

The completed files are already in [`data/`](data/). You do not need R or
RStudio to use them.

### Which file should I use?

| What you need | File |
|---|---|
| Sub-ICB deprivation scores | **Main file:** [`data/imd2025_subicb_scores_long.csv`](data/imd2025_subicb_scores_long.csv). It has one row per Sub-ICB, index and boundary year: 6,784 rows covering 106 Sub-ICBs, 16 indices and four boundary years. |
| The meaning, scale and weighting population for each index | [`data/index_metadata.csv`](data/index_metadata.csv). Use this alongside the main file. |
| Total population and the four other published population measures | [`data/population_denominators_subicb.csv`](data/population_denominators_subicb.csv). It has one row per Sub-ICB, population measure and boundary year. |
| Evidence comparing the calculation with MHCLG's published ICB and local-authority figures | The `validation_*.csv` files described in the [data guide](data/README.md). These support the checks and are not needed for routine use of the Sub-ICB scores. |

Most users need `imd2025_subicb_scores_long.csv` together with
`index_metadata.csv`. Select the required boundary year using `sicbl_vintage`
and the required deprivation measure using `index`. The 2023, 2024 and 2025
scores are identical; use the year matching the other geography data in your
analysis. Use 2026 for the reorganised 2026 boundaries.

The [data guide](data/README.md) defines every column and explains the licence
and required attribution.

### Download options

Choose whichever option is easiest:

1. **Download one file:** open a CSV link in the table above and use GitHub's
   download button.
2. **Download all files without Git:** select **Code → Download ZIP** on the
   repository's GitHub page, unzip it, and open the `data/` folder.
3. **Clone the repository:** if Git is available, run the following commands.
   They can be pasted into the **RStudio Terminal** tab; do not paste them into
   the R Console.

```bash
git clone https://github.com/SIRSAZOFDUCK/IMD2025_subICB_scores.git
cd IMD2025_subICB_scores
ls data
```

Cloning the repository downloads the completed data files. Installing R
packages or rerunning the calculations is unnecessary if you only need the
data.

In the long file, `weight_pop` is the population used for that index. It is
therefore not always the total population: Employment uses people aged 18–66,
IDACI uses children aged 0–15, and IDAOPI uses people aged 60 or over. The
`mhclg_comparison_available` column shows whether MHCLG publishes a higher-area
summary for that index against which the calculation method could be checked.
It does not mean that MHCLG has approved or published the Sub-ICB value.

## Points to consider before using the scores

### Scores for different indices are not comparable

The indices use different scales. For example, a Crime score of 0.3 cannot be
compared with an Income score of 0.15.

| Scale in the data | Indices | Observed LSOA range |
|---|---|---|
| `imd_composite` | Overall IMD | 0.17 to 94.22 |
| `rate_0_1` | Income, Employment, IDACI, IDAOPI | 0.00 to 1.00 |
| `exponential_0_100` | Education, Barriers, Living Environment | 0.00 to 99.61 |
| `standardised` | Health, Crime | −3.29 to 3.55; values can be negative |
| `untransformed_subdomain` | Six sub-domains | Mixed; see `data/index_metadata.csv` |

The average of exponentially transformed scores is not the transformation of
an average on another scale, so the measures cannot be reconstructed from one
another.

MHCLG does not publish higher-area summaries for the six sub-domains. Their
total-population weighting is a choice made for this project rather than an
MHCLG specification.

### Boundary years

- The 2023, 2024 and 2025 files contain the same Sub-ICB codes, LSOA membership
  and scores. Choose the year that matches the other data in your analysis.
- In 2026, three Sub-ICBs were replaced, 2,080 LSOAs were reassigned, and the
  number of parent ICBs changed from 42 to 36. The scores for the 103 Sub-ICBs
  retained from 2025 are unchanged; the changes affect the three replacement
  areas and the parent ICB fields.

### Precision

MHCLG's LSOA scores in File 7 are published to three decimal places. Any area
average calculated from them therefore carries a small amount of rounding
uncertainty compared with MHCLG's own calculations from unrounded data.

The Sub-ICB scores are written to six decimal places so that no useful
information is lost.
The six displayed decimal places should not be interpreted as six-decimal
accuracy. In particular, the published source data cannot support ordering two
areas whose scores differ by less than about 0.001.

## Data sources

| Source | Use in this project |
|---|---|
| [MHCLG English indices of deprivation 2025](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2025), File 7 | LSOA scores and four of the population measures |
| MHCLG File 6 | All five LSOA population measures |
| MHCLG Files 10, 11 and 13 | Published local authority and ICB averages used to check the calculation |
| [ONS Open Geography Portal](https://geoportal.statistics.gov.uk/) | LSOA-to-Sub-ICB and related geography lookups for 2023–2026 |

The [source-file record](SOURCE_FILES.md), also available as a
[CSV file](data/source_file_record.csv), gives the source URL, the time the local
copy was saved, its size and its SHA-256 hash. The MHCLG entries describe the
files as downloaded. The ONS entries describe the lookup tables collected from
the Open Geography Portal and give the details needed to collect them again.

## Method

IoD2025 contains one row for each of England's 33,755 2021 LSOAs. Each LSOA
belongs to one Sub-ICB Location in the ONS lookups.

For each index and Sub-ICB, the score is the population-weighted mean of its LSOA
scores, following the **Average score** measure in section 3.8.8 and Appendix
M.3 of the [IoD2025 Technical
Report](https://assets.publishing.service.gov.uk/media/68ff59c80f801e57b5bef907/ID_2025_Technical_Report.pdf):

$$
\text{average score}_a =
\frac{\sum_{i \in a}(\text{LSOA score}_i \times \text{population}_i)}
     {\sum_{i \in a}\text{population}_i}
$$

The population measure varies by index.

| Index | Mid-2022 population used |
|---|---|
| Overall IMD; Income, Education, Health, Crime, Barriers and Living Environment domains | Total population |
| Employment domain | People aged 18–66 |
| IDACI | Dependent children aged 0–15 |
| IDAOPI | People aged 60 or over |
| Six sub-domains | Total population; a project choice because MHCLG does not specify higher-area sub-domain summaries |

File 7 has no missing scores or weighting populations.

File 6 includes a population aged 16–59 measure that is absent from File 7. It
is included in `data/population_denominators_subicb.csv` but is not used as a
weight for any index. The four population measures present in both source files
are checked for agreement.

## Checks against MHCLG's published averages

There is no published Sub-ICB result for a direct comparison. The calculation
was therefore repeated for ICBs and both local authority tiers, for which MHCLG
does publish average scores. The same R function and the same index-specific
population measures were used; only the area used to group LSOAs changed.

All **6,040 comparisons** were within 0.001 of the published value.

| Area and boundary year | Areas matched | Comparisons | Same value when rounded to 3 decimal places | Largest absolute difference |
|---|---:|---:|---:|---:|
| ICB, 2023 | 42 | 420 | 419 (99.76%) | 0.000501 |
| ICB, 2024 | 42 | 420 | 419 (99.76%) | 0.000501 |
| ICB, 2025 | 42 | 420 | 419 (99.76%) | 0.000501 |
| ICB, 2026 | 29 | 290 | 290 (100%) | 0.000499 |
| Lower-tier local authority, 2024 | 296 | 2,960 | 2,895 (97.80%) | 0.000565 |
| Upper-tier local authority, 2024 | 153 | 1,530 | 1,498 (97.91%) | 0.000557 |

The 2026 check contains 29 ICBs because MHCLG File 13 uses 2024 ICB codes and
only 29 of those codes remained after the 2026 changes.

The small differences are consistent with File 7's LSOA scores being rounded to
three decimal places, while MHCLG calculated its published area summaries from
unrounded scores. Detailed results are in:

- [`data/validation_vs_file13_icb.csv`](data/validation_vs_file13_icb.csv) and
  [`data/validation_vs_file13_icb_detail.csv`](data/validation_vs_file13_icb_detail.csv);
- [`data/validation_vs_file1011_la.csv`](data/validation_vs_file1011_la.csv) and
  [`data/validation_vs_file1011_la_detail.csv`](data/validation_vs_file1011_la_detail.csv).

These checks support the calculation method.

## If you want to reproduce the results

The instructions in this section rebuild the Sub-ICB files and repeat the
comparisons with MHCLG. Every command below is a terminal command. It can be
pasted into the **RStudio Terminal** tab from **Tools → Terminal → New
Terminal**. Run the commands from the repository root, not from the R Console.

The analysis was developed with R 4.6.1. The automated GitHub checks use the
current R release on Ubuntu. It also requires `jsonlite`, `readxl` and `digest`.

### 1. Download the repository

Open an RStudio Terminal and run:

```bash
git clone https://github.com/SIRSAZOFDUCK/IMD2025_subICB_scores.git
cd IMD2025_subICB_scores
```

If you already downloaded or cloned the repository, open that folder in
RStudio and use its Terminal tab instead.

### 2. Check R and install the three packages

Run these commands in the RStudio Terminal:

```bash
Rscript --version
Rscript -e 'install.packages(c("jsonlite", "readxl", "digest"), repos = "https://cloud.r-project.org")'
```

### 3. Run the scripts in order

Run each command in the RStudio Terminal from the repository root:

```bash
Rscript R/02_calculate_subicb_scores.R
Rscript R/03_calculate_population_denominators.R
Rscript R/04_check_icb_scores.R
Rscript R/05_check_local_authority_scores.R
Rscript R/06_record_source_files.R --check
Rscript R/07_check_saved_results.R
```

`R/01_imd2025_calculations.R` contains the shared settings and calculations.
Scripts 02–06 read it automatically, so do not run script 01 separately.

The first calculation downloads about 30 MB from MHCLG and ONS into
`data-raw/`. The files are retained locally and reused on later runs. Scripts
02 and 03 rebuild the three Sub-ICB data files. Scripts 04 and 05 repeat the
comparisons with MHCLG.

Script 06 with `--check` calculates the SHA-256 of each downloaded source file
and compares it with `data/source_file_record.csv`; it does not change the
saved record. Script 07 compares the seven rebuilt result files with the copies
committed in the repository. Both scripts stop if a file has changed beyond the
stated checks. A successful complete run ends with `PASS` messages from scripts
04–07.

### Project structure

```text
data/       Completed Sub-ICB data and records of the MHCLG comparisons
data-raw/   Source files downloaded when the scripts run; not included in Git
R/          Calculation and checking scripts
```

| Script | Purpose |
|---|---|
| `R/01_imd2025_calculations.R` | Contains the shared calculation and source settings; scripts 02–06 read it automatically, so it is not run directly |
| `R/02_calculate_subicb_scores.R` | Calculates the Sub-ICB scores and writes the main data files |
| `R/03_calculate_population_denominators.R` | Writes all five population measures at Sub-ICB level |
| `R/04_check_icb_scores.R` | Compares recalculated ICB averages with MHCLG File 13 |
| `R/05_check_local_authority_scores.R` | Compares recalculated local authority averages with MHCLG Files 10 and 11 |
| `R/06_record_source_files.R` | Records source-file details; `--check` compares downloaded files with the recorded SHA-256 values |
| `R/07_check_saved_results.R` | Compares rebuilt data with the files included in the project |

## Licence and citation

The R code is available under the [MIT licence](LICENSE).

The source data and derived files in `data/` are Crown copyright under the
[Open Government Licence
v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/),
not the MIT licence. Reuse, including commercial reuse, is permitted, but both
of the following statements must be reproduced:

> Contains public sector information licensed under the Open Government Licence
> v3.0. Source: Ministry of Housing, Communities and Local Government, English
> Indices of Deprivation 2025. © Crown copyright.

> Source: Office for National Statistics licensed under the Open Government
> Licence v.3.0.

The derived data remain under OGL v3 and cannot be relicensed. See
[`DATA_LICENCE.md`](DATA_LICENCE.md) for full details.

To cite this work, use [`CITATION.cff`](CITATION.cff) and also cite the
[underlying MHCLG publication](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2025).

Authors: **Ben Luckraft** and **Saran Shantikumar**, University of Warwick.

The R code was reviewed, cross-checked and reorganised into a clear sequence of scripts with assistance from [Claude Code](https://claude.com/claude-code) (Anthropic) and [Codex](https://openai.com/codex/) (OpenAI). Codex was also used to expand the code comments in plain English and to draft and structure this README.

Saran Shantikumar is the guarantor for this repository and reviewed and approved the final code, data outputs and documentation before release.
