# Copyright 2016 Opening Reproducible Research (http://o2r.info)

#' An S4 class to represent a RUN instruction in shell form
#' @include Class-Instruction.R
#' 
#' See official documentation at \url{https://docs.docker.com/engine/reference/builder/#run}.
#'
#' @slot commands  One or more commands to be included in the label
#' @family instruction classes
#' @family Run instruction
#'
#' @return object of class Run
#' @export
setClass("Run_shell",
         slots = list(commands = "character"), contains = "Instruction")


.arguments.Run_shell <- function(obj) {
  # create arcuments in exec form, i.e.
  # ["executable","param1","param2"]
  # or ["param1","param2"] (for CMD as default parameters to ENTRYPOINT)
  
  commands <- slot(obj, "commands")
  string <- paste(commands, collapse = " \\\n && ") 
  return(string)
}

setMethod("docker_arguments",
          signature(obj = "Run_shell"),
          .arguments.Run_shell #uses the same function as Cmd for now
)

setMethod(
  "docker_key",
  signature = signature(obj = "Run_shell"),
  definition =
    function(obj) {
      return("RUN")
    }
)

setValidity("Run_shell",
            method = function(object) {
              commands <- slot(object, "commands")
              
              if(is.na(commands) || length(commands) == 0 || any(stringr::str_length(commands) == 0))
                return(paste("Commands must have at least one string and empty strings are not alowed. Given was: \n\t", paste(commands,collapse = "\n\t")))
              else  
                return(TRUE)
            }
)

#' Create objects representing a RUN instruction in shell form
#'
#' @param commands character vector of commands (will be concatenated with && and linebreaks)
#' @family Run instruction
#' @return An S4 object of class Run_shell
#' @export
Run_shell <- function(commands){
  new("Run_shell",  commands = commands)
}


#' An S4 class to represent a RUN instruction
#' @include Class-Instruction.R
#' 
#' See official documentation at \url{https://docs.docker.com/engine/reference/builder/#run}.
#'
#' @slot exec character. 
#' @slot params character.
#' @family instruction classes
#' @family Run instruction
#' @return object of class Run
#' @export
setClass("Run",
         slots = list(exec = "character",
                      params = "character"), contains = "Instruction")

#' Create objects representing a RUN instruction
#'
#' @param exec character argument naming the executable
#' @param params paramterer arguments
#' @family Run instruction
#' @return An S4 object of class Run
#' @export
Run <- function(exec, params = NA_character_){
  new("Run",  exec = exec, params = params)
}

setMethod("docker_arguments",
          signature(obj = "Run"),
          .arguments.Cmd_Run #uses the same function as Cmd for now
)

setValidity("Run",
            method = function(object) {
              exec <- slot(object, "exec")
              params <- slot(object, "params")
              
              if (is.na(exec) || stringr::str_length(exec) == 0)
                return(paste("Exec must be a non-empty string, given was: ", exec))
              else
                if (length(params) == 1 && is.na(params))
                  return(TRUE)
              else
                if ( (length(params) > 1 && any(is.na(params))) ||
                   any(stringr::str_length(params) == 0))
                  return("If parameters are given for RUN (optional), they cannot be empty strings or NA")
              else
                return(TRUE)
            }
)