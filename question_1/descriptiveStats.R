install.packages("usethis")
install.packages("here")
library (usethis)
library (here)


getwd()
setwd("~/Desktop/Roche_Tech_Assessment/question_1/descriptiveStats/")

usethis::create_package("~/Desktop/Roche_Tech_Assessment/question_1/descriptiveStats", open = TRUE)

here::dr_here()
