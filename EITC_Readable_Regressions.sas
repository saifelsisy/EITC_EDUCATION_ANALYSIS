*
Programmed by: Saif Elsisy
EITC and Education Outcomes
Regression Output Tables Readable
;

x "cd S:\EITC\Output";
options nodate;
ods noproctitle;


%macro reg_table(pdfname=, outcome=, dep_label=, inc_control=0, tbl_num=);

    ods exclude all;

    proc glm data=work.analysis_sample;
        class cohort_ref modal_state nkids_ref;
        %if &inc_control = 1 %then %do;
        model &outcome = avg_eitc_000 log_income
                         female race_black race_other
                         dad_HS dad_CollegeOrAbove
                         mom_HS mom_CollegeOrAbove
                         cohort_ref modal_state nkids_ref / solution ss3;
        %end;
        %else %do;
        model &outcome = avg_eitc_000
                         female race_black race_other
                         dad_HS dad_CollegeOrAbove
                         mom_HS mom_CollegeOrAbove
                         cohort_ref modal_state nkids_ref / solution ss3;
        %end;
        ods output ParameterEstimates = work._pe
                   ModelANOVA        = work._anova
                   FitStatistics     = work._fit
                   NObs              = work._nobs;
    run;
    quit;

    ods exclude none;


    data work._pe_display;
        set work._pe;
        length VarLabel $60 Stars $3;

        if Parameter not in (
            'Intercept',
            'avg_eitc_000',
            'log_income',
            'female',
            'race_black',
            'race_other',
            'dad_HS',
            'dad_CollegeOrAbove',
            'mom_HS',
            'mom_CollegeOrAbove'
        ) then delete;

        select (Parameter);
            when ('Intercept')
                VarLabel = 'Intercept';
            when ('avg_eitc_000')
                VarLabel = 'Avg. EITC Exposure Ages 10-16 ($000s)';
            when ('log_income')
                VarLabel = 'Log Avg. Family Income (Ages 10-16)';
            when ('female')
                VarLabel = 'Female (ref: Male)';
            when ('race_black')
                VarLabel = 'Black (ref: White)';
            when ('race_other')
                VarLabel = 'Other Race (ref: White)';
            when ('dad_HS')
                VarLabel = 'Father: HS Diploma (ref: Below HS)';
            when ('dad_CollegeOrAbove')
                VarLabel = 'Father: College or Above (ref: Below HS)';
            when ('mom_HS')
                VarLabel = 'Mother: HS Diploma (ref: Below HS)';
            when ('mom_CollegeOrAbove')
                VarLabel = 'Mother: College or Above (ref: Below HS)';
            otherwise
                VarLabel = Parameter;
        end;

        select (Parameter);
            when ('Intercept')          SortOrder = 1;
            when ('avg_eitc_000')       SortOrder = 2;
            when ('log_income')         SortOrder = 3;
            when ('female')             SortOrder = 4;
            when ('race_black')         SortOrder = 5;
            when ('race_other')         SortOrder = 6;
            when ('dad_HS')             SortOrder = 7;
            when ('dad_CollegeOrAbove') SortOrder = 8;
            when ('mom_HS')             SortOrder = 9;
            when ('mom_CollegeOrAbove') SortOrder = 10;
            otherwise                  SortOrder = 99;
        end;

        if      Probt < 0.01 then Stars = '***';
        else if Probt < 0.05 then Stars = '**';
        else if Probt < 0.10 then Stars = '*';
        else                      Stars = '';

        keep VarLabel SortOrder Estimate StdErr Probt Stars;
    run;

    proc sort data=work._pe_display;
        by SortOrder;
    run;


    data work._fe_fstats;
        set work._anova;
        length FELabel $25;
        if Source = 'cohort_ref'
            then FELabel = 'Birth Cohort FE';
        else if Source = 'modal_state'
            then FELabel = 'State of Residence FE';
        else if Source = 'nkids_ref'
            then FELabel = 'Family Size FE';
        else delete;
        keep FELabel DF FValue ProbF;
    run;

    %let nobs = .;
    %let rsq  = .;


    data _null_;
        set work._nobs;
        call symputx('nobs', nValue2);
    Run;

   data _null_;
        set work._fit;
        call symputx('rsq', put(RSquare, 6.4));
    run;




    ods pdf file="&pdfname..pdf"
            dpi=300
            style=Journal
            notoc;

    title1 "Table &tbl_num: Effect of EITC Exposure on &dep_label";
    %if &inc_control = 1 %then %do;
    title2 "OLS Estimates with Income Control  Dependent Variable: &dep_label";
    %end;
    %else %do;
    title2 "OLS Estimates without Income Control  Dependent Variable: &dep_label";
    %end;

    footnote1 "* p<0.10   ** p<0.05   *** p<0.01";
    footnote2 "Omitted reference groups: Male (sex), White (race), Below HS (parental education), 0 children (family size), born <=1974 (cohort).";
    footnote3 "Fixed effects for birth cohort, state of residence, and family size are included but suppressed above. Joint F-statistics shown separately below.";
    footnote4 "N = &nobs     R-squared = &rsq";

    proc report data=work._pe_display nowd;
        columns VarLabel Estimate StdErr Probt Stars;
        define VarLabel  / display 'Variable'     width=50 left;
        define Estimate  / display 'Estimate'     width=12 format=8.4 right;
        define StdErr    / display 'Std. Error'   width=12 format=8.4 right;
        define Probt     / display 'P-Value'      width=10 format=6.3 right;
        define Stars     / display ''             width=5  left;
    run;

    title1 "Fixed Effects — Joint F-Statistics (Type III)";
    title2;
    footnote;

    proc report data=work._fe_fstats nowd;
        columns FELabel DF FValue ProbF;
        define FELabel / display 'Fixed Effect'   width=25 left;
        define DF      / display 'DF'             width=8  right;
        define FValue  / display 'F-Statistic'    width=14 format=8.2 right;
        define ProbF   / display 'P-Value'        width=10 format=6.3 right;
    run;

    title;
    ods pdf close;



    proc datasets lib=work nolist;
        delete _pe _pe_display _anova _fe_fstats _fit _fit_info _nobs;
    run;
    quit;

%mend reg_table;



%reg_table(
    pdfname     = HS_Completion_Regression,
    outcome     = hs_complete,
    dep_label   = %str(HS Completion),
    inc_control = 0,
    tbl_num     = 1
);

%reg_table(
    pdfname     = Any_College_Regression,
    outcome     = any_college,
    dep_label   = %str(Any College Attendance),
    inc_control = 0,
    tbl_num     = 2
);

%reg_table(
    pdfname     = Bachelors_Regression,
    outcome     = bachelors,
    dep_label   = %str(Bachelors Completion),
    inc_control = 0,
    tbl_num     = 3
);

%reg_table(
    pdfname     = HS_Completion_Income_Regression,
    outcome     = hs_complete,
    dep_label   = %str(HS Completion),
    inc_control = 1,
    tbl_num     = 4
);

%reg_table(
    pdfname     = Any_College_Income_Regression,
    outcome     = any_college,
    dep_label   = %str(Any College Attendance),
    inc_control = 1,
    tbl_num     = 5
);

%reg_table(
    pdfname     = Bachelors_Income_Regression,
    outcome     = bachelors,
    dep_label   = %str(Bachelors Completion),
    inc_control = 1,
    tbl_num     = 6
);


