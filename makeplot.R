#!/usr/bin/env Rscript
#
# makeplots.R
# - Create plots from strace logfiles
#   Expects one argument - directory containing '.strace' files
#
# '.strace' files should be created running this commandline
#    strace -f -e io_submit <fiocmd>
#
# Issues 'grep' cmd to extract offsset values from strace logfiles.
# NOTE: variable 'regex_iosubmit_offset' can be adapted to work with
#   alternative strace output formats
#
#
########################################

#---------------------------------------
# some variable definitions
#
# strace logfile names end in ".strace"
regex_strace <- "\\.strace$"
# temp file into which offset values are written 
tmp_offsets <- "./tmp.offsets"
# used to label X-axis in 'hist' and 'plot' calls
syscall <- "io_submit OFFSET"
# regex used by grep to extract io_submit offset values
regex_iosubmit_offset = "'(?<=offset:)[0-9]+'"

#---------------------------------------
# get cmdline arg (name of data file)
args <- commandArgs(trailingOnly = TRUE)
if (length(args)==0) {
  stop("Requires strace logfile dirname as only argument", call. = FALSE)
} 
#print(args)
datadir <- args[1]
rm(args)

# get the strace file names from the directory
filelist <- list.files(datadir, pattern = regex_strace, full.names = TRUE,
    recursive = FALSE)
#print(filelist)

# check to see that files were found. If not, bail...
if (length(filelist)==0) {
  stop("No input files found", call. = FALSE)
}

#
# FOR loop - process each file
#
for (stracefile in filelist) {
    message(sprintf("Processing file: %s\n", stracefile))

# Use grep to extract the offset values
# write results to TMP offsets file
#    system2("grep", args=c("-oP", "'(?<=offset:)[0-9]+'", 
    system2("grep", args=c("-oP", regex_iosubmit_offset, 
      stracefile), stdout=tmp_offsets, wait=TRUE)
    message(sprintf("> offset values written to: %s\n", tmp_offsets))
# DEBUG
#    stop("DEBUG after grep call", call. = FALSE)

# read in the data from TMP offsets file
    DATA <- read.table(tmp_offsets, header = FALSE)
# unlist and convert to numeric values
    DATA <- as.numeric(unlist(DATA))
    numrows <- NROW(DATA)
#print(numrows)

# set points per inch for plotting
    ppi <- 300

# FREQUENCY plot: Make a 6x6 inch image at 300dpi
    message(sprintf("> Creating frequency plot\n"))
    png(paste(stracefile,"_freq.png",sep=""), 
      width=6*ppi, height=6*ppi, res=ppi)
    hist(DATA, xlab = paste(syscall, " Values : #Samples=", numrows), 
      main = paste("Histogram: ", stracefile), 
      col = "lightgreen")
    dev.off()

# LEAVE OUT FOR NOW
# DENSITY plot
#    message(sprintf("> Creating density plot\n"))
#    d <- density(DATA)
#    png(paste(stracefile,"_density.png",sep=""), 
#      width=6*ppi, height=6*ppi, res=ppi)
#    plot(d, xlab = paste(syscall, " Values : #Samples=", numrows),
#      main = paste("Kernel Density: ", datafile)
#    polygon(d, col="aquamarine", border="blue")
#    dev.off()
}

# clean up any remaining TMP files
if (file.exists(tmp_offsets)) {
    message(sprintf("Removing tmp file: %s \n ", tmp_offsets))
    file.remove(tmp_offsets)
}

# list the plot files in the directory
plotlist <- list.files(datadir, pattern = '\\.png$', full.names = TRUE,
    recursive = FALSE)
message("Plots available: ")
print(plotlist)

# check to see if any files were found. If not, bail...
if (length(plotlist)==0) {
    message("WARNING: no plot files were found")
}
# END

