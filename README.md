# RplotStrace
Rscript which plots strace logfiles (both histogram/frequency and density plots)

The '.strace' logfiles should be created running this commandline
  "strace -f -e io_submit <fiocmd>"

The makeplot.R script uses 'grep' cmd to extract offset values from strace logfiles.
NOTE: variable 'regex_iosubmit_offset' can be adapted to work with alternative strace output formats
