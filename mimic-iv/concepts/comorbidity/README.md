# Charlson comorbidity concepts (MIMIC-IV)

SQL in this folder implements the Quan et al. (2005) ICD-9-CM / ICD-10 coding
algorithms for the Charlson Comorbidity Index against MIMIC-IV `diagnoses_icd`.

## ICD-10 vs ICD-10-CM

Quan et al. published ranges against **WHO ICD-10**. MIMIC-IV stores
**ICD-10-CM** codes. Most three-character prefixes align; a few CM-only
categories do not appear in the 2005 tables:

| Code | Meaning | Charlson mapping in this repo |
|------|---------|--------------------------------|
| `C4A` | Merkel cell carcinoma | Excluded from `malignant_cancer` (skin malignancy carve-out); see PR discussion on #2017 / #2142 |
| `C7A` | Malignant neuroendocrine tumors | **Not mapped** — outside Quan’s WHO ICD-10 ranges |
| `C7B` | Secondary neuroendocrine tumors | **Not mapped** — outside Quan’s WHO ICD-10 ranges |

Leaving `C7A` / `C7B` unmapped is intentional until a published CM-specific
extension is adopted. Do not widen the `C45`–`C58`-style prefix ranges without
updating this note and citing a coding reference.
