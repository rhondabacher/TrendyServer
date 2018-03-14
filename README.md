# TrendyServer


Run Trendy through Shiny app. on servers.

Required packages: Trendy and EBSeq 

To download:

library(devtools)

install_github("rhondabacher/Trendy/package/Trendy")


source("https://bioconductor.org/biocLite.R")

biocLite("EBSeq")




## To launch this Shiny app:

library(shiny)

runGitHub('rhondabacher/TrendyServer')

## Last update was 3-14-2018
### This is compatible with Trendy versions > v0.99.0
##### Otherwise, download the previous verion of this under the Release page, unzip the package, then access by typing:
library(shiny)
runApp("pathToOlderVersionOfTrendyServer/TrendyServer")