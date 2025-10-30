# ======================
# SETUP & LIBRARIES
# ======================
library(tidyverse)
library(ggthemes)
library(scales)
library(ggrepel)
library(viridis)
library(patchwork)
library(readxl)
library(countrycode)

data_dir <- "/Users/marcellacung/Downloads/实验2-MARCELLA-2023952001/Diabetes/"
years <- 1960:2024

# ======================
# FUNCTIONS
# ======================
standardize_country_names <- function(countries) {
  cleaned <- str_trim(countries)
  standardized <- countrycode(cleaned, origin = "country.name", destination = "country.name")
  coalesce(standardized, cleaned)
}

load_wb_data <- function(filename, value_name = "Value") {
  df <- read_csv(file.path(data_dir, filename), skip = 4, col_names = FALSE) %>%
    select(Country = 1, Code = 2, Indicator = 3, 5:(5 + length(years) - 1)) %>%
    setNames(c("Country", "Code", "Indicator", as.character(years))) %>%
    filter(!Country %in% c("Country Name", "World", "High income", "Low income")) %>% # Filter header/meta rows
    pivot_longer(cols = all_of(as.character(years)), names_to = "Year", values_to = value_name) %>%
    mutate(
      Year = as.integer(Year),
      !!value_name := as.numeric(.data[[value_name]]),
      Country = standardize_country_names(Country)
    ) %>%
    filter(!is.na(.data[[value_name]])) %>%
    select(-Indicator)
  return(df)
}

# ======================
# LOAD DATA
# ======================
df_prev <- load_wb_data("diabetes_prevalence.csv", "Prevalence")
df_spend <- load_wb_data("health_expenditure_per_capita.csv", "Health_Expenditure")
df_pop <- load_wb_data("population_total.csv", "Population")

df_treat <- read_csv(file.path(data_dir, "Diabetes Treatment Coverage.csv")) %>%
  transmute(
    Country = standardize_country_names(Location),
    Year = Period,
    Coverage = FactValueNumeric
  )

df_meta <- read_excel(file.path(data_dir, "CLASS.xlsx")) %>%
  mutate(
    ISO3 = countrycode(Economy, origin = "country.name", destination = "iso3c")
  ) %>%
  filter(!is.na(ISO3)) %>%
  transmute(
    Country = standardize_country_names(Economy),
    Region = if_else(`Region` == "Latin America & Caribbean", "Latin America/Caribbean", `Region`),
    Income_Level = factor(`Income group`, levels = c("Low income", "Lower middle income", "Upper middle income", "High income")),
    ISO3 = ISO3
  )

# ======================
# MERGE & CLEAN
# ======================
merged_data <- df_prev %>%
  left_join(df_spend, by = c("Country", "Year")) %>%
  left_join(df_pop, by = c("Country", "Year")) %>%
  left_join(df_meta, by = "Country") %>%
  filter(!is.na(Region), !is.na(Income_Level))

latest_year <- max(df_prev$Year, na.rm = TRUE)

# ======================
# PLOT 1: TIME TREND (Top 6 Countries)
# ======================
# Identify latest year with good prevalence data
latest_year <- max(df_prev$Year[!is.na(df_prev$Prevalence)], na.rm = TRUE)

# Safely extract top 6 countries with highest prevalence
top6 <- df_prev %>%
  filter(Year == latest_year, !is.na(Prevalence)) %>%
  group_by(Country) %>%
  summarise(Prevalence = mean(Prevalence, na.rm = TRUE), .groups = "drop") %>%
  slice_max(order_by = Prevalence, n = 6, with_ties = FALSE) %>%
  pull(Country)

df_top6 <- df_prev %>%
  filter(Country %in% top6)

df_top6_labels <- df_top6 %>%
  filter(Year == latest_year) %>%
  mutate(Label = sprintf("%s\n%.1f%%", Country, Prevalence))

p1 <- ggplot(df_top6, aes(Year, Prevalence, color = Country)) +
  geom_line(size = 1.1) +
  geom_point(size = 1.6) +
  geom_text_repel(
    data = df_top6_labels,
    aes(label = Label),
    size = 3,
    nudge_x = 2,
    direction = "y",
    box.padding = 0.4,
    segment.color = "grey50"
  ) +
  scale_x_continuous(breaks = seq(2000, latest_year, 5), limits = c(2000, latest_year + 6))+
  scale_color_brewer(palette = "Dark2") +
  labs(title = "Diabetes Prevalence Over Time", y = "Prevalence (%)", x = "Year") +
  theme_minimal() +
  theme(legend.position = "none", plot.margin = margin(r = 70))

# ======================
# PLOT 2: BUBBLE PLOT (Revised)
# ======================
bubble_data <- merged_data %>%
  filter(Year == latest_year) %>%
  drop_na(Health_Expenditure, Prevalence, Population) %>%
  mutate(
    Population = Population / 1e6,
    Label = if_else(
      Prevalence > quantile(Prevalence, 0.9) |
        Health_Expenditure > quantile(Health_Expenditure, 0.9) |
        Population > quantile(Population, 0.9),
      Country, ""
    )
  )

p2 <- ggplot(bubble_data, aes(Health_Expenditure, Prevalence, size = Population, color = Region)) +
  geom_point(alpha = 0.75) +
  geom_text_repel(aes(label = Label), size = 2.8, max.overlaps = 25) +
  scale_size_area(max_size = 12, breaks = c(10, 50, 100, 500), labels = c("10M", "50M", "100M", "500M")) +
  scale_x_log10(
    labels = dollar,
    breaks = c(10, 100, 1000, 10000)
  ) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Prevalence vs Health Spending",
    x = "Health Expenditure (log, USD)",
    y = "Prevalence (%)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8)
  )

# ======================
# PLOT 3: REGIONAL BAR
# ======================
p3_data <- merged_data %>%
  filter(Year == latest_year) %>%
  group_by(Region) %>%
  summarise(
    Avg_Prevalence = mean(Prevalence, na.rm = TRUE),
    SE = sd(Prevalence, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(
    CI_lower = Avg_Prevalence - 1.96 * SE,
    CI_upper = Avg_Prevalence + 1.96 * SE
  )

p3 <- ggplot(p3_data, aes(reorder(Region, Avg_Prevalence), Avg_Prevalence, fill = Region)) +
  geom_col(width = 0.6, alpha = 0.85) +
  geom_errorbar(aes(ymin = CI_lower, ymax = CI_upper), width = 0.15, color = "gray40", size = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", Avg_Prevalence), y = CI_upper), hjust = -0.1, size = 3.1) +
  coord_flip() +
  scale_fill_brewer(palette = "Pastel1") +
  labs(title = "Average Prevalence by Region", subtitle = "With 95% Confidence Intervals", x = "", y = "Prevalence (%)") +
  theme_minimal() +
  theme(legend.position = "none")

# ======================
# PLOT 4: TREATMENT HEATMAP (REVISED)
# ======================
df_treat_heatmap <- df_treat %>%
  left_join(df_meta, by = "Country") %>%
  drop_na(Region, Income_Level, Coverage) %>%
  group_by(Region, Income_Level) %>%
  summarise(
    Mean_Coverage = mean(Coverage, na.rm = TRUE),
    Count = n(),
    .groups = "drop"
  )

p4 <- ggplot(df_treat_heatmap, aes(x = Region, y = Income_Level, fill = Mean_Coverage)) +
  geom_tile(color = "white", linewidth = 0.4) +
  geom_text(aes(label = ifelse(Count > 1,
                               sprintf("%.1f%%\n(n=%d)", Mean_Coverage, Count),
                               sprintf("%.1f%%", Mean_Coverage))),
            size = 3, color = "white", lineheight = 0.9) +
  scale_fill_viridis(option = "viridis", limits = c(0, 100), direction = -1) +
  labs(
    title = "Treatment Coverage by Region & Income",
    x = "Region",
    y = "Income Level",
    fill = "Coverage (%)"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 35, hjust = 1)
  )

# ======================
# FINAL COMPOSITION
# ======================
design <- "
AABB
AABB
CCDD
CCDD
"

final_plot <- p1 + p2 + p3 + p4 +
  plot_layout(design = design) +
  plot_annotation(
    title = "Global Diabetes Data Exploration",
    subtitle = "Comprehensive visualization of prevalence, spending, and treatment patterns",
    caption = "Data: World Bank, IHME, WHO",
    theme = theme(
      plot.title = element_text(size = 18, face = "bold", hjust = 0.5, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40", margin = margin(b = 15)),
      plot.caption = element_text(size = 9, color = "gray50", hjust = 0.98),
      plot.margin = margin(15, 15, 15, 15)
    )
  )

# ======================
# SAVE OUTPUT
# ======================
ggsave("/Users/marcellacung/Downloads/实验2-MARCELLA-2023952001/diabetes_dashboard.png",
       plot = final_plot,
       width = 16,
       height = 12,
       dpi = 300,
       bg = "white")

# Show plot
final_plot
