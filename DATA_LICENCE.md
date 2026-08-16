# Data licence and attribution

The MIT licence in [`LICENSE`](LICENSE) covers **the code only** — the R scripts.

All data in this repository, both the original source files and the calculated
outputs in `data/`, is **Crown copyright** and released under the
[**Open Government Licence v3.0**](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
The OGL permits copying, adapting and redistributing, including commercially,
provided the source is acknowledged.

The derived outputs are adaptations of OGL-licensed data, so they remain under
OGL v3 and carry the same attribution obligations. You cannot relicense them.

## Required attribution

If you use the outputs in `data/`, reproduce both statements:

> Contains public sector information licensed under the Open Government Licence
> v3.0. Source: Ministry of Housing, Communities and Local Government, English
> Indices of Deprivation 2025. © Crown copyright.

> Source: Office for National Statistics licensed under the Open Government
> Licence v.3.0.

The first covers the deprivation scores and population denominators; the second
covers the geography lookups used to assign LSOAs to areas.

**No Ordnance Survey or Royal Mail attribution is required.** ONS require those
only for postcode and UPRN products. The lookups used here are plain code-to-code
tables, for which
[ONS geography licences](https://www.ons.gov.uk/methodology/geography/licences)
specify the single ONS statement above. Adding an OS statement would be
incorrect, not merely cautious.

## Sources

| Source | Publisher | Licence |
|---|---|---|
| [English Indices of Deprivation 2025](https://www.gov.uk/government/statistics/english-indices-of-deprivation-2025) (Files 6, 7, 10, 11, 13) | MHCLG | OGL v3 |
| [Open Geography Portal](https://geoportal.statistics.gov.uk/) (LSOA/SICBL/ICB/LAD/UTLA lookups) | ONS | OGL v3 |

The [source-file record](SOURCE_FILES.md) gives the exact files, URLs, collection
times and SHA-256 hashes.

## Not an official statistic

⚠️ **This is an independent derivation, not an official MHCLG product.**

MHCLG publish higher-area summaries for local authorities, LEPs, ICBs, LRFs and
Built Up Areas. They do **not** publish Sub-ICB Location summaries — those
figures exist only here, produced by applying MHCLG's documented method to a
geography they did not cover.

This repository publishes **Sub-ICB scores only**. If you need local authority
or ICB deprivation scores, take them from MHCLG's own Files 10, 11 and 13 —
they are official statistics. The R scripts recalculate those figures only to
check the method against them. The recalculated values appear beside the
published values in `data/validation_*_detail.csv` and are not offered as
separate outputs.

Neither MHCLG nor ONS endorse this work or are responsible for it.
