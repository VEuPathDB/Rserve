## General helper functions


# Write data table to tab
  # writeDT <- function(dt, pattern=NULL) {
  #   outFileName <- basename(tempfile(pattern = pattern, tmpdir = tempdir(), fileext = ".tab"))
  #   fwrite(dt, outFileName)

  #   return(outFileName)
  # }


# Write compute metadata to json ()
#   writeMetaData <- function(metaData, pattern) {
#     outJson <- jsonlite::toJSON(metaData)
#     if (is.null(pattern)) { 
#       pattern <- 'metadata'
#     }
#     outFileName <- basename(tempfile(pattern = pattern, tmpdir = tempdir(), fileext = ".json"))
#     write(outJson, outFileName)
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
  