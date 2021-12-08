# This script installs the learnpop package from GitHub using the `remotes`
# package, installing `remotes` first if necessary

if (!"remotes" %in% rownames(installed.packages())) install.packages("remotes")

remotes::install_github(
  repo = "mpjashby/learnpop",
  # Upgrade all dependencies that are not the latest version
  upgrade = "always"
)

if ("learnpop" %in% installed.packages()) {

  library(learnpop)

} else {

  stop("There was an error while installing the necessary packages. PLEASE ASK FOR HELP.")

}


