#### ============================================================
#### Data cleaning for Equity Index Census Tracts (R)
#### ============================================================

## 0) Packages
needed <- c("readr","dplyr","stringr","tibble")
to_install <- setdiff(needed, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install)

library(readr); library(dplyr); library(stringr); library(tibble)

## 1) Paths (edit if needed)
# Option A (recommended): use a relative path inside your project
raw_path   <- "~/Documents/Math 261A/Project 1/Equity_Index_Census_Tracts.csv"
clean_path <- "~/Documents/Math 261A/Project 1/Clean_Equity_Index_Census_Tracts.csv"

# Option B: use a file picker
if (!file.exists(raw_path)) raw_path <- file.choose()

## 2) Read raw
raw <- read_csv(raw_path, show_col_types = FALSE)

## 3) Drop identifier / metadata / geometry-like columns
id_cols <- c(
  "OBJECTID","FACILITYID","FIPSCODE","GEOID","CENSUSTRACT",
  "GEOGRAPHICAREANAME","LASTUPDATESOURCE","LASTUPDATE",
  "ENTERPRISEID","INSANJOSE","Shape_Length","Shape_Area"
)

dat <- raw %>% select(-any_of(id_cols))

## 4) Drop columns with too many missing values (> 50% NA)
na_count <- sapply(dat, function(x) sum(is.na(x)))
too_missing <- names(na_count[ na_count > 0.5 * nrow(dat) ])
dat <- dat %>% select(-any_of(too_missing))

## 5) Explicitly drop **derived equity score** columns to prevent leakage
# (these are constructed from underlying variables and can circularly include income/education info)
leak_columns <- names(dat)[ str_detect(names(dat), "^EQUITYSCORE") ]
dat <- dat %>% select(-any_of(leak_columns))

## 6) Keep rows with complete data across remaining vars
dat_complete <- dat %>% tidyr::drop_na()

## 7) Quick range sanity checks for key fields (do not modify; just verify)
# If present, check expected ranges
msg <- c()
if ("EDULESSTHANHSRATIO" %in% names(dat_complete)) {
  r <- range(dat_complete$EDULESSTHANHSRATIO, na.rm = TRUE)
  msg <- c(msg, sprintf("EDULESSTHANHSRATIO range: %.3f to %.3f", r[1], r[2]))
}
if ("INCMEDIANINCOME" %in% names(dat_complete)) {
  r <- range(dat_complete$INCMEDIANINCOME, na.rm = TRUE)
  msg <- c(msg, sprintf("INCMEDIANINCOME range: %s to %s",
                        scales::dollar(r[1]), scales::dollar(r[2])))
}

## 8) Flag potential outliers (IQR rule) for *numeric* columns, but do NOT remove them
num_cols <- names(dat_complete)[ sapply(dat_complete, is.numeric) ]
flag_outliers <- function(v) {
  q <- quantile(v, probs = c(0.25, 0.75), na.rm = TRUE)
  iqr <- q[2] - q[1]
  lower <- q[1] - 1.5 * iqr
  upper <- q[2] + 1.5 * iqr
  (v < lower) | (v > upper)
}
outlier_tbl <- lapply(num_cols, \(nm) {
  tibble(variable = nm, n_outliers = sum(flag_outliers(dat_complete[[nm]]), na.rm = TRUE))
}) |> dplyr::bind_rows()

## 9) Save cleaned data + a small cleaning report
write_csv(dat_complete, clean_path)

clean_report <- list(
  rows_cols_before = c(rows = nrow(raw), cols = ncol(raw)),
  rows_cols_after  = c(rows = nrow(dat_complete), cols = ncol(dat_complete)),
  dropped_id_cols  = intersect(id_cols, names(raw)),
  dropped_high_NA_cols = too_missing,
  dropped_leakage_cols = leak_columns,
  key_ranges = msg
)

# Print to console
cat("\n=== Cleaning summary ===\n")
print(clean_report)
cat("\nPotential outliers per numeric variable (IQR rule):\n")
print(outlier_tbl %>% arrange(desc(n_outliers)) %>% head(10))
cat("\nSaved cleaned CSV to:", normalizePath(clean_path), "\n")

