## this script can be used to plot co-ancestry matrix, population wise, you can use the row count data file
## Prepared by Shailesh Desai, BHU. 

setwd("C:/Users/shail/OneDrive/Documents/Analysis/RScript/")
library(readr)  # if not installed, install first
library(readxl)
library(tidyverse)
list.files()

X<- read.table("example_linked.chunkcounts.out_Modified", sep = "\t", skip = 1, header = TRUE)

dim(X) ## both dimension should not be same here, as first row, first column is receipt tag
head(X[, 1:6])  # this might make more sense now 
## lets explore the data

dim(X)

class(X)

str(X[, 1:5])

## lets built the matrix first

recipients<- X$Recipient
M<- as.matrix(X[, -1]) ## remove the first column

rownames(M)<- recipients

dim(M) ## now this should be the same, contrary to above one

all(rownames(M) == colnames(M)) ## if true, you are excellent to go ahead

## now we have matrix, but we need population level matrix, hence need to filter bit more

pop <- sub("_.*", "", rownames(M))

head(pop, 3)

## population level summary
table(pop)
pops <- unique(pop)
## matrix frame for downstream work

P <- matrix(
  NA,
  nrow = length(pops),
  ncol = length(pops)
)

rownames(P)<- pops
colnames(P)<- pops

head(P, 3)
dim(P)  # should be equal


## THE HORSE

P <- matrix(
  NA,
  nrow = length(pops),
  ncol = length(pops),
  dimnames = list(pops, pops)
)

for (i in seq_along(pops)) {
  
  for (j in seq_along(pops)) {
    
    # Identify recipient individuals
    rec_ind <- which(pop == pops[i])
    
    # Identify donor individuals
    don_ind <- which(pop == pops[j])
    
    # Extract the chunk-count block
    block <- M[rec_ind, don_ind, drop = FALSE]
    
    # Exclude self-comparisons within the same population
    if (i == j) {
      diag(block) <- NA
    }
    
    # Calculate average chunk sharing
    P[i, j] <- mean(block, na.rm = TRUE)
    
  }
}


dim(P)

round(P[1:5, 1:5], 2)

summary(as.vector(P))

# final population level matrix average sharing is ready

## Our target as donor now
View(P)

PP <- data.frame(P)
Donor_to_recipient <- as.matrix(
  PP %>%
    select(Kota1, Kota2, Toda, Kurumba1, Kurumba2)
)

heatmap(
  Donor_to_recipient,
  margins = c(1, 1),
  main = "Population-level Co-ancestry Matrix"
)


pdf("Population_Coancestry_Heatmap_Donor.pdf",
    width = 14,
    height = 15)

heatmap(
  Donor_to_recipient,
  Rowv = TRUE,
  Colv = TRUE,
  scale = "row",
  margins = c(15, 15),
  cexRow = 0.55,
  cexCol = 0.8,
  labRow = rownames(Donor_to_recipient),
  labCol = colnames(Donor_to_recipient),
  main = "Population-level Co-ancestry Matrix, where target as Donor"
)

dev.off()


## its time to switch them 

Recipient_to_donor <- as.matrix (PP %>%
  filter(row.names(PP) %in% c("Kota1", "Kota2", "Toda", "Kurumba1", "Kurumba2")))


pdf("Population_Coancestry_Heatmap_Recipient.pdf",
    width = 14,
    height = 15)

heatmap(
  Recipient_to_donor,
  Rowv = TRUE,
  Colv = TRUE,
  scale = "col",
  margins = c(15, 15),
  cexRow = 0.8,
  cexCol = 0.55,
  labRow = rownames(Recipient_to_donor),
  labCol = colnames(Recipient_to_donor),
  main = "Population-level Co-ancestry Matrix, where target as Recipient"
)

dev.off()