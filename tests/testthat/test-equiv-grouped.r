context("Equivalence (grouped)")

srcs <- lahman_srcs("df", "dt", "cpp", "postgres", "sqlite")
players <- lapply(srcs, function(src) {
  src %.% tbl("Batting") %.% group_by(playerID)
})

test_that("n the same regardless of tbl", {
  # Can't test group_size directly, because no assurance that groups are in the 
  # same order
  
  # FIXME: only needed because postgresql returns integer for count
  compare_tbls(players, function(tbl) tbl %.% summarise(n = n()), 
    compare = int_to_num)
})

test_that("filter the same regardless of tbl", {
  # Only test on local sources
  compare_tbls(players[c("df", "dt", "cpp")], function(tbl) {
    tbl %.% filter(AB == max(AB))
  })
})

test_that("arrange the same regardless of tbl", {
  compare_tbls(players, function(tbl) {
    tbl %.% select(playerID, AB, G, yearID) %.% arrange(AB, desc(G), yearID)
  }, compare = function(x, y) equal_data_frame(x, y, sort_rows = FALSE))

})

test_that("mutate the same regardless of tbl", {
  compare_tbls(players[c("df", "dt", "postgres")], function(tbl) {
    tbl %.% select(playerID, yearID) %.% 
      mutate(cyear = yearID - min(yearID) + 1)
  })
})
