# covid19R_data

To update with a new package

1. Add the package to `data/packages.csv'  
2. Add package dependencies to `.github/workflows/data_refresh.yml` in the `Install dependencies` part.  
3. Add the package installation to `R/cron_job_dependencies.R`  
4. Run the `R/acquire_data.R` and make sure it works.  
5. Commit, push, and make sure the github action works.  
