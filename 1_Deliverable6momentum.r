### recap of this code ###
# - goes through all 10 data sets (all the output-Set#.txt)
# - finds every bacteriumm with one of the IDs we're investigating
# - calculates that momentum with p = sqrt(px^2 + py^2 + pz^2)
# - saves the results in one CSV file per dataset
#----------------------------------------------------------------------#

# settings
idsOfInterest <- c(2212, -2212, 3312, -3312, 3334, -3334) # our bacterial pairs
inputPrefix  <- "output-" # the data files: output-Set1.txt to output-Set10.txt
outputPrefix <- "momenta-" # the actual results: momenta-Set1.csv to momenta-Set10.csv
chunkSize <- 2e6 # the number of lines read at a time (2 million bc the file is so big)

# momentum formula
calculate_momentum <- function(px, py, pz) {
  p <- sqrt(px^2 + py^2 + pz^2)
  return(p)
}

setFiles <- paste0(inputPrefix, "Set", 1:10, ".txt")
outFiles <- paste0(outputPrefix, "Set", 1:10, ".csv")
# 1:10 is a vector so we get 10 names each (going from output-Set1.txt to output-Set10.txt)

# just in case one of the files isn't present
for (f in setFiles) {
  if (!file.exists(f)) { # triggers when a file is missing
    stop("Cant find file: ", f, " - Check its location.") # stops the code and displays that error message
  }
}

# momentum of each respective bacterium
momentumFile <- function(inFile, outFile) { # takes one input file & output file name(s) and processes
  found <- setNames(rep(0, length(idsOfInterest)), idsOfInterest) # counter for how many of each ID found

  # creates output CSV with just a header
  write.table(data.frame(ID = integer(0), p = numeric(0)), outFile,
              sep = ",", row.names = FALSE, col.names = TRUE)
  
  # opens connection to the input file in read mode
  con <- file(inFile, open = "r")
  on.exit(close(con)) # makes sure file is closed when function ends
  readLines(con, n = 1) # skips the header line

  # each pass read ups to 2 million lines as text
  repeat { # loops forever until break
    lines <- readLines(con, n = chunkSize)
    if (length(lines) == 0) break

    # splits every line into its 4 columns: px, py, pz, particle_id
    fields <- scan(text = lines, what = list("", "", "", ""),
                   fill = TRUE, flush = TRUE, quiet = TRUE,
                   quote = "", comment.char = "")

    # takes column 4 and converts text to numbers
    id <- suppressWarnings(as.numeric(fields[[4]]))
    keep <- !is.na(id) & id %in% idsOfInterest   # only the IDs we want
    # "keep" to filter the rows, then converts to numbers
    px <- suppressWarnings(as.numeric(fields[[1]][keep]))
    py <- suppressWarnings(as.numeric(fields[[2]][keep]))
    pz <- suppressWarnings(as.numeric(fields[[3]][keep]))
    id <- id[keep]

    # flags rows where all 3 momentum components are valid numbers as to drop malformed lines
    ok <- !is.na(px) & !is.na(py) & !is.na(pz)

    # builds a table of the good rows (ID & momentum)
    result <- data.frame(ID = id[ok],
                         p = round(calculate_momentum(px[ok], py[ok], pz[ok]), 6))

    # adds this chunk to the CSV
    write.table(result, outFile, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE) # append = TRUE adds to the end (instead of overwriting) and col.name = FALSE avoids repeating the header
    found <- found + as.numeric(table(factor(result$ID, levels = idsOfInterest))) # updates the counters and makes sure all four IDs are counted
  }
  return(found) # closes the loop
}

cat("Please wait, reading all 10 files...\n")

foundPerSet <- matrix(0, nrow = length(setFiles), ncol = length(idsOfInterest), dimnames = list(paste0("Set", 1:10), idsOfInterest)) # 10 x 4 matrix of zeros (rows = Set 1 - 10, and columns named by ID)

# for each i, prints progress + runs momentumFile on the "i"th input/output file + stores returned 4 counts in row i
for (i in seq_along(setFiles)) {
  cat("Reading", setFiles[i], "->", outFiles[i], "\n")
  foundPerSet[i, ] <- momentumFile(setFiles[i], outFiles[i])
}

# prints the per-dataset count table, and colSums adds up each column to give total per ID across the 10 sets
cat("\nNumber of bacteria found per dataset (compare with Week 4):\n")
print(foundPerSet)
cat("\nTotal over all datasets:\n")
print(colSums(foundPerSet))
cat("\nMomentum files written:", paste(outFiles, collapse = ", "), "\n")