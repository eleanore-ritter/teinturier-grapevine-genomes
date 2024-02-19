#setwd("C:/Users/rittere5/OneDrive - Michigan State University/Dakapo_Genome/") #Work working directory
setwd("C:/Users/elean/OneDrive - Michigan State University/Dakapo_Genome/")

library(biomaRt)
library(dplyr)
library(ggplot2)

########################## PLOT INVERSION ##########################
# NOT USING FOR NOW!

# # Load data
# hap1.coords <- read.csv("hap1_chr10.coords", skip=4, sep = "\t", header=FALSE)
# colnames(hap1.coords) <- c("S1", "E1", "S2", "E2", "LEN_1", "LEN_2", "PERCENT_ID", "TAGS1", "TAGS2")
# 
# # Extract coordinates and set up dataframe
# dak1 <- hap1.coords[,1:2]
# colnames(dak1) <- c("X","Y")
# dak1$genome <- c("Dakapo")
# 
# hap1 <- hap1.coords[,4:3]
# colnames(hap1) <- c("X","Y")
# hap1$genome <- c("Rubired haplotype 1")
# 
# coords1 <- rbind(dak1,hap1)
# ggplot(coords1, aes(x = X, y = Y, color = genome)) +
#   geom_point()
# 
# coords1 <- hap1.coords[,c("E1","E2")]
# ggplot(coords1, aes(x = E1, y = E2)) +
#   geom_point()

########################## FUNCTION OF GENES IN INVERSION ##########################
# Load data
dak.ath <- read.csv("Dakapo-Athaliana.tsv", header = FALSE, sep = "\t")
hap1.genes <- read.csv("chr10-inv-hap1.gene_list.txt", header = FALSE)
hap2.genes <- read.csv("chr10-inv-hap2.gene_list.txt", header = FALSE)


#Add in Arabidopsis orthologs
data1 <- merge(hap1.genes, dak.ath, by = "V1", all.x = TRUE)
data2 <- merge(hap2.genes, dak.ath, by = "V1", all.x = TRUE)

#Get TAIR IDs for hap1
atha.genes1 <- data1$V2
atha.genes1 <- na.omit(atha.genes1)

ensembl_plants = useMart(biomart="plants_mart", host = "plants.ensembl.org")

datasets <- listDatasets(ensembl_plants)
ensembl = useDataset("athaliana_eg_gene", ensembl_plants)

results1 <- getBM(attributes=c('ensembl_gene_id','tair_symbol', 'description', 'name_1006', 'tair_locus_model'),
                  filters = 'tair_locus_model',           
                  values = atha.genes1, 
                  mart = ensembl,
                  uniqueRows = TRUE)
results1A <- results1[!duplicated(results1$ensembl_gene_id), ] # Remove duplicates

data1A <- merge(data1,results1A, by.x = "V2", by.y = "tair_locus_model", all.x = TRUE)

#Get TAIR IDs for hap2
atha.genes2 <- data2$V2
atha.genes2 <- na.omit(atha.genes2)

ensembl_plants = useMart(biomart="plants_mart", host = "plants.ensembl.org")

datasets <- listDatasets(ensembl_plants)
ensembl = useDataset("athaliana_eg_gene", ensembl_plants)

results2 <- getBM(attributes=c('ensembl_gene_id','tair_symbol', 'description', 'name_1006', 'tair_locus_model'),
                  filters = 'tair_locus_model',           
                  values = atha.genes2, 
                  mart = ensembl,
                  uniqueRows = TRUE)
results2A <- results2[!duplicated(results2$ensembl_gene_id), ] # Remove duplicates

data2A <- merge(data2,results2A, by.x = "V2", by.y = "tair_locus_model", all.x = TRUE)
