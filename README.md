# SAL — Saccade Analysis Lab

A MATLAB toolkit for detecting and analyzing **saccades** (rapid eye movements) from raw eye-tracker recordings. SAL was built to process behavioral data from non-human primates performing reward-based saccade-adaptation tasks, but the core detection and kinematics routines apply to any 2D eye-position time series.

## Features

- Adaptive velocity-threshold saccade detection from raw X/Y eye-position signals
- Onset / offset estimation with optional acceleration-based refinement
- Per-saccade kinematics: amplitude, duration, peak velocity, visual error
- Trial-level bookkeeping for reward-modulated paradigms (reward condition, direction, intra-saccadic step, free-choice trials)
- Detection of repeated trials and consecutively repeated rewarded sequences
- Cross-session pooling and export of a single data frame ready for downstream statistical analysis in R

## Repository structure

```
SAL/
├── sal_source_code/    Ordered pipeline scripts (A → E) plus a Live Script walkthrough
├── sal_functions/      ~45 helper functions called by the pipeline
├── LICENSE             MIT
└── README.md
```

## Pipeline

The scripts in `sal_source_code/` are designed to be run in order:

| Step | Script                          | Purpose                                                                              |
|------|---------------------------------|--------------------------------------------------------------------------------------|
| A    | `A_Preprocessing.m`             | Load a session, remove repeated trials, smooth signals, detect saccades & fixations  |
| B    | `B_Looping_1_Preprocessing.m`   | Run step A in batch over every session in a data folder                              |
| C    | `C_Kinematics.m`                | Compute per-saccade kinematics and tag trials by reward / direction / step condition |
| D    | `D_Looping_C_Kinematics.m`      | Run step C in batch                                                                  |
| E    | `E_poolSessions.m`              | Pool per-session outputs into a single cross-session data frame                      |
| —    | `Rpreparation.m`                | Reshape the pooled frame for export to R                                             |

`saccadeDetectionAlgorithm.mlx` provides an interactive walkthrough of the detection routine.

## Requirements

- MATLAB (recent release recommended)
- Eye-tracking session files in `.mat` format containing at minimum: `EyeX`, `EyeY`, `TargetX`, `TrialList`, `ExtraChannel4`
- *(Optional)* R, for downstream statistical analysis of the exported data frame

## Getting started

1. Clone the repository and add `sal_functions/` to your MATLAB path:
   ```matlab
   addpath(genpath('sal_functions'));
   ```
2. Open `sal_source_code/A_Preprocessing.m` and edit the `filepath` / `filename` variables to point at your data.
3. Run `A_Preprocessing.m` on a single session, or `B_Looping_1_Preprocessing.m` to batch-process a directory.
4. Continue with `C_Kinematics.m`, `D_Looping_C_Kinematics.m`, and `E_poolSessions.m`.
5. *(Optional)* Export the pooled frame to R with `Rpreparation.m`.

> **Note:** Data paths are currently hard-coded inside each script (e.g. `J:\Monkey Project\...`). You will need to edit them to point at your local data tree. Parameterizing these paths is on the short-term roadmap.

## Status

SAL grew out of a single-researcher workflow and is being progressively cleaned up for wider use. Expect rough edges: hard-coded paths, manual file-list trimming, and assumptions about variable names in the input `.mat` files. Issues and pull requests are welcome.

## Citation

If you use SAL in academic work, please cite this repository and contact the author for the appropriate reference.

## Author

**Masih Shafiei** — [shafiei.masih@gmail.com](mailto:shafiei.masih@gmail.com)

## License

Released under the MIT License — see [LICENSE](LICENSE).
