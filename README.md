# MATH261A – Project 1  
**From Classrooms to Paychecks: How Education Levels Shape Economic Outcomes Across Santa Clara County Neighborhoods**

**Author:** Abhishek Rasikbhai Shekhada  
**Submission date:** 2025-09-23  

---

## Project folder structure

The repository is organized to make the workflow reproducible and easy to follow:


---

## Data

- **Source:** City of San José Open Data Portal → *Equity Index Census Tracts*  
  <https://data.sanjoseca.gov/dataset/equity-index-census-tracts>  
- **Provenance:** Based on **ACS 2021 5-year estimates** compiled by the City of San José.  
- **License:** [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)  

**How to obtain data (if not committed):**  
Download the CSV from the dataset page above and place it in `data/raw/`. Then run `scripts/01_clean_data.R` and `scripts/02_model_and_figures.R` to generate the cleaned dataset, regression table, and figure used in the report.

---

## External resources and academic integrity

This project report and all accompanying R code were authored by **Abhishek Rasikbhai Shekhada**. To support the development process, I made limited use of external resources:

- **LLM-based chatbots (e.g., ChatGPT Edu):** consulted for brainstorming phrasing, clarifying R/Quarto concepts, and reviewing draft code structures. All final text and code were produced and verified by me.  
- **Online forums (e.g., Stack Overflow):** referenced for troubleshooting specific R errors and Quarto rendering issues.  

All external inputs were used only for guidance, and the responsibility for the final analysis and report rests entirely with me. Per course policy, transcripts of LLM interactions are included in `llm_logs/`.  

---

## Acknowledgments

This project repository is based on the template provided by **Rohan Alexander** for MATH 261A. The dataset originates from the **City of San José Open Data Portal** (ACS 2021 5-year estimates).
