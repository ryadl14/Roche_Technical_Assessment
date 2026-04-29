test_that("mean calculation works", {
  expect_equal(calc_mean(c(1,2,3)), 2)
})

test_that("empty string returns the right error", {
  expect_error(calc_mean(c()), "Empty vector, please try again.")
})

test_that("Vector with non-numeric values will error", {
  expect_error(calc_mean(c(1, "a", 2, 3)), "The vector contains non-numeric values, please try again.")
})



test_that("median calculation works", {
  expect_equal(calc_median(c(1,2,3)), 2)
})

test_that("empty string returns the right error", {
  expect_error(calc_median(c()), "Empty vector, please try again.")
})

test_that("Vector with non-numeric values will error", {
  expect_error(calc_median(c(1, "a", 2, 3)), "The vector contains non-numeric values, please try again.")
})



test_that("Single mode calculation works", {
  expect_equal(calc_mode(c(1,2,3,3,4,5)), 3)
})

test_that("Mode calculation with multiple modes works", {
  expect_equal(calc_mode(c(1,2,3,3,4,5,5)), c(3, 5))
})

test_that("empty string returns the right error", {
  expect_error(calc_mode(c()), "Empty vector, please try again.")
})

test_that("Vector with non-numeric values will error", {
  expect_error(calc_mode(c(1, "a", 2, 3)), "The vector contains non-numeric values, please try again.")
})




test_that("1st quartile calculation works", {
  expect_equal(calc_q1(c(1,2,3)), 1.5)
})

test_that("empty string returns the right error", {
  expect_error(calc_q1(c()), "Empty vector, please try again.")
})

test_that("Vector with non-numeric values will error", {
  expect_error(calc_q1(c(1, "a", 2, 3)), "The vector contains non-numeric values, please try again.")
})




test_that("3rd quartile calculation works", {
  expect_equal(calc_q3(c(1,2,3)), 2.5)
})

test_that("empty string returns the right error", {
  expect_error(calc_q3(c()), "Empty vector, please try again.")
})

test_that("Vector with non-numeric values will error", {
  expect_error(calc_q3(c(1, "a", 2, 3)), "The vector contains non-numeric values, please try again.")
})



test_that("Interquartile calculation works", {
  expect_equal(calc_iqr(c(1,2,3)), 1)
})

test_that("empty string returns the right error", {
  expect_error(calc_iqr(c()), "Empty vector, please try again.")
})

test_that("Vector with non-numeric values will error", {
  expect_error(calc_iqr(c(1, "a", 2, 3)), "The vector contains non-numeric values, please try again.")
})

