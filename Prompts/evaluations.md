# Evaluations Prompt: Online Retail Intelligence Agent

## Context
Run evaluations against the agent:
`HOL_ONLINE_RETAIL.AGENTS.RETAIL_INTELLIGENCE_AGENT`

Using the semantic view:
`HOL_ONLINE_RETAIL.TOOLS.RETAIL_ANALYTICS`

## Task
1. Query the underlying tables to compute ground truth answers
2. Create an evaluation dataset with 10 questions across 5 categories
3. Register the dataset using SYSTEM$CREATE_EVALUATION_DATASET
4. Run evaluations measuring answer_correctness and logical_consistency
5. Present results with per-question scores

## Evaluation Questions

### Category 1: Basic Metrics
- What is the total revenue across all transactions?
- How many total transactions are in the dataset?
- What is the average revenue per transaction?

### Category 2: Dimensional Analysis
- Which country generates the most revenue?
- What are the top 3 countries by number of transactions?

### Category 3: Product Analysis
- What is the top selling product by revenue?
- What is the top selling product by quantity sold?

### Category 4: Trend Analysis
- Which month had the highest revenue?
- Show the monthly revenue trend across all years.

### Category 5: Cancellation Analysis
- Which country has the highest cancellation rate?

## Expected Scores
- Answer Correctness: ~90%+
- Logical Consistency: 100%