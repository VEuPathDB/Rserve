## General helper functions


  # Write to file - will need to be a helper function
  # writeDT <- function(dt, pattern=NULL, verbose=c(TRUE, FALSE)) {
  #   outFileName <- basename(tempfile(pattern = pattern, tmpdir = tempdir(), fileext = ".tab"))
  #   data.table::fwrite(dt, outFileName)

  #   plot.data::logWithTime(paste('New computation file written:', outFileName), verbose)
  #   return(outFileName)
  # }


  # Write to json ()
#   writeMetaData <- function(metaData, pattern, verbose) {
#     outJson <- jsonlite::toJSON(metaData)
#     if (is.null(pattern)) { 
#       pattern <- 'metadata'
#     }
#     outFileName <- basename(tempfile(pattern = pattern, tmpdir = tempdir(), fileext = ".json"))
#     write(outJson, outFileName)
#     plot.data::logWithTime(paste('New metadata file written:', outFileName), verbose)
#   }

# Parsing args? Each app will have it's own list of args. Args come in via string or some other weirdness sometimes.
# May become something else later, but at least this can serve as a reminder.
  # Current compute config to parse?
  # ComputeConfig:
  #       type: object
  #       additionalProperties: false
  #       properties:
  #         name: string
  #         parameters:
  #           required: false
  #           type: string[]
  