# @author Scott Dobbins
# @version 0.9.7.2
# @date 2017-07-29 20:00


### Version History ###

0.1
This version mapped out semi-cleaned longitudinal and latitudinal target data
  from the United States Airforce in WW2 onto one color map with map labels.
Major changes: implemented basic data cleaning and basic plotting


0.2
This version mapped out semi-cleaned longitudinal and latitudinal target data
  from the United States Airforce in 4 major conflicts during the 20th century
  onto a selection of maps with map label options.
Major changes: added other datasets; added other maps and map options


0.3
This version maps out semi-cleaned longitudinal and latitudinal target data
  from the United States Airforce in 4 major conflicts during the 20th century
  onto a selection of maps with map label options and clickable, detailed tooltips.
Major changes: tooltips

0.3.1	Separated scripts into Shiny 3-file structure (with README.rm and code_graveyard.txt)
	Fixed leaflet tile attributions (sort of) and removed htmlEscapes
	Added app_id and app_code for HERE map usage
	Removed redundant initial drawings of map and labels
0.3.2	Made code much more readable with line breaks
	Edited formatting of popup labels

0.4
This version maps out all semi-cleaned longitudinal and latitudinal target data
  from the United States Airforce in 4 major conflicts during the 20th century
  onto a selection of maps with map label options and clickable, detailed tooltips.
Major changes: big data clean; incorporation of all Vietnam and Korea data

0.5
This version maps out all semi-cleaned longitudinal and latitudinal target data
  from the United States Airforce in 4 major conflicts during the 20th century
  onto a selection of maps with map label options and clickable, well-formatted, 
  detailed tooltips using speed advantages brought to it by data table functions.
Major changes: help cleaning and formatting with helper.R; speed-optimized with data table

0.6
This version maps out all semi-cleaned longitudinal and latitudinal target data
  from the United States Airforce in 4 major conflicts during the 20th century
  onto a selection of maps with map label options and clickable, well-formatted, 
  detailed tooltips using speed advantages brought to it by data table functions
  and cached outputs (while still enabling full refreshes of the displayed data).
Major changes: further organized code with cleaner.R; development-friendly caching

0.6.1	Additionally cleared up how data is input and processed
	Fixed Korean war dates
	Fixed how data is saved and read

0.7
This version maps out all semi-cleaned longitudinal and latitudinal target data
  from the United States Airforce in 4 major conflicts during the 20th century
  onto a selection of maps with map label options and clickable, well-formatted, 
  detailed tooltips using speed advantages brought to it by data table functions
  and cached outputs (while still enabling full refreshes of the displayed data).
Major changes: Shiny dashboard

0.8
This version maps out all semi-cleaned longitudinal and latitudinal target data
  from the United States Airforce in 4 major conflicts during the 20th century
  onto a selection of maps with map label options and clickable, well-formatted, 
  detailed tooltips using speed advantages brought to it by data table functions
  and cached outputs (while still enabling full refreshes of the displayed data).
  It also plots a bin-editable histogram of missions by date for each conflict.
Major changes: full sidebar; tabs for each war

0.8.1	Added stat boxes in the overview tab
	Made date restrictions apply to all data accessed in all tabs
	Made sampling occur after date restriction changes
	Opacity now updates with sample size as well

0.9
Version for class lecture
Major changes: Sandbox added; labeling added
Notes: sidebar and other parts reduced to what works

0.9.1	Fixed civilian tab
	Moved "which wars?" selectizeInput to the sidebar
	Made "which wars?" update civilian tab
	Increased speed of sandbox and removed one typo-bug

0.9.2	Added explanatory text box to overview tab for spacing
	Put comma delimiters in infoBoxes
	Increased maximum sample size
	Filtered out (0,0) GPS locations

0.9.3	Properly formatted tooltips for all conflicts
	Included all sandboxes for all conflicts

0.9.4	Functionalized code with vectorized helper functions
	Broke code up into more representative scripts

0.9.5	Implemented selectize inputs so that they filter and get updated
	Used data.table syntax to improve filtering and fix bugs in graphs

0.9.6	Redesigned cleaner.R to edit strings as factors for vast speed improvement
	Introduced parallel processing for a few steps

0.9.7	Wrote script to further clean WW2 weapon types, numbers, and total weights
	Implemented DataTable display

0.9.8	Improved style of code
	Did unit testing
	Created utils.R for debugging purposes
	Split README into README and NEWS

### Future version plans:

0.9.9	<finalize graphs and other tabs>

1.0	<misc bug fixes, data polishing, and tooltip improvement>
Complete version


### Future change notepad:

# render icons from within ui.R, not server.R

#******big deals:
# modify levels of factors instead of strings directly (forcats)
# purrr and map reduce stuff
# times with hms or ITime
# broom for list-columns of models etc
# eventually, Rmarkdown stuff
# proper noun phrase functions for aircaft don't work!#*** probably fixed***
# why can't I just set certain parts of the levels manually in place and then save them back in? don't use fct_recode or fct_other because they will mess it up I think.
# also figure out whether graphs should show totals or statistics (medians, means, and the like)
# make sure filters returning NAs don't mess things up--check if nomatch = 0 would be better

#*** lesser deals:
# further functionalize a lot of repeated code
# fix proxies to see if we can save redundancy
# see if different map_*() functions can improve speed
# see if broom can fix issues with the vectorized strsplit helper functions I made
# get regex working on levels (to set to "")
# duplicates appear in dataset (check for duplicates: same aircraft type, same day, same target area and type, same weapons and same num_attacking_aircraft)
# update country and other codes when knowable (generate list of code to description matches and fill in as possible)
# use all new data.table knowledge to rewrite cleaner.R, processor.R, and server.R (especially the filtering parts)
# use append() for get_unique_from_selected_wars?

#** other ideas:
#*Better ggplots, maybe a self-playing gif of bombs droppedover time for each conflict
#*Make efficient for use on shinyapps.io through SQLite
#*Maybe match (or fail to match) the data with the historical record.
#*Could also allow users to link (using html) to relevant Wikipedia articles on certain aspects of the conflicts (airframes, campaigns, etc.)
#*Edit civilian map to have not just number of bombing missions but also number of bombs and weight of bombs to get a better sense of danger/intensity
#*Change heatmap parameters so it's not as odd-looking, especially changing so much between zoom levels: change blur and radius (and maybe even max) parameters?

# move all label changes into labs() function

# there's a 9:00 am and an 11:00 am in Unit_Squadron of WW2--check for other misplaced values
# turn label text sideways above a certain number of labels
# make sure sandbox is integrating over entire dataset, not just first observation or whatever
# maybe reorder bars in plots in ascending order
# maybe use coord_flip() to help category names not overlap
# maybe change local absolute paths to relative paths

#* check bomb_altitude and bomb_altitude_feet in WW2
#* make sure types of bombs are formatted, cleaned, and processed

#** fix formatting of title, axes, background, and legend in sandbox
#** also add in new columns and/or rephrase descriptions of old columns

#*** fix other war bomb nums and weights too
#*** lots of tooltips still say "0 pounds of bombs"--have tooltips not just test if they're not NA but also not 0
#*** fix the fact that the app saves locally when it should save externally
#*** ensure that aircraft_attacking_num is as clean and complete as possible

#**** add Unit_Country to all tooltips
#**** also include type of bombs
#**** maybe fix proper_noun_phrase_vectorized by filtering down amount of data that needs to be processed at each step: first check if the given line is empthy, then check if the line is only one word long (doesn't contain any of the split characters) and then check for each character before each step (or keep large vectors of logicals about whether each symbol is contained in each row and use those)
#**** use more <<- to make sure sessions don't interfere with one another
#**** please somehow isolate the selection reactive function from senseless updates (adding or subtracting "all") on every filtering factor

# see if you can fix how long it takes Vietnam data to be sampled (sub-sample further?)
# maybe put background of flags with low alpha over territories they controlled
# fix Korea1 to make sure its data gets included too
# maybe figure out how to add all war data together into one big dataset (perhaps combinatorially based on which wars have been selected)
# if you do any text editing on bomb type descriptions then you may need to change the WW2 match from "X" to "x" and the Korea match from "Unknown" to "unknown"
# also include vague categories like "incendiary", "fragmentary", and "high explosive" (as in WW2) as possible selections in weapons drop down (depending on what wars and countries are selected)
# provide fragmentary, incendiary, and high explosive columns in non-WW2 databases as well
# maybe also add a kinetic weapon column for WW2 and others
# maybe try doing all tooltip calculations at once to see if data.table parallelizes it
# maybe further functionalize cleaner.R cleaning sections for each war
# maybe functionalize the sandbox and histogram plots
# merge together Korea1 and Korea2 after cleaning
# compare timing with and without JIT compiler
# figure out a way to suppress or fix all those warnings (and also random data.table updates and package information)
# 2 Vietnam dates fail to parse as they are for an impossible date (1970-02-29)--could change to 1970-02-28 manually
# make sure all fields with codes have their relevant explanation/text and all relevant texts that are 1:1 with a code if they have the code (like WW2 Sighting_Method_Code and Sighting_Method_Explanation etc)
# maybe read the times in as character to allow better processing--I bet not all are integers/numbers (some may have formatting characters like : in them)
# redo strptime() and format() bits--it's silly to convert from text to POSIXlt (converted inside data.table to POSIXct) then back to text again
# plenty of O vs 0 mistakes in Vietnam (and maybe other database) callsigns; Korea1 callsign has nothing; Korea2 callsign has nothing except one data leak; very few callsigns in WW2; WW1 callsigns are just aircraft types
# be careful about "squadron division" sounding funny in tooltips
# maybe add Vietnam squadrons back into tooltip (though very rare)
# complete country, target priority, target industry, etc. codes where possible (WW2 and potentially others)
# perhaps update WW2 (and potentially other wars') weapons types that include clusters to just be counted as singlets but with a mention that they were originally in clusters
# I like the functionality of the filter_selection() function, but it seems slower than having separate functions for each war
