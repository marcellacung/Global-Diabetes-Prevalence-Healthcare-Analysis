# Global Diabetes Data Visualization Dashboard

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![ggplot2](https://img.shields.io/badge/ggplot2-1.65B?style=for-the-badge&logo=r&logoColor=white)
![Data Visualization](https://img.shields.io/badge/Data%20Visualization-FF6B6B?style=for-the-badge)

A comprehensive data visualization project analyzing global diabetes patterns, healthcare spending, and treatment coverage across 1960-2024.

## 📊 Project Overview

This project explores global diabetes data through multiple interactive visualizations, examining relationships between prevalence rates, healthcare expenditure, population demographics, and treatment accessibility across different regions and income levels.

## 🎯 Key Features

- **Multi-dimensional Analysis**: Diabetes prevalence, health expenditure, population, and treatment coverage
- **Global Scope**: Data from 1960-2024 covering multiple countries and regions
- **Advanced Visualizations**: Trend lines, bubble charts, bar plots, and heatmaps
- **Statistical Insights**: Confidence intervals and regional comparisons
- **Professional Layout**: Custom dashboard design using patchwork

## 📈 Visualizations

### 1. Time Trend Analysis
- Tracks diabetes prevalence over time for top 6 countries
- Identifies countries with fastest-growing rates
- Uses geom_line() with intelligent labeling
<img width="425" height="309" alt="image" src="https://github.com/user-attachments/assets/ae5790ab-ee7f-4577-9937-01e590636839" />


### 2. Prevalence vs Healthcare Spending Bubble Chart
- Examines relationship between spending and prevalence
- Bubble size represents population
- Color-coded by region with logarithmic scaling
<img width="426" height="257" alt="image" src="https://github.com/user-attachments/assets/c0ba9cb7-a3ec-4baf-88d8-0c711459e1df" />


### 3. Regional Prevalence Comparison
- Bar chart with 95% confidence intervals
- Shows significant regional disparities
- Coord_flip() for better readability
<img width="426" height="362" alt="image" src="https://github.com/user-attachments/assets/cf3b5e4d-60d4-4448-877b-f2c75ed4dd10" />


### 4. Treatment Coverage Heatmap
- Cross-tabulation of region vs income level
- Viridis color scale for accessibility
- Includes sample size annotations
<img width="425" height="296" alt="image" src="https://github.com/user-attachments/assets/3c767ac1-f172-44b4-b59c-b7f73e6f1a6a" />


## 🗂️ Project Structure

```
diabetes-visualization/
├── diabetes.R                 # Main analysis script
├── 数据可视化-实验.docx       # Project report (Chinese)
├── data/                      # Data directory
│   ├── diabetes_prevalence.csv
│   ├── health_expenditure_per_capita.csv
│   ├── population_total.csv
│   ├── Diabetes Treatment Coverage.csv
│   └── CLASS.xlsx
├── outputs/                   # Generated visualizations
│   └── diabetes_dashboard.png
└── README.md
```

## 🛠️ Technical Stack

### Programming Language
- **R** (Primary analysis and visualization)

### Core Packages
```r
library(tidyverse)    # Data manipulation and visualization
library(ggthemes)     # Enhanced ggplot2 themes
library(scales)       # Axis formatting and scaling
library(ggrepel)      # Intelligent label positioning
library(viridis)      # Color-blind friendly palettes
library(patchwork)    # Multi-plot layout management
library(readxl)       # Excel file reading
library(countrycode)  # Country name standardization
```

### Visualization Techniques
- **ggplot2** for all chart types
- **patchwork** for dashboard layout
- **Statistical annotations** (confidence intervals, sample sizes)
- **Responsive labeling** with ggrepel

## 📥 Installation & Usage

### Prerequisites
- R (version 4.0+ recommended)
- RStudio (optional but recommended)

### Required Packages
```r
install.packages(c(
  "tidyverse", "ggthemes", "scales", "ggrepel", 
  "viridis", "patchwork", "readxl", "countrycode"
))
```

### Running the Analysis
```r
# Set your data directory path
data_dir <- "/path/to/your/data/folder"

# Source and run the main script
source("diabetes.R")
```

## 🔍 Key Insights Discovered

### Regional Patterns
- **Middle East & North Africa**: Highest diabetes prevalence rates
- **East Asia & Africa**: Relatively lower prevalence rates
- **High-income countries**: Better treatment coverage but varying prevalence

### Economic Factors
- Healthcare spending doesn't always correlate with lower prevalence
- Some low-spending countries show unexpectedly high prevalence rates
- Treatment coverage strongly linked to income levels

### Temporal Trends
- Rapid increase in diabetes prevalence in Gulf countries
- Stable or slow growth in developed nations
- Emerging patterns in developing economies

## 📊 Data Sources

| Data Type | Source | Description |
|-----------|--------|-------------|
| Diabetes Prevalence | World Bank | Modeled estimates of diabetes prevalence |
| Health Expenditure | World Bank | Per capita health spending (USD) |
| Population Data | World Bank | Annual population estimates |
| Treatment Coverage | WHO Global Health Observatory | Proportion receiving diabetes treatment |
| Country Metadata | World Bank | Region and income level classifications |

## 🎓 Academic Context

This project was completed as **Assignment 2** for the **Data Visualization** course, demonstrating:

- Data acquisition and integration from multiple sources
- Advanced ggplot2 visualization techniques
- Statistical interpretation of health data
- Professional report writing and documentation

## 🤝 Challenges & Solutions

### Data Integration
- **Challenge**: Inconsistent country names across datasets
- **Solution**: Implemented `countrycode` package for standardization

### Visualization Complexity
- **Challenge**: Overlapping labels in multi-dimensional plots
- **Solution**: Used `ggrepel` for intelligent label positioning

### Layout Management
- **Challenge**: Arranging multiple plots in a cohesive dashboard
- **Solution**: Leveraged `patchwork` for custom grid layouts

## 📄 Output

The main output is a comprehensive dashboard image (`diabetes_dashboard.png`) that integrates all four visualizations into a single, publication-ready figure.

## 👨‍💻 Author

**MARCELLA**  
- Student ID: 2023952001  
- Course: Data Visualization  
- Institution: Shantou University  
- Date: May 2025  

## 📜 License

This project is for academic purposes. Data sources are attributed to respective organizations (World Bank, WHO).

## 🙏 Acknowledgments

- World Bank for comprehensive global health data
- WHO for treatment coverage statistics
- R community for excellent visualization packages
- Course instructors for project guidance

---

<div align="center">

*"Turning data into insights through thoughtful visualization"*

</div>
