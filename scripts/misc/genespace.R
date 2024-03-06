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

# -- plot for publication

load('genespace/workingDirectory/results/gsParams.rda',
     verbose = TRUE)

chr.assemblies <- c("Vvinifera_dakapo", 
                    "Vvinifera_rubired_hap1",
                    "Vvinifera_rubired_hap2",
                    "Vvinifera_cabernetfranc",
                    "Vvinifera_cabernetsauvignon",
                    "Vvinifera_pinotnoir",
                    "Vvinifera_chardonnay")

ggthemes <- ggplot2::theme(
  panel.background = ggplot2::element_rect(fill = "white"))

customPal <- colorRampPalette(
  c("darkorange", "skyblue", "darkblue", "purple", "darkred", "salmon"))

ripDat <- plot_riparian(
  gsParam = gsParam, 
  refGenome = "Vvinifera_dakapo", 
  forceRecalcBlocks = FALSE,
  genomeIDs = chr.assemblies,
  minChrLen2plot = 500,
  chrFill = "lightgrey",
  addThemes = ggthemes,
  palette = customPal,
  braidAlpha = 0.75,
  chrLabFun = function(x) gsub("^0", "", gsub("chr|scaf|chromosome|scaffold|^lg|_|vitvixrubiredfps02_v1\\.0\\.hap1\\.|vitvixrubiredfps02_v1\\.0\\.hap2\\.|vitvvi_vcabfran04_v1\\.1\\.hap1\\.|vitvvi_vcabsauv08_v1\\.1\\.hap1\\.|vitvvi_vpinnoir123_v1\\.0\\.hap1\\.|vvchar04_v1_gcs", "", tolower(x))))
p1 <- ripDat$plotData$ggplotObj
p2 <- p1 + 
  scale_y_discrete(limits = c("Dakapo", "Rubired Haplotype 1", "Rubired Haplotype 2", "Cabernet Franc", "Cabernet Sauvignon", "Pinot Noir", "Chardonnay"))+
  theme(axis.text.y = element_text(size = 10), axis.title.y = element_blank())
p2