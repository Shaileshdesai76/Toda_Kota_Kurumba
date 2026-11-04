### This is script for plotting the data for PCA (Principal component Analysis)

## Prepared By Shailesh Desai, BHU, India

## i have made single excel sheet which contain two sheet, first contain pop, Ind Id and PCA (1-10) data
## second sheet contian Continent/Region/language, Pop and Ind Id. we will merge by Ind ID here

setwd("C:/Users/shail/OneDrive/Documents/Analysis/RScript/")
library(readr)  # if not installed, install first
library(readxl)
Data1<- read_excel("PCA_Data.xlsx", sheet = 1)
Data2<- read_excel("PCA_Data.xlsx", sheet = 2)
head(Data1)
head(Data2)

# lets check if all Individual are covered in both list or not

unmatched<- Data1[!Data1$`INDIVIDUAL ID` %in% Data2$`INDIVIDUAL ID`, ]
head(unmatched) ## this confirm that we do not have any ID which is not covered by both data
nrow(unmatched) ## it should be zeroooooooo!

## its time to merge data, my favorite step

Data<- merge(Data1, Data2, by= "INDIVIDUAL ID")
head(Data)

library(ggplot2)

data(Data)
plot(Data$PC1, Data$PC2, main = "Principal component Analysis",
     xlab= "PCA 1", ylab = "PCA 2")

#lets use ggplot now

p<- ggplot(Data, aes(x = PC1, y= PC2)) + 
  geom_point(aes(colour = factor(GROUP))) + 
  labs(colour = "Population") +
  
  theme_classic() 
  
  scale_colour_manual(values = c(
    "Toda" = "red",
    "Kota1" = "blue",
    "Kota2" = "darkblue",
    "Kurumba1" = "green",
    "Kurumba2" = "darkgreen"
  )) +
  scale_shape_manual(values = c(
    "Toda" = 16,
    "Kota1" = 17,
    "Kota2" = 15,
    "Kurumba1" = 18,
    "Kurumba2" = 8
  )) 



ggsave("PCA_plot_colour.tiff", plot = p,
       width = 8, height = 6, units = "in",
       dpi = 300, compression = "lzw")

ggsave("PCA_plot_colour.pdf", plot = p,
       width = 8, height = 6, units = "in")

ggsave("PCA_plot_colour.png", plot = p,
       width = 8, height = 6, units = "in",
       dpi = 300)
