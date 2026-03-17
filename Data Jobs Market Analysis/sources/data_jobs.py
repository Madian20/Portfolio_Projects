# Importing relevant liberaries
import pandas as pd
from adjustText import adjust_text
from datasets import load_dataset

# Loading Data
dataset = load_dataset('lukebarousse/data_jobs')
df = dataset['train'].to_pandas()

# Importing Data to CSV file
df.to_csv(r'D:\data_jobs.csv', index=False)
