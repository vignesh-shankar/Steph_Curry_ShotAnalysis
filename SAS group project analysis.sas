
filename in1 'C:\Users\Vignesh\Downloads\SHOT_LOGS_TRANSFORMED.csv';

* Specify location of our shot_logs transformed file with proper PATH;
data work.PranayAnalytics;
infile in1 DSD DLM = ',' FIRSTOBS=2 MISSOVER;
length CLOSEST_DEFENDER $25 PLAYER_NAME $25;  
input CLOSEST_DEFENDER PLAYER_NAME $ GAME_ID MATCHUP_DATE $ TEAM $ OPPOSITION_TEAM  $ LOCATION $ RESULT $ FINAL_MARGIN SHOT_NUMBER PERIOD 
GAME_CLOCK $ SHOT_CLOCK DRIBBLES TOUCH_TIME SHOT_DIST PTS_TYPE SHOT_RESULT $ CLOSEST_DEFENDER_PLAYER_ID CLOSE_DEF_DIST FGM PTS PLAYER_ID;
run;

/* Below code takes a lot of time to run, be careful with the RAM of your machine
proc print data = work.PranayAnalytics (OBS=10);
where PLAYER_ID = 201939;
run;
*/

*Filtering the data only for the player under analysis - Stephen Curry;
data work.ActualInput;
	set PranayAnalytics;
	where PLAYER_ID = 201939;
run;

*Part 1 ;
proc sql;
create table info as 
select distinct GAME_ID,count(SHOT_RESULT) as TotalShotsAttempted, RESULT,
count(case when SHOT_RESULT='made' then 1 end) as Shot_Result_Made
from ActualInput
where OPPOSITION_TEAM in (select distinct OPPOSITION_TEAM from ActualInput)
group by GAME_ID;
run;quit;


proc sql;
create table TotalPercentageShots as
select RESULT,GAME_ID ,Shot_Result_Made,TotalShotsAttempted, (100*Shot_Result_Made/TotalShotsAttempted) as FG_PERCENTAGE
from info;
run;quit;
ods rtf file = 'C:\Users\Vignesh\Documents\Output_3.rtf';
proc logistic data = TotalPercentageShots descending;
model RESULT=FG_PERCENTAGE;
run;quit;
ods rtf close;
*For every unit increase in percent, odds of winning go up by 1.05;
*Part 2 ;
ods rtf file = 'C:\Users\Vignesh\Documents\Output_4.rtf';
data clutchAnalysis; 
	set Actualinput;
	if (GAME_CLOCK < 0.3) and (PERIOD in (1,2,3)) then 
	do
	clutch_time = 1; end;
	else if (GAME_CLOCK < 3.0) and (PERIOD = 4) then 
	do
	clutch_time = 1; end;
	else if PERIOD in (5,6,7) then
	do
	clutch_time = 1;end;
	else clutch_time = 0;
run;


proc freq data = clutchAnalysis;
tables clutch_time*shot_result / chisq ;
run;quit;

data clutchAnalysis_rest; 
	set PranayAnalytics;
	if (GAME_CLOCK < 0.3) and (PERIOD in (1,2,3)) then 
	do
	clutch_time = 1; end;
	else if (GAME_CLOCK < 3.0) and (PERIOD = 4) then 
	do
	clutch_time = 1; end;
	else if PERIOD in (5,6,7) then
	do
	clutch_time = 1;end;
	else clutch_time = 0;
run;

proc freq data = clutchAnalysis_rest;
tables clutch_time*shot_result / chisq ;
run;quit;
ods rtf close;

*The shot-result is not related to the crunch time for Stephen Curry, 
which brings us to the conclusion he is equally efficient during crunch and non crunch times; 
/*
*/

*Part 3 ;
ods rtf file = 'C:\Users\Vignesh\Documents\Output_2.rtf';
proc freq data = ActualInput;
tables PTS_TYPE / chisq;
run;quit;

proc freq data = PranayAnalytics;
tables PTS_TYPE / chisq;
run;quit;
ods rtf close;
*Chisq test for goodness of fit/ equal proportion;
*SC scores equally good in 2 and 3 pointers whereas other players have an unequal distribution ;






