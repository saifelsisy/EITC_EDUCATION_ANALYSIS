*
Programmed by: Saif Elsisy
Personal Project on the Earned Income Tax Credits effect 
on Education Outcomes
;

x "cd S:\EC490\Data";
libname InputDS ".";

x "cd S:\EC490\Output";
libname P2 ".";

ods pdf file="P2 EC490_Analysis_Fixed.pdf" dpi=300 style=Sapphire;
options nodate;
ods noproctitle;

/* FORMATS*/

proc format;
    value statefmt
        1  = 'Alabama'
        2  = 'Alaska'
        4  = 'Arizona'
        5  = 'Arkansas'
        6  = 'California'
        8  = 'Colorado'
        9  = 'Connecticut'
        10 = 'Delaware'
        11 = 'District of Columbia'
        12 = 'Florida'
        13 = 'Georgia'
        15 = 'Hawaii'
        16 = 'Idaho'
        17 = 'Illinois'
        18 = 'Indiana'
        19 = 'Iowa'
        20 = 'Kansas'
        21 = 'Kentucky'
        22 = 'Louisiana'
        23 = 'Maine'
        24 = 'Maryland'
        25 = 'Massachusetts'
        26 = 'Michigan'
        27 = 'Minnesota'
        28 = 'Mississippi'
        29 = 'Missouri'
        30 = 'Montana'
        31 = 'Nebraska'
        32 = 'Nevada'
        33 = 'New Hampshire'
        34 = 'New Jersey'
        35 = 'New Mexico'
        36 = 'New York'
        37 = 'North Carolina'
        38 = 'North Dakota'
        39 = 'Ohio'
        40 = 'Oklahoma'
        41 = 'Oregon'
        42 = 'Pennsylvania'
        44 = 'Rhode Island'
        45 = 'South Carolina'
        46 = 'South Dakota'
        47 = 'Tennessee'
        48 = 'Texas'
        49 = 'Utah'
        50 = 'Vermont'
        51 = 'Virginia'
        53 = 'Washington'
        54 = 'West Virginia'
        55 = 'Wisconsin'
        56 = 'Wyoming'
        other = 'Unknown'
    ;
    value ER32006F
        0 = 'Nonsample'
        1 = 'Original sample (SRC)'
        2 = 'Born-in sample'
        3 = 'Moved-in sample'
        4 = 'Joint inclusion'
        5 = 'Followable nonsample parent';

    value pareducfmt
        1 = "0-5 Grades"
        2 = "6-8 Grades (Grade School)"
        3 = "Some High School (9-11 Grades)"
        4 = "Completed High School"
        5 = "HS + Nonacademic Training"
        6 = "Some College / Associates"
        7 = "Bachelors Degree"
        8 = "Advanced / Professional Degree";

    value nkidsrefmt
        1 = "1 Child"
        2 = "2 Children"
        3 = "3 Children"
        4 = "4 Children"
        5 = "5 Children"
        6 = "6+ Children"
        8 = "0 Children (Ref)";
run;


/*  STEP 1: BUILD ProjectData_Cleaned_Long*/

data work.cleaned_long_temp;
    set P2.ProjectData_WithEITC;

    array ids[43]
        IDNUMBER_1968-IDNUMBER_1997
        IDNUMBER_1999  IDNUMBER_2001  IDNUMBER_2003  IDNUMBER_2005
        IDNUMBER_2007  IDNUMBER_2009  IDNUMBER_2011  IDNUMBER_2013
        IDNUMBER_2015  IDNUMBER_2017  IDNUMBER_2019  IDNUMBER_2021
        IDNUMBER_2023;

    array seqs[43]
        SEQUENCENUMBER_1968-SEQUENCENUMBER_1997
        SEQUENCENUMBER_1999  SEQUENCENUMBER_2001  SEQUENCENUMBER_2003  SEQUENCENUMBER_2005
        SEQUENCENUMBER_2007  SEQUENCENUMBER_2009  SEQUENCENUMBER_2011  SEQUENCENUMBER_2013
        SEQUENCENUMBER_2015  SEQUENCENUMBER_2017  SEQUENCENUMBER_2019  SEQUENCENUMBER_2021
        SEQUENCENUMBER_2023;

    length person_id $15;
    person_id = '';
    do _p = 1 to 43;
        if ids[_p] > 0 and seqs[_p] > 0 then do;
            person_id = cats(put(ids[_p], 8.), '_', put(seqs[_p], 8.));
            leave;
        end;
    end;

    if missing(person_id) then delete;
    drop _p;

    array yr_map[43] _temporary_
        (1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980
         1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993
         1994 1995 1996 1997 1999 2001 2003 2005 2007 2009 2011 2013 2015
         2017 2019 2021 2023);

    array age_w[43]
        AGEOFINDIVIDUAL_1968-AGEOFINDIVIDUAL_1997
        AGEOFINDIVIDUAL_1999  AGEOFINDIVIDUAL_2001  AGEOFINDIVIDUAL_2003
        AGEOFINDIVIDUAL_2005  AGEOFINDIVIDUAL_2007  AGEOFINDIVIDUAL_2009
        AGEOFINDIVIDUAL_2011  AGEOFINDIVIDUAL_2013  AGEOFINDIVIDUAL_2015
        AGEOFINDIVIDUAL_2017  AGEOFINDIVIDUAL_2019  AGEOFINDIVIDUAL_2021
        AGEOFINDIVIDUAL_2023;

    array educ_w[43]
        EDUCATIONATTAINED_1968-EDUCATIONATTAINED_1997
        EDUCATIONATTAINED_1999  EDUCATIONATTAINED_2001  EDUCATIONATTAINED_2003
        EDUCATIONATTAINED_2005  EDUCATIONATTAINED_2007  EDUCATIONATTAINED_2009
        EDUCATIONATTAINED_2011  EDUCATIONATTAINED_2013  EDUCATIONATTAINED_2015
        EDUCATIONATTAINED_2017  EDUCATIONATTAINED_2019  EDUCATIONATTAINED_2021
        EDUCATIONATTAINED_2023;


    array finc_w[43]
        TOTALFAMILYINCOME_1968-TOTALFAMILYINCOME_1997
        TOTALFAMILYINCOME_1997   /* 1999 survey wave */
        TOTALFAMILYINCOME_2000   /* 2001 survey wave */
        TOTALFAMILYINCOME_2002   /* 2003 survey wave */
        TOTALFAMILYINCOME_2004   /* 2005 survey wave */
        TOTALFAMILYINCOME_2006   /* 2007 survey wave */
        TOTALFAMILYINCOME_2008   /* 2009 survey wave */
        TOTALFAMILYINCOME_2010   /* 2011 survey wave */
        TOTALFAMILYINCOME_2013   /* 2013 survey wave */
        TOTALFAMILYINCOME_2014   /* 2015 survey wave */
        TOTALFAMILYINCOME_2016   /* 2017 survey wave */
        TOTALFAMILYINCOME_2018   /* 2019 survey wave */
        TOTALFAMILYINCOME_2020   /* 2021 survey wave */
        TOTALFAMILYINCOME_2022;  /* 2023 survey wave */

    array faduc_w[43]
        FATHERSEDUCATION_1968-FATHERSEDUCATION_1997
        FATHERSEDUCATION_1999  FATHERSEDUCATION_2001  FATHERSEDUCATION_2003
        FATHERSEDUCATION_2005  FATHERSEDUCATION_2007  FATHERSEDUCATION_2009
        FATHERSEDUCATION_2011  FATHERSEDUCATION_2013  FATHERSEDUCATION_2015
        FATHERSEDUCATION_2017  FATHERSEDUCATION_2019  FATHERSEDUCATION_2021
        FATHERSEDUCATION_2023;

    array moduc_w[43]
        MOTHERSEDUCATION_1968-MOTHERSEDUCATION_1997
        MOTHERSEDUCATION_1999  MOTHERSEDUCATION_2001  MOTHERSEDUCATION_2003
        MOTHERSEDUCATION_2005  MOTHERSEDUCATION_2007  MOTHERSEDUCATION_2009
        MOTHERSEDUCATION_2011  MOTHERSEDUCATION_2013  MOTHERSEDUCATION_2015
        MOTHERSEDUCATION_2017  MOTHERSEDUCATION_2019  MOTHERSEDUCATION_2021
        MOTHERSEDUCATION_2023;


    array race_w[43]
        RACE_1968-RACE_1997
        RACE_1999  RACE_2001  RACE_2003  RACE_2005
        RACE_2007  RACE_2009  RACE_2011  RACE_2012   /* pos 38: 2013 wave */
        RACE_2015  RACE_2017  RACE_2019  RACE_2021
        RACE_2023;

    /* SEXOFINDIVIDUAL is time-invariant */

    _idx = .;
    do _k = 1 to 43;
        if yr_map[_k] = YEAR then do; _idx = _k; leave; end;
    end;

    if not missing(_idx) then do;
        AGEOFINDIVIDUAL   = age_w[_idx];
        EDUCATIONATTAINED = educ_w[_idx];
        TOTALFAMILYINCOME = finc_w[_idx];
        FATHERSEDUCATION  = faduc_w[_idx];
        MOTHERSEDUCATION  = moduc_w[_idx];
        RACE              = race_w[_idx];
    end;

    if AGEOFINDIVIDUAL in (0, 999)         then AGEOFINDIVIDUAL = .;
    if EDUCATIONATTAINED in (0,96,97,98,99) then EDUCATIONATTAINED = .;

    if YEAR < 1993 then do;
        if FATHERSEDUCATION in (0, 9)       then FATHERSEDUCATION = .;
        if MOTHERSEDUCATION in (0, 9)       then MOTHERSEDUCATION = .;
    end;
    if YEAR >= 1993 then do;
        if FATHERSEDUCATION in (0,9,98,99)  then FATHERSEDUCATION = .;
        if MOTHERSEDUCATION in (0,9,98,99)  then MOTHERSEDUCATION = .;
    end;

    if YEAR in (1993,1994) and TOTALFAMILYINCOME = 9999999
        then TOTALFAMILYINCOME = .;

    if STATE in (0, 99)                    then STATE = .;
    if SEXOFINDIVIDUAL not in (1, 2)       then SEXOFINDIVIDUAL = .;
    if RACE not in (1,2,3,4,5,6,7)        then RACE = .;

    drop _k _idx;

    keep IDNUMBER_1968 person_id YEAR AGEOFINDIVIDUAL EDUCATIONATTAINED
         TOTALFAMILYINCOME FATHERSEDUCATION MOTHERSEDUCATION
         N_KIDS N_KIDS_CAT STATE EITC_EXPOSURE
         SEXOFINDIVIDUAL RACE WHETHERSAMPLEORNONSAMPLE;
run;

proc sort data=work.cleaned_long_temp;
    by IDNUMBER_1968 YEAR;
run;

data P2.ProjectData_Cleaned_Long;
    set work.cleaned_long_temp;
run;

proc sql;
    select count(distinct person_id) as n_individuals,
           count(distinct IDNUMBER_1968) as n_idnum,
           count(*) as n_rows
    from P2.ProjectData_Cleaned_Long;
quit;

/* SUMMARY STATISTICS ON CLEANED LONG DATASET */

proc freq data=P2.ProjectData_Cleaned_Long;
    tables WHETHERSAMPLEORNONSAMPLE / missing;
    title "Subsample Check: SRC vs SEO Composition";
run;

proc means data=P2.ProjectData_Cleaned_Long n nmiss mean std min max maxdec=2;
    class YEAR;
    var AGEOFINDIVIDUAL EDUCATIONATTAINED FATHERSEDUCATION
        MOTHERSEDUCATION TOTALFAMILYINCOME N_KIDS EITC_EXPOSURE;
    title "Summary Statistics - Key Analysis Variables by Year";
run;

options nodate;
ods noproctitle;


proc sort data=P2.ProjectData_Cleaned_Long;
    by person_id YEAR;
run;

/* BUILD ANALYSIS SAMPLE */

data work.analysis_sample;
    set P2.ProjectData_Cleaned_Long;
    by person_id;

    array sv[56] s1-s56;

    retain total_eitc exposure_count
           max_educ dad_educ mom_educ
           birth_year_est ever_age_10_16
           first_valid_year first_valid_age
           avg_income income_count
           times_below_phaseout times_above_phaseout
           modal_state state_count
           s1-s56
           modal_nkids nk0 nk1 nk2 nk3 nk4 nk5 nk6plus
           sex_val race_val
           Subsample
  first_post86_state; 


    if first.person_id then do;
        total_eitc            = 0;
        exposure_count        = 0;
        max_educ              = .;
        dad_educ              = .;
        mom_educ              = .;
        birth_year_est        = .;
        ever_age_10_16        = 0;
        first_valid_year      = .;
        first_valid_age       = .;
        avg_income            = 0;
        income_count          = 0;
        times_below_phaseout  = 0;
        times_above_phaseout  = 0;
        modal_state           = .;
        state_count           = 0;
        modal_nkids           = .;
        nk0 = 0; nk1 = 0; nk2 = 0; nk3 = 0;
        nk4 = 0; nk5 = 0; nk6plus = 0;
        do _i = 1 to 56; sv[_i] = 0; end;
        sex_val   = .;
        race_val  = .;
        subsample = .;
        first_post86_state = .; 
    end;

    if missing(birth_year_est)
        and not missing(AGEOFINDIVIDUAL)
        and AGEOFINDIVIDUAL > 0
        then birth_year_est = YEAR - AGEOFINDIVIDUAL;

    in_exposure_age = (not missing(AGEOFINDIVIDUAL)
                       and 10 <= AGEOFINDIVIDUAL <= 16);

/* Capture first observed state from any post-1986 wave as fallback
   for persons whose ages 10-16 window predates 1986 state data. */
if missing(first_post86_state)
    and not missing(STATE)
    and YEAR >= 1986
    then first_post86_state = STATE;

    if in_exposure_age then do;
        ever_age_10_16 = 1;
        if missing(first_valid_year) then do;
            first_valid_year = YEAR;
            first_valid_age  = AGEOFINDIVIDUAL;
        end;
    end;

    /* Sex and race are time-stable. Capture first non-missing value
       from any wave across the full panel for each person. */
    if missing(sex_val)  and not missing(SEXOFINDIVIDUAL)
        then sex_val  = SEXOFINDIVIDUAL;
    if missing(race_val) and not missing(RACE)
        then race_val = RACE;
    if missing(subsample) and not missing(WHETHERSAMPLEORNONSAMPLE)
        then subsample = WHETHERSAMPLEORNONSAMPLE;

    select (YEAR);
        when (1975,1976,1977,1978)           phaseout_ceiling = 8000;
        when (1979,1980,1981,1982,1983,1984) phaseout_ceiling = 10000;
        when (1985,1986)                     phaseout_ceiling = 11000;
        when (1987)                          phaseout_ceiling = 15432;
        when (1988)                          phaseout_ceiling = 18576;
        when (1989)                          phaseout_ceiling = 19340;
        when (1990)                          phaseout_ceiling = 20264;
        when (1991)                          phaseout_ceiling = 21250;
        when (1992)                          phaseout_ceiling = 22370;
        when (1993)                          phaseout_ceiling = 23050;
        when (1994)                          phaseout_ceiling = 25296;
        when (1995)                          phaseout_ceiling = 26673;
        when (1996)                          phaseout_ceiling = 28495;
        when (1997)                          phaseout_ceiling = 29290;
        when (1999)                          phaseout_ceiling = 30580;
        when (2001)                          phaseout_ceiling = 32121;
        when (2003)                          phaseout_ceiling = 33692;
        when (2005)                          phaseout_ceiling = 35263;
        when (2007)                          phaseout_ceiling = 37783;
        when (2009)                          phaseout_ceiling = 43279;
        when (2011)                          phaseout_ceiling = 43998;
        when (2013)                          phaseout_ceiling = 46227;
        when (2015)                          phaseout_ceiling = 47747;
        otherwise phaseout_ceiling = .;
    end;

    if in_exposure_age then do;

        if not missing(EITC_EXPOSURE) then do;
            total_eitc     = total_eitc + EITC_EXPOSURE;
            exposure_count = exposure_count + 1;
        end;

        if not missing(TOTALFAMILYINCOME) and TOTALFAMILYINCOME > 0 then do;
            avg_income   = avg_income + TOTALFAMILYINCOME;
            income_count = income_count + 1;
            if not missing(phaseout_ceiling) then do;
                if TOTALFAMILYINCOME <= phaseout_ceiling
                    then times_below_phaseout = times_below_phaseout + 1;
                else     times_above_phaseout = times_above_phaseout + 1;
            end;
        end;

        if not missing(STATE) and 1 <= STATE <= 56 then do;
            sv[STATE] = sv[STATE] + 1;
            state_count = state_count + 1;
        end;

        if not missing(N_KIDS) and N_KIDS >= 0 then do;
            if      N_KIDS = 0 then nk0     = nk0     + 1;
            else if N_KIDS = 1 then nk1     = nk1     + 1;
            else if N_KIDS = 2 then nk2     = nk2     + 1;
            else if N_KIDS = 3 then nk3     = nk3     + 1;
            else if N_KIDS = 4 then nk4     = nk4     + 1;
            else if N_KIDS = 5 then nk5     = nk5     + 1;
            else                    nk6plus = nk6plus + 1;
        end;
    end;

    if not missing(EDUCATIONATTAINED) then
        max_educ = max(max_educ, EDUCATIONATTAINED);

    if missing(dad_educ) and not missing(FATHERSEDUCATION)
        then dad_educ = FATHERSEDUCATION;
    if missing(mom_educ) and not missing(MOTHERSEDUCATION)
        then mom_educ = MOTHERSEDUCATION;

    if last.person_id then do;

        if ever_age_10_16 = 1
            and not missing(birth_year_est)
            and birth_year_est <= 1999
                then eligible = 1;
        else eligible = 0;

        if exposure_count > 0
            then avg_eitc = total_eitc / exposure_count;
            else avg_eitc = 0;

        if income_count > 0
            then avg_family_income = avg_income / income_count;
            else avg_family_income = .;

        /* below_phaseout retained for Step 7 graphs only —
           not used in any regression. */
        if times_below_phaseout > 0 or times_above_phaseout > 0 then do;
            if times_below_phaseout >= 1
                then below_phaseout = 1;
            else below_phaseout = 0;
        end;
        else below_phaseout = .;

       if state_count > 0 then do;
            _max_votes = 0;
            do _j = 1 to 56;
                if sv[_j] > _max_votes then do;
                    _max_votes = sv[_j];
                    modal_state = _j;
                end;
            end;
        end;
        /* NEW: fallback for persons whose ages 10-16 window predated
           1986 state data — use first observed post-1986 state instead
           of defaulting to the modal_state=0 catch-all. */
        else if not missing(first_post86_state)
            then modal_state = first_post86_state;

        _max_nk = max(nk0, nk1, nk2, nk3, nk4, nk5, nk6plus);
        if _max_nk > 0 then do;
            if      nk0     = _max_nk then modal_nkids = 0;
            else if nk1     = _max_nk then modal_nkids = 1;
            else if nk2     = _max_nk then modal_nkids = 2;
            else if nk3     = _max_nk then modal_nkids = 3;
            else if nk4     = _max_nk then modal_nkids = 4;
            else if nk5     = _max_nk then modal_nkids = 5;
            else                           modal_nkids = 6;
        end;
        else modal_nkids = .;

        cohort = birth_year_est;
        sex    = sex_val;
        race   = race_val;

        output;
    end;

    keep person_id eligible avg_eitc max_educ dad_educ mom_educ
         birth_year_est cohort exposure_count
         first_valid_year first_valid_age
         avg_family_income below_phaseout modal_state modal_nkids
         sex race subsample;
run;

/* ---- Drop ineligible persons and finalize analysis variables ---- */
data work.analysis_sample;
    set work.analysis_sample;

    if eligible = 0 then delete;
    if exposure_count = 0 then delete;
    if missing(max_educ) then delete;

    if dad_educ in (9, 98, 99) then dad_educ = .;
    if mom_educ in (9, 98, 99) then mom_educ = .;

    hs_complete = (max_educ >= 12);
    any_college = (max_educ >= 13);
    bachelors   = (max_educ >= 16);

    avg_eitc_000 = avg_eitc / 1000;

    if not missing(avg_family_income) and avg_family_income > 0
        then log_income = log(avg_family_income);
        else log_income = .;

    /* FIXED: female=1 for women, female=0 for men.
       Male is the implicit omitted reference in all regressions —
       the female coefficient shows the gap relative to men. */
    if not missing(sex) then female = (sex = 2);
    else female = .;

    /* FIXED: White (race=1) is now the omitted reference category.
       race_black and race_other coefficients show gaps relative to
       White respondents. Categories 3-7 (Native American, Asian,
       Latino, Other color, Other) are collapsed into race_other
       because their combined share is ~7%, making separate estimates
       unreliable. All coefficients are now interpretable relative
       to White as the baseline. */
    if not missing(race) then do;
        race_black = (race = 2);
        race_other = (race in (3,4,5,6,7));
        /* race=1 (White) is the implicit reference — no indicator
           created for White. */
    end;
    else do;
        race_black = .;
        race_other = .;
    end;


    if cohort <= 1974 then cohort_ref = 9999;
    else cohort_ref = cohort;

    if missing(modal_state) then modal_state = 0;

    if missing(modal_nkids) then nkids_ref = .;
    else if modal_nkids = 0 then nkids_ref = 8;
    else                         nkids_ref = modal_nkids;

    format dad_educ mom_educ pareducfmt.
           nkids_ref nkidsrefmt.;


    drop eligible exposure_count first_valid_year first_valid_age
         sex race modal_nkids;
run;

/* CHECK SAMPLE */

proc freq data=work.analysis_sample;
    tables subsample / missing;
    title "Subsample Composition in Analysis Sample (1=SRC, 2=SEO)";
run;

/* UPDATED: race_white removed from tables since White is now the
   reference and has no binary indicator. race_other added.
   nkids_ref replaces modal_nkids. */
proc freq data=work.analysis_sample;
    tables hs_complete any_college bachelors
           dad_educ mom_educ cohort_ref below_phaseout
           modal_state nkids_ref female race_black race_other / missing;
    title "Sample Frequency Checks";
run;

proc means data=work.analysis_sample n nmiss mean std min max maxdec=2;
    var avg_eitc avg_eitc_000 max_educ hs_complete any_college
        bachelors avg_family_income log_income female race_black race_other;
    title "Summary Statistics - Analysis Sample";
run;

/* CORRELATION MATRIX */

proc corr data=work.analysis_sample
          pearson
          plots=matrix(histogram)
          nosimple;
    var hs_complete any_college bachelors
        avg_eitc_000
        log_income
        female
        race_black race_other
        dad_educ mom_educ;
    title "Correlation Matrix - Continuous and Binary Analysis Variables";
run;

/* dad_educ and mom_educ seperate */
proc corr data=work.analysis_sample
          pearson
          nosimple;
    var dad_educ mom_educ avg_eitc_000 log_income;
    title "Correlation Matrix - Parental Education vs EITC and Income";
run;


/* REGRESSIONS - WITHOUT INCOME CONTROL
   Reference categories:
     Race:      White (race=1, no indicator created)
     Sex:       Male  (female=0)
     Cohort:    Born <=1974 (cohort_ref=9999, sorts last)
     Kids:      0 children (nkids_ref=8, sorts last)
     State:     State 56 / state unknown=0 (sorts last in class)
     Parental education: "Some High School" (sorts last alphabetically)  */

/* HS completion Regression */
proc glm data=work.analysis_sample;

    class dad_educ mom_educ cohort_ref modal_state nkids_ref;
    model hs_complete = avg_eitc_000
                        female race_black race_other
                        dad_educ mom_educ
                        cohort_ref modal_state nkids_ref / solution;
    title " HS Completion with Cohort, State, Race, Sex, and Family Size FE";
run;
quit;

/* Any College Regression */
proc glm data=work.analysis_sample;
    class dad_educ mom_educ cohort_ref modal_state nkids_ref;
    model any_college = avg_eitc_000
                        female race_black race_other
                        dad_educ mom_educ
                        cohort_ref modal_state nkids_ref / solution;
    title "Any College Attendance with Cohort, State, Race, Sex, and Family Size FE";
run;
quit;

/* Bachelors Regression*/
proc glm data=work.analysis_sample;
    class dad_educ mom_educ cohort_ref modal_state nkids_ref;
    model bachelors = avg_eitc_000
                      female race_black race_other
                      dad_educ mom_educ
                      cohort_ref modal_state nkids_ref / solution;
    title "Bachelors Completion with Cohort, State, Race, Sex, and Family Size FE";
run;
quit;

/* REGRESSIONS - WITH INCOME CONTROL.*/

/* HS completion with income Regression*/
proc glm data=work.analysis_sample;
    class dad_educ mom_educ cohort_ref modal_state nkids_ref;
    model hs_complete = avg_eitc_000 log_income
                        female race_black race_other
                        dad_educ mom_educ
                        cohort_ref modal_state nkids_ref / solution;
    title "HS Completion with Income, Cohort, State, Race, Sex, and Family Size FE";
run;
quit;

/* Any College with income Regression*/
proc glm data=work.analysis_sample;
    class dad_educ mom_educ cohort_ref modal_state nkids_ref;
    model any_college = avg_eitc_000 log_income
                        female race_black race_other
                        dad_educ mom_educ
                        cohort_ref modal_state nkids_ref / solution;
    title "Any College with Income, Cohort, State, Race, Sex, and Family Size FE";
run;
quit;

/* Bachelors with income Regression */
proc glm data=work.analysis_sample;
    class dad_educ mom_educ cohort_ref modal_state nkids_ref;
    model bachelors = avg_eitc_000 log_income
                      female race_black race_other
                      dad_educ mom_educ
                      cohort_ref modal_state nkids_ref / solution;
    title "Bachelors with Income, Cohort, State, Race, Sex, and Family Size FE";
run;
quit;

/* STEP 7: GRAPHS - COHORT-ADJUSTED OUTCOME RATES BY EITC BIN AND INCOME GROUP */

proc glm data=work.analysis_sample noprint;
    class cohort_ref;
    model hs_complete any_college bachelors = cohort_ref / solution;
    output out=work.resid_data r=resid_hs resid_college resid_bach;
run;
quit;

proc means data=work.analysis_sample noprint;
    var hs_complete any_college bachelors;
    output out=work.grand_means
           mean(hs_complete) = mean_hs
           mean(any_college) = mean_college
           mean(bachelors)   = mean_bach;
run;

data _null_;
    set work.grand_means;
    call symputx('gm_hs',      mean_hs);
    call symputx('gm_college', mean_college);
    call symputx('gm_bach',    mean_bach);
run;

data work.resid_plot;
    set work.resid_data;

    if missing(below_phaseout) then delete;
    if missing(resid_hs)       then delete;

    if      avg_eitc_000 < 0.5  then eitc_bin = 0.25;
    else if avg_eitc_000 < 1.0  then eitc_bin = 0.75;
    else if avg_eitc_000 < 1.5  then eitc_bin = 1.25;
    else if avg_eitc_000 < 2.0  then eitc_bin = 1.75;
    else if avg_eitc_000 < 2.5  then eitc_bin = 2.25;
    else if avg_eitc_000 < 3.0  then eitc_bin = 2.75;
    else if avg_eitc_000 < 3.5  then eitc_bin = 3.25;
    else if avg_eitc_000 < 4.0  then eitc_bin = 3.75;
    else if avg_eitc_000 < 4.5  then eitc_bin = 4.25;
    else if avg_eitc_000 < 5.0  then eitc_bin = 4.75;
    else if avg_eitc_000 < 5.5  then eitc_bin = 5.25;
    else if avg_eitc_000 < 6.0  then eitc_bin = 5.75;
    else                             eitc_bin = 6.25;

    if below_phaseout = 1 then income_group = "Below Phaseout Ceiling";
    else                       income_group = "Above Phaseout Ceiling";

    adj_hs      = resid_hs      + &gm_hs.;
    adj_college = resid_college + &gm_college.;
    adj_bach    = resid_bach    + &gm_bach.;
run;

proc means data=work.resid_plot nway noprint;
    class eitc_bin income_group;
    var adj_hs adj_college adj_bach;
    output out=work.resid_plot_means
           mean(adj_hs)      = mean_hs
           mean(adj_college) = mean_college
           mean(adj_bach)    = mean_bach
           n(adj_hs)         = n_obs;
run;

proc means data=work.resid_plot_means nway noprint;
    class eitc_bin;
    var n_obs;
    output out=work.bin_min min(n_obs) = min_n;
run;

data work.resid_plot_means;
    merge work.resid_plot_means (in=a)
          work.bin_min          (keep=eitc_bin min_n);
    by eitc_bin;
    if a and min_n >= 10;
    drop min_n _type_ _freq_;
run;

proc sgplot data=work.resid_plot_means;
    series x=eitc_bin y=mean_college / group=income_group
           markers markerattrs=(size=8) lineattrs=(thickness=2);
    scatter x=eitc_bin y=mean_college / group=income_group
            markerattrs=(size=8)
            datalabel=n_obs datalabelattrs=(size=7);
    xaxis label="Average EITC Exposure During Ages 10-16 (Thousands $)"
          values=(0.25 0.75 1.25 1.75 2.25 2.75 3.25, 3.75, 4.25, 4.75, 5.25, 5.75, 6.25);
    yaxis label="Cohort-Adjusted Rate of Any College Attendance"
          min=0.3 max=0.7;
    keylegend / title="Family Income vs EITC Phaseout Ceiling";
    title "Cohort-Adjusted College Attendance Rate by EITC Exposure and Income Group";
    footnote "Note: "
             "Numbers on points show observation count per bin.";
run;

proc sgplot data=work.resid_plot_means;
    series x=eitc_bin y=mean_hs / group=income_group
           markers markerattrs=(size=8) lineattrs=(thickness=2);
    scatter x=eitc_bin y=mean_hs / group=income_group
            markerattrs=(size=8)
            datalabel=n_obs datalabelattrs=(size=7);
    xaxis label="Average EITC Exposure During Ages 10-16 (Thousands $)"
          values=(0.25 0.75 1.25 1.75 2.25 2.75 3.25, 3.75, 4.25, 4.75, 5.25, 5.75, 6.25);
    yaxis label="Cohort-Adjusted Rate of HS Completion"
          min=0.65 max=1;
    keylegend / title="Family Income vs EITC Phaseout Ceiling";
    title "Cohort-Adjusted HS Completion Rate by EITC Exposure and Income Group";
    footnote "Note: "
             "Numbers on points show observation count per bin.";
run;

proc sgplot data=work.resid_plot_means;
    series x=eitc_bin y=mean_bach / group=income_group
           markers markerattrs=(size=8) lineattrs=(thickness=2);
    scatter x=eitc_bin y=mean_bach / group=income_group
            markerattrs=(size=8)
            datalabel=n_obs datalabelattrs=(size=7);
    xaxis label="Average EITC Exposure During Ages 10-16 (Thousands $)"
          values=(0.25 0.75 1.25 1.75 2.25 2.75 3.25, 3.75, 4.25, 4.75, 5.25, 5.75, 6.25);
    yaxis label="Cohort-Adjusted Rate of Bachelors Completion"
          min=0 max=0.45;
    keylegend / title="Family Income vs EITC Phaseout Ceiling";
    title "Cohort-Adjusted Bachelors Completion Rate by EITC Exposure and Income Group";
    footnote "Note: "
             "Numbers on points show observation count per bin.";
run;

ods pdf close;






