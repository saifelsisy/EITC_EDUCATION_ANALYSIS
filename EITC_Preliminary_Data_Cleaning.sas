*
Programmed by: Saif Elsisy
Personal Project on the Earned Income Tax Credits effect 
on Education Outcomes
;

x "cd S:\EITC\Data";
libname InputDS ".";


x "cd S:\EITC\Output";
libname P2 ".";

options nodate;
ods noproctitle;


ods pdf file="EITC_Data_Output.pdf" dpi=300 style=Sapphire;

data codebook;
  infile "S:\EITC\Data\Correct_Labels_TextFile.txt" lrecl=200 truncover firstobs=6;
  length var $11 rawlabel $38 year $4 final_label $100 newname $32;
  input @1 var $10.
  @12 rawlabel $38.
  @50 year $4.;

  var = strip(var);
  rawlabel = strip(rawlabel);
  year = strip(year);

    if not missing(year) then do;
    if length(year)=2 then do;
    if input(year,8.) >= 67 then year = cats('19', year);
    else year = cats('20', year);
    end;
    final_label = catx(' ', rawlabel, year);
    end;
    else final_label = rawlabel;

  final_label = strip(final_label);

  newname = upcase(final_label);

  newname = compbl(newname);
  newname = tranwrd(newname,' ','_');

  newname = compress(newname,, 'kas');

    if not missing(year) then do;
    yearnum = compress(year,, 'kd');
    if yearnum ne '' then newname = cats(newname,'_',yearnum);
    end;

  newname = substr(newname,1,32);

    drop yearnum;
run;

proc import datafile="S:\EITC\Data\Fixed_Data.xlsx"
  out=work.projectdata_raw
  dbms=xlsx
;
  getnames=yes;
run;

proc sql noprint;
  select cats(a.var,'=',a.newname)
    into :renamelist separated by ' '
  from codebook as a
    inner join dictionary.columns as b
  on upcase(a.var)=upcase(b.name)
    where upcase(b.libname)='WORK'
    and upcase(b.memname)='PROJECTDATA_RAW';
quit;

data work.ProjectData_WithEITC;
  %if %length(&renamelist) %then %do;
    set work.projectdata_raw (rename=(&renamelist));
  %end;
  %else %do;
    set work.projectdata_raw;
  %end;


  array yr_map[43] _temporary_
    (1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980
     1981 1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993
     1994 1995 1996 1997 1999 2001 2003 2005 2007 2009 2011 2013 2015
     2017 2019 2021 2023);

  array age_arr[43]
    AGEOFINDIVIDUAL_1968  AGEOFINDIVIDUAL_1969  AGEOFINDIVIDUAL_1970
    AGEOFINDIVIDUAL_1971  AGEOFINDIVIDUAL_1972  AGEOFINDIVIDUAL_1973
    AGEOFINDIVIDUAL_1974  AGEOFINDIVIDUAL_1975  AGEOFINDIVIDUAL_1976
    AGEOFINDIVIDUAL_1977  AGEOFINDIVIDUAL_1978  AGEOFINDIVIDUAL_1979
    AGEOFINDIVIDUAL_1980  AGEOFINDIVIDUAL_1981  AGEOFINDIVIDUAL_1982
    AGEOFINDIVIDUAL_1983  AGEOFINDIVIDUAL_1984  AGEOFINDIVIDUAL_1985
    AGEOFINDIVIDUAL_1986  AGEOFINDIVIDUAL_1987  AGEOFINDIVIDUAL_1988
    AGEOFINDIVIDUAL_1989  AGEOFINDIVIDUAL_1990  AGEOFINDIVIDUAL_1991
    AGEOFINDIVIDUAL_1992  AGEOFINDIVIDUAL_1993  AGEOFINDIVIDUAL_1994
    AGEOFINDIVIDUAL_1995  AGEOFINDIVIDUAL_1996  AGEOFINDIVIDUAL_1997
    AGEOFINDIVIDUAL_1999  AGEOFINDIVIDUAL_2001  AGEOFINDIVIDUAL_2003
    AGEOFINDIVIDUAL_2005  AGEOFINDIVIDUAL_2007  AGEOFINDIVIDUAL_2009
    AGEOFINDIVIDUAL_2011  AGEOFINDIVIDUAL_2013  AGEOFINDIVIDUAL_2015
    AGEOFINDIVIDUAL_2017  AGEOFINDIVIDUAL_2019  AGEOFINDIVIDUAL_2021
    AGEOFINDIVIDUAL_2023;

  _birth_year = .;
  do _j = 1 to 43;
    if age_arr[_j] > 0 and age_arr[_j] < 120 then do;
      _birth_year = yr_map[_j] - age_arr[_j];
      leave;
    end;
  end;

  if not (1959 <= _birth_year <= 1999) then delete;

/* California from 2015 onward had a complicated eitc method. I am not able to calculate it properly so I am dropping them so that they don’t interfere with correct analysis. Only people born 1999 could be old enough in 2023 and be between ages 10-16 in 2015 so they are the ones being dropped*/
  if _birth_year in (1999) and CURRENTSTATE_2015 = 6 then delete;

  array nk[43]
    NUMBEROFCHILDREN_1968  NUMBEROFCHILDREN_1969  NUMBEROFCHILDREN_1970
    NUMBEROFCHILDREN_1971  NUMBEROFCHILDREN_1972  NUMBEROFCHILDREN_1973
    NUMBEROFCHILDREN_1974  NUMBEROFCHILDREN_1975  NUMBEROFCHILDREN_1976
    NUMBEROFCHILDREN_1977  NUMBEROFCHILDREN_1978  NUMBEROFCHILDREN_1979
    NUMBEROFCHILDREN_1980  NUMBEROFCHILDREN_1981  NUMBEROFCHILDREN_1982
    NUMBEROFCHILDREN_1983  NUMBEROFCHILDREN_1984  NUMBEROFCHILDREN_1985
    NUMBEROFCHILDREN_1986  NUMBEROFCHILDREN_1987  NUMBEROFCHILDREN_1988
    NUMBEROFCHILDREN_1989  NUMBEROFCHILDREN_1990  NUMBEROFCHILDREN_1991
    NUMBEROFCHILDREN_1992  NUMBEROFCHILDREN_1993  NUMBEROFCHILDREN_1994
    NUMBEROFCHILDREN_1995  NUMBEROFCHILDREN_1996  NUMBEROFCHILDREN_1997
    NUMBEROFCHILDREN_1999  NUMBEROFCHILDREN_2001  NUMBEROFCHILDREN_2003
    NUMBEROFCHILDREN_2005  NUMBEROFCHILDREN_2007  NUMBEROFCHILDREN_2009
    NUMBEROFCHILDREN_2011  NUMBEROFCHILDREN_2013  NUMBEROFCHILDREN_2015
    NUMBEROFCHILDREN_2017  NUMBEROFCHILDREN_2019  NUMBEROFCHILDREN_2021
    NUMBEROFCHILDREN_2023;

  array stvar[25]
    CURRENTSTATE_1986  CURRENTSTATE_1987  CURRENTSTATE_1988
    CURRENTSTATE_1989  CURRENTSTATE_1990  CURRENTSTATE_1991
    CURRENTSTATE_1992  CURRENTSTATE_1993  CURRENTSTATE_1994
    CURRENTSTATE_1995  CURRENTSTATE_1996  CURRENTSTATE_1997
    CURRENTSTATE_1999  CURRENTSTATE_2001  CURRENTSTATE_2003
    CURRENTSTATE_2005  CURRENTSTATE_2007  CURRENTSTATE_2009
    CURRENTSTATE_2011  CURRENTSTATE_2013  CURRENTSTATE_2015
    CURRENTSTATE_2017  CURRENTSTATE_2019  CURRENTSTATE_2021
    CURRENTSTATE_2023;

  array stidx[43] _temporary_
    ( 0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
      1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18
     19 20 21 22 23 24 25);

  length _f0 _f1 _f2 _f3 _pct 8;

  do _i = 1 to 43;
    YEAR = yr_map[_i];

    if stidx[_i] > 0 then STATE = stvar[stidx[_i]];
    else                   STATE = .;

    N_KIDS = nk[_i];
    if      N_KIDS >= 3 then N_KIDS_CAT = 3;
    else if N_KIDS >= 0 then N_KIDS_CAT = N_KIDS;
    else                     N_KIDS_CAT = .;

    if YEAR <= 1974 then
      EITC_EXPOSURE = 0;

    else if YEAR <= 1978 then do;
      if N_KIDS_CAT in (0,1,2,3) then EITC_EXPOSURE = 400;
      else EITC_EXPOSURE = .;
    end;

    else if YEAR <= 1983 then do;
      if N_KIDS_CAT in (0,1,2,3) then EITC_EXPOSURE = 500;
      else EITC_EXPOSURE = .;
    end;

    else if YEAR = 1984 then do;
      if N_KIDS_CAT in (0,1,2,3) then EITC_EXPOSURE = 500;
      else EITC_EXPOSURE = .;
    end;

    else if YEAR = 1985 then do;
      if N_KIDS_CAT in (0,1,2,3) then EITC_EXPOSURE = 550;
      else EITC_EXPOSURE = .;
    end;

    else if YEAR = 1986 then do;
      if N_KIDS_CAT in (0,1,2,3) then EITC_EXPOSURE = 550;
      else EITC_EXPOSURE = .;
    end;

    else if YEAR = 1987 then do;
      _f0=851; _f1=851; _f2=851; _f3=851;
      if STATE=24 then _pct=0.50;
      else             _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
    end;

    else if YEAR = 1988 then do;
      _f0=874; _f1=874; _f2=874; _f3=874;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.23;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
    end;

    else if YEAR = 1989 then do;
      _f0=910; _f1=910; _f2=910; _f3=910;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.28;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.05;
          when (1) EITC_EXPOSURE = _f1*1.25;
          when (2) EITC_EXPOSURE = _f2*1.75;
          when (3) EITC_EXPOSURE = _f3*1.75;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1990 then do;
      _f0=953; _f1=953; _f2=953; _f3=953;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.28;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.05;
          when (1) EITC_EXPOSURE = _f1*1.25;
          when (2) EITC_EXPOSURE = _f2*1.75;
          when (3) EITC_EXPOSURE = _f3*1.75;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1991 then do;
      _f0=1192; _f1=1192; _f2=1235; _f3=1235;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.28;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.05;
          when (1) EITC_EXPOSURE = _f1*1.25;
          when (2) EITC_EXPOSURE = _f2*1.75;
          when (3) EITC_EXPOSURE = _f3*1.75;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1992 then do;
      _f0=1324; _f1=1324; _f2=1384; _f3=1384;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.28;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.05;
          when (1) EITC_EXPOSURE = _f1*1.25;
          when (2) EITC_EXPOSURE = _f2*1.75;
          when (3) EITC_EXPOSURE = _f3*1.75;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1993 then do;
      _f0=1434; _f1=1434; _f2=1511; _f3=1511;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.28;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.05;
          when (1) EITC_EXPOSURE = _f1*1.25;
          when (2) EITC_EXPOSURE = _f2*1.75;
          when (3) EITC_EXPOSURE = _f3*1.75;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1994 then do;
      _f0=2038; _f1=2038; _f2=2528; _f3=2528;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.25;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.12;
          when (1) EITC_EXPOSURE = _f1*1.63;
          when (2) EITC_EXPOSURE = _f2*1.188;
          when (3) EITC_EXPOSURE = _f3*1.188;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1995 then do;
      _f0=2094; _f1=2094; _f2=3110; _f3=3110;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.25;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.04;
          when (1) EITC_EXPOSURE = _f1*1.16;
          when (2) EITC_EXPOSURE = _f2*1.50;
          when (3) EITC_EXPOSURE = _f3*1.50;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1996 then do;
      _f0=2152; _f1=2152; _f2=3556; _f3=3556;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.25;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.04;
          when (1) EITC_EXPOSURE = _f1*1.14;
          when (2) EITC_EXPOSURE = _f2*1.43;
          when (3) EITC_EXPOSURE = _f3*1.43;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1997 then do;
      _f0=2210; _f1=2210; _f2=3656; _f3=3656;
      if      STATE=24 then _pct=0.50;
      else if STATE=50 then _pct=0.25;
      else if STATE=41 then _pct=0.05;
      else if STATE=25 then _pct=0.10;
      else if STATE=36 then _pct=0.20;
      else if STATE=19 then _pct=0.065;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0*1.04;
          when (1) EITC_EXPOSURE = _f1*1.14;
          when (2) EITC_EXPOSURE = _f2*1.43;
          when (3) EITC_EXPOSURE = _f3*1.43;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 1999 then do;
      _f0=347; _f1=2312; _f2=3816; _f3=3816;
      if      STATE= 8 then _pct=0.10;
      else if STATE=11 then _pct=0.10;
      else if STATE=19 then _pct=0.065;
      else if STATE=20 then _pct=0.10;
      else if STATE=25 then _pct=0.10;
      else if STATE=24 then _pct=0.60;
      else if STATE=36 then _pct=0.20;
      else if STATE=50 then _pct=0.25;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.14;
          when (3) EITC_EXPOSURE = _f3*1.43;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 2001 then do;
      _f0=364; _f1=2428; _f2=4008; _f3=4008;
      if      STATE= 8 then _pct=0.10;
      else if STATE=11 then _pct=0.25;
      else if STATE=19 then _pct=0.065;
      else if STATE=20 then _pct=0.10;
      else if STATE=25 then _pct=0.15;
      else if STATE=24 then _pct=0.66;
      else if STATE=34 then _pct=0.15;
      else if STATE=36 then _pct=0.25;
      else if STATE=50 then _pct=0.32;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.14;
          when (3) EITC_EXPOSURE = _f3*1.43;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 2003 then do;
      _f0=382; _f1=2547; _f2=4204; _f3=4204;
      if      STATE=11 then _pct=0.25;
      else if STATE=19 then _pct=0.065;
      else if STATE=17 then _pct=0.05;
      else if STATE=18 then _pct=0.06;
      else if STATE=20 then _pct=0.15;
      else if STATE=25 then _pct=0.15;
      else if STATE=24 then _pct=0.68;
      else if STATE=34 then _pct=0.20;
      else if STATE=36 then _pct=0.30;
      else if STATE=41 then _pct=0.05;
      else if STATE=44 then _pct=0.30;
      else if STATE=50 then _pct=0.32;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.14;
          when (3) EITC_EXPOSURE = _f3*1.43;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 2005 then do;
      _f0=399; _f1=2662; _f2=4400; _f3=4400;
      if      STATE=11 then _pct=0.35;
      else if STATE=19 then _pct=0.065;
      else if STATE=17 then _pct=0.05;
      else if STATE=18 then _pct=0.06;
      else if STATE=20 then _pct=0.15;
      else if STATE=25 then _pct=0.15;
      else if STATE=24 then _pct=0.70;
      else if STATE=34 then _pct=0.20;
      else if STATE=36 then _pct=0.30;
      else if STATE=41 then _pct=0.05;
      else if STATE=44 then _pct=0.35;
      else if STATE=50 then _pct=0.32;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.14;
          when (3) EITC_EXPOSURE = _f3*1.43;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 2007 then do;
      _f0=428; _f1=2853; _f2=4716; _f3=4716;
      if      STATE=11 then _pct=0.35;
      else if STATE=10 then _pct=0.20;
      else if STATE=19 then _pct=0.07;
      else if STATE=17 then _pct=0.05;
      else if STATE=18 then _pct=0.06;
      else if STATE=20 then _pct=0.17;
      else if STATE=25 then _pct=0.15;
      else if STATE=24 then _pct=0.70;
      else if STATE=31 then _pct=0.10;
      else if STATE=34 then _pct=0.20;
      else if STATE=35 then _pct=0.08;
      else if STATE=36 then _pct=0.30;
      else if STATE=40 then _pct=0.05;
      else if STATE=41 then _pct=0.05;
      else if STATE=44 then _pct=0.40;
      else if STATE=51 then _pct=0.20;
      else if STATE=50 then _pct=0.32;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.14;
          when (3) EITC_EXPOSURE = _f3*1.43;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 2009 then do;
      _f0=457; _f1=3043; _f2=5028; _f3=5657;
      if      STATE=11 then _pct=0.40;
      else if STATE=10 then _pct=0.20;
      else if STATE=19 then _pct=0.07;
      else if STATE=17 then _pct=0.05;
      else if STATE=18 then _pct=0.09;
      else if STATE=20 then _pct=0.17;
      else if STATE=22 then _pct=0.035;
      else if STATE=25 then _pct=0.15;
      else if STATE=24 then _pct=0.75;
      else if STATE=23 then _pct=0.04;
      else if STATE=26 then _pct=0.20;
      else if STATE=31 then _pct=0.10;
      else if STATE=34 then _pct=0.25;
      else if STATE=35 then _pct=0.10;
      else if STATE=36 then _pct=0.30;
      else if STATE=37 then _pct=0.05;
      else if STATE=40 then _pct=0.05;
      else if STATE=41 then _pct=0.06;
      else if STATE=44 then _pct=0.40;
      else if STATE=51 then _pct=0.20;
      else if STATE=50 then _pct=0.32;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.14;
          when (3) EITC_EXPOSURE = _f3*1.43;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 2011 then do;
      _f0=464; _f1=3094; _f2=5112; _f3=5751;
      if      STATE= 9 then _pct=0.30;
      else if STATE=11 then _pct=0.40;
      else if STATE=10 then _pct=0.20;
      else if STATE=19 then _pct=0.07;
      else if STATE=17 then _pct=0.05;
      else if STATE=18 then _pct=0.09;
      else if STATE=20 then _pct=0.18;
      else if STATE=22 then _pct=0.035;
      else if STATE=25 then _pct=0.15;
      else if STATE=24 then _pct=0.75;
      else if STATE=23 then _pct=0.05;
      else if STATE=26 then _pct=0.06;
      else if STATE=31 then _pct=0.10;
      else if STATE=34 then _pct=0.20;
      else if STATE=35 then _pct=0.10;
      else if STATE=36 then _pct=0.30;
      else if STATE=37 then _pct=0.05;
      else if STATE=40 then _pct=0.05;
      else if STATE=41 then _pct=0.06;
      else if STATE=44 then _pct=0.40;
      else if STATE=51 then _pct=0.20;
      else if STATE=50 then _pct=0.32;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.11;
          when (3) EITC_EXPOSURE = _f3*1.34;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 2013 then do;
      _f0=487; _f1=3250; _f2=5372; _f3=6044;
      if      STATE= 9 then _pct=0.25;
      else if STATE=11 then _pct=0.40;
      else if STATE=10 then _pct=0.20;
      else if STATE=19 then _pct=0.14;
      else if STATE=17 then _pct=0.10;
      else if STATE=18 then _pct=0.09;
      else if STATE=20 then _pct=0.17;
      else if STATE=22 then _pct=0.035;
      else if STATE=25 then _pct=0.15;
      else if STATE=24 then _pct=0.75;
      else if STATE=23 then _pct=0.05;
      else if STATE=26 then _pct=0.06;
      else if STATE=31 then _pct=0.10;
      else if STATE=34 then _pct=0.20;
      else if STATE=35 then _pct=0.10;
      else if STATE=36 then _pct=0.30;
      else if STATE=37 then _pct=0.045;
      else if STATE=39 then _pct=0.05;
      else if STATE=40 then _pct=0.05;
      else if STATE=41 then _pct=0.06;
      else if STATE=44 then _pct=0.375;
      else if STATE=51 then _pct=0.20;
      else if STATE=50 then _pct=0.32;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.11;
          when (3) EITC_EXPOSURE = _f3*1.34;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else if YEAR = 2015 then do;
      _f0=503; _f1=3359; _f2=5548; _f3=6242;
      if      STATE= 8 then _pct=0.10;
      else if STATE= 9 then _pct=0.275;
      else if STATE=11 then _pct=0.40;
      else if STATE=10 then _pct=0.20;
      else if STATE=19 then _pct=0.15;
      else if STATE=17 then _pct=0.10;
      else if STATE=18 then _pct=0.09;
      else if STATE=20 then _pct=0.17;
      else if STATE=22 then _pct=0.035;
      else if STATE=25 then _pct=0.15;
      else if STATE=24 then _pct=0.755;
      else if STATE=23 then _pct=0.05;
      else if STATE=26 then _pct=0.06;
      else if STATE=31 then _pct=0.10;
      else if STATE=34 then _pct=0.30;
      else if STATE=35 then _pct=0.10;
      else if STATE=36 then _pct=0.30;
      else if STATE=39 then _pct=0.10;
      else if STATE=40 then _pct=0.05;
      else if STATE=41 then _pct=0.08;
      else if STATE=44 then _pct=0.35;
      else if STATE=51 then _pct=0.20;
      else if STATE=50 then _pct=0.32;
      else                  _pct=0.00;
      select (N_KIDS_CAT);
        when (0) EITC_EXPOSURE = _f0*(1+_pct);
        when (1) EITC_EXPOSURE = _f1*(1+_pct);
        when (2) EITC_EXPOSURE = _f2*(1+_pct);
        when (3) EITC_EXPOSURE = _f3*(1+_pct);
        otherwise EITC_EXPOSURE = .;
      end;
      if STATE=55 then do;
        select (N_KIDS_CAT);
          when (0) EITC_EXPOSURE = _f0;
          when (1) EITC_EXPOSURE = _f1*1.04;
          when (2) EITC_EXPOSURE = _f2*1.11;
          when (3) EITC_EXPOSURE = _f3*1.34;
          otherwise EITC_EXPOSURE = .;
        end;
      end;
    end;

    else EITC_EXPOSURE = .;

    output;
  end;

  drop _i _j _birth_year _f0 _f1 _f2 _f3 _pct;
run;


proc sort data=work.ProjectData_WithEITC;
  by IDNUMBER_1968 YEAR;
run;

/* Only write to network once, sequentially — no merge step */
data P2.ProjectData_WithEITC;
  set work.ProjectData_WithEITC;
run;


proc means data=P2.ProjectData_WithEITC n nmiss min max mean;
  class YEAR;
  var EITC_EXPOSURE;
run;


ods pdf close;

/*
proc contents data=P2.ProjectData_WithEITC varnum; run;
*/

quit;

