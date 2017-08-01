# TrendyServer


Run Trendy through Shiny app. on servers.

Required packages: Trendy and EBSeq 

To download:

library(devtools)

install_github("rhondabacher/Trendy/package/Trendy")


source("https://bioconductor.org/biocLite.R")

biocLite("EBSeq")




## To launch this Shiny app:

runGitHub('rhondabacher/TrendyServer')