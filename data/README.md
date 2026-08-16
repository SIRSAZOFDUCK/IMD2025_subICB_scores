# Data outputs — licence and attribution

**These files are NOT covered by the MIT licence in the repository root.**

The MIT licence covers the R code only. Everything in this directory is derived
from Crown copyright data and is released under the
[**Open Government Licence v3.0**](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).

You may copy, adapt and redistribute these files, including commercially, but
**attribution is required**. Reproduce both statements:

> Contains public sector information licensed under the Open Government Licence
> v3.0. Source: Ministry of Housing, Communities and Local Government, English
> Indices of Deprivation 2025. © Crown copyright.

> Source: Office for National Statistics licensed under the Open Government
> Licence v.3.0.

The first covers the deprivation scores and population denominators; the second
covers the geography lookups used to assign LSOAs to Sub-ICB Locations.

Because these outputs are adaptations of OGL-licensed data, they remain under
OGL v3. **You cannot relicense them**, including under MIT.

Full detail: [`../DATA_LICENCE.md`](../DATA_LICENCE.md).
Source files, URLs and SHA-256 hashes: [source-file record](../SOURCE_FILES.md).

## Not an official statistic

These Sub-ICB figures are an independent derivation, not an MHCLG product. MHCLG
publish no Sub-ICB Location summaries; these apply MHCLG's documented method to a
geography they did not cover. Neither MHCLG nor ONS endorse this work.

For **local authority or ICB** deprivation scores, use MHCLG's own Files 10, 11
and 13 from the
[IoD2025 release](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2025)
rather than anything here.

## What is in this directory

| File | Contents |
|---|---|
| `imd2025_subicb_scores_long.csv` | **Main output** — 106 Sub-ICBs × 16 indices × 4 vintages, tidy long |
| `index_metadata.csv` | Per-index scale type, weighting denominator, observed LSOA range |
| `population_denominators_subicb.csv` | All 5 denominators by Sub-ICB and vintage |
| `source_file_record.csv` | Source-file record in CSV format |
| `validation_vs_file13_icb*.csv` | Validation evidence against MHCLG File 13 |
| `validation_vs_file1011_la*.csv` | Validation evidence against MHCLG Files 10 and 11 |

⚠️ Scores are **not comparable across indices** — the `scale` column marks five
genuinely different scales, and Health and Crime scores can be negative. See the
repository README.

## Column definitions (`imd2025_subicb_scores_long.csv`)

| Column | Meaning |
|---|---|
| `sicbl_vintage` | Sub-ICB boundary year (2023–2026). **2023, 2024 and 2025 are identical** — same codes, same LSOA membership, same scores; pick whichever matches your other data. 2026 differs: 3 SICBLs replaced, 2,080 LSOAs reassigned, ICBs 42 → 36. |
| `sicbl_code` / `sicbl_nhs_code` | ONS code (E38…) / NHS 3-character code |
| `sicbl_name`, `icb_code`, `icb_name` | Names and parent ICB |
| `index` / `index_label` | Which of the 16 indices the row is for |
| `scale` | Which of the five scales the score sits on — do not compare across scales |
| `avg_score` | The population-weighted average score (6 dp) |
| `weight_pop` | **Sum of the index-specific weighting denominator** — total population for most indices, but working-age 18–66 on `employment` rows, children 0–15 on `idaci` rows, 60+ on `idaopi` rows |
| `n_lsoa` | Number of LSOAs aggregated |
| `mhclg_comparison_available` | `TRUE` for the 10 indices checkable against MHCLG's published summaries; `FALSE` for the 6 sub-domains, which have none |
