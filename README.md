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

![This is an image](https://github.com/aaron-ardell/Crowdfunding-ETL/blob/main/crowdfunding_db_relationships.png.png)

```
CREATE TABLE "campaign" (
    "cf_id" int   NOT NULL,
    "contact_id" int   NOT NULL,
    "company_name" varchar(100)   NOT NULL,
    "description" text   NOT NULL,
    "goal" numeric(10,2)   NOT NULL,
    "pledged" numeric(10,2)   NOT NULL,
    "outcome" varchar(50)   NOT NULL,
    "backers_count" int   NOT NULL,
    "country" varchar(10)   NOT NULL,
    "currency" varchar(10)   NOT NULL,
    "launch_date" date   NOT NULL,
    "end_date" date   NOT NULL,
    "category_id" varchar(10)   NOT NULL,
    "subcategory_id" varchar(10)   NOT NULL,
    CONSTRAINT "pk_campaign" PRIMARY KEY (
        "cf_id"
     )
);

CREATE TABLE "contacts" (
    "contact_id" int   NOT NULL,
    "first_name" varchar(50)   NOT NULL,
    "last_name" varchar(50)   NOT NULL,
    "email" varchar(100)   NOT NULL,
    CONSTRAINT "pk_contacts" PRIMARY KEY (
        "contact_id"
     )
);

CREATE TABLE "category" (
    "category_id" varchar(10)   NOT NULL,
    "category_name" varchar(50)   NOT NULL,
    CONSTRAINT "pk_category" PRIMARY KEY (
        "category_id"
     )
);

CREATE TABLE "subcategory" (
    "subcategory_id" varchar(10)   NOT NULL,
    "subcategory_name" varchar(50)   NOT NULL,
    CONSTRAINT "pk_subcategory" PRIMARY KEY (
        "subcategory_id"
     )
);

CREATE TABLE "backers" (
    "backer_id" varchar(30)   NOT NULL,
    "cf_id" int   NOT NULL,
    "first_name" varchar(30)   NOT NULL,
    "last_name" varchar(30)   NOT NULL,
    "email" varchar(30)   NOT NULL,
    CONSTRAINT "pk_backers" PRIMARY KEY (
        "backer_id"
     )
);


ALTER TABLE "campaign" ADD CONSTRAINT "fk_campaign_contact_id" FOREIGN KEY("contact_id")
REFERENCES "contacts" ("contact_id");

ALTER TABLE "campaign" ADD CONSTRAINT "fk_campaign_category_id" FOREIGN KEY("category_id")
REFERENCES "category" ("category_id");

ALTER TABLE "campaign" ADD CONSTRAINT "fk_campaign_subcategory_id" FOREIGN KEY("subcategory_id")
REFERENCES "subcategory" ("subcategory_id");

ALTER TABLE "backers" ADD CONSTRAINT "fk_backers_cf_id" FOREIGN KEY("cf_id")
REFERENCES "campaign" ("cf_id");
```

## SQL Analysis

Verifying amount of backers for our new backers table with our previous campaign table.

```
SELECT cf_id, 
	backers_count
FROM campaign 
WHERE campaign.outcome = 'live'
GROUP BY campaign.cf_id
ORDER BY backers_count DESC;

SELECT backers.cf_id, 
	COUNT(backers.backer_id)
FROM backers
INNER JOIN campaign
ON backers.cf_id = campaign.cf_id 
WHERE campaign.outcome = 'live'
GROUP BY campaign.cf_id, backers.cf_id
ORDER BY COUNT(backer_id) DESC;
```

Create a list of campaign contact emails/information related to live campaigns and how much of their goal is remaining. We needed to subtract the value from the goal column from the value of the pledged column to come up with a column with the remaining goal amount.

```
SELECT contacts.first_name,
	contacts.last_name,
	contacts.email,
	(campaign.goal-campaign.pledged) as "Remaining Goal Amount"
INTO email_contacts_remaining_goal_amount
FROM contacts
INNER JOIN campaign
ON contacts.contact_id = campaign.contact_id
WHERE campaign.outcome = 'live'
ORDER BY (goal-pledged) DESC;
```

Create a list of backers information related to live campaigns they've supported and how much of those goals are remaining.

```
SELECT backers.email,
	backers.first_name,
	backers.last_name,
	campaign.cf_id,
	campaign.company_name,
	campaign.description,
	campaign.end_date,
	(campaign.goal-campaign.pledged) as "Left of Goal"
INTO email_backers_remaining_goal_amount
FROM backers
INNER JOIN campaign ON backers.cf_id = campaign.cf_id
WHERE campaign.outcome = 'live'
ORDER BY backers.email DESC;
```
