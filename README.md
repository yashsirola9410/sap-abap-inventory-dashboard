# SAP ABAP Inventory Aging Dashboard

## 📌 Project Overview

This project is an SAP ABAP ALV (ABAP List Viewer) report designed to analyze inventory stock across plants and storage locations. It provides insights into stock aging, movement patterns, and risk classification to support better inventory management decisions.

The report demonstrates clean ABAP design, performance optimization using JOIN, and interactive ALV features.

---

## 🎯 Problem Statement

Organizations often face challenges in:

* Identifying slow-moving or dead stock
* Monitoring stock availability across plants
* Analyzing inventory aging for decision-making

Traditional reports lack proper visualization and classification, making it difficult to derive actionable insights.

---

## 💡 Solution

This project provides:

* Inventory aging analysis
* Stock classification (Fast Moving, Normal, Slow Moving, Dead Stock)
* Centralized dashboard using ALV
* Interactive and readable output

---

## 🚀 Features

### 🔹 Core Functionality

* Inventory data retrieval using optimized JOIN
* Aging calculation (based on material creation date)
* Stock classification logic
* ALV grid display

### 🔹 Business Logic

* **Out of Stock** → Stock = 0
* **Dead Stock** → > 365 days
* **Slow Moving** → 181–365 days
* **Normal** → 61–180 days
* **Fast Moving** → ≤ 60 days

### 🔹 UI & ALV Features

* Zebra pattern for readability
* Auto column width optimization
* Color-coded rows based on category
* Top-of-page header
* Sorting and grouping

### 🔹 Interactive Feature

* Click on material → navigates to transaction `MM03`

---

## 🏗️ Technical Architecture

### Tables Used

* **MARA** → Material Master
* **MARD** → Storage Location Data
* **MAKT** → Material Description

### Data Flow

Selection Screen → Data Fetch (JOIN) → Processing → ALV Display

---

## ⚙️ Technologies Used

* Language: ABAP
* UI: ALV Grid (REUSE_ALV_GRID_DISPLAY)
* Platform: SAP NetWeaver / SAP ECC / S4HANA

---

## 📂 Project Structure

```
sap-abap-inventory-dashboard/
│
├── zinv_stock_insight_report.abap
├── README.md
```

---

## 🛠️ Installation & Execution

1. Open SAP GUI
2. Go to Transaction `SE38`
3. Create program: `ZINV_STOCK_INSIGHT_REPORT`
4. Paste the ABAP code
5. Activate (Ctrl + F3)
6. Execute (F8)

---

## 📊 Expected Output

* ALV table showing:

  * Material
  * Plant
  * Stock
  * Days Old
  * Category

* Color-coded rows based on stock condition

---

## 📈 Performance Considerations

* Uses JOIN instead of SELECT in LOOP
* Single database call for efficiency
* Suitable for medium to large datasets

---

## 🔥 Key Highlights

* Real-world business use case
* Clean modular code structure
* Performance-optimized data retrieval
* Visual and interactive reporting

---

## ⚠️ Limitations

* Requires SAP system access
* Depends on availability of data in MARA, MARD tables
* Authorization may be required for table access

---

## 🚀 Future Enhancements

* Drill-down reports
* Graphical dashboards
* Email report generation
* Fiori-based UI
* Predictive inventory analysis

---

## 👤 Author Information

* **Name:** Yash Sirola
* **Roll Number:** 23053179
* **Batch/Program:** B.Tech
* **Submission Date:** April 2026


---

## 📚 References

* SAP ABAP Documentation
* ALV Grid Programming Guide
* SAP Table Reference

---

## 📌 Note

This project is created for academic and learning purposes and demonstrates SAP ABAP reporting concepts and best practices.
