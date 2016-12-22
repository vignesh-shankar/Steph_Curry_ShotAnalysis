 %let TOTAL_POINTS = 0;
 ods rtf file = 'C:\Users\Vignesh\Documents\DescStats.rtf';
/*proc FORMAT;
value miss_value_sc '.' = 0;
run;*/
DATA SHOT_LOG;
INFILE 'F:\shot_logs.csv' DSD DLM = ',' FIRSTOBS=2 MISSOVER;
LENGTH CLOSEST_DEFENDER $25 PLAYER_NAME $25;
INPUT GAME_ID MATCHUP_DATE $ TEAM $ OPPOSITION_TEAM $ LOCATION $ RESULT $ FINAL_MARGIN SHOT_NUMBER PERIOD GAME_CLOCK $ SHOT_CLOCK DRIBBLES TOUCH_TIME SHOT_DIST PTS_TYPE SHOT_RESULT $ CLOSEST_DEFENDER $ CLOSEST_DEFENDER_PLAYER_ID CLOSE_DEF_DIST FGM PTS PLAYER_NAME $ PLAYER_ID;
*FORMAT SHOT_CLOCK miss_value_sc.;
IF SHOT_CLOCK = . THEN SHOT_CLOCK = 0;
GAME_CLOCK = TRANWRD(GAME_CLOCK, ":", ".");
GAME_CLOCK = INPUT(GAME_CLOCK, 5.2);
RUN;

PROC PRINT DATA = SHOT_LOG (OBS=10);
RUN;

PROC EXPORT DATA = SHOT_LOG
OUTFILE = 'F:\SHOT_LOGS_TRANSFORMED.csv';
RUN;

proc sql;
create table DESC_STATS1 as 
select PLAYER_NAME , 
count(SHOT_RESULT) as TOTAL_SHOTS,
count(case when SHOT_RESULT='made' then 1 end) as Shot_Made
from SHOT_LOG
where PLAYER_NAME in (select distinct PLAYER_NAME from SHOT_LOG) and PTS_TYPE = 2
group by PLAYER_NAME ;
run;quit;

PROC PRINT DATA = DESC_STATS1 (OBS = 10);
RUN;

proc sql;
create table DESC_STATS2 as 
select PLAYER_NAME , 
count(SHOT_RESULT) as TOTAL_SHOTS,
count(case when SHOT_RESULT='made' then 1 end) as Shot_Made
from SHOT_LOG
where PLAYER_NAME in (select distinct PLAYER_NAME from SHOT_LOG) and PTS_TYPE = 3
group by PLAYER_NAME ;
run;quit;

PROC PRINT DATA = DESC_STATS2 (OBS = 10);
RUN;

proc sql;
create table DESC_STATS3 as 
select PLAYER_NAME , 
count(SHOT_RESULT) as TOTAL_SHOTS,
count(case when SHOT_RESULT='made' and PTS_TYPE = 2 then 2 end) as PT_2_TOTAL,
count(case when SHOT_RESULT='made' and PTS_TYPE = 3 then 3 end) as PT_3_TOTAL
from SHOT_LOG
where PLAYER_NAME in (select distinct PLAYER_NAME from SHOT_LOG)
group by PLAYER_NAME ;
run;quit;

PROC PRINT DATA = DESC_STATS3 (OBS = 10);
RUN;
*POINTS PER SHOT COMPARISON THROUGHOUT NBA;
*Condition for comparison....TOTAL_SHOTS>500;
DATA POINTS_PER_SHOT;
SET DESC_STATS3;
TOTAL_PONTS = (PT_2_TOTAL*2) + (PT_3_TOTAL*3);
POINTS_PER_SHOT = ((PT_2_TOTAL*2) + (PT_3_TOTAL*3))/(TOTAL_SHOTS);
RUN;
proc sort data = points_per_shot;
by descending points_per_shot;
run;

PROC PRINT DATA = POINTS_PER_SHOT (OBS = 10);
id player_name;
title "POINTS PER SHOT (MINIMUM SHOTS ATTEMPTED - 500)";
where total_shots > 500;
RUN;
* 3-point fgm;
data fgm_3;
set desc_stats2;
fg_percentage_3pt = ((Shot_Made)/(Total_Shots))*100;
run;

proc sort data = fgm_3;
by descending fg_percentage_3pt;
run;

PROC PRINT DATA = fgm_3 (OBS = 10);
id player_name;
title "TOP 10 FG % - 3 POINTS (MINIMUM SHOTS ATTEMPTED GREATER THAN 300)";
where total_shots > 300;
RUN;
* 2-point fgm;
data fgm_2;
set desc_stats1;
fg_percentage_2pt = ((Shot_Made)/(Total_Shots))*100;
run;

proc sort data = fgm_2;
by descending fg_percentage_2pt;
run;

PROC PRINT DATA = fgm_2 (OBS = 10);
title "TOP 10 FG % - 2 POINTS - SHOTS ATTEMPTED GREATER THAN 400";
id player_name;
where total_shots > 400;
RUN;
*TOP 10 POINT GUARD POINTS PER SHOT COMPARISON;
DATA POINTS_PER_SHOT_PG;
SET DESC_STATS3;
TOTAL_PONTS = (PT_2_TOTAL*2) + (PT_3_TOTAL*3);
POINTS_PER_SHOT_var = ((PT_2_TOTAL*2) + (PT_3_TOTAL*3))/(TOTAL_SHOTS);
where player_name = 'tony parker' OR player_name = 'mike conley' OR player_name = 'jeff teague' OR player_name = 'kyle lowry' OR player_name = 'kyrie irving'||player_name = 'damian lillard' OR player_name = 'john wall' 
OR player_name = 'russell westbrook' OR player_name = 'chris paul' OR player_name = 'stephen curry';
RUN;

proc sort data = points_per_shot_pg;
by descending points_per_shot_var;
run;

proc print data = points_per_shot_pg;
title "POINTS PER SHOT - TOP 10 POINT GUARDS";
run;

PROC gCHART DATA = points_per_shot;
where total_shots > 500;
TITLE "POINTS PER SHOT DISTRIBUTION (TOTAL SHOTS > 500)";
VBAR points_per_shot / maxis=axis1 raxis=axis2 frame type=FREQ patternid=midpoint; 
RUN;

ods rtf close;
