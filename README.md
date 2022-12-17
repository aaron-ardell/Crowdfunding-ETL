# Crowdfunding-ETL

## Overview
With the reception of a new dataset, Independent Funding wants us to analyze the information concerning their backers. For this project we'll:
1. Extract the data from a CSV file using Python and Pandas to create a DataFrame.
2. In the Dataframe, with more Python and Pandas strategies we'll transform and clean the data into a more effective form before loading into postgresql.
3. Next, we'll create an ERD, a table schema and load the data into a postgreql table.
4. Finally, utilizing SQL queries we'll combine our previously created campaign and contacts tables with our new backers table to produce answers to the following questions:
    * Verify the new backers table with the campaign table utilizing the backers_count column.
    * Create a list of campaign contact emails/information related to live campaigns and how much of their goal is remaining.
    * Create a list of backers information related to live campaigns they've supported and how much of those goals are remaining.

## Process

### Extracting

Loading the CSV into a DataFrame, then converting each row into a dictionary. We'll reiterate through all of the rows of data adding them toa  new list.

```
backers_data = pd.read_csv("backer_info.csv")

dict_values = []
for i, row in backers_data.iterrows():
    data = row['backer_info']
    converted_data = json.loads(data)
    row_values = [v for k, v in converted_data.items()]
    dict_values.append(row_values)
```

Then we can create our own columns of data in preparation for uploading.

`backers_df = pd.DataFrame(dict_values, columns=['backer_id', 'cf_id', 'name', 'email'])`

## Transforming

First, we'll check the data types of the new dataframe. Next, we'll seperate the name column into separate first name and last name columns. Once we accomplish this, we'll be able to drop the redundant name column.

```
backers_df.info()

backers_df[["first_name", "last_name"]] = backers_df["name"].str.split(' ', n=1, expand=True)

backers_df_clean = backers_df.drop(["name"], axis=1)
```

Rearrange our columns and create a new CSV without the index.

`backers_df_clean.to_csv('backers_info.csv', encoding='utf8', index=False)`

## Creating ERD and Table Schema

![This is an image]()

![This is an image]()

