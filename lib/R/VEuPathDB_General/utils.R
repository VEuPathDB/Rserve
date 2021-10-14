## General helper functions


# Write a list to json file
writeListToJson <- function(jsonList, pattern = NULL, dir = NULL, verbose = c(TRUE, FALSE)) {
    verbose <- matchArg(verbose)

    if (is.null(pattern)) pattern <- 'file'
    if (is.null(dir)) dir <- tempdir()

    outJson <- jsonlite::toJSON(jsonList)
    outFileName <- basename(tempfile(pattern = pattern, tmpdir = dir, fileext = ".json"))
    write(outJson, outFileName)
    plot.data::logWithTime(paste('New json file written:', outFileName), verbose)

    return(outFileName)
}
