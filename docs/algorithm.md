# Saccade detection algorithm

This document describes how SAL detects saccades and fixations from raw eye-position data, and how it then estimates each saccade's onset, offset, and kinematics. The detector is an extension of the adaptive velocity-threshold method of Nyström & Holmqvist (2010), adapted for trial-structured behavioral data (one threshold per trial rather than one per recording) and supplemented with paradigm-specific filters.

The implementation lives in `sal_functions/`. The [`saccadeDetectionAlgorithm.mlx`](saccadeDetectionAlgorithm.mlx) Live Script in this folder walks through the same steps interactively in MATLAB and is the recommended companion to this document.

---

## 1. Input data

The detector expects each session to be a set of trials × samples matrices, typically at 1 kHz sampling, with values in degrees of visual angle:

| Variable     | Shape              | Meaning                                          |
|--------------|--------------------|--------------------------------------------------|
| `EyeX`       | trials × samples   | Horizontal eye position                          |
| `EyeY`       | trials × samples   | Vertical eye position                            |
| `TargetX`    | trials × samples   | Horizontal target position (drives search window)|
| `TrialList`  | trials × metadata  | Per-trial conditions                             |

Trials are zero-padded with `NaN` at the end; the detector tracks the last non-`NaN` sample per trial so the padding never enters the math.

## 2. Pipeline overview

```
raw EyeX/EyeY
   │
   ▼ Savitzky–Golay smoothing
smooth_EyeX, smooth_EyeY
   │
   ▼ point-by-point first derivative × 1000  (for 1 kHz sampling)
velX, velY, vel
   │
   ▼ trial-by-trial search window from target onset
   ▼ findpeaks → all "potential saccades"
   ▼ ITERATIVE ADAPTIVE THRESHOLD
true saccades vs fixations
   │
   ▼ remove early saccades (< 70 ms from target shift)
   ▼ keep only N saccades expected per trial type
   ▼ ONSET detection (local minimum search)
   ▼ OFFSET detection (hybrid global / local threshold)
   ▼ kinematics (amplitude, peak velocity, duration, errors)
```

## 3. Preprocessing

**Smoothing.** `smooth_saccade.m` applies a Savitzky-Golay filter (`smooth(..., 'sgolay')`) with default parameters:

- `window_span = 20` samples (≈ 20 ms at 1 kHz)
- `order = 4`

Trailing samples whose window would extend past the last non-`NaN` point are returned unsmoothed, which prevents the filter's edge artefact from contaminating saccade detection.

**Velocity & acceleration.** `pbp_derivatives.m` computes point-by-point first derivatives independently along x and y, plus the total speed `vel = sqrt(velX² + velY²)`. All velocities are scaled by ×1000 to convert from deg/sample to deg/s (sampling rate is 1 kHz for the search-coil data the toolkit was developed against; for other rates, the scaling factor in `A_Preprocessing.m` must be adjusted).

## 4. Adaptive velocity-threshold detection

This is the core of the algorithm. It runs **per trial**, not per session, so a trial in which the subject is unusually noisy or unusually still gets its own threshold.

### 4.1 Search window

`InitialPointOfSearch(i)` is the time of the primary target shift on trial *i*, returned by `firstTargetShift.m`. The search runs from that point to the last non-`NaN` sample minus 20 (a small safety margin against edge effects in the smoothed velocity).

### 4.2 Potential saccades

Within the search window, `findpeaks` returns every local maximum in `vel`, regardless of height. These are the "potential saccades" — a mix of real saccades and high-amplitude fixation noise.

### 4.3 Iterative threshold refinement

`adaptiveVelocityThreshold.m` then separates true saccades from noise as follows:

1. Start with a **default threshold** (`defaultVelocityThreshold = 100` deg/s, within the 100–300 deg/s range recommended by Nyström & Holmqvist 2010).
2. Remove all peaks with velocity ≥ threshold from the pool.
3. Recompute the threshold from the **remaining** peaks:
   ```
   threshold_new = mean(remaining) + 6 · std(remaining)
   ```
4. Repeat steps 2–3 until no peak in the pool exceeds the threshold.
5. The final threshold is the trial's adaptive velocity threshold.

Two points worth flagging:

- The multiplier in step 3 is **6**, not the **3** suggested by Nyström & Holmqvist. The larger constant tolerates more noise in the fixation distribution before promoting a candidate to a saccade — chosen empirically for the search-coil signal-to-noise ratio in the data this toolkit was developed against.
- Because peaks above threshold are *removed before* the mean/std are recomputed, the threshold is driven by the **non-saccade** peaks, which is what makes it stable across noise regimes.

### 4.4 Final saccades and fixations

Using the trial's adaptive threshold, `saccadeFixationDetector.m` re-runs `findpeaks` with:

- `MinPeakHeight = adaptive_threshold`
- `MinPeakDistance = minInterPeakIntervalThreshold` (default 100 samples ≈ 100 ms — a refractory period preventing closely-spaced peaks from being counted as separate saccades)

Peaks meeting both constraints are **true saccades**. The remaining "potential saccades" — peaks above zero but below the adaptive threshold — are stored as **fixations** and used downstream to set the onset/offset thresholds.

## 5. Post-detection polish

Two paradigm-driven filters run before kinematics:

- **`removeEarlySaccades`** discards saccades whose peak occurs within `minDistanceFromTargetShift = 70` ms of the primary target shift. These are usually anticipatory responses or detection artefacts that pre-date the target's visual processing.
- **`findRelevantNumSaccades`** retains only as many saccades per trial as the paradigm expects (e.g. one for "stay-put" trials, two when an intrasaccadic step is present), provided the primary saccade exceeds `vel_threshold = 200` deg/s.

## 6. Onset detection

`findSaccadeOnset.m` defines a per-trial **global onset threshold** from the trial's fixations:

```
onset_threshold = mean(fixation velocities) + 3 · std(fixation velocities)
```

The onset of each saccade is then the **local minimum in velocity** between the last fixation point below this threshold and the saccade's peak.

## 7. Offset detection

The offset routine uses a **hybrid threshold** that blends a global and a local estimate, motivated by the observation that the velocity profile around the offset is paradigm- and saccade-dependent.

For each saccade *j*, `offsetThresholdFinder.m` computes:

```
overall_threshold = mean(all fixation velocities) + 3 · std(all fixation velocities)
local_threshold   = mean(window after peak)         + 3 · std(window after peak)
offset_threshold  = α · overall_threshold + β · local_threshold
```

with coefficients differing for primary vs. secondary (corrective) saccades:

| Saccade   | α (overall) | β (local) | Local window size |
|-----------|-------------|-----------|-------------------|
| Primary   | 0.5         | 0.5       | 40 samples        |
| Secondary | 0.7         | 0.3       | 40 samples        |

`findSaccadeOffset.m` then searches forward from the peak until velocity first drops below `offset_threshold`, and refines that to the first local minimum (point where velocity starts rising again). An acceleration-based variant, `findSaccadeOffset_acc.m`, applies the same idea to the acceleration signal for paradigms where the velocity tail is too shallow to localise reliably.

## 8. Kinematics

With onsets and offsets in place, `saccadeKinematicsCalculator.m` computes per saccade:

- **Amplitude** (Euclidean distance between onset and offset eye positions)
- **Duration** (offset time − onset time)
- **Peak velocity** (already known from detection)
- **Endpoint error** (`visualErrorCalculator.m`): difference between offset position and the target position after the primary, and where applicable, secondary target shift.

## 9. Where SAL diverges from Nyström & Holmqvist (2010)

The detector is *based on* their method but is not a faithful re-implementation. Differences worth noting:

| Aspect              | Nyström & Holmqvist (2010) | SAL                                            |
|---------------------|----------------------------|------------------------------------------------|
| Threshold scope     | One per recording          | One **per trial**                              |
| Noise multiplier    | mean + 3 · std             | mean + **6** · std                             |
| Glissade detection  | Explicit                   | Not separately modelled                        |
| Offset criterion    | Single adaptive threshold  | Hybrid (global + local) with separate α/β per saccade order |
| Post-detection pass | —                          | Paradigm-specific filters: anticipatory exclusion, expected saccade count |

These changes reflect SAL's origin as an analysis tool for **trial-structured, reward-modulated, non-human-primate saccade paradigms**, where each trial is a short, time-locked epoch rather than a long free-viewing recording.

## 10. Default parameters at a glance

Set in `A_Preprocessing.m`. Tweak with care.

| Parameter                          | Default        | Used in                              |
|------------------------------------|----------------|--------------------------------------|
| Smoothing window                   | 20 samples     | `smooth_saccade`                     |
| Smoothing polynomial order         | 4              | `smooth_saccade`                     |
| Default velocity threshold         | 100 deg/s      | `saccadeFixationDetector`            |
| Noise std multiplier (detection)   | 6              | `adaptiveVelocityThreshold`          |
| Min inter-peak interval            | 100 samples    | `saccadeFixationDetector`            |
| Min time from target shift         | 70 ms          | `removeEarlySaccades`                |
| Min primary saccade peak velocity  | 200 deg/s      | `findRelevantNumSaccades`            |
| Onset noise std multiplier         | 3              | `findSaccadeOnset`                   |
| Offset α / β (primary)             | 0.5 / 0.5      | `offsetThresholdFinder`              |
| Offset α / β (secondary)           | 0.7 / 0.3      | `offsetThresholdFinder`              |
| Offset local window                | 40 samples     | `offsetThresholdFinder`              |
| Sampling rate (assumed)            | 1000 Hz        | velocity unit conversion             |

## References

- Nyström, M., & Holmqvist, K. (2010). An adaptive algorithm for fixation, saccade, and glissade detection in eyetracking data. *Behavior Research Methods*, 42(1), 188–204. doi:[10.3758/BRM.42.1.188](https://doi.org/10.3758/BRM.42.1.188)
