# 05 Improve efficiency with \`data.table\`

## Introduction

This vignette shares techniques of working with big data within the
[Source Linkage Files
(SLFs)](https://github.com/Public-Health-Scotland/source-linkage-files).
It will introduce an R package, `data.table`, on the basic syntax and
some common data operations. This package can speed up processes by
reducing the time consumption and memory usage. The objective of this
vignette is to explicate the application of `data.table` through
illustrative examples. Readers should be able to write `data.table`
syntax after reading this vignette. This document aspires to promote
optimization skills and techniques to a broader audience within the Data
and Digital Innovation (DDI) directorate and across Public Health
Scotland (PHS), thereby enhancing operational efficiency.

## Showcases of Efficiency Enhancement in the Source Linkage File Project

Efficiency improvement is paramount in data-intensive projects,
especially within public health. The SLF dataset at PHS has undertaken
optimization efforts to streamline processing workflows and reduce
computational overhead. This section showcases tangible efficiency
improvements achieved through these techniques.

With the help of `data.table`, the SLF team has further achieved great
improvement in enhancing code efficiency, notably in terms of script
execution time and memory utilization. Two illustrative examples the
improvements attained by the team.

#### Example 1

The first example mainly shows the efficiency improvement with
`data.table` in script executing time. The details of this example is on
[the pull request \#899 source linkage file project on
GitHub](https://github.com/Public-Health-Scotland/source-linkage-files/pull/899).
A comparison between the old and new methods, focusing on the functions
`process_sc_all_sds` and `process_sc_all_alarms_telecare`, is presented
below:

| Function Name                    | Old Method `dplyr` | New Method `data.table` | Time Reduction |
|----------------------------------|--------------------|-------------------------|----------------|
| `process_sc_all_sds`             | 24.94 mins         | 1.69 mins               | 94% reduction  |
| `process_sc_all_alarms_telecare` | 31.81 mins         | 0.81 mins               | 98% reduction  |

Both functions yield identical results to their predecessors but exhibit
remarkable reductions in execution time. Notably, `process_sc_all_sds`
achieved a 94% reduction, while `process_sc_all_alarms_telecare`
demonstrated an even more substantial 98% reduction, affirming the
efficacy of the refined functions in enhancing performance.

#### Example 2

The second example showcases performance optimization in terms of both
memory usage and executing time. Further details regarding this example
can be found on [the pull request \#677 the source linkage file project
on
GitHub](https://github.com/Public-Health-Scotland/source-linkage-files/pull/677).
To show the efficiency improvement, a benchmark comparison were
conducted between the old version and the new version of the
`aggregate_by_chi` function. Benchmark results are based on a test
dataset with 10,000 (10^4) rows, as the complete benchmark on the real
dataset is constrained by time and resource limitations. Typically, a
real dataset consists of usually more than 10 million (10^7) rows for a
financial year. The summarized benchmark results for the test dataset
are as follows:

| Function                | Time      | Memory | Time Reduction | Memory Reduction |
|-------------------------|-----------|--------|----------------|------------------|
| Old Method `dplyr`      | 139.8 sec | 953 MB | \-             | \-               |
| New Method `data.table` | 18.38 sec | 546 MB | 92.1%          | 42.7%            |

It’s noteworthy that these benchmarks were conducted on a test dataset
comprising 10,000 rows. Given that our actual data sets typically have
more than 10 million rows, we can estimate substantial improvements in
time and memory consumption when applying the new function to real data
sets. Although the exact reduction estimates for the real data sets may
vary, based on the observed improvements in the benchmark results, we
can anticipate a boost in performance and efficiency at a similar level.

## Syntax of `data.table` and converting dplyr to `data.table`

In this section, our primary objective is to identify resource-intensive
scenarios prevalent in data analysis scripts within the public health
domain and demonstrate how the `data.table` package can enhance
efficiency without necessitating extensive modifications to the original
scripts or functions. We commence by presenting fundamental `data.table`
syntax. Subsequently, we pinpoint instances where operations utilising
`dplyr` functions may exhibit resource-intensive behaviour and
illustrate how integration with `data.table` techniques can ameliorate
such issues. It is essential to emphasize that our aim is not to
entirely supplement `dplyr` code with `data.table` equivalents. Instead,
we seek to identify scenarios where leveraging `data.table` can
substantially mitigate execution time and memory usage of R scripts,
thereby justifying the conversion of select portions from `dplyr` to
`data.table` syntax while maintaining overall consistency with the
`dplyr` approach. These scenarios encompass:

- grouped operations on large datasets
- joining large datasets
- reshaping dataset
- conditional updates

This is served with some dummy examples to demonstrate the ideas,
providing insight into where and how one can enhance their own R
scripts.

### data.table\` package and syntax

`data.table` can do fast aggregation of large data (e.g. 100GB in RAM),
fast ordered joins, fast add/modify/delete of columns by group using no
copies at all, list columns, friendly and fast character-separated-value
read/write. It offers a natural and flexible syntax, for faster
development.

We will brief some basic `data.table` syntax that could be used in the
scenarios where `data.table` can help with the work across data analysis
in the public health field. It is the quickest way to improve the
efficiency of data pipeline in the health and social care team. Delving
into all `data.table` syntax is not our pursuit here although it is
absolutely necessary to familiarize oneself with all `data.table` syntax
to achieve a better efficiency of scripts. For a better knowledge of
`data.table`, we refer to [R `data.table`
cheatsheet](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwij657zzoyEAxVIWkEAHZMRDJEQFnoECBYQAQ&url=https%3A%2F%2Fraw.githubusercontent.com%2Frstudio%2Fcheatsheets%2Fmaster%2Fdatatable.pdf&usg=AOvVaw1DWM0-_fhk9Tgvu1b88YDr&opi=89978449),
and further [R `data.table` reference manual and
vignettes](https://cran.r-project.org/web/packages/data.table/).

- `dt[i,j,by]` - take data.table **dt**, and for row **i**, manipulate
  columns with **j**, grouped according to **by**.

- `setDT` or `as.data.table` - convert a data frame or a list to a
  data.table.

- `dt[, .(x = sum(b))]` - create a data.table with new columns based on
  the summarised values of rows. Summary functions like
  [`mean()`](https://rdrr.io/r/base/mean.html),
  [`median()`](https://rdrr.io/r/stats/median.html),
  [`min()`](https://rdrr.io/r/base/Extremes.html),
  [`max()`](https://rdrr.io/r/base/Extremes.html), etc.

- `dt[, .(x = sum(b)), by = a]` - summarise rows within groups.

- `dt[, c := 1+2]` - compute a column based on an expression.

- `dt[a==1, c := 1+2]` - compute a column based on an expression but
  only for subset of rows.

- `` dt[, `:=`(c=1, d=2)] `` - compute multiple columns based on
  separate expressions.

- `dt[, c := NULL]` - delete a column.

- `dt_b[dt_a, on = .(b = y)]` - join data.tables on rows with equal
  values, similar to `left_join(dt_a, dt_b, by = c("y" = "b"))`.

- `dt_b[dt_a, on = .(b = y, c > z)]` - join data.tables on rows with
  equal and unequal values.

- `dcast(dt, id ~ y, value.var = c("a", "b"))` - Reshape a data.table
  from long to wide format.

  - `dt` A data.table.

  - `id ~ y` Formula with a LHS: ID columns containing IDs for multiple
    entries. And a RHS columns with values to spread in column headers.

  - `value.var` Columns containing values to fill into cells.

        > dt
              id      y value
           <num> <char> <num>
        1:     1      a    10
        2:     1      b    20
        3:     2      a    30
        4:     2      b    40
        5:     3      a    50
        6:     3      b    60
        > result
        Key: <id>
              id     a     b
            <num> <num> <num>
        1:     1    10    20
        2:     2    30    40
        3:     3    50    60

- `melt(dt, id.vars, measure.vars, variable.name, value.name)` - Reshape
  a data.table from wide to long format.

  - `dt` A data.table.

  - `id.vars` ID columns with IDs for multiple entries.

  - `measure.vars` Columns containing values to fill into cells (often
    in pattern form).

  - `variable.name`, `value.name` Names of new columns for variables and
    values derived from old headers.

        melt(
          dt,
          id.vars = c("id"),
          measure.vars = patterns("^a", "^b"),
          variable.name = "y",
          value.name = c("a", "b")
        )
        # Original data.table:
        > dt
              id   a_1   a_2   b_1   b_2
           <num> <num> <num> <num> <num>
        1:     1    10    40    70   100
        2:     2    20    50    80   110
        3:     3    30    60    90   120
        # Melted data.table:
        > result
              id      y     a     b
           <num> <fctr> <num> <num>
        1:     1      1    10    70
        2:     2      1    20    80
        3:     3      1    30    90
        4:     1      2    40   100
        5:     2      2    50   110
        6:     3      2    60   120

------------------------------------------------------------------------

### Grouped Operations on Large Datasets

Manipulating grouped data with `dplyr` can be very resource-intensive,
particularly when working with grouped data. By contrast, `data.table`
can achieve a better efficiency in terms of executing time and RAM
usage. Therefore, there is a situation where one can improve the code
efficiency without much effort and time by employing `data.table`. Here
is how one can achieve this.

#### Conversion from `dplyr` to `data.table`

We first show how one can convert `dplyr` code to the equivalent
`data.table` syntax as follows. For example, there is a data frame
called `height`, recording all students’ “height” and “gender”. Our aim
is to find the maximum of “height” by gender. The `dplyr` style and the
equivalent `data.table` style are as follows:

``` r
height <- data.frame(
  gender = c("Male", "Female", "Male", "Female", "Male", "Female"),
  height = c(180, 165, 175, 160, 185, 170)
)
# dplyr
max_height_df <- height %>%
  group_by(gender) %>%
  dplyr::summarise(max_height = max(height))

# first transform data to data.table class
data.table::setDT(height)
max_height_dt <- height[,
  .(max_height = max(height)),
  by = gender
]
# max_height_dt is now data.table format
# and change it back to data.frame format if needed
max_height_dt <- as.data.frame(max_height_dt)
```

Both `dplyr` and `data.table` codes achieve the same result but the
latter is more efficient. In addition, always remember setting the data
to `data.table` format before applying `data.table` package and
formatting the data back to `data.frame` for any further analysis with
`dplyr` package. In the example above, converting the `height` data
frame to a `data.table` allows us to utilize `data.table`’s efficient
operations for grouped summaries.

### Joining Large Datasets

Efficient join operations are crucial for merging large datasets
seamlessly in data analysis workflows. Joining large datasets can be a
computationally intensive task, especially when using `dplyr`’s join
functions. However, `data.table` offers optimized join operations that
significantly improve efficiency. First we will show how `dplyr` code
can be transformed to `data.table` syntax when joining large datasets.
Then, benchmark will be provide to demonstrate the efficiency and speed
improvement scale.

#### Conversion from `dplyr` to `data.table`

Consider two large datasets `df1` and `df2`, each containing information
about customers and their transactions. We aim to join these datasets
based on a common key, such as customer ID (customer_id). Below is an
example comparison of the join operation using dplyr and its equivalent
in `data.table`:

``` r
library(dplyr)
library(data.table)

# Generate dummy data
set.seed(123)
n_rows <- 1e2

# Creating first dataset
df1 <- data.frame(
  customer_id = sample(1:(n_rows * 10), n_rows, replace = FALSE),
  transaction_amount = runif(n_rows, min = 10, max = 100)
)

# Creating second dataset
df2 <- data.frame(
  customer_id = sample(1:(n_rows * 10), n_rows, replace = FALSE),
  customer_name = paste0("Customer_", sample(1:(n_rows * 10), n_rows, replace = FALSE))
)

# Joining with dplyr
joined_df <- left_join(df1, df2, by = "customer_id") %>%
  select(customer_id, transaction_amount, customer_name) %>%
  arrange(customer_id)

# Converting to data.table
dt1 <- data.table::as.data.table(df1)
dt2 <- data.table::as.data.table(df2)

# Joining with data.table
joined_dt <- dt2[dt1, on = "customer_id"] %>%
  as.data.frame() %>%
  select(customer_id, transaction_amount, customer_name) %>%
  arrange(customer_id)

identical(joined_df, joined_dt)
# TRUE
```

In the following we demonstrate equivalent code for various join types
using both `dplyr` and `data.table`. Each join type — left, right, full,
inner, anti, and semi — serves different purposes in merging datasets
based on a common key. For instance, a full join retains all rows from
both datasets, while an inner join only includes rows with matching keys
in both datasets. The left and right joins prioritize rows from one
dataset while retaining unmatched rows from the other. In contrast, anti
joins exclude rows with matching keys, while semi joins include only
rows with at least one match. By providing equivalent code snippets for
each join type in both dplyr and data.table, we aim to illustrate the
flexibility and efficiency of both packages in handling various join
scenarios, allowing users to choose the approach that best fits their
specific requirements.

``` r
# left join
joined_df_left <- left_join(df1, df2, by = "customer_id")
joined_dt_left1 <- dt2[dt1, on = "customer_id"]
joined_dt_left2 <- merge(dt1, dt2, by = "customer_id", all.x = TRUE)

# right join
joined_df_right <- right_join(df1, df2, by = "customer_id")
joined_dt_right1 <- dt1[dt2, on = "customer_id"]
joined_dt_rigth2 <-
  merge(dt1, dt2, by = "customer_id", all.y = TRUE)

# inner join
joined_df_inner <- inner_join(df1, df2, by = "customer_id")
joined_dt_inner1 <- dt1[dt2, on = "customer_id", nomatch = NULL]
joined_dt_inner2 <- merge(dt1,
  dt2,
  by = "customer_id",
  all.x = FALSE,
  all.y = FALSE
)

# full join
joined_df_full <- full_join(df1, df2, by = "customer_id")
joined_dt_full2 <- merge(dt1, dt2, by = "customer_id", all = TRUE)

# anti join
joined_df_anti <- anti_join(df1, df2, by = "customer_id")
joined_dt_anti1 <- dt1[!dt2, on = "customer_id"]

# semi join
joined_df_semi <- semi_join(df1, df2, by = "customer_id")
joined_dt_semi1 <- dt1[dt2,
  on = "customer_id",
  nomatch = 0,
  .(customer_id, transaction_amount)
]
```

### Reshaping Data

Reshaping data refers to the process of restructuring or reorganizing
the layout of a dataset. This typically involves converting data from
one format to another to make it more suitable for analysis or
presentation. Reshaping often involves tasks such as:

1.  **Changing the layout of data:** This includes tasks like converting
    data from wide to long format or vice versa. In the wide format,
    each observation is represented by a single row, and different
    variables are stored in separate columns. In the long format, each
    observation is represented by multiple rows, and different values of
    variables are stored in a single column along with an identifier
    variable to distinguish them.

2.  **Pivoting or melting data:** Pivoting involves rotating the data
    from a tall, thin format to a wide format, typically by converting
    unique values in a column to separate columns. Melting, on the other
    hand, involves converting multiple columns into key-value pairs,
    often for easier aggregation or analysis.

Overall, reshaping data is an important step in data preprocessing and
analysis, as it helps to organize data in a way that facilitates
efficient analysis, visualization, and interpretation. Libraries like
`dplyr` and `data.table` in R provide powerful tools for reshaping data,
making it easier to perform these tasks programmatically.

#### Conversion from `dplyr` to `data.table`

We demonstrate how to convert data between wide-format and long-format
representations using both `dplyr` and `data.table`. Each package
provides functions
([`pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html)
and
[`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html)
in `dplyr`,
[`melt()`](https://rdrr.io/pkg/data.table/man/melt.data.table.html) and
[`dcast()`](https://rdrr.io/pkg/data.table/man/dcast.data.table.html) in
`data.table`) that streamline the conversion process, allowing for
flexible and efficient manipulation of data structures.

##### Wide to long format

The equivalent functions for formatting data from wide to long format of
`dplyr` and `data.table` are `pivot_wider` and `dcast` respectively.

``` r
library(dplyr)
library(tidyr)
library(data.table)
# Example long-format data frame
long_df <- data.frame(
  ID = c(1, 1, 2, 2, 3),
  key1 = c("A", "A", "B", "B", "C"),
  key2 = c("W", "W", "X", "X", "Y"),
  variable = c("value1", "value2", "value1", "value2", "value1"),
  value = c(10, 100, 20, 200, 30)
)

# Convert to wide format using dplyr
wide_df <- long_df %>%
  pivot_wider(
    names_from = variable,
    values_from = value
  )

long_dt <- data.table::as.data.table(long_df)
wide_dt <- dcast(long_dt,
  ID + key1 + key2 ~ variable,
  value.var = "value"
)
```

##### Long to wide format

The equivalent functions for formatting data from long to wide format of
`dplyr` and `data.table` are `pivot_longer` and `melt` respectively.

``` r
library(dplyr)
library(tidyr)
library(data.table)
# Example wide-format data frame
wide_df <- data.frame(
  ID = 1:5,
  key1 = c("A", "B", "C", "D", "E"),
  key2 = c("W", "X", "Y", "Z", "V"),
  value1 = c(10, 20, 30, 40, 50),
  value2 = c(100, 200, 300, 400, 500)
)

# Convert to long format using dplyr
long_df <- wide_df %>%
  pivot_longer(
    cols = starts_with("value"),
    names_to = "variable",
    values_to = "value"
  )

wide_dt <- data.table::as.data.table(wide_df)
long_dt <- melt(
  wide_dt,
  id.vars = c("ID", "key1", "key2"),
  measure.vars = patterns("^value"),
  variable.name = "variable",
  value.name = "value"
)
```

In these examples, the long-format data is converted into wide format
using the
[`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html)
function from `dplyr` and the
[`dcast()`](https://rdrr.io/pkg/data.table/man/dcast.data.table.html)
function from `data.table`. This reshaping operation allows for easier
analysis and visualization of the data in a wider format.

### Conditional Updates

Conditional updates refer to the process of modifying values in a
dataset based on specified conditions. In other words, it involves
updating certain values in a dataset only if they meet specific criteria
or conditions. This can be particularly useful when you need to apply
changes to a dataset selectively, depending on the values of certain
variables or combinations of variables. For instance, one might want to
update the values in a column based on whether they meet certain
thresholds, or one might want to apply different transformations to
different subsets of your data based on some criteria. Conditional
updates allow one to automate these modifications efficiently, saving
time and effort compared to manual editing.

#### Conversion from `dplyr` to `data.table`

Both `dplyr` and `data.table` provide functionality for performing
conditional updates, allowing you to implement complex data
transformations with ease. These operations are often performed using
functions like
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) in
`dplyr` and `:=` in `data.table`, along with logical conditions to
specify when the updates should occur.

Suppose we have a dataset containing information about students’ exam
scores, and we want to update the scores based on certain conditions.
Let’s consider a scenario where we want to increase the scores of
students who scored below a certain threshold. In this `dplyr` example,
we use the
[`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) function
to update the `exam_score` column based on the condition specified
inside [`ifelse()`](https://rdrr.io/r/base/ifelse.html). If the
`exam_score` is below 70, we increase it by 5; otherwise, we keep it
unchanged. In the `data.table` example, we use the `:=` operator to
update the `exam_score` column directly within the dataset. The logical
condition `exam_score < 70` is used to specify which rows should be
updated, and the expression `exam_score + 5` is used to define the new
values for those rows. Both approaches achieve the same result: updating
exam scores for students who scored below 70. However, they differ in
syntax and implementation, showcasing the flexibility of both `dplyr`
and `data.table` for performing conditional updates. Similarly,
[`data.table::fcase()`](https://rdrr.io/pkg/data.table/man/fcase.html)
is the equivalent version to
[`dplyr::case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html).

``` r
library(dplyr)
library(data.table)
# Dummy dataset
scores_df <- data.frame(
  student_id = 1:10,
  exam_score = c(75, 82, 65, 90, 55, 78, 70, 85, 60, 72)
)
# Increase scores for students with scores below 70
updated_scores_df <- scores_df %>%
  mutate(exam_score = ifelse(exam_score < 70, exam_score + 5, exam_score))

# Convert to data.table
scores_dt <- as.data.table(scores_df)
# Increase scores for students with scores below 70
scores_dt[exam_score < 70, exam_score := exam_score + 5]
scores_dt[, exam_score := fifelse(exam_score < 70, exam_score + 5, exam_score)]
scores_dt[, exam_score := fcase(exam_score < 70, exam_score + 5)]
```

## Concluding Remarks

`data.table` can provide a great improvement in efficiency using its
native syntax. There are R packages that can allow one to write dplyr
code that is automatically translated to the equivalent `data.table`
code, e.g. `dtplyr` and `tidytable`. However, after testing, those
packages does not produce much improvement in grouped operations, which
is the main scenario in the SLF. In addition, the SLF team are exploring
options on the emerging packages
[`polars`](https://github.com/pola-rs/r-polars) and its friend
[`tidypolars`](https://github.com/etiennebacher/tidypolars/) which are
developed with Rust. We aim to apply those packages when R v4.4 is
available to PHS.
