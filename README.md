# 🛒 Snowflake Retail AI Agent

An end-to-end AI-powered retail analytics agent built on **Snowflake Cortex** — 
from raw transactional data to a production-ready conversational agent with 
customer segmentation, basket analysis, and anomaly detection.

Built using **Snowflake Cortex Code (CoCo)** and **Snowflake CoWork**.

---

## 🎬 Demo Video
> 📺 *[Video link coming soon]*

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  HOL_ONLINE_RETAIL Database                   │
├─────────────────┬────────────────────┬───────────────────────┤
│   DATA Schema   │   TOOLS Schema     │   AGENTS Schema       │
│                 │                    │                       │
│  DIM_CUSTOMER   │  Semantic View:    │  Cortex Agent:        │
│  DIM_PRODUCT    │  RETAIL_ANALYTICS  │  RETAIL_INTELLIGENCE  │
│  DIM_COUNTRY    │                    │  _AGENT               │
│  FACT_          │  (10 VQRs,         │                       │
│  TRANSACTIONS   │   4 relationships, │  (text-to-SQL tool,   │
│                 │   4 tables)        │   3 skills,           │
│  5,942 customers│                    │   orchestration +     │
│  5,305 products │  Skills Stage:     │   response instrs)    │
│  1,041,671 txns │  cancellation_alert│                       │
│  38 countries   │  customer_rfm      │                       │
│                 │  basket_insight    │                       │
└─────────────────┴────────────────────┴───────────────────────┘
```

---

## 📊 Dataset

**Source:** [UCI Online Retail II Dataset](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci)

| Property | Value |
|---|---|
| Retailer | UK-based online gift-ware store |
| Period | December 2009 — December 2011 |
| Transactions | 1,041,671 |
| Customers | 5,942 |
| Products | 5,305 SKUs |
| Countries | 38 |
| Currency | British Pounds (£) |

---

## 🤖 Agent Capabilities

The `RETAIL_INTELLIGENCE_AGENT` can answer natural language questions about:

- 📈 Revenue trends by country, product, and time period
- 🏆 Top performing products and customers
- 🌍 Geographic market analysis
- 🔄 Cancellation and return patterns

### Skills

| Skill | Description |
|---|---|
| `cancellation_alert` | Z-score anomaly detection on cancellation rates by country and product |
| `customer_rfm_report` | RFM segmentation — Champions, Loyal, At Risk, Lost |
| `basket_insight` | Market basket analysis with Support, Confidence, and Lift metrics |

---

## 💡 Key Findings

### RFM Customer Segmentation
| Segment | Customers | Total Revenue | Avg Order Value |
|---|---|---|---|
| Champions | 1,278 | £12,077,266 | £9,450 |
| Loyal | 655 | £2,711,383 | £4,139 |
| Other | 2,544 | £2,506,713 | £985 |
| Lost | 1,245 | £317,086 | £254 |
| At Risk | 156 | £130,980 | £839 |

> 💡 33% of customers (Champions + Loyal) generate 83% of total revenue

### Basket Analysis — Top Cross-Sell Finding
The **Herb Marker collection** shows a **132–140× lift** with **79–93% confidence** — 
customers buying one herb marker variety are ~135× more likely to buy another. 
Recommendation: sell as a bundle set.

### Strategic Recommendations
1. **Protect Champions, win back Loyals** — revenue is dangerously concentrated in top customers
2. **Bundle high-lift product pairs** — Herb Markers, Jumbo Bags, Lunch Bag designs
3. **Diversify beyond UK** — 85% revenue dependency; proven footholds in Netherlands, Germany, France

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| Snowflake Cortex Code (CoCo) | AI-native IDE — semantic view, agent, evaluations |
| Snowflake Cortex Analyst | Text-to-SQL over semantic view |
| Snowflake Cortex Agent | Orchestration + skill execution |
| Snowflake CoWork | Conversational agent interface |
| Snowsight Workspaces | SQL + Python execution environment |

---

## 📁 Repo Structure

```
snowflake-retail-ai-agent/
├── README.md
├── .gitignore
├── Setup/
│   ├── 01_setup.sql        # Warehouse, database, schemas, tables
│   ├── 02_copy_files.py    # Upload CSVs to Snowflake stage
│   └── 03_load_data.sql    # Load and verify all 4 tables
├── Prompts/
│   ├── semantic_view.md    # CoCo prompt → RETAIL_ANALYTICS semantic view
│   ├── agent.md            # CoCo prompt → RETAIL_INTELLIGENCE_AGENT
│   └── evaluations.md      # CoCo prompt → evaluation framework
└── Skills/
    ├── cancellation_alert/
    │   └── SKILL.md
    ├── customer_rfm_report/
    │   └── SKILL.md
    └── basket_insight/
        └── SKILL.md
```

---

## 🚀 How to Reproduce

### Prerequisites
- Snowflake Enterprise trial account (AWS US-East or US-West)
- Cortex Code (CoCo) desktop app installed
- Python 3.8+ with `pandas` installed
- Kaggle account to download the dataset

### Step 1 — Get the Data
Download the [UCI Online Retail II dataset](https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci) 
from Kaggle and place the CSV in a local folder.

### Step 2 — Run Setup SQL
Open `Setup/01_setup.sql` in a Snowflake Workspace and run all statements.
This creates the warehouse, database, schemas, stages, and star-schema tables.

### Step 3 — Upload Data to Stage
Upload both CSV files to `@HOL_ONLINE_RETAIL.DATA.RETAIL_DATA_STAGE` via 
Snowsight (Data → Databases → HOL_ONLINE_RETAIL → DATA → Stages → RETAIL_DATA_STAGE → + Files).

### Step 4 — Load Data
Run `Setup/03_load_data.sql` in the Workspace. Verify row counts:

| Table | Rows |
|---|---|
| DIM_COUNTRY | 43 |
| DIM_PRODUCT | 5,305 |
| DIM_CUSTOMER | 5,942 |
| FACT_TRANSACTIONS | 1,041,671 |

### Step 5 — Create Semantic View (CoCo)
In CoCo chat panel:
```
/semantic-view @semantic_view.md
```

### Step 6 — Create Agent (CoCo)
In CoCo chat panel:
```
/cortex-agent @agent.md
```

### Step 7 — Run Evaluations (CoCo)
In CoCo chat panel:
```
@evaluations.md
```
Expected: ~83% Answer Correctness, 100% Logical Consistency

### Step 8 — Test in CoWork
Open Snowflake CoWork, select `RETAIL_INTELLIGENCE_AGENT` and start asking questions!

---

## 📈 Evaluation Results

| Metric | Score |
|---|---|
| Answer Correctness | 83% |
| Logical Consistency | 100% |

---

## 👤 Author
**Talha** — [LinkedIn](https://linkedin.com/in/your-profile) | [GitHub](https://github.com/your-username)

---

## 📄 License
MIT License — feel free to fork and build your own version!

---

## 🙏 Acknowledgements
- Inspired by the [Snowflake CoCo + CoWork HOL](https://github.com/sfc-gh-cserrano/coco_cowork_agent_hol) by Carlos Serrano
- Dataset: UCI Online Retail II via Kaggle
