# Mobile Phones Evolution Analysis

## Executive Summary:

This project explores mobile phone specifications across multiple brands and years to uncover trends in
display technology, camera development, and memory capacity.

Data was cleaned, transformed and analyzed to understand how hardware advancements relate to product pricing and brand evolution

## Business Problem:

With the smartphone market becoming increasingly competitive, manufactureres must understand which features - such as display type,
camera resolution and memory - drive price and consumer perception.

The goal is to:
   - identify technological trends over time
   - understand which features correlate most with higher prices

 ## Methodology:

 1. SQL query that extracts, cleans and transforms the data from the database
 2. Build a dashboard using Tableau that visualizes all the data

## Skills 

SQL: CTEs, joins, cases, aggregate functions

Tableau: joins, charts, data visualizations

## Results:

- OLD and AMOLED displays are associated with higher average prices compared to LCDs, 
and with that they are produced less, however the number of them has been rising

![display_type_price](https://github.com/nev12/cellphone-evolution-analysis/blob/main/images/display_price.png)

- Camera resolutions (especially multi-lens setups) increased significantly ater 2018, correalating with a price rise

![rear_camera_resolutions](https://github.com/nev12/cellphone-evolution-analysis/blob/main/images/rear_cams.png)

- Memory capacities (RAM and internal storage) have grown steadily, with a top-tier models reaching 16 GB RAM and 512 GB internal memory in 2023

![outstanding_memory](https://github.com/nev12/cellphone-evolution-analysis/blob/main/images/outstanding_memory.png)

- Brands differ greatly in feature strategy - Apple and Google prioritize camera and display, while others push storage capacity.

## Business Recommendations:

Based on this dataset, consumers seem to value visual experience and image quality more than other specifications

Manufacturers should prioritize investment into camera systems and display technologies like brighter OLED panel, adaptive refresh rates and advanced camera sensors.

## Next Steps:

1. Expand the Dataset
2. Brand Level Comparison
     Conduct deeper brand segmentation - compare how different brands balance price with specs
3. Market Trends Analysis
4. Predictive Insights
     Develop visual models to forecast future specs or price trends based on past growth patterns


