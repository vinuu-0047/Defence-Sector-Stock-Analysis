import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import glob
import os

#Define the absolute folder path using a raw string (r'')
folder_path = r'D:\projects\Defence_Project\Defence_Dataset'

#Find all CSV files in the folder using glob
file_paths = glob.glob(os.path.join(folder_path, '*.csv'))

df_list = []

#Loop through each file path to load the datasets
for file in file_paths:
    #Read the current CSV file
    temp_df = pd.read_csv(file)
    
    #Extract the ticker symbol from the file name (e.g., 'HAL' from 'HAL.NS.csv')
    ticker_name = os.path.basename(file).split('.')[0]
    
    #Add a new column to identify which stock the data belongs to
    temp_df['Ticker'] = ticker_name
    
    #Append the dataframe to our list
    df_list.append(temp_df)

#Concatenate all individual stock dataframes into one large dataframe
df = pd.concat(df_list, ignore_index=True)
df.to_csv("combined_defence_data.csv", index=False)
#1. Data Cleaning
#Drop any rows that contain missing (NaN) values to ensure data integrity
df.dropna(inplace=True)

#Remove any completely duplicated rows
df.drop_duplicates(inplace=True)

#Convert the 'Date' column from string/object format to datetime format for proper time series plotting
df['Date'] = pd.to_datetime(df['Date'])
#2. Exploratory Data Analysis (EDA)
#Display summary statistics (count, mean, std, min, percentiles, max) for numerical columns
print("--- Summary Statistics ---")
print(df.describe())

#Visualization 1: Line Plot of Closing Prices over Time
plt.figure(figsize=(10, 5))
#Plot the 'Close' price on the y-axis, 'Date' on the x-axis, separated by 'Ticker'
sns.lineplot(data=df, x='Date', y='Close', hue='Ticker')
plt.title('Closing Stock Prices Over Time by Ticker')
plt.xlabel('Date')
plt.ylabel('Closing Price (INR)')
#Move the legend outside the plot so it doesn't cover the lines
plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
plt.tight_layout()
plt.show()
#3.Additional Analysis

#Visualization 2: Correlation Heatmap

#This helps us understand how the different price metrics correlate with volume
plt.figure(figsize=(8, 6))
#Select only numerical columns for correlation calculation
numerical_cols = df[['Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume']]
correlation_matrix = numerical_cols.corr()
#Plot the heatmap using seaborn
sns.heatmap(correlation_matrix, annot=True, cmap='coolwarm', fmt=".3f")
plt.title('Correlation Matrix of Stock Variables')
plt.show()