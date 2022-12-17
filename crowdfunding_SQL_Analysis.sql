-- Challenge Bonus queries.
-- 1. (2.5 pts)
-- Retrieve all the number of backer_c6ounts in descending order for each `cf_id` for the "live" campaigns. 
SELECT cf_id, 
	backers_count
FROM campaign 
WHERE campaign.outcome = 'live'
GROUP BY campaign.cf_id
ORDER BY backers_count DESC;


-- 2. (2.5 pts)
-- Using the "backers" table confirm the results in the first query.
SELECT backers.cf_id, 
	COUNT(backers.backer_id)
FROM backers
INNER JOIN campaign
ON backers.cf_id = campaign.cf_id 
WHERE campaign.outcome = 'live'
GROUP BY campaign.cf_id, backers.cf_id
ORDER BY COUNT(backer_id) DESC;


-- 3. (5 pts)
-- Create a table that has the first and last name, and email address of each contact.
-- and the amount left to reach the goal for all "live" projects in descending order. 
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



-- Check the table


-- 4. (5 pts)
-- Create a table, "email_backers_remaining_goal_amount" that contains the email address of each backer in descending order, 
-- and has the first and last name of each backer, the cf_id, company name, description, 
-- end date of the campaign, and the remaining amount of the campaign goal as "Left of Goal". 
-- email_backers_remaining_goal_amount
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

-- Check the table


