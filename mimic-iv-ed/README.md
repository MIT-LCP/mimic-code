# MIMIC-IV-ED

MIMIC-IV-ED is a publicly available database of emergency department visit data. You can read more about the dataset on [the PhysioNet project page](https://mimic.mit.edu/docs/iv/modules/ed/).

## Timing caveats

`edstays.intime` is an administrative ED registration time. Pyxis and prescription timestamps can legitimately fall slightly before that window — see [docs/TIMING_NOTES.md](docs/TIMING_NOTES.md).
