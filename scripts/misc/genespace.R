setwd("/mnt/scratch/rittere5/witchs-broom/results/")
.libPaths("/mnt/ufs18/home-080/rittere5/R/library/4.3.1")
library("GENESPACE")
library("rtracklayer")

# -- load in dataset details
grape_datasets <- read.csv("genespace/genespace-data.csv")
no_nas <- grape_datasets[!grape_datasets$Directory_Name=="",]
ids <- no_nas$Directory_Name

# -- change paths to those valid on your system
wd <- "genespace/workingDirectory"
path2mcscanx <- "/mnt/ufs18/home-080/rittere5/programs/MCScanX-master"
#path2orthofinder <- "/home/eleanore_r/programs/OrthoFinder/./"
#path2diamond <- "/home/eleanore_r/programs/OrthoFinder/bin"

# -- initalize the run and QC the inputs
gpar <- init_genespace(
  wd = wd,
  nCores = 8, 
  path2mcscanx = path2mcscanx,
  dotplots = "never")

# -- accomplish the run
out <- run_genespace(gpar)

## -- test plot
ripDat <- plot_riparian(
  gsParam = out, 
  refGenome = "Vvinifera_dakapo", 
  forceRecalcBlocks = FALSE)
