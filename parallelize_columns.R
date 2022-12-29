library(tictoc)

# Create a parallel cluster with 4 or total core - 1 cores
cluster <- makeCluster(4)
cluster <- parallel::detectCores() -1
registerDoParallel(cluster)


# Define the function to apply to each column
process_column <- function(x) {
  # Perform some operation on the column
  result <- mean(x)
  return(result)
}

# Create a data frame with 10 columns and 1000 rows
df <- data.frame(matrix(rnorm(100000), nrow = 100000, ncol = 50))


tic()

# Use foreach to apply the function to each column in parallel
results <- foreach(i = 1:ncol(df), .combine = c) %dopar% {
  process_column(df[, i])
}

toc()


results

# Stop the parallel cluster
stopCluster(cluster)
