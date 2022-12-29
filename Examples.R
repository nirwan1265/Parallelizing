#Loading example data
data("penguins")


#Simple for loops
a <- Sys.time()
x <- vector()
for(i in 1:10000){
  x[i] <- sqrt(i)
}
x
b <- Sys.time()
time = b - a
time

#For each 
x <- foreach(i = 1:10) %do% {
  sqrt(i)
}
x
#use .combine to arrange as vector. cbind and rbind too
x <- foreach(
  i = 1:10,
  .combine = 'c'
) %do% {
  sqrt(i)
}
x

#supports several iterators of the same length at once. 
x <- foreach(
  i = 1:3,
  j = 1:3,
  k = 1:3,
  .combine = 'c'
) %do% {
  i + j + k
}
x

# Running foreach loops in parallel
#The foreach loops shown above use the operator %do%, that processes the tasks sequentially. To run tasks in parallel, foreach uses the operator %dopar%, that has to be supported by a parallel backend. If there is no parallel backend, %dopar% warns the user that it is being run sequentially, as shown below. But what the heck is a parallel backend?
x <- foreach(
  i = 1:10,
  .combine = 'c'
) %dopar% {
  sqrt(i)
}
x

# Parallel backend 
# When running tasks in parallel, there should be a director node that tells a group of workers what to do with a given set of data and functions. 
# the workers exectute the iterations, and the director manages execution and gathers the results provided by the workers
# A parallel backedn proves the means for the director and workers to communicate, while allocating and managing the required computing resources(processors, RAM memory, and network bandwidth among others)
# Two types of parallel backednds that can be used with foreach, FORK and PSOCK

# FORK
# FORK backends are only available on UNIX machines(Linux, Mac) and do not work in clisters. 
# So only single machine environments are approproate for this backend. 
# In a FORK backend, the workers share the same environment (data, loaded packages, and functions) as the director
# Efficient, because the main environment doesn't have to be copied, and only worker ouputs need to be sent back to the director. 

#PSOCK
# PSOCK backends (Parallel Socket Cluster) are available for both UNIX and WINDOWS systems, and are default option for foreach
# Disadvantage: the environment of the director needs to be copied to the environment of each worker, which increases network overhead while decreasing the overall efficiency of the cluster
# By default, all the functions in base R are copied to each worker, and if a particular set of R packages needed in the workers, they need to be copoed to the respective environments of the workers as well. 

# Fork is about 40% faster than PSOCK.


#Setup of parallel backend

#setup for a single computer
#Finding cores 
#Recommended to leave one free core for other tasks
parallel::detectCores()

n.cores <- parallel::detectCores() -1

# Define cluster the cluster with parallel::makeCluster() and register it so it can be used by %dopar% with doParallel::registerDoParallel(my.cluster). The type argument of parallel::makeCluster() accepts the strings “PSOCK” and “FORK” to define the type of parallel backend to be used.

#Create the cluster
my.cluster <- parallel::makeCluster(
  n.cores,
  type = "FORK"
)
#check cluster definition
print(my.cluster)

#Register it to be used by %dopar%
doParallel::registerDoParallel(cl = my.cluster)

#Check for registration
foreach::getDoParRegistered()


#How many workers available 
foreach::getDoParWorkers()


#Compare
a <- Sys.time()
x <- vector()
for(i in 1:10000){
  x[i] <- sqrt(i) + i^2 + i * i
}
x
b <- Sys.time()
time = b - a
time


#Run a set of tasks in parallel
a <- Sys.time()
x <- foreach(
  i = 1:10000,
  .combine = 'c'
) %dopar%{
  i+j
}
b <- Sys.time()
time = b - a
time
# No error

#Nested loops

#Loop
a <- Sys.time()
x <- matrix(0, nrow = 1000, ncol = 1000)
for(i in 1:1000){
  for(j in 1:1000){
    x[i,j] <- i+j * i * j + 1/100 + j * 8976 + i - j
  }
}
x
b <- Sys.time()
time = b - a
time

#For each
a <- Sys.time()
x <- vector()
x <- foreach(i = 1:10, .combine = 'cbind') %dopar%
  foreach(j = 1:10, .combine = 'c') %do% {
    x[i,j] <- sqrt(i) + i^2 + i * j
  }
b <- Sys.time()
time = b - a
time
x


a <- Sys.time()
x <- vector()
x <- foreach(i=1:1000, .combine='rbind') %do% {
  foreach(j=1:1000, .combine='c') %dopar% {
    i+j * i * j + 1/100 + j * 8976 + i - j
  }
}
b <- Sys.time()
time = b - a
time
x

# Recommended to stop the cluster 
parallel::stopCluster(cl = my.cluster)
