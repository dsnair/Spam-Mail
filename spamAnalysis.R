junkmail = readLines("Junkmail", encoding = "UTF-8")  # reads Chinese characters in file

# QUESTION 1 #

# get fromEMail #
beginEmail = grep("^From ", junkmail)  # line number in file where each email begins
firstFromLine = junkmail[beginEmail]  # view the first line of each email
totalEmails = length(firstFromLine)  # total number of emails

# assign eMailID (1 to n) for each email #
eMailID = 1:totalEmails

# split firstFromLine into individual strings
firstFromLineParse = sapply(eMailID, function(h) unlist(strsplit(firstFromLine[h], " ")))  # list

# get fromEMail, date, dayOfWeek, time #
fromEMail = rep(NA, totalEmails)
dayOfWeek = rep(NA, totalEmails)
time = rep(NA, totalEmails)
month = rep(NA, totalEmails)
day = rep(NA, totalEmails)
year = rep(NA, totalEmails)

for (i in eMailID) {
  j = grep("@", firstFromLineParse[[i]])
  fromEMail[i] = firstFromLineParse[[i]][j]  # From email address per email
  j = grep("(Mon|Tue|Wed|Thu|Fri|Sat|Sun)", firstFromLineParse[[i]])
  dayOfWeek[i] = firstFromLineParse[[i]][j]  # day of week per email
  j = grep("[[:digit:]]{2}:", firstFromLineParse[[i]])
  time[i] = firstFromLineParse[[i]][j]  # time per email
  j = grep("(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)", firstFromLineParse[[i]])
  month[i] = firstFromLineParse[[i]][j]  # month per email 
  k = grep("^[[:digit:]]{1,2}$", firstFromLineParse[[i]])
  day[i] = firstFromLineParse[[i]][k]  # day/date number per email
  l = grep("[[:digit:]]{4}$", firstFromLineParse[[i]])
  year[i] = firstFromLineParse[[i]][l]  # year per email
}
fromEMail
dayOfWeek
time
date = sapply(eMailID, function(h) paste(month[h], day[h], year[h], sep = " "))
date

# QUESTION 3 and QUESTION 1: contd. #

# get each email header (Q3) #
beginHeader = grep("Return-Path:", junkmail)  # starting line number for each email header
endHeader = grep("X-Virus-Scanned:", junkmail)  # ending line number for each email header
header = sapply(eMailID, function(h) junkmail[beginHeader[h]:endHeader[h]])  # email header; list 
header[[1]]  # check: view header of 1st email

# get each email body (Q3) #
endEmail = grep("------------=_(.*?)--", junkmail)  # line number in file where each email ends
endEmail = endEmail - 1  # do not print grepped line in email body
endHeader = endHeader + 1  # do not print grepped line in email body
body = sapply(eMailID, function(h) junkmail[endHeader[h]:endEmail[h]])  # email body; list
body[[1]]  # check: view 1st email body

# get entire email content per eMailID
individualEmail = sapply(eMailID, function(h) junkmail[beginEmail[h]:endEmail[h]])
individualEmail[[1]]  # check: view 1st entire email

# get fromTrueName per email (Q1) #
secndFromLine = rep(NA, totalEmails)
fromTrueName = rep(NA, totalEmails)

for (i in eMailID) {
  j = grep("^From: \"", individualEmail[[i]])
  if(length(j) != length(integer(0))) { # if grep found a match, proceed
    # don't want duplicates of From: lines in each email, so only take 1st element
    secndFromLine[i] = individualEmail[[i]][j[1]]
    # fromTrueNames is 2nd element of strsplit
    fromTrueName[i] = unlist(strsplit(secndFromLine[i], "\""))[2]
  }
}
secndFromLine  # check: view all From: lines
fromTrueName  # note: UFT-8 encoding in effect for fromTrueName[60]
sum(is.na(fromTrueName))  # number of missing true names

# get subject per email (Q1) #
subjectLine = rep(NA, totalEmails)
subject = rep(NA, totalEmails)

for (i in eMailID) {
  j = grep("\\{SPAM\\}", individualEmail[[i]])
  subjectLine[i] = individualEmail[[i]][j]  # got Subject: {SPAM} line per email
  subject[i] = unlist(substring(subjectLine[i], 17, nchar(subjectLine[i])))  # subject per email
}
subject  # note: UFT-8 encoding in effect for subject[60]

# get # of email attachments per email (Q3) #
numAttachment = rep(0, totalEmails)

for (i in eMailID) {
  j = grep("Content-Disposition: attachment; filename=", individualEmail[[i]])
  if(length(j) != length(integer(0))) {
    numAttachment[i] = as.numeric(length(j))  # count number of attachments per email
  }
}
numAttachment

# create data frame (Q1) #
junkmailDF = data.frame(eMailID, fromEMail, fromTrueName, date, dayOfWeek, time, subject)
head(junkmailDF)

# create a list of header, body, and number of attachments per email (Q3) #
headBodyAttach = list()
for (i in eMailID) {
  headBodyAttach[[i]] = list(header[[i]], body[[i]], numAttachment[[i]])
}
headBodyAttach[[2]] # check: 2nd email

# QUESTION 2 #

# get total spam points per email #
spamPointsLine = rep(NA, totalEmails)
totalSpamPoints = rep(0, totalEmails)

for (i in eMailID) {
  j = grep("[[:digit:]]{1,2}\\.[[:digit:]]{1,2} points,", individualEmail[[i]])
  spamPointsLine[i] = individualEmail[[i]][j]  # get "number points, 5 required" line per email
  # total spam points is 1st element of strsplit
  totalSpamPoints[i] = unlist(strsplit(spamPointsLine[i], " "))[1]
}
totalSpamPoints = as.numeric(totalSpamPoints)
totalSpamPoints

# create a list of total spam points, spam indicators and their scores per email #
beginAnalysis = rep(NA, totalEmails)
endAnalysis = rep(NA, totalEmails)
analysis = list()
spamScore = list()
spamIndicator = list()
analysisDF = list()
spamAssassin = list()

for (i in eMailID) {
  beginAnalysis[i] = grep("---- Start SpamAssassin results", individualEmail[[i]])
  endAnalysis[i] = grep("---- End of SpamAssassin results", individualEmail[[i]])
  analysis[[i]] = individualEmail[[i]][beginAnalysis[i]:endAnalysis[i]]  # spam analysis per email; list
  analysis[[i]] = analysis[[i]][3:(length(analysis[[i]]) - 2)]  # remove header & footer
  spamScore[[i]] = substring(analysis[[i]], 2, 7)  # spam scores per email; list
  spamIndicator[[i]] = substring(analysis[[i]], 10, nchar(analysis[[i]]))  # spam indicator per email; list
  analysisDF[[i]] = data.frame(spamScore[[i]], spamIndicator[[i]])  # data frame
  colnames(analysisDF[[i]]) = c("spam score", "spam indicator")  # name data frame columns
  spamAssassin[[i]] = list(totalSpamPoints[i], analysisDF[[i]])  # list of all info
}

analysis[[2]]  # check: view spam analysis of 2nd email
spamScore[[2]]  # check: view spam scores of 2nd email
spamIndicator[[2]]  # check: view spam indicators of 2nd email
analysisDF[[2]]  # check: view data frame of spam indicators & their scores of 2nd email
spamAssassin[[2]]  # check: view list of all info for 2nd email

# QUESTION 6 #

CharVecFreq = function(charVec, n) {
  # Outputs the frequency of each element in a character vector.
  #
  # Args:
  #   charVec: A character vector.
  #   n: An integer.
  #
  # Returns:
  #   The frequency of each element in a character vector.
  charVecFreq = as.data.frame.table(sort(table(charVec), decreasing = T))
  charVecFreq[charVecFreq[, 2] >= charVecFreq[n, 2], ]
}

# 3 most fromEMail senders; list all ties for 3rd frequent #
CharVecFreq(fromEMail, 3)

# QUESTION 12 #

# 10 most frequent spam indicators; list all ties for 10th frequent #
spamIndicatorVec = unlist(spamIndicator)  # convert from list to vector
CharVecFreq(spamIndicatorVec, 10)

# QUESTION 10 #

ToLower = function(string) {
  # Converts a string to lowercase using tolower(), unless it contains foreign fonts.
  # Example, Chinese fonts in subject[60].
  #
  # Args:
  #   string: character string.
  #
  # Returns:
  #   lowercase string unless it contains foreign characters.
  y = string
  tryError = tryCatch(tolower(string), error = function(e) e)
  if (!inherits(tryError, "error")) { # if no error obtained
    y = tolower(string)
  }
  return(y)
}

# convert subject to lower case; check: note formatSubject[60]
formatSubject = sapply(1:totalEmails, function(h) ToLower(subject[h]))

formatSubject = gsub("[[:punct:]]", " ", formatSubject)  # remove non-alphabetic symbols
formatSubject = gsub("[[:digit:]]", " ", formatSubject)  # remove numbers
subjectParse = unlist(strsplit(formatSubject, " "))
i = grep("^$", subjectParse)  # find "" i.e. blank strings
subjectParse = subjectParse[-i]  # remove blank strings

# 20 most frequent keywords used in the subject line; list all ties for 20th frequent #
subjWordFreq = CharVecFreq(subjectParse, 20)

# Organize to present in tabular form using library xtable
agSubjWordFreq = aggregate(charVec ~ Freq, data = subjWordFreq, FUN = toString)

# QUESTION 7 #

# date when emails were received as mm/dd/yyyy #
formatDate = format(strptime(date, "%b %d %Y"), "%m/%d/%Y")
formatDate

# QUESTION 8 #

# graph the distribution of emails by the days of the week #
emailDayFreq = sort(table(dayOfWeek), decreasing = T)
barplot(emailDayFreq, ylab = "Email Frequency", ylim = c(0, 20), xlab = "Day of the Week")

# QUESTION 9 #

# email distribution over 24 hours of day; 2 hr interval; start at midnight #
# install.packages("chron")
library(chron)
require(chron)
formatTime = hours(chron(times. = time, format = c(times = "h:m:s")))
hist(formatTime, breaks = 12, main = "", xlab = "24 Hours", axes = F)
axis(1, at = seq(0, 24, by = 2))
axis(2, at = seq(0, 12))

# Organize to present in tabular form using library xtable
formatTimeFreq = as.data.frame.table(sort(table(formatTime), decreasing = T))
agformatTimeFreq = aggregate(formatTime ~ Freq, data = formatTimeFreq, FUN = toString)

# QUESTION 11 #

# histograme of total spam points of all emails; 14 bins
hist(totalSpamPoints, breaks = seq(min(totalSpamPoints), max(totalSpamPoints), length.out = 14), 
     xlab = "Spam Points", main = "")

# QUESTION 13 #

# eMailID's of 5 lowest total spam points and their email address #
orderTotSpmPts = order(totalSpamPoints)[1:5]
fromEMail[orderTotSpmPts]

# QUESTION 14 #
InspectEMail = function(eMailID, numLines, part = c("header", "body", "attachment")) {
  # Prints email header or body lines, or number of file attachements for a given e-mail ID.
  #
  # Args:
  #   eMailID: An integer ID of the e-mail.
  #   numLines: A numeric number of email header or body lines to be printed for the eMailID;
  #             ignored for attachments.
  #   part: Select an item to print: header or body (list), or number of attachments (numeric).
  #
  # Returns:
  #   The specified number of email header or body lines; or number of attachments for a specified e-mail ID.
  if (eMailID > totalEmails) {
    warning("Warning: E-mail ID can not be greater than total number of emails.")
    return(NA)  # minimal logic checking
  } else if (numLines <= 0 | eMailID <= 0 | (numLines %% 1 != 0) | (eMailID %% 1 != 0)) {
      warning("Warning: E-mail ID and numLines must be positive integers.")
      return(NA)  # minimal logic checking
    } else if (part == "header") {
        # if numLines > header length, then head() prints all lines by default
        head(header[[eMailID]], numLines)
      } else if (part == "body") {
          head(body[[eMailID]], numLines)
        } else {
          return(numAttachment[eMailID])
        } 
}

# check:
InspectEMail(74, 6, "attachment")
InspectEMail(69, 2, "attachment")
InspectEMail(1, 58, "body")  # when numLines > length of body
InspectEMail(7, 62, "body")  # when length of body > numLines
InspectEMail(60, 20, "header")  # when numLines > length of header
InspectEMail(8, 10, "header")  # when length of header > numLines
InspectEMail(80, 1, "header")  # test warning
InspectEMail(0, 1, "body")  # test warning
InspectEMail(3.5, 1, "attachment")  # test warning

# QUESTION 15 #

# for the eMailID's with 5 lowest spam points, look at the 1st 20 lines of their email body #
sapply(orderTotSpmPts[1:5], function(h) InspectEMail(h, 20, "body"))
