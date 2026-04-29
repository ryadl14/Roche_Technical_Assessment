#'Calculate the mean of a vector
#'
#' @param x A numeric vector
#' @return The mean of the input vector. Will return error messages if the vector is not numeric or empty
#' @examples
#' calc_mean(c(1, 2, 3))       # Returns 2
#' @export

calc_mean <- function(x){
  if (length(x) == 0) { # Checks that the length of the vector is greater than 0.
    stop("Empty vector, please try again.")
  }
  else if (is.numeric(x)){
    y <- mean(x, na.rm = TRUE) # Uses the mean function in base R.
    return (y)
  }
  else stop("The vector contains non-numeric values, please try again.")

}


#'Calculate the median of a vector
#' @importFrom stats median
#' @param x A numeric vector
#' @return The median of the input vector. Will return error messages if the vector is not numeric or empty
#' @examples
#' calc_median(c(1, 2, 3))       # Returns 2
#' @export

calc_median <- function(x){
  if (length(x) == 0) {
    stop("Empty vector, please try again.")
  }
  else if (is.numeric(x)){
    y <- median(x, na.rm = TRUE) # Uses the median function from the stats package, imported at the top.
    return (y)
  }
  else stop("The vector contains non-numeric values, please try again.")

}

#'Calculate the mode of a vector
#'
#' @param x A numeric vector
#' @return The mode of the input vector. Will return error messages if the vector is not numeric, empty, or if there is no mode.
#' @examples
#' calc_mode(c(1, 1, 2, 3))      # Returns 1
#' calc_mode(c(1, 1, 2, 2, 3))   # Returns 1 2
#' @export

calc_mode <- function(x){
  if (length(x) == 0) {
    stop("Empty vector, please try again.")
  }
  else if (is.numeric(x)){
    uniquex <- unique(x)

    if (((length(uniquex) == length(x))) & (length(x) > 1)) { # Catches vectors where there is no mode, without grabbing single number vectors.
      stop("There is no mode.")
    }

    tab <- tabulate(match(x, uniquex)) # Matches the unique values back to x and counts how many times they each appear using the tabulate function
    most_freq <- uniquex[tab == max(tab)] # Grabs the most common number from tab.
    return (most_freq)
  }
  else stop("The vector contains non-numeric values, please try again.")

}


#'Calculate the first quartile of a vector
#' @importFrom stats quantile
#' @param x A numeric vector
#' @return The first quartile of the input vector. Will return error messages if the vector is not numeric or empty
#' @examples
#' calc_q1(c(1, 2, 3))       # Returns 1.5
#' @export

calc_q1 <- function(x){
  if (length(x) == 0) {
    stop("Empty vector, please try again.")
  }
  else if (is.numeric(x)){
    y <- quantile(x, 0.25, na.rm = TRUE) # Gets the 1st quartile (25% / 0.25) using quantile from the stats package.
    y <- unname(y) # Removes the name (25%) attached to the vector
    return (y)
  }
  else stop("The vector contains non-numeric values, please try again.")

}

#'Calculate the third quartile of a vector
#' @importFrom stats quantile
#' @param x A numeric vector
#' @return The third quartile of the input vector. Will return error messages if the vector is not numeric or empty
#' @examples
#' calc_q3(c(1, 2, 3))       # Returns 2.5
#' @export

calc_q3 <- function(x){
  if (length(x) == 0) {
    stop("Empty vector, please try again.")
  }
  else if (is.numeric(x)){
    y <- quantile(x, 0.75, na.rm = TRUE)
    y <- unname(y)
    return (y)
  }
  else stop("The vector contains non-numeric values, please try again.")

}

#'Calculate the interquartile range of a vector
#'
#' @param x A numeric vector
#' @return The interquartile range of the input vector. Will return error messages if the vector is not numeric or empty
#' @examples
#' calc_iqr(c(1, 2, 3))       # Returns 1
#' @export

calc_iqr <- function(x){
  if (length(x) == 0) {
    stop("Empty vector, please try again.")
  }
  else if (is.numeric(x)){
    y <- calc_q3(x) - calc_q1(x) # Subtracts the 3rd and 1st quartiles from each other to get the interquartile range.
    y <- unname(y)
    return (y)
  }
  else stop("The vector contains non-numeric values, please try again.")

}
