FROM docker.io/rocker/tidyverse:4.4.3 as environment
RUN apt update && apt -y install basex=10.5-1 && apt -y install pandoc && apt -y install curl && rm -rf /var/lib/apt/lists/*
RUN install2.r --error lubridate ggplot2 rmarkdown stringr RCurl tinytex
FROM environment
COPY *.R /
COPY *.Rmd /
COPY Queries /Queries
COPY Referenzdaten /Referenzdaten
ENTRYPOINT ["Rscript", "Framework.R"]