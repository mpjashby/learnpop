# This script installs the learnpop package from GitHub using the `remotes`
# package, installing `remotes` first if necessary

if (!"remotes" %in% rownames(installed.packages())) install.packages("remotes")

remotes::install_github("mpjashby/learnpop")
