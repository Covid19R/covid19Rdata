FROM rkrispin/r-base-4:latest

LABEL maintainer="Rami Krispin <rami.krispin@gmail.com>"

# installing R packages
RUN mkdir packages
COPY install_packages.R packages/
RUN Rscript packages/install_packages.R


