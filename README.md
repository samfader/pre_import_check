PreCheck v00.01
===============

*   I. Before using pre_check.rb  
*   II. How to use pre_check.rb
	*	Steps to run PreCheck
	*	Tips
	* 	How long should PreCheck take to finish?
	*	Have problems using PreCheck?
*	III. Acknowledgments
	*	Regarding DRY code
	*	Regarding error handling and `` `rescue => er` ``
*	IV. About PreCheck	
	*	Why was it made?
	*	What does it do?
	*	What's with the colors?
	*	Suggestions/Fixes/etc.
*   V. Next release
	*	When can I expect the next release?
	*	What is being planned for next release?

* * *

##I. Before using pre_check.rb##
Read everything listed in this document, it may answer any questions you have now or in the future.

To run PreCheck you will need to install Dev Tools Command Line, Homebrew, RVM and Ruby 2.0.0. The link below will take you to a great link on how to install all that is needed for your Mac.
[Instructions to install](http://www.moncefbelyamani.com/how-to-install-xcode-homebrew-git-rvm-ruby-on-mac/#clt "Title")

##II. How to use pre_check.rb##

###Steps to run PreCheck###
1. Open a terminal window.   
NOTE: you can also choose different colors of terminal windows by clicking on _Shell > New Window > and choosing one like Pro or Basic_
2. Navigate to the folder where pre_check.rb and pre_check_utils.rb are located.  
3. Type `` `ruby pre_check.rb ` `` NOTE: the space before and after prech_check.rb are necessary.  
4. Type the folder location or drag and drop the folder (unzipped) into terminal.  
NOTE: If the domain that this import is inteded for is using Google Apps Integration, you can check the users.csv file for the google domain, or sub domain, by doing the following. Not required to have either of the domains to run PreCheck. Again spacing is essential for pre_check to run correctly. 
>`` `ruby pre_check.rb path/to/folder @domain1.com @domain2.com` ``  
 
5. Finally hit the "Enter" key  

###How long should PreCheck take to finish?###
This will depend on 3 factors:

1. The size of the folder
2. The number of errors
3. The processing power of your computer

Here are some examples:

| Size | Errors | Time |
| ---- | ------ | ---- |
| 7.8 MB | 4000+ | 1 min, 40 sec |
| 8.7 MB | 52+ | 1 min, 7 sec |
| 635 KB | 15 | 13 sec |

###Tips###
1. You can copy the output from PreCheck and email it to a customer so that they can check on warnings such as duplicate import_ids, etc.
2. This program is intended to aid in quickly finding possible import issues, it is not meant to replace opening up the file and actually looking at the data. I do however run the PreCheck currently to give me a quick view of where I should start searching.
3. Even when a file is encoded as UTF-8, there can still be issues. Try opening the file and exporting it out to UTF-8 to see if that resolves an error within PreCheck.
 

###Have problems using PreCheck?###
Please feel free to contact me and let me know what isn't working. I really want this to be helpful and will keep working on it until it is helpful.

##III. Acknowledgments##

###Regarding DRY code ###
I know that the code could be more dry but for this first iteration I just wanted to get something out that was working and could benefit me, my team and ultimately my customers. I welcome any suggestions to making the code DRY.

###Regarding error handling and `` `rescue => er` ``###
I realize that using `` `rescue => er` `` will prevent the use of CTRL + C but I figured since I am doing it individually by methods, then it won't be a problem. As I become more proficient with error handling (and writing better code), then I figure I won't have to result to poor error handling.

##IV. About Pre_Check.rb##
###Why was it made?###
This is an unoffical Haiku Learning program to check imports according to Haiku Learning's specifications. The import issues I see are too common to be looking for a needle in a small haystack. I would rather just have a program do all the work.
###What does it do?###
*	displays contents of folder, so it is easy to see if file names were not spelled correctly

*	checks to see if csv files are partial or full, if any partial then it will run as partial
	*	notes how many were partial import files

*	checks encoding of import files
	*	if encoding is other than UTF-8 then, color will change to red
	
*	all csv files have the following checked:
	*	if file exists
	*	list number of columns compared to expected
	*	compares column titles to expected
	*	compares # of rows
	
*	(update)users.csv
	*	(optional, depends on args 1 and 2) compares one or two google domains
		*	displays a quick grid of those that matched, didn't or were nil/empty
	*	checks for duplicate import ids, and how many times they are duplicated
		*	and displays the duplicates, i.e. 20323(3) = import id 20323 duplicated 3 x
	*	checks that usernames only starts with and/or contains letters, numbers, underscores, dots or dashes
	*	checks that usernames are either less than 3 characters or greater than 68 characters in length.
	*	checks that passwords only starts with and/or contains letters, numbers, underscores, dots or dashes
	*	checks that passwords are either less than 6 characters or greater than 40 characters in length.
	*   checks if there are any spaces or apostrophes in the login
		*	and displays the login and row i.e. "de santiagocr106" at row 29497
	*	checks org id values in users.csv file compared to (update_)organizations.csv
		*	and displays those that matched and a grid of matched, no match and nil/empty	

*	(update)classes.csv
	*	checks teacher id values from (update)classes.csv with import ids from (update)users.csv
		*	and displays import ids of teachers not found and a grid of matched, no match and nil/empty
	*	checks for duplicate import ids, and how many times they are duplicated
		*	and displays the duplicates, i.e. 20323(3) = import_id 20323 duplicated 3 x
	*	checks org id values in users.csv file compared to (update_)organizations.csv
		*	and displays those that matched and a grid of matched, no match and nil/empty
		
*	(update)roster.csv
	*	checks (update)roster user id value with import id in (update)user.csv
		*	and displays non duplicated user id and grid of matched, no match and nil/empty	
	*	checks (update)roster class id value with import id in (update)classes.csv
		*	and displays non duplicated class id and grid of matched, no match and nil/empty  

###What's with the colors?###
Currently I am using the color scheme below to enhance readability.

*	*green* 	= normal/good ouput
*	*yellow* 	= cautions/directions
*	*red*		= warnings
*	*cyan*	= fyi, not really a caution (i.e. have more columns than expected)
* 	*pink*	= make output easier to find (i.e. duplicate import_id, etc.)
*	*blue*	= help some output standout even more (i.e. logins with spaces or apostrophes)

###Suggestions/Fixes/etc.###
Please feel free to email all suggestions, fixes, etc. to me and I will do my best to add asap.

##V. Next release##

###When can I expect the next release?###
As soon as I submit this to github tomorrow I will already be working on the next release. I will not stop until this program can flag almost every known import issue.

###What is being planned for next release?###
Honestly this will depend on need and feedback however the following are what I plan on adding:  

*	better documentation - I ran out of time for this first release but hope to comment better next version
*	better error handling
*	more checks like:
	*	required columns for nil/empty
	*	if using LDAP, password should be blank
	*	giving quick count of # of user_types
	*	google_id is unique
	*	login is unique
*	quick vs. full check possibly, to check for all possible files instead of just the big five
*	better way to view the output
*	more meaningful wording
*	find a better solution to .split(",") and combine methods 
	*	combine methods compare_expected_column_titles_with_actual_from_csv and count_number_of_columns_in_csv_file
*	create easier way to read errors/warning/alerts, maybe even have a total of each, or % or summary of how the import will do (i.e. 59%, this import will fail)




