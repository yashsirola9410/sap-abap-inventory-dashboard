# SAP ABAP Custom ALV Report – Inventory Aging & Stock Insight

## Project Overview

This project is a comprehensive SAP ABAP ALV (ABAP List Viewer) report developed to analyze inventory stock across plants and storage locations. It follows industry best practices and demonstrates production-level ABAP design using optimized data retrieval and interactive reporting.

**Program Name:** ZINV_STOCK_INSIGHT_REPORT

---

## Author Information

* **Name:** Yash Sirola
* **Roll Number:** 23053179
* **Batch/Program:** B.Tech Computer Science Engineering
* **Submission Date:** April 2026

---

## Problem Statement

Organizations often struggle with inventory visibility and control. Key challenges include:

* Identifying slow-moving and dead stock
* Monitoring stock availability across plants
* Understanding inventory aging trends
* Reducing overstock and stockout risks

Traditional reports lack performance efficiency and actionable insights.

---

## Solution & Features

### Core Functionality

* Interactive ALV Grid Display
* Inventory Aging Analysis
* Stock Classification based on business logic
* Multi-dimensional filtering (Material, Plant)
* Color-coded stock categories

---

### Business Logic

Stock is categorized as:

* **Out of Stock** → Quantity = 0
* **Dead Stock** → > 365 days
* **Slow Moving** → 181–365 days
* **Normal** → 61–180 days
* **Fast Moving** → ≤ 60 days

---

## Technical Highlights

### 1. Performance Optimization (JOIN Usage)

```abap
SELECT mara~matnr makt~maktx mard~werks ...
FROM mara
INNER JOIN mard ON mara~matnr = mard~matnr
```

**Benefits:**

* Avoids SELECT in LOOP
* Reduces database calls
* Improves performance on large datasets

---

### 2. ALV Features

* Field catalog for structured output
* Layout customization (zebra pattern, optimized columns)
* Sorting and subtotal functionality
* Top-of-page header display
* Interactive hotspot navigation

---

### 3. Data Processing Logic

* Calculates inventory aging (days since creation)
* Applies classification rules
* Assigns color codes dynamically

---

## Technical Architecture

### Tables Used

* **MARA** – Material Master
* **MARD** – Storage Location Data
* **MAKT** – Material Description

### Data Flow

Selection Screen → Data Fetch (JOIN) → Processing → ALV Display

---

## Technologies Used

* Language: ABAP
* UI Component: ALV Grid (REUSE_ALV_GRID_DISPLAY)
* Platform: SAP NetWeaver / SAP ECC / S/4HANA

---

## Installation & Execution

1. Open SAP GUI
2. Go to Transaction `SE38`
3. Create program: `ZINV_STOCK_INSIGHT_REPORT`
4. Paste the ABAP code
5. Activate (Ctrl + F3)
6. Execute (F8)

---

## Usage Guide

### Selection Parameters

* Material (s_matnr) → Filter by material
* Plant (s_werks) → Filter by plant
* Layout Variant (p_var) → Save/load layout

---

### Interactive Features

* Click on **Material** → Opens transaction `MM03`
* Sorting → Click column headers
* Filtering → Use ALV toolbar
* Layout Save → Customize display

---

## Expected Output

* ALV Grid displaying:

  * Material
  * Plant
  * Stock
  * Days Old
  * Category

* Color-coded rows for better visualization

---

## Performance Considerations

* Single database call using JOIN
* Efficient data handling
* Suitable for medium to large datasets

---

## Key Highlights

* Real-world inventory analysis use case
* Performance-optimized design
* Clean modular ABAP structure
* Interactive and user-friendly interface

---

## Future Enhancements

* Drill-down detailed reports
* Graphical dashboards
* Email report automation
* Fiori-based UI integration
* Predictive inventory analysis

---

## Limitations

* Requires SAP system access
* Depends on available data in MARA/MARD tables
* Authorization required for table access

---

## References

* SAP ABAP Documentation
* ALV Grid Programming Guide
* SAP Table Reference

---

## Note

This project is developed for academic purposes and demonstrates practical implementation of SAP ABAP reporting concepts and best practices.
