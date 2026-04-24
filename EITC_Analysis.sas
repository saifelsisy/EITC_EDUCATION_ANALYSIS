*
Programmed by: Saif Elsisy
Personal Project on the Earned Income Tax Credits effect 
on Education Outcomes
;

%let root = S:\EITC;

x "cd &root.\Data";
libname InputDS ".";

x "cd &root.\Output";
libname P2 ".";

Ods listing gpath = “&root.\Output\Visuals”;

ods pdf file="EITC_Summary_Stats.pdf" dpi=300 style=Sapphire startpage=never;
ods graphics / width=5.5in;;

options nodate;
ods noproctitle;


%let FootOpts = j=L h=10pt;

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
        _birth_year = .;
    do _b = 1 to 43;
        if age_w[_b] > 0 and age_w[_b] < 120 then do;
            _birth_year = yr_map[_b] - age_w[_b];
            leave;
        end;
    end;
    if missing(AGEOFINDIVIDUAL) and not missing(_birth_year) then do;
        AGEOFINDIVIDUAL = YEAR - _birth_year;
        If AGEOFINDIVIDUAL < 0 then AGEOFINDIVIDUAL = .;
end;

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

title "Subsample Check: SRC vs SEO Composition";
proc freq data=P2.ProjectData_Cleaned_Long;
    tables WHETHERSAMPLEORNONSAMPLE / missing;
run;
title;

title "Summary Statistics - Key Analysis Variables by Year";
proc means data=P2.ProjectData_Cleaned_Long n nmiss mean std min max maxdec=2;
    class YEAR;
    var AGEOFINDIVIDUAL EDUCATIONATTAINED FATHERSEDUCATION
        MOTHERSEDUCATION TOTALFAMILYINCOME N_KIDS EITC_EXPOSURE;
run;
title;

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

    if missing(sex_val)  and not missing(SEXOFINDIVIDUAL)
        then sex_val  = SEXOFINDIVIDUAL;
    if missing(race_val) and not missing(RACE)
        then race_val = RACE;
    if missing(subsample) and not missing(WHETHERSAMPLEORNONSAMPLE)
        then subsample = WHETHERSAMPLEORNONSAMPLE;

    phaseout_floor   = .;
    phaseout_ceiling = .;

    if YEAR in (1975,1976,1977,1978) then do;
            phaseout_floor   = 4000;
            phaseout_ceiling = 8000;
        end;
    else if YEAR in (1979,1980,1981,1982,1983,1984) then do;
            phaseout_floor   = 6000;
            phaseout_ceiling = 10000;
        end;
    else if YEAR in (1985,1986) then do;
            phaseout_floor   = 6500;
            phaseout_ceiling = 11000;
        end;
    else if YEAR = 1987 then do;
            phaseout_floor   = 6920;
            phaseout_ceiling = 15432;
        end;
    else if YEAR = 1988 then do;
        if N_KIDS >= 1 then do;
            phaseout_floor   = 9840;
            phaseout_ceiling = 18576;
        end;
    end;
    else if YEAR = 1989 then do;
            phaseout_floor   = 10240;
            phaseout_ceiling = 19340;
        end;
    else if YEAR = 1990 then do;
            phaseout_floor   = 10730;
            phaseout_ceiling = 20264;
        end;
    else if YEAR = 1991 then do;
        if N_KIDS = 1 then do;
            phaseout_floor   = 11250;
            phaseout_ceiling = 21250;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 11250;
            phaseout_ceiling = 21250;
        end;
    end;
    else if YEAR = 1992 then do;
        if N_KIDS = 1 then do;
            phaseout_floor   = 11840;
            phaseout_ceiling = 22370;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 11840;
            phaseout_ceiling = 22370;
        end;
    end;
    else if YEAR = 1993 then do;
        if N_KIDS = 1 then do;
            phaseout_floor   = 12200;
            phaseout_ceiling = 23050;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 12200;
            phaseout_ceiling = 23050;
        end;
    end;
    else if YEAR = 1994 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 5000;
            phaseout_ceiling = 9000;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 11000;
            phaseout_ceiling = 23755;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 11000;
            phaseout_ceiling = 25296;
        end;
    end;
    else if YEAR = 1995 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 5130;
            phaseout_ceiling = 9230;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 11290;
            phaseout_ceiling = 24396;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 11290;
            phaseout_ceiling = 26673;
        end;
    end;
    else if YEAR = 1996 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 5280;
            phaseout_ceiling = 9500;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 11610;
            phaseout_ceiling = 25078;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 11610;
            phaseout_ceiling = 28495;
        end;
    end;
    else if YEAR = 1997 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 5430;
            phaseout_ceiling = 9770;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 11930;
            phaseout_ceiling = 25750;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 11930;
            phaseout_ceiling = 29290;
        end;
    end;
    else if YEAR = 1999 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 5670;
            phaseout_ceiling = 10200;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 12460;
            phaseout_ceiling = 26928;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 12460;
            phaseout_ceiling = 30580;
        end;
    end;
    else if YEAR = 2001 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 5950;
            phaseout_ceiling = 10710;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 13090;
            phaseout_ceiling = 28281;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 13090;
            phaseout_ceiling = 32121;
        end;
    end;
    else if YEAR = 2003 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 6240;
            phaseout_ceiling = 11230;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 13730;
            phaseout_ceiling = 29666;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 13730;
            phaseout_ceiling = 33692;
        end;
    end;
    else if YEAR = 2005 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 6530;
            phaseout_ceiling = 11750;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 14370;
            phaseout_ceiling = 31030;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 14370;
            phaseout_ceiling = 35263;
        end;
    end;
    else if YEAR = 2007 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 7000;
            phaseout_ceiling = 12590;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 15390;
            phaseout_ceiling = 33241;
        end;
        else if N_KIDS >= 2 then do;
            phaseout_floor   = 15390;
            phaseout_ceiling = 37783;
        end;
    end;
    else if YEAR = 2009 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 7470;
            phaseout_ceiling = 13440;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 16420;
            phaseout_ceiling = 35463;
        end;
        else if N_KIDS = 2 then do;
            phaseout_floor   = 16420;
            phaseout_ceiling = 40295;
        end;
        else if N_KIDS >= 3 then do;
            phaseout_floor   = 16420;
            phaseout_ceiling = 43279;
        end;
    end;
    else if YEAR = 2011 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 7590;
            phaseout_ceiling = 13660;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 16690;
            phaseout_ceiling = 36052;
        end;
        else if N_KIDS = 2 then do;
            phaseout_floor   = 16690;
            phaseout_ceiling = 40964;
        end;
        else if N_KIDS >= 3 then do;
            phaseout_floor   = 16690;
            phaseout_ceiling = 43998;
        end;
    end;
    else if YEAR = 2013 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 7970;
            phaseout_ceiling = 14340;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 17530;
            phaseout_ceiling = 37870;
        end;
        else if N_KIDS = 2 then do;
            phaseout_floor   = 17530;
            phaseout_ceiling = 43038;
        end;
        else if N_KIDS >= 3 then do;
            phaseout_floor   = 17530;
            phaseout_ceiling = 46227;
        end;
    end;
    else if YEAR = 2015 then do;
        if N_KIDS = 0 then do;
            phaseout_floor   = 8240;
            phaseout_ceiling = 14820;
        end;
        else if N_KIDS = 1 then do;
            phaseout_floor   = 18110;
            phaseout_ceiling = 39131;
        end;
        else if N_KIDS = 2 then do;
            phaseout_floor   = 18110;
            phaseout_ceiling = 44454;
        end;
        else if N_KIDS >= 3 then do;
            phaseout_floor   = 18110;
            phaseout_ceiling = 47747;
        end;
    end;

    if in_exposure_age then do;

        if not missing(EITC_EXPOSURE) then do;
            total_eitc     = total_eitc + EITC_EXPOSURE;
            exposure_count = exposure_count + 1;
        end;

        if not missing(TOTALFAMILYINCOME) and TOTALFAMILYINCOME > 0 then do;
            avg_income   = avg_income + TOTALFAMILYINCOME;
            income_count = income_count + 1;
            if not missing(phaseout_floor) and not missing(phaseout_ceiling)
                and TOTALFAMILYINCOME >= phaseout_floor then do;
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

    if not missing(dad_educ) then do;
        dad_BelowHS        = (dad_educ in (1,2,3));
        dad_HS             = (dad_educ in (4,5));
        dad_CollegeOrAbove = (dad_educ in (6,7,8));
    end;
    else do;
        dad_BelowHS = .; dad_HS = .; dad_CollegeOrAbove = .;
    end;

    if not missing(mom_educ) then do;
        mom_BelowHS        = (mom_educ in (1,2,3));
        mom_HS             = (mom_educ in (4,5));
        mom_CollegeOrAbove = (mom_educ in (6,7,8));
    end;
    else do;
        mom_BelowHS = .; mom_HS = .; mom_CollegeOrAbove = .;
    end;

    hs_complete = (max_educ >= 12);
    any_college = (max_educ >= 13);
    bachelors   = (max_educ >= 16);

    avg_eitc_000 = avg_eitc / 1000;

    if not missing(avg_family_income) and avg_family_income > 0
        then log_income = log(avg_family_income);
        else log_income = .;

    if not missing(sex) then female = (sex = 2);
    else female = .;


    if not missing(race) then do;
        race_black = (race = 2);
        race_other = (race in (3,4,5,6,7));
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

title "Subsample Composition in Analysis Sample (1=SRC, 2=SEO)";
proc freq data=work.analysis_sample;
    tables subsample / missing;
run;
title;


title "Sample Frequency Checks";
proc freq data=work.analysis_sample;
    tables hs_complete any_college bachelors
           dad_educ mom_educ cohort_ref below_phaseout
           modal_state nkids_ref female race_black race_other / missing;
run;
title;

title "Summary Statistics - Analysis Sample";
proc means data=work.analysis_sample n nmiss mean std min max maxdec=2;
    var avg_eitc avg_eitc_000 max_educ hs_complete any_college
        bachelors avg_family_income log_income female race_black race_other;
run;
title;

/* CORRELATION MATRIX */

title "Correlation Matrix - Continuous and Binary Analysis Variables";
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
run;
title;

/* dad_educ and mom_educ seperate */
title "Correlation Matrix - Parental Education vs EITC and Income";
proc corr data=work.analysis_sample
          pearson
          nosimple;
    var dad_educ mom_educ avg_eitc_000 log_income;
run;
title;

ods pdf close;

ods pdf file="EITC_Regressions_Plus_Plots.pdf" dpi=300 style=Sapphire startpage=never;

footnote &FootOpts "Note: For both mom and dad education, below high school education is the reference group.";
footnote2 &FootOpts "For race white is the reference group."

/* HS completion Regression */
title "HS Completion with Cohort, State, Race, Sex, and Family Size FE";
proc glm data=work.analysis_sample;
    class cohort_ref modal_state nkids_ref;
    model hs_complete = avg_eitc_000
                        female race_black race_other
                        dad_HS dad_CollegeOrAbove
                        mom_HS mom_CollegeOrAbove
                        cohort_ref modal_state nkids_ref / solution;
run;
quit;
title;

/* Any College Regression */
title "Any College Attendance with Cohort, State, Race, Sex, and Family Size FE";
proc glm data=work.analysis_sample;
    class cohort_ref modal_state nkids_ref;
    model any_college = avg_eitc_000
                        female race_black race_other
                        dad_HS dad_CollegeOrAbove
                        mom_HS mom_CollegeOrAbove
                        cohort_ref modal_state nkids_ref / solution;
run;
quit;
title;

/* Bachelors Regression*/
title "Bachelors Completion with Cohort, State, Race, Sex, and Family Size FE";
proc glm data=work.analysis_sample;
    class cohort_ref modal_state nkids_ref;
    model bachelors = avg_eitc_000
                      female race_black race_other
                      dad_HS dad_CollegeOrAbove
                      mom_HS mom_CollegeOrAbove
                      cohort_ref modal_state nkids_ref / solution;
run;
quit;
title;

/* REGRESSIONS - WITH INCOME CONTROL.*/

/* HS completion with income Regression*/
title "HS Completion with Income, Cohort, State, Race, Sex, and Family Size FE";
proc glm data=work.analysis_sample;
    class cohort_ref modal_state nkids_ref;
    model hs_complete = avg_eitc_000 log_income
                        female race_black race_other
                        dad_HS dad_CollegeOrAbove
                        mom_HS mom_CollegeOrAbove
                        cohort_ref modal_state nkids_ref / solution;
run;
quit;
title;

/* Any College with income Regression*/
title "Any College with Income, Cohort, State, Race, Sex, and Family Size FE";
proc glm data=work.analysis_sample;
    class cohort_ref modal_state nkids_ref;
    model any_college = avg_eitc_000 log_income
                        female race_black race_other
                        dad_HS dad_CollegeOrAbove
                        mom_HS mom_CollegeOrAbove
                        cohort_ref modal_state nkids_ref / solution;
run;
quit;
title;

/* Bachelors with income Regression */
title "Bachelors with Income, Cohort, State, Race, Sex, and Family Size FE";
proc glm data=work.analysis_sample;
    class cohort_ref modal_state nkids_ref;
    model bachelors = avg_eitc_000 log_income
                      female race_black race_other
                      dad_HS dad_CollegeOrAbove
                      mom_HS mom_CollegeOrAbove
                      cohort_ref modal_state nkids_ref / solution;
run;
quit;
title;

footnote;

/* GRAPHS - COHORT-ADJUSTED OUTCOME RATES BY EITC BIN, INCOME GROUP, AND KIDS GROUP */

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
 
Ods graphics / reset imagename= “College_Attendance_Plot” imagefmt=png width = 7in height = 5in;

title "Cohort-Adjusted College Attendance Rate by EITC Exposure and Income Group";
footnote &FootOpts "Note: Numbers on points show observation count per bin. Income floor based on EITC phaseout beginning income by year and number of children.";
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
run;
title;
Footnote;

Ods graphics / reset imagename= “HS_Completion_Plot” imagefmt=png width = 7in height = 5in;

title "Cohort-Adjusted HS Completion Rate by EITC Exposure and Income Group";
footnote &FootOpts "Note: Numbers on points show observation count per bin. Income floor based on EITC phaseout beginning income by year and number of children.";
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
run;
title;
footnote;

Ods graphics / reset imagename= “Bachelors_Completion_Plot” imagefmt=png width = 7in height = 5in;

title "Cohort-Adjusted Bachelors Completion Rate by EITC Exposure and Income Group";
footnote &FootOpts "Note: Numbers on points show observation count per bin. Income floor based on EITC phaseout beginning income by year and number of children.";
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
run;
title;
footnote;

ods pdf close;


