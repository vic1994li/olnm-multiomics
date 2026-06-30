# Non-invasive identification of occult lymph node metastasis in clinical N0 NSCLC

This repository contains the analysis framework for a multicentre study of
non-invasive identification of occult lymph node metastasis in patients with
clinical N0 non-small-cell lung cancer (NSCLC). The study integrates plasma
cfDNA methylation, 5mC-enriched cfDNA fragmentomics and CT habitat imaging for
preoperative nodal risk assessment.

## Analysis modules

1. cfDNA methylation processing
2. 5mC-enriched fragmentomic feature extraction
3. CT habitat generation
4. Single-modality model training
5. Score-level multiomics integration
6. Model evaluation
7. SHAP interpretation
8. Survival and clinical utility analyses
9. Figure generation

## Repository status

This repository is the manuscript submission preparation version. Complete
analysis code, model configurations and example data will be added
progressively before manuscript acceptance or publication.

Individual-level clinical, sequencing and imaging data are not included
because of patient-privacy requirements and institutional restrictions.
De-identified example inputs and reproducible example workflows will be
provided where permitted.

## Planned archival release

A versioned release will be archived on Zenodo to generate a persistent DOI.
The archived release is planned to include source code, software environment
specifications, model configurations and example workflows required to
reproduce the principal analyses and figures.

## Directory overview

- `environment/`: software environment specifications
- `config/`: model configuration placeholders
- `scripts/`: analysis modules in workflow order
- `example_data/`: documentation and future de-identified examples
- `model_weights/`: documentation and future shareable model artifacts
- `results/`: documentation for reproducible derived outputs
- `docs/`: supporting documentation and code availability statement

## License

Code in this repository is released under the MIT License unless otherwise
noted. Data access is not granted by the software license.
