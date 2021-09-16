library(slfhelper)
library(tidyverse)

data <- read_slf_individual(
  year = c(1415, 1516, 1617, 1718, 1819, 1920),
  columns = c("year", "nsu", "keep_population", "age", "gender")
) %>%
  as_tibble() %>%
  mutate(age_group = phsmethods::age_group(age, by = 10, as_factor = TRUE)) %>%
  mutate(
    year = ordered(year),
    gender = factor(gender, levels = c(1, 2), labels = c("Male", "Female")),
    nsu = factor(nsu)
  )

slf_pop_data <- data %>%
  as_tibble() %>%
  count(year, gender, age_group, nsu)

pop_data <- data %>%
  as_tibble() %>%
  filter(keep_population == 1) %>%
  count(year, gender, age_group)


slf_pop_data %>%
  ggplot(aes(x = if_else(gender == "Female", n, -n), y = age_group, fill = gender)) +
  geom_col(aes(alpha = fct_rev(nsu))) +
  geom_col(data = pop_data, alpha = 0, colour = "black", size = 0.1) +
  theme_minimal() +
  facet_wrap("year") +
  xlab("Count of people") +
  ylab("Age Group") +
  lemon::scale_x_symmetric(labels = abs) +
  scale_fill_brewer("Gender", type = "qual") +
  scale_alpha_discrete("NSU", range = c(0.5, 1))
