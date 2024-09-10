# AffectiveImagesRecode
Trigger recode for the Affective Images MEG task

This script needs the original EVTs, so you will have to put all original EVTs into one place. 

It will output either a "_recoded.evt" or a "_recoded_check.evt." 
If it says check, then that means there are extraneous triggers that may or may not need to be manually recoded. 

If the script went as it should, you should see something like this, with no random triggers not on the trigger recode legend:

	30 (fixation)
	31 (stimulus)
	30 (fixation)
	21 (stimulus)
	30 (fixation)
	40 (oddball)
	256 (responded in time)
	30 (fixation) 
	...
	...
	30 (fixation)
	9931 (did not respond at all)
	30 (fixation)
	...
	...
	30 (fixation)
	9931 (did not respond in time)
	30 (fixation)
	256 (late response)
	555 (contaminated trial)

In some cases there may be something like a random button press (i.e., 256/512) that occurs without an oddball stimulus. 
If that's the case, then the stim trigger in the trial that button press occurs in should be recoded manually from 21/31 to 555.
			**NOTE: you should manually edit the "_recoded.evt" or "_recoded_check.evt"**

If you manually recode someone, you can rerun the recode on the "_recoded.evt" or "_recoded_check.evt" files to re-calculate their behavior, and it should (theoretically) work.

Another thing to note: the "Behav.txt" file does not output URSIs, so when putting these results into an excel sheet, make sure the URSIs in that sheet are in the same order as the files in your directory in matlab.

I've built a couple of sanity checks into the "Behav.txt" file that you can use to evaluate if things worked right and see if numbers add up:
	- number_correctoddball is the number of oddballs that have a response (whether technically in time or not)
	- number_incorrectoddball is the number of oddballs that do not have a response at all
	- contaminated is the number of trials that are contaminated by a late oddball response
	- positive_image is the number of clean positive trials
	- negative_image is the number of clean negative trials
	- contamination_mismatch is a binary yes/no if the total clean trial count makes sense given contaminated trials. 
		- **THIS SHOULD BE EVALUATED INDEPENDENTLY OF WHETHER OR NOT THE FILE IS NAMED "_recoded_check.evt" OR NOT!**
