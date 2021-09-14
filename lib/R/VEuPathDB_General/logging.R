freadWithLogging <- function(file, select = NULL, na.strings=c('')) {
  .dt <- try(data.table::fread(file, select = select, na.strings = na.strings))

  if (inherits(.dt, 'try-error')) {
    message('\n', Sys.time(), ' Failed reading file: ', file)
    stop(.dt)
  } else {
    message('\n', Sys.time(), ' Successfully finished reading file: ', file)
  }

  return(.dt)
}
