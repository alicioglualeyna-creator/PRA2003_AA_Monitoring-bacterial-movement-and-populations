# PRA2003 - Week 3 deliverable

# For this assignment, I chose the file called "output-Set1.txt" which contains data on 12 bacterial strains.
# How to run: make sure to have the file "output-Set1.txt" in the same folder as this script, so it can run.

# Events that have 0 particles (e.g. "19 0") are the failed experiments and are not counted as events.

# For each strain:
  # Average per event = total count / number of events
  # Uncertainty = sqrt(total count) / number of events
  # (a count N has a Poisson uncertainty of sqrt(N); dividing by the number of 
  # events gives the uncertainty on the average per event)


# SETTINGS

# defaultFile will store the name of the input file 
# If you don't give R another filename then it will use this one when running the script
defaultFile <- "output-Set1.txt" 
chunkSize <- 1000000 # Because the input file is very large, 1,000,000 lines will be read at a time
fieldSep <- " " # separator between the fields of a line
headerFields <- 2 # header has two values: eventNumber nParticles
dataFields <- 4 # data line has 4 values: px py pz bacterialID
inputPrefix <- "output-" # input "output-<name>.txt" gives ...
outputPrefix <- "results-" # ... output "results-<name>.csv"
outputExtension <- ".csv"
averageDigits <- 5 # average per event will be rounded to 5 decimal places
uncertaintySignifDigits <- 3 # uncertainity will be shown as 3 significant figures

# STRAIN DEFINITIONS

# Strain IDS of interest 
# The IDs are the last column of the data lines
# Vector contains 12 strain IDs with positive and negative values 
strainID <- c(211, -211, 321, -321, 2212, -2212, 3122, -3122, 3312, -3312, 3334, -3334)

# Names of the strains which are in the same order as the IDs above
# The ID will be matched with the correct strain name 
strainName <- c(
"E. coli WT",
"E. coli mutant",
"Bacillus subtilis WT",
"Bacillus subtilis mutant",
"Pseudomonas aeruginosa WT",
"Pseudomonas aeruginosa antibiotic-resistant",
"Streptococcus pneumoniae",
"Capsule-deficient S. pneumoniae",
"Mycobacterium tuberculosis",
"Drug-resistant M. tuberculosis",
"Salmonella enterica",
"Salmonella mutant"
)

# length() returns the number of bacterial strains in the strainID vector
# This number is 12
nStrains <- length(strainID)

# CHECK SETTINGS  
# A wrong value here would give wrong results without any error, so check it now.

# Checks whether something is a valid whole number 
isWholeNumber <- function(x, minimum) {
is.numeric(x) && length(x) == 1 && !is.na(x) && x >= minimum && x == round(x)
}

# Checks whether something is a valid text value
isText <- function(x) {
is.character(x) && length(x) == 1 && !is.na(x) && nzchar(x)
}

# Checks whether chunk size is a valid whole number 
if (!isWholeNumber(chunkSize, 1)) {
stop("Setting chunkSize must be a whole number of at least 1, not: ", chunkSize)
}

if (!isWholeNumber(headerFields, 1) || !isWholeNumber(dataFields, 1) ||
headerFields == dataFields) {
stop("Settings headerFields and dataFields must be whole numbers and different from ",
"each other (that is how header and data lines are told apart).")
}

if (!isText(fieldSep) || nchar(fieldSep) != 1) {
stop("Setting fieldSep must be a single character.")
}

if (!isWholeNumber(averageDigits, 0) ||
!isWholeNumber(uncertaintySignifDigits, 1)) {
stop("Settings averageDigits and uncertaintySignifDigits must be whole numbers.")
}

if (!isText(defaultFile) || !isText(outputPrefix) || !isText(outputExtension)) {
stop("Setting defaultFile, outputPrefix and outputExtension must be text.")
}

if (length(strainName) != nStrains) {
stop("strainID has ", nStrains, " values but strainName has ", length(strainName), ".")
}

if (anyNA(strainID) || anyDuplicated(strainID) > 0) {
stop("strainID must not contain missing or duplicate values.")
}

# REGULAR EXPRESSIONS

# This function builds a pattern for identifying lines with a specific number of fields 
lineRegex <- function(nFields) {
notSep <- paste0("[^", fieldSep, "]")
paste0("^", notSep, "+(", fieldSep, notSep, "+){", nFields - 1, "}$")
}

# Pattern for a header line
headerRegex <- lineRegex(headerFields)

# Pattern for a data line
dataRegex <- lineRegex(dataFields)

# Pattern used to remove everything up to the last field of a line 
lastFieldRegex <- paste0("^.*", fieldSep)

# FUNCTION TO PROCESS ONE CHUNK

# Function processes one chunk of lines from the input file 
processChunk <- function(chunk) {
chunk <- sub("\r$", "", chunk, perl = TRUE) # handle Windows line endings
chunk <- chunk[nzchar(chunk)] # skip empty lines

# A line is a header, a data line, or malformed (any other number of fields)

# Creates TRUE/FALSE values for the headers
isHeader <- grepl(headerRegex, chunk, perl = TRUE)
isData <- !isHeader & grepl(dataRegex, chunk, perl = TRUE)

# Only the last field of each line is needed: the number of particles for a
# header line and the bacterial ID for a data line. Skipping px, py and pz is
# much faster than splitting every line into fields.

lastField <- sub(lastFieldRegex, "", chunk, perl = TRUE)

# HEADER INFO

# The last field from all headers will be converted to a number 
nParticlesInEvent <- suppressWarnings(as.numeric(lastField[isHeader]))

# Identifies the headers that are malformed: missing, negative, or not a whole number
badHeader <- is.na(nParticlesInEvent) | nParticlesInEvent < 0 |
nParticlesInEvent != round(nParticlesInEvent)

# Invalid particle numbers are removed, so they will not be included in the calculations 
nParticlesInEvent <- nParticlesInEvent[!badHeader]

# DATA INFO

# The last field from all data lines will be converted to a number
# In this case, it will give the bacterial IDs 
ids <- suppressWarnings(as.numeric(lastField[isData]))

# Identify the data lines that were not converted into numbers 
badId <- is.na(ids)

# Removes invalid IDs from the list
ids <- ids[!badId]

# Matches the IDs to the name of the bacterial strains 
row <- match(ids, strainID) # position in strainID, NA if not one of the strains
known <- !is.na(row)

# Return all information collected from this chunk 
list(
nEvents = sum(nParticlesInEvent > 0),
counts = tabulate(row[known], nbins = nStrains),
nOther = sum(!known),
nMalformed = sum(!isHeader & !isData) + sum(badHeader) + sum(badId),
nDeclared = sum(nParticlesInEvent),
nData = length(ids)
)
}

# CHECK INPUT FILE 

args <- commandArgs(trailingOnly = TRUE)

# Only one input file is allowed
if (length(args) > 1) {
stop(
"Give at most one argument (the input file), but got ", length(args), ": ",
paste(args, collapse = " ")
)
}

# If another file is given then R will use it
# If not, R will use the default file name that was named in the settings above
filepath <- if (length(args) == 1) args[1] else defaultFile

if (!isText(filepath)) {
stop("The input file name is empty.")
}

if (!file.exists(filepath)) {
stop("File not found: ", filepath, " - put it in the same folder as this script.")
}

if (dir.exists(filepath)) {
stop(filepath, " is a folder, not a file.")
}

if (file.access(filepath, mode = 4) != 0) {
stop("No permission to read: ", filepath)
}

if (is.na(file.size(filepath)) || file.size(filepath) == 0) {
stop("The file is empty: ", filepath)
}

# SELF-TEST 

# New ID is created that is not in the strainID vector
unknownID <- max(abs(strainID)) + 1

# Small test dataset is to test the processChunk function
testLines <- c(
"1 4",
paste("0 0 1", strainID[1]),
paste("0 0 3", strainID[1]),
paste("3 4 12", strainID[2]),
paste("0 0 1", unknownID),
"2 0",
"",
"1 2 3",
"0 0 1 abc"
)

# Run
test <- processChunk(testLines)

# stopifnot() will stop the script if one of the checks fails 
stopifnot(
test$nEvents == 1, # the empty event is not counted
test$counts[1] == 2, # strain 1
test$counts[2] == 1, # strain 2
sum(test$counts) == 3,
test$nOther == 1,
test$nMalformed == 2,
test$nDeclared == 4,
test$nData == 4
)

# READ FILE IN CHUNKS 

# Counters start at 0
# Updates as each chunk is processed
totalCount <- rep(0, nStrains) # count per strain
nEvents <- 0 # events with at least one particle
nOther <- 0 # particles with an ID outside the strains
nDeclared <- 0 # particles announced by the header lines
nData <- 0 # valid data lines found
nMalformed <- 0 # lines that are not a valid header or data line
linesRead <- 0 # lines read so far (used in error messages)

con <- file(filepath, "r")

# tryCatch() allows the script to continue running even if an error occurs
tryCatch({
repeat {
chunk <- readLines(con, n = chunkSize)

if (length(chunk) == 0) {
  break
}

result <- processChunk(chunk)

totalCount <- totalCount + result$counts
nEvents    <- nEvents + result$nEvents
nOther     <- nOther + result$nOther
nMalformed <- nMalformed + result$nMalformed
nDeclared  <- nDeclared + result$nDeclared
nData      <- nData + result$nData
linesRead  <- linesRead + length(chunk)

}
}, error = function(e) {
stop(
"Reading ", filepath, " failed after about ", linesRead, " lines: ",
conditionMessage(e),
call. = FALSE
)
}, finally = close(con))

if (nEvents == 0) {
stop("No events found in file - check the file path/format.")
}

if (sum(totalCount) == 0) {
stop("None of the ", nStrains, " strain IDs occur in the file - check the file format.")
}

if (nMalformed > 0) {
warning(
nMalformed, " lines were not a valid header (", headerFields, " fields) or ",
"data line (", dataFields, " fields with a numeric ID) and were ignored"
)
}

if (nDeclared != nData) {
warning("Headers announce ", nDeclared, " particles but ", nData, " were found")
}

# COMPUTE STATISTICS

# Calculates the average number of particles per event for each strain
avgPerEvent <- totalCount / nEvents

# Calculates the Poisson uncertainty 
# Divides it by the number of events
uncertainty <- sqrt(totalCount) / nEvents

# Create a table 
results <- data.frame(
ID = strainID,
Strain = strainName,
TotalCount = totalCount,
AveragePerEvent = round(avgPerEvent, averageDigits),
Uncertainty = signif(
uncertainty,
uncertaintySignifDigits
) # significant digits: the smallest values are tiny
)

# OUTPUT

# Print 
cat("Total events processed:", nEvents, "\n")
cat("Particles with an ID outside the", nStrains, "strains (ignored):", nOther, "\n")
cat("Lines that were not valid (ignored):", nMalformed, "\n\n")
print(results)

# Name the output after the input: "output-Set1.txt" gives "results-Set1.csv"

inputName <- tools::file_path_sans_ext(basename(filepath))

if (startsWith(inputName, inputPrefix)) {
inputName <- substring(inputName, nchar(inputPrefix) + 1)
}

# Combines outputPrefix, inputName, and file extension 
outFile <- paste0(outputPrefix, inputName, outputExtension)

# Will save the results to a CSV file 
tryCatch(
write.csv(results, file = outFile, row.names = FALSE),

# If CSV fails to be created, an error will be given explaining the reason why it failed 
error = function(e) {
stop(
"Could not write ", outFile, ": ", conditionMessage(e),
call. = FALSE
)
}
)

cat("\nResults written to", outFile, "\n")