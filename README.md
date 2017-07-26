# Project Description

Reassess e-mails that were previously classified as spam by spam detection software called SpamAssassin. Recommend attributes for spam e-mail classification.

## Data file type: raw/binary R data

# Work Summary
1. Data munging. The raw data consisted of e-mails with UTF-8 characters. Converted this raw data into data frame by rigorously using regular expressions.
2. Exploratory analysis to recommend spam classification criterion.

## Data Munging Tasks

1. Read in the e-mail data from the external Junkmail file and create a data frame with the following columns:
* eMailID (from 1 through n),
* fromEMail (note that some e-mails have more than one from field; one is fake),
* fromTrueName,
* date,
* dayOfWeek,
* time,
* subject. Some of these may be empty or missing.
2. For each e-mail, create a list that consists of two components: The total spam points assigned by spamAssassin and a data frame with two columns: the first column contains the type of the spam indicator (such as “From: does not include a real name”) and the second column contain the score for this indicator (such as 0.8). The elements should be accessible via the same eMailID as used in part 1.
3. For each e-mail, create a second list that consists of three components:
* The first one contains each row of the e-mail header as a separate string.
* The second one contains each row of the e-mail body as a separate string. Note that this may be html code.
* The third one is a single number that indicates the number of attachments to this e-mail. The elements should be accessible via the same eMailID as used in part 1.

## Data Analysis Questions

1. How many e-mails are there overall in this file?
2. How many e-mails do not contain a real name?
3. What are the 3 most frequent senders, based on the fromEMail addresses? If there is a tie, list all other senders as well that occur the same number of times as the 3rd one.
4. During which time period were these e-mails received? List the first and last date as “mm/dd/yyyy”. Do not use the format that is used in the e-mails.
5. Create a bar chart that shows the distribution of these e-mails during the seven days of the week. Sort from day with most e-mails to day with least e-mails received.
6. Create a histogram that shows the distribution of these e-mails over the 24 hours of a day. Work with 2–hour wide intervals, starting at midnight.
7. What are the 20 most frequent character–based keywords (such as buy, purchase, re, free, fwd) in the subject line across all e-mails? Translate all keywords to lower case. Remove all numbers, spaces, and any other non–alphabetic symbols. If there is a tie, list all other keywords as well that occur the same number of times as the 20th one.
8. Display the distribution of the total spam points of all e-mails.
9. What are the 10 most frequent spam indicators? If there is a tie, list all other spam indicators as well that occur the same number of times as the 10th one.
10. Return the eMailID’s of the e–mails with the 5 lowest total spam points. Which are those? No need to break any ties here. Just use the first one in your list in case of a tie.
11. Write a function called InspectEMail that has the following arguments:
* eMailID: a single e–mail ID
* part: this could be “header”, “body”, or “attachment”
* numLines: the number of lines to be shown (will be ignored for attachments) This function should show the first numLines of the part or simply indicate the number of attachments. If the actual number of lines in part is less than numLines, show all lines from part. Test your function for 6 different scenarios (two for each part).
12. For the 5 e-mails with the lowest total spam points, look at 20 lines from the “body”. Do all of these bodys look like spam to you?
13. So, what do you think of the overall performance of the SpamAssassin software? Base your conclusions on your previous results.
