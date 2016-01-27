# Load data using the control files

e.g. where the tables are on the MIMICIII_V1_3 user's schema:

```sqlldr MIMICIII_V1_3 control=services.ctl log=logfile.log```

## Load time for chartevents (the largest table) with partitions is ~30min

Elapsed time was:     00:33:46.44
CPU time was:         00:28:30.03
