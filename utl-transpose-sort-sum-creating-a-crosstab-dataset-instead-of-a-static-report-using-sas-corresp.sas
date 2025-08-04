%let pgm=utl-transpose-sort-sum-creating-a-crosstab-dataset-instead-of-a-static-report-using-sas-corresp;

%stop_submission;

Transpose sort sum creating a crosstab dataset instead of a static report using sas corresp

SOAPBOX ON
 Instead of a staic report each of these solutions produce a crosstab sas datasets.
 Classic two dimensional crosstab?
SOAPBOX OFF

CONTENTS
   1 sas corresp
   2 sas proc report
   3 sas proc sql
   4 r sql (works for most language with a interface to sql)
     (use with sql arrays when machine has less 10,000 levels (array macro supports up to 10,000 levels?)
   5 related repos

github
https://tinyurl.com/5xw66kt5
https://github.com/rogerjdeangelis/utl-transpose-sort-sum-creating-a-crosstab-dataset-instead-of-a-static-report-using-sas-corresp

communities.sas
https://tinyurl.com/2p9v9ahw
https://communities.sas.com/t5/SAS-Programming/Make-new-variables-from-existing-groups/m-p/753988#M237699

/**************************************************************************************************************************/
/* INPUT                       | PROCESS                                | OUTPUT                                          */
/* =====                       | =======                                | ======                                          */
/* SD1,HAVE                    | 1 SAS PROC CORRESP                     | LABEL     RAM01    RAM02    SUM                 */
/* ALARM_                      | ==================                     |                                                 */
/*  NAME     MACHINE    TOT    |                                        | Alarm1     236      198     434                 */
/*                             | ods exclude all;                       | Alarm2      49       47      96                 */
/* Alarm1     RAM01     236    | ods output observed=want_corresp;      | Alarm3       0        9       9                 */
/* Alarm1     RAM02     198    | proc corresp  dimens=1                 | Alarm4       1        0       1                 */
/* Alarm2     RAM01      49    |  data=sd1.have observed;               | Sum        286      254     540                 */
/* Alarm2     RAM02      47    |  tables ALARM_NAME, MACHINE;           |                                                 */
/* Alarm3     RAM02       9    | weight tot;                            |                                                 */
/* Alarm4     RAM01       1    | run;quit;                              |                                                 */
/*                             | ods select all;                        |                                                 */
/* options                     |                                        |                                                 */
/*  validvarname=upcase;       |------------------------------------------------------------------------------------------*/
/* libname sd1 "d:/sd1";       | 2 SAS PROC REPORT                      | ALARM_                                          */
/* data sd1.have;              | =================                      |  NAME     RAM01    RAM02                        */
/*    input ALARM_NAME$        |                                        |                                                 */
/*    MACHINE$ tot;            | proc report data=sd1.have out=         | Alarm1     236      198                         */
/* cards4;                     |  want_report(                          | Alarm2      49       47                         */
/* Alarm1 RAM01 236            |    drop=_break_                        | Alarm3       .        9                         */
/* Alarm1 RAM02 198            |    rename=(                            | Alarm4       1        .                         */
/* Alarm2 RAM01 49             |       _c2_=RAM01                       |                                                 */
/* Alarm2 RAM02 47             |       _c3_=RAM02));                    |                                                 */
/* Alarm3 RAM02 9              |  cols ALARM_NAME MACHINE, tot;         |                                                 */
/* Alarm4 RAM01 1              | define  ALARM_NAME/ group;             |                                                 */
/* ;;;;                        | define  machine/ across ;              |                                                 */
/* run;quit;                   | define tot /analysis sum ' ';          |                                                 */
/*                             | run;quit;                              |                                                 */
/*                             |                                        |                                                 */
/*                             |------------------------------------------------------------------------------------------*/
/*                             | 3 SAS PROC SQL                         | ALARM_                                          */
/*                             | ==============                         |  NAME     RAM01    RAM02                        */
/*                             |                                        |                                                 */
/*                             | proc sql;                              | Alarm1     236      198                         */
/*                             |  create                                | Alarm2      49       47                         */
/*                             |    table want_sql as                   | Alarm3       0        9                         */
/*                             |  select                                | Alarm4       1        0                         */
/*                             |    alarm_name                          |                                                 */
/*                             |   ,max(case                            |                                                 */
/*                             |     when machine="RAM01"               |                                                 */
/*                             |     then tot                           |                                                 */
/*                             |     else . end) as RAM01               |                                                 */
/*                             |   ,max(case                            |                                                 */
/*                             |     when machine="RAM02"               |                                                 */
/*                             |     then tot                           |                                                 */
/*                             |     else . end) as RAM02               |                                                 */
/*                             |  from                                  |                                                 */
/*                             |    (select                             |                                                 */
/*                             |       alarm_name                       |                                                 */
/*                             |      ,machine                          |                                                 */
/*                             |      ,sum(tot) as tot                  |                                                 */
/*                             |    from                                |                                                 */
/*                             |       sd1.have                         |                                                 */
/*                             |    group                               |                                                 */
/*                             |       by alarm_name,machine)           |                                                 */
/*                             |  group                                 |                                                 */
/*                             |     by alarm_name                      |                                                 */
/*                             | ;quit;                                 |                                                 */
/*                             |                                        |                                                 */
/*                             |                                        |                                                 */
/*                             |------------------------------------------------------------------------------------------*/
/*                             | 4 R SQL                                |                                                 */
/*                             | =======                                | ALARM_                                          */
/*                             |                                        |  NAME     RAM01    RAM02                        */
/*                             | proc datasets lib=sd1                  |                                                 */
/*                             |  nolist nodetails;                     | Alarm1     236      198                         */
/*                             |  delete want;                          | Alarm2      49       47                         */
/*                             | run;quit;                              | Alarm3       0        9                         */
/*                             |                                        | Alarm4       1        0                         */
/*                             | %utl_rbeginx;                          |                                                 */
/*                             | parmcards4;                            |                                                 */
/*                             | library(haven)                         |                                                 */
/*                             | library(sqldf)                         |                                                 */
/*                             | source("c:/oto/fn_tosas9x.R")          |                                                 */
/*                             | options(sqldf.dll =                    |                                                 */
/*                             |   "d:/dll/sqlean.dll")                 |                                                 */
/*                             | have<-read_sas(                        |                                                 */
/*                             |   "d:/sd1/have.sas7bdat")              |                                                 */
/*                             | print(have)                            |                                                 */
/*                             | want<-sqldf('                          |                                                 */
/*                             |  select                                |                                                 */
/*                             |    alarm_name                          |                                                 */
/*                             |   ,max(case                            |                                                 */
/*                             |     when machine="RAM01"               |                                                 */
/*                             |     then tot                           |                                                 */
/*                             |     else null end) as RAM01            |                                                 */
/*                             |   ,max(case                            |                                                 */
/*                             |     when machine="RAM02"               |                                                 */
/*                             |     then tot                           |                                                 */
/*                             |     else null end) as RAM02            |                                                 */
/*                             |  from                                  |                                                 */
/*                             |    (select                             |                                                 */
/*                             |       alarm_name                       |                                                 */
/*                             |      ,machine                          |                                                 */
/*                             |      ,sum(tot) as tot                  |                                                 */
/*                             |    from                                |                                                 */
/*                             |       have                             |                                                 */
/*                             |    group                               |                                                 */
/*                             |       by alarm_name,machine)           |                                                 */
/*                             |  group                                 |                                                 */
/*                             |     by alarm_name                      |                                                 */
/*                             | ;quit;                                 |                                                 */
/*                             | ')                                     |                                                 */
/*                             | want                                   |                                                 */
/*                             | fn_tosas9x(                            |                                                 */
/*                             |       inp    = want                    |                                                 */
/*                             |      ,outlib ="d:/sd1/"                |                                                 */
/*                             |      ,outdsn ="want"                   |                                                 */
/*                             |      )                                 |                                                 */
/*                             | ;;;;                                   |                                                 */
/*                             | %utl_rendx;                            |                                                 */
/*                             |                                        |                                                 */
/*                             | proc print data=sd1.want;              |                                                 */
/*                             | run;quit;                              |                                                 */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options
 validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
   input ALARM_NAME$
   MACHINE$ tot;
cards4;
Alarm1 RAM01 236
Alarm1 RAM02 198
Alarm2 RAM01 49
Alarm2 RAM02 47
Alarm3 RAM02 9
Alarm4 RAM01 1
;;;;
run;quit;


/**************************************************************************************************************************/
/*  ALARM_                                                                                                                */
/*  NAME     MACHINE    TOT                                                                                               */
/* Alarm1     RAM01     236                                                                                               */
/* Alarm1     RAM02     198                                                                                               */
/* Alarm2     RAM01      49                                                                                               */
/* Alarm2     RAM02      47                                                                                               */
/* Alarm3     RAM02       9                                                                                               */
/* Alarm4     RAM01       1                                                                                               */
/**************************************************************************************************************************/

/*___
|___ \   ___  __ _ ___    ___ ___  _ __ _ __ ___  ___ _ __
  __) | / __|/ _` / __|  / __/ _ \| `__| `__/ _ \/ __| `_ \
 / __/  \__ \ (_| \__ \ | (_| (_) | |  | | |  __/\__ \ |_) |
|_____| |___/\__,_|___/  \___\___/|_|  |_|  \___||___/ .__/
                                                     |_|
2 SAS PROC REPORT
=================
*/

proc report data=sd1.have out=
 want_report(
   drop=_break_
   rename=(
      _c2_=RAM01
      _c3_=RAM02));
 cols ALARM_NAME MACHINE, tot;
define  ALARM_NAME/ group;
define  machine/ across ;
define tot /analysis sum ' ';
run;quit;

/**************************************************************************************************************************/
/*  ALARM_                                                                                                                */
/*  NAME     RAM01    RAM02                                                                                               */
/* Alarm1     236      198                                                                                                */
/* Alarm2      49       47                                                                                                */
/* Alarm3       0        9                                                                                                */
/* Alarm4       1        0                                                                                                */
/**************************************************************************************************************************/

/*____                                                    _
|___ /   ___  __ _ ___   _ __  _ __ ___   ___   ___  __ _| |
  |_ \  / __|/ _` / __| | `_ \| `__/ _ \ / __| / __|/ _` | |
 ___) | \__ \ (_| \__ \ | |_) | | | (_) | (__  \__ \ (_| | |
|____/  |___/\__,_|___/ | .__/|_|  \___/ \___| |___/\__, |_|
                        |_|                            |_|
3 SAS PROC SQL
==============
*/

proc sql;
 create
   table want_sql as
 select
   alarm_name
  ,max(case
    when machine="RAM01"
    then tot
    else . end) as RAM01
  ,max(case
    when machine="RAM02"
    then tot
    else . end) as RAM02
 from
   (select
      alarm_name
     ,machine
     ,sum(tot) as tot
   from
      sd1.have
   group
      by alarm_name,machine)
 group
    by alarm_name
;quit;

/**************************************************************************************************************************/
/*  ALARM_                                                                                                                */
/*  NAME     RAM01    RAM02                                                                                              */
/* Alarm1     236      198                                                                                               */
/* Alarm2      49       47                                                                                               */
/* Alarm3       0        9                                                                                               */
/* Alarm4       1        0                                                                                               */
/**************************************************************************************************************************/
/*  _                      _
| || |    _ __   ___  __ _| |
| || |_  | `__| / __|/ _` | |
|__   _| | |    \__ \ (_| | |
   |_|   |_|    |___/\__, |_|
                        |_|
*/

proc datasets lib=sd1
 nolist nodetails;
 delete want;
run;quit;

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
options(sqldf.dll =
  "d:/dll/sqlean.dll")
have<-read_sas(
  "d:/sd1/have.sas7bdat")
print(have)
want<-sqldf('
 select
   alarm_name
  ,max(case
    when machine="RAM01"
    then tot
    else null end) as RAM01
  ,max(case
    when machine="RAM02"
    then tot
    else null end) as RAM02
 from
   (select
      alarm_name
     ,machine
     ,sum(tot) as tot
   from
      have
   group
      by alarm_name,machine)
 group
    by alarm_name
;quit;
')
want
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;

/**************************************************************************************************************************/
/*R                         | SAS ALARM_                                                                                  */
/*   alarm_name RAM01 RAM02 |     NAME     RAM01    RAM02                                                                 */
/*                          |                                                                                             */
/* 1     Alarm1   236   198 |    Alarm1     236      198                                                                  */
/* 2     Alarm2    49    47 |    Alarm2      49       47                                                                  */
/* 3     Alarm3    NA     9 |    Alarm3       0        9                                                                  */
/* 4     Alarm4     1    NA |    Alarm4       1        0                                                                  */
/**************************************************************************************************************************/

/*___             _       _           _
| ___|   _ __ ___| | __ _| |_ ___  __| |  _ __ ___ _ __   ___  ___
|___ \  | `__/ _ \ |/ _` | __/ _ \/ _` | | `__/ _ \ `_ \ / _ \/ __|
 ___) | | | |  __/ | (_| | ||  __/ (_| | | | |  __/ |_) | (_) \__ \
|____/  |_|  \___|_|\__,_|\__\___|\__,_| |_|  \___| .__/ \___/|___/
                                                  |_|
*/
CORRESP REPOS
--------------------------------------------------------------------------------------------------------------------------------
https://github.com/rogerjdeangelis/utl-create-a-state-diagram-table-hash-corresp-and-transpose
https://github.com/rogerjdeangelis/utl-creating-big-N-headers-in-your-reports-corresp-clinical-ods
https://github.com/rogerjdeangelis/utl-crosstab-output-tables-from-corresp-report-not-static-tabulate
https://github.com/rogerjdeangelis/utl-proc-corresp-sort-transpose-summary-combined-with-output-table
https://github.com/rogerjdeangelis/utl-three-dimensional-crosstab-proc-freq-tabulate-corresp-and-report
https://github.com/rogerjdeangelis/utl-transposing-sorting-and-summarizing-with-a-single-proc-corresp-freq-tabulate-and-report
https://github.com/rogerjdeangelis/utl-use-freq-and-corresp-table-output-to-avoid-tabulate-static-printouts

TRANSPOSE
----------------------------------------------------------------------------------------------------------------------------------- -
https://github.com/rogerjdeangelis/utl-Changing-variable-labels-formats-and-informats-with-proc-sort-transpose-report-and-mean
https://github.com/rogerjdeangelis/utl-Computing-the-matrix-product-of-a-dataframe-with-its-transpose
https://github.com/rogerjdeangelis/utl-adding-functionality-to-sas-proc-transpose-when-transposing-sets-of-variables
https://github.com/rogerjdeangelis/utl-another-classic-long-to-wide-transpose-using-Arts-untanspose-macro
https://github.com/rogerjdeangelis/utl-classic-pivot-wider-transpose-with-output-compound-column-names-using-sas-r-python-excel
https://github.com/rogerjdeangelis/utl-classic-problem-with-proc-transpose-and-mutiple-variables-seven-solutions
https://github.com/rogerjdeangelis/utl-classic-transpose-by-index-variableid-and-value-in-sas-r-and-python
https://github.com/rogerjdeangelis/utl-classic-untranspose-problem-posted-in-stackoverflow-r
https://github.com/rogerjdeangelis/utl-controlling-the-order-of-transposed-variables-using-interleave-set
https://github.com/rogerjdeangelis/utl-create-a-sorted-summarized-and-transposed-crosstab-dataset-using-a-single-proc
https://github.com/rogerjdeangelis/utl-create-a-state-diagram-table-hash-corresp-and-transpose
https://github.com/rogerjdeangelis/utl-create-a-stored-datastep-program-with-sql-code-that-creates-a-dynamic-array-transpose
https://github.com/rogerjdeangelis/utl-dedup-transpose-pivot-based-on-unique-values-in-three-columns
https://github.com/rogerjdeangelis/utl-fast-normalization-and-join-using-vvaluex-arrays-sql-hash-untranspose-macro
https://github.com/rogerjdeangelis/utl-formatting-transposed-variable-names
https://github.com/rogerjdeangelis/utl-improved-transpose-and-string-parser
https://github.com/rogerjdeangelis/utl-loop-through-one-table-and-find-data-in-next-table--hash-dosubl-arts-transpose
https://github.com/rogerjdeangelis/utl-minimize-the-space-used-by-a-transposed-table-macro-utl-optlen
https://github.com/rogerjdeangelis/utl-minimmum-code-to-transpose-and-summarize-a-skinny-to-fat-with-sas-wps-r-and-python
https://github.com/rogerjdeangelis/utl-normalize-a-table-with-many-columns-flexible-transpose
https://github.com/rogerjdeangelis/utl-normalizing-multiple-horizontal-arrays-of-variables-using-macro-untranspose
https://github.com/rogerjdeangelis/utl-pivot-long-pivot-wide-transpose-partitioning-sql-arrays-wps-r-python
https://github.com/rogerjdeangelis/utl-pivot-long-transpose-three-arrays-of-size-three-sas-r-python-sql
https://github.com/rogerjdeangelis/utl-pivot-longer-when-transpose-does-not-work-sas-gather-macro-key-value-pairs
https://github.com/rogerjdeangelis/utl-pivot-multiple-columns-to-long-format-untranspose
https://github.com/rogerjdeangelis/utl-pivot-transpose-all-variables-including-the-by-variable-tagging-with-numeric-suffix
https://github.com/rogerjdeangelis/utl-pivot-transpose-an-excel-sheet-with-columns-that-are-excel-dates
https://github.com/rogerjdeangelis/utl-pivot-transpose-by-id-using-wps-r-python-sql-using-partitioning
https://github.com/rogerjdeangelis/utl-pivot-transpose-long-and-summarize-in-sql-query-amd-generate-code-using-sas-and-vectorized-r
https://github.com/rogerjdeangelis/utl-pivot-transpose-longer-using-six-methods-sas-r-python-case-and-sql
https://github.com/rogerjdeangelis/utl-proc-corresp-sort-transpose-summary-combined-with-output-table
https://github.com/rogerjdeangelis/utl-proc-transpose-fat-to-fat
https://github.com/rogerjdeangelis/utl-reshaping-data-from-long-to-wide-using-transpose-macro
https://github.com/rogerjdeangelis/utl-sas-normalize-transpose-pivot-long-remove-missing-values-columns-and-missing-rows
https://github.com/rogerjdeangelis/utl-sas-proc-transpose-in-sas-r-wps-python-native-and-sql-code
https://github.com/rogerjdeangelis/utl-sas-proc-transpose-supports-notsorted-option
https://github.com/rogerjdeangelis/utl-sas-proc-transpose-wide-to-long-in-sas-wps-r-python-native-and-sql
https://github.com/rogerjdeangelis/utl-simple-classic-transpose-pivot-wider-in-native-and-sql-wps-r-python
https://github.com/rogerjdeangelis/utl-simple-pivot-or-transpose-of-id-and-value-pairs-in-R-and-SAS
https://github.com/rogerjdeangelis/utl-simple-transpose-in-R-and-SAS-you-be-the-judge
https://github.com/rogerjdeangelis/utl-simple-transpose-of-two-variables-using-normalization-gather-and-untranspose
https://github.com/rogerjdeangelis/utl-sort-summarize-transpose-with-minimal-code-in-one-proc
https://github.com/rogerjdeangelis/utl-sort-transpose-and-merge-two-tables-packaged-in-a-single-datastep
https://github.com/rogerjdeangelis/utl-sort-transpose-and-summarize-with-output-dataset-using-just-one-proc
https://github.com/rogerjdeangelis/utl-the-all-powerfull-proc-report-to-create-transposed-sorted-and-summarized-output-datasets
https://github.com/rogerjdeangelis/utl-three-algorithms-to-transpose-sets-of-variables
https://github.com/rogerjdeangelis/utl-transpose-and-apply-several-different-formats-to-the-same-column
https://github.com/rogerjdeangelis/utl-transpose-and-create-a-state-matrix
https://github.com/rogerjdeangelis/utl-transpose-and-rename-variables-using-variable-labels-and-class-variables
https://github.com/rogerjdeangelis/utl-transpose-and-set-all-generated-missing-values-to-zero-five-solutions
https://github.com/rogerjdeangelis/utl-transpose-fat-to-skinny-pivot-longer-in-sas-wps-r-pythonv
https://github.com/rogerjdeangelis/utl-transpose-long-to-wide-with-a-twist-add-a-grouping-varible-to-the-input
https://github.com/rogerjdeangelis/utl-transpose-macro-eliminates-five-steps-transpose-sort-transpose-sort-merge
https://github.com/rogerjdeangelis/utl-transpose-macro-rather-than-proc-print-report-or-tabulate
https://github.com/rogerjdeangelis/utl-transpose-matrices-with-base-sas
https://github.com/rogerjdeangelis/utl-transpose-more-than-one-variable
https://github.com/rogerjdeangelis/utl-transpose-multiple-rows-into-one-row-do_over-dosubl-and-varlist-macros
https://github.com/rogerjdeangelis/utl-transpose-mutiple-sets-of-variable-fast-macro-transpose
https://github.com/rogerjdeangelis/utl-transpose-mutiple-variables-with-complete-missing-levels-and-missing-values
https://github.com/rogerjdeangelis/utl-transpose-pairs-of-dates-by-groups-or-transposing-mutiple-variables
https://github.com/rogerjdeangelis/utl-transpose-pivot-skinny-to-fat-multiple-sets-of-variables-in-wps-and-sas
https://github.com/rogerjdeangelis/utl-transpose-pivot-summmarize-in-sql-select-using-r-tidyverse-language-and-sql-sas-r-and-python
https://github.com/rogerjdeangelis/utl-transpose-pivot-wide-to-long-using-sql-arrays-in-sas-r-and-python
https://github.com/rogerjdeangelis/utl-transpose-pivot-wide-using-sql-partitioning-in-wps-r-python
https://github.com/rogerjdeangelis/utl-transpose-sets-of-variables-using-Art-Tabachneck-et-all-very-fast-macro
https://github.com/rogerjdeangelis/utl-transpose-sets-of-variables-with-a-compound-identification-Arts-macro
https://github.com/rogerjdeangelis/utl-transpose-successive-sets-of-four-records-in-a-single-column-of-random-numbers-sas-r-sql
https://github.com/rogerjdeangelis/utl-transpose-table-creating-column-names-from-input-table-rownames-sas-sql-r-pyhon-multi-language
https://github.com/rogerjdeangelis/utl-transpose-table-with-duplicate-values
https://github.com/rogerjdeangelis/utl-transposing-a-complex-data-set-in-sas-arts-transpose-macro
https://github.com/rogerjdeangelis/utl-transposing-multiple-variables-using-transpose-macro-sql-arrays-proc-report
https://github.com/rogerjdeangelis/utl-transposing-normalizing-a-table-using-four-techniques-arrays-untranspose-transpose-and-gather
https://github.com/rogerjdeangelis/utl-transposing-two-variable-to-columns-using-transpose-macro
https://github.com/rogerjdeangelis/utl-untranspose-mutiple-arrays-fat-to-skinny-or-normalize
https://github.com/rogerjdeangelis/utl-using-arts-transpose-macro-with-two-unsorted-tables
https://github.com/rogerjdeangelis/utl-using-r-to-generate-sql-code-to-pivot-transpose-long-like-sas-array-and-do_over-macros
https://github.com/rogerjdeangelis/utl-using-sas-gather-macro-to-untranspose-a-fat-dataset-into-one-obsevation
https://github.com/rogerjdeangelis/utl-very-complex-transpose-with-character-numeric-variables-and-counts-percents
https://github.com/rogerjdeangelis/utl_an_unsusual_transpose_based_on__groups_of_variable_names
https://github.com/rogerjdeangelis/utl_classic_transpose_in_r_and_sas
https://github.com/rogerjdeangelis/utl_diagonal_transpose_while_keeping_all_original_rows
https://github.com/rogerjdeangelis/utl_excel_Import_and_transpose_range_A9-Y97_using_only_one_procedure
https://github.com/rogerjdeangelis/utl_flexible_complex_multi-dimensional_transpose_using_one_proc_report
https://github.com/rogerjdeangelis/utl_simple_three_dimensional_transpose_in_r_and_sas
https://github.com/rogerjdeangelis/utl_sophisticated_transpose_with_proc_summary_idgroup
https://github.com/rogerjdeangelis/utl_sort_summarize_and_transpose_multiple_variable_and_create_output_dataset
https://github.com/rogerjdeangelis/utl_sort_summarize_transpose_and_format_in_1_datastep
https://github.com/rogerjdeangelis/utl_sort_transpose_and_summarize_a_dataset_using_just_one_proc_report
https://github.com/rogerjdeangelis/utl_sort_transpose_and_summarize_in_one_proc_v2
https://github.com/rogerjdeangelis/utl_sort_transpose_summarize
https://github.com/rogerjdeangelis/utl_sql_version_of_proc_transpose_with_major_advantage_of_summarization
https://github.com/rogerjdeangelis/utl_techniques_to_transpose_and_stack_multiple_variables
https://github.com/rogerjdeangelis/utl_transpose_and_concatenate_observations_by_id_in_one_datastep
https://github.com/rogerjdeangelis/utl_transpose_long_to_wide_with_sequential_matching_pairs
https://github.com/rogerjdeangelis/utl_transpose_multiple_variables_and_split_variables_into_multiple_variables
https://github.com/rogerjdeangelis/utl_transpose_rows_to_column_identifying_type_of_data
https://github.com/rogerjdeangelis/utl_transpose_table_by_two_variables_not_supported_by_proc_transpose
https://github.com/rogerjdeangelis/utl_transpose_with_multiple_id_values_per_group
https://github.com/rogerjdeangelis/utl_transpose_with_proc_report
https://github.com/rogerjdeangelis/utl_transpose_with_proc_sql
https://github.com/rogerjdeangelis/utl_transposing_multiple_variables_with_different_ids_a_single_transpose_cannot_do_this
https://github.com/rogerjdeangelis/utl_two_families_itinerary_through_italy_transpose
https://github.com/rogerjdeangelis/utl_using_a_hash_to_transpose_and_reorder_a_table
https://github.com/rogerjdeangelis/wps-pivot-longer-transpose--using-r-and-wps-loops
https://github.com/rogerjdeangelis/utl-create-primary-key-for-duplicated-records-using-sql-partitionaling-and-pivot-wide-sas-python-r
https://github.com/rogerjdeangelis/utl-pivot-excel-columns-and-output-a-database-table
https://github.com/rogerjdeangelis/utl-pivot-long--excel-sheet-and-run-a-regression-in-r-and-python
https://github.com/rogerjdeangelis/utl-pivot-wide-when-variable-names-contain-values-sql-and-base-r-sas-oython-excel-postgreSQL
https://github.com/rogerjdeangelis/utl-pivoting-transposing-wide-using-sas-r-python-sql-macro-language


/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/










































































































































































































































INPUT                        PROCESS                                 OUTPUT
=====                        =======                                 ======
SD1,HAVE                     1 SAS PROC CORRESP                      LABEL     RAM01    RAM02    SUM
ALARM_                       ==================
 NAME     MACHINE    TOT                                             Alarm1     236      198     434
                             ods exclude all;                        Alarm2      49       47      96
Alarm1     RAM01     236     ods output observed=want_corresp;       Alarm3       0        9       9
Alarm1     RAM02     198     proc corresp  dimens=1                  Alarm4       1        0       1
Alarm2     RAM01      49      data=sd1.have observed;                Sum        286      254     540
Alarm2     RAM02      47      tables ALARM_NAME, MACHINE;
Alarm3     RAM02       9     weight tot;
Alarm4     RAM01       1     run;quit;
                             ods select all;
options
 validvarname=upcase;
libname sd1 "d:/sd1";        2 SAS PROC REPORT                       ALARM_
data sd1.have;               =================                        NAME     RAM01    RAM02
   input ALARM_NAME$
   MACHINE$ tot;             proc report data=sd1.have out=          Alarm1     236      198
cards4;                       want_report(                           Alarm2      49       47
Alarm1 RAM01 236                drop=_break_                         Alarm3       .        9
Alarm1 RAM02 198                rename=(                             Alarm4       1        .
Alarm2 RAM01 49                    _c2_=RAM01
Alarm2 RAM02 47                    _c3_=RAM02));
Alarm3 RAM02 9                cols ALARM_NAME MACHINE, tot;
Alarm4 RAM01 1               define  ALARM_NAME/ group;
;;;;                         define  machine/ across ;
run;quit;                    define tot /analysis sum ' ';
                             run;quit;


                             3 SAS PROC SQL                          ALARM_
                             ==============                           NAME     RAM01    RAM02

                             proc sql;                               Alarm1     236      198
                              create                                 Alarm2      49       47
                                table want_sql as                    Alarm3       0        9
                              select                                 Alarm4       1        0
                                alarm_name
                               ,max(case
                                 when machine="RAM01"
                                 then tot
                                 else . end) as RAM01
                               ,max(case
                                 when machine="RAM02"
                                 then tot
                                 else . end) as RAM02
                              from
                                (select
                                   alarm_name
                                  ,machine
                                  ,sum(tot) as tot
                                from
                                   sd1.have
                                group
                                   by alarm_name,machine)
                              group
                                 by alarm_name
                             ;quit;



                             4 R SQL
                             =======                                 ALARM_
                                                                      NAME     RAM01    RAM02
                             proc datasets lib=sd1
                              nolist nodetails;                      Alarm1     236      198
                              delete want;                           Alarm2      49       47
                             run;quit;                               Alarm3       0        9
                                                                     Alarm4       1        0
                             %utl_rbeginx;
                             parmcards4;
                             library(haven)
                             library(sqldf)
                             source("c:/oto/fn_tosas9x.R")
                             options(sqldf.dll =
                               "d:/dll/sqlean.dll")
                             have<-read_sas(
                               "d:/sd1/have.sas7bdat")
                             print(have)
                             want<-sqldf('
                              select
                                alarm_name
                               ,max(case
                                 when machine="RAM01"
                                 then tot
                                 else null end) as RAM01
                               ,max(case
                                 when machine="RAM02"
                                 then tot
                                 else null end) as RAM02
                              from
                                (select
                                   alarm_name
                                  ,machine
                                  ,sum(tot) as tot
                                from
                                   have
                                group
                                   by alarm_name,machine)
                              group
                                 by alarm_name
                             ;quit;
                             ')
                             want
                             fn_tosas9x(
                                   inp    = want
                                  ,outlib ="d:/sd1/"
                                  ,outdsn ="want"
                                  )
                             ;;;;
                             %utl_rendx;

                             proc print data=sd1.want;
                             run;quit;





CORRESP REPOS
--------------------------------------------------------------------------------------------------------------------------------
https://github.com/rogerjdeangelis/utl-create-a-state-diagram-table-hash-corresp-and-transpose
https://github.com/rogerjdeangelis/utl-creating-big-N-headers-in-your-reports-corresp-clinical-ods
https://github.com/rogerjdeangelis/utl-crosstab-output-tables-from-corresp-report-not-static-tabulate
https://github.com/rogerjdeangelis/utl-proc-corresp-sort-transpose-summary-combined-with-output-table
https://github.com/rogerjdeangelis/utl-three-dimensional-crosstab-proc-freq-tabulate-corresp-and-report
https://github.com/rogerjdeangelis/utl-transposing-sorting-and-summarizing-with-a-single-proc-corresp-freq-tabulate-and-report
https://github.com/rogerjdeangelis/utl-use-freq-and-corresp-table-output-to-avoid-tabulate-static-printouts

































ALARM_TEXT   RAM01_SUM  RAM02_SUM
Alarm1      236      198
Alarm2      49      47
Alarm3      .      9
Alarm4      1
.

ods exclude all;
ods output observed=want_corresp;
proc corresp  dimens=1
 data=have observed;
 tables ALARM_NAME, MACHINE;
weight tot;
run;quit;
ods select all;


 LABEL     RAM01    RAM02    SUM

 Alarm1     236      198     434
 Alarm2      49       47      96
 Alarm3       0        9       9
 Alarm4       1        0       1
 Sum        286      254     540


proc report data=have out=
 want_report(
   drop=_break_
   rename=(
      _c2_=RAM01
      _c3_=RAM02));
 cols ALARM_NAME MACHINE, tot;
define  ALARM_NAME/ group;
define  machine/ across ;
define tot /analysis sum ' ';
run;quit;

ALARM_
 NAME     RAM01    RAM02

Alarm1     236      198
Alarm2      49       47
Alarm3       .        9
Alarm4       1        .


proc sql;
  create view prewant as
  select
      a.ALARM_NAME,
      b.MACHINE,
      coalesce(c.TOT, 0) as TOT
  from
      (select distinct ALARM_NAME from have) a
      cross join (select distinct MACHINE from have) b
      left join have c
          on a.alarm_NAME = c.alarm_NAME and b.MACHINE = c.MACHINE
  order by alarm_NAME, MACHINE;
quit;



proc sql;
 select
   alarm_name
  ,max(case
    when machine="RAM01"
    then tot
    else . end) as RAM01
  ,max(case
    when machine="RAM02"
    then tot
    else . end) as RAM02
 from
   (select
      alarm_name
     ,machine
     ,sum(tot) as tot
   from
      have
   group
      by alarm_name,machine)
 group
    by alarm_name
;quit;



ods html close;
ods listing
  file="d:/txt/tab.txt";

options
   missing=0
   formchar=","
   ls=255;

proc tabulate data=have;
  class ALARM_NAME MACHINE;
  var tot;
  table ALARM_NAME=' ', MACHINE=' '*(tot=' '*sum=' ')/rts=10 box='Alarm_name';
run;

/*---- create sas dataset ----*/

ods listing;

proc import
 datafile=
  "d:/txt/tab.txt"
 dbms=csv
 out=prewant
 replace;
 getnames=YES;
 datarow=4;
run;quit;

/*---- minor cleanup ----*/

data want;
 set prewant;
  if left(var2) ne "";
  keep var2-var4;
run;quit;



options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;

proc datasets lib=sd1 nolist nodetails;
 delete want;
run;quit;

%utl_rbeginx;
parmcards4;
library(haven)
library(sqldf)
source("c:/oto/fn_tosas9x.R")
options(sqldf.dll = "d:/dll/sqlean.dll")
have<-read_sas("d:/sd1/have.sas7bdat")
print(have)
want<-sqldf('
')
fn_tosas9x(
      inp    = want
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

proc print data=sd1.want;
run;quit;























data want;
 length header $12;
 set prewant;
  if left(var2) ne "";
  if left(val)=:"@" then do;
      header=substr(val,2);
      val="";
  end;
  drop zz:;
run;quit;




How do i suppress the column heading Sum in the sas proc tabulate below

proc tabulate data=have;
  class ALARM_NAME MACHINE;
  var tot;
  table ALARM_NAME=' ', MACHINE=' '*(tot=' '*sum=' ')/box='Alarm_name';
run;


-------------------------------------
|Alarm    |   RAM01    |   RAM02    |
|         |------------+------------|
|         |    Sum     |    Sum     |
|---------+------------+------------|
|Alarm1   |      236.00|      198.00|
|---------+------------+------------|
|Alarm2   |       49.00|       47.00|
|---------+------------+------------|
|Alarm3   |           .|        9.00|
|---------+------------+------------|
|Alarm4   |        1.00|           .|
-------------------------------------







Given this data

 ALARM_
  NAME     MACHINE    TOT

 Alarm1     RAM01     236
 Alarm1     RAM02     198
 Alarm2     RAM01      49
 Alarm2     RAM02      47
 Alarm3     RAM02       9
 Alarm4     RAM01       1

how can i use sas proc report to crate this report and the acroos option

Alarm_name  _col2_  _col3_

 Alarm1     236      198
 Alarm2      49       47
 Alarm3       0        9
 Alarm4       1        0



proc report data=have nowd;
  column name machine, tot;
  define name / group 'Alarm_name';
  define machine / across sum '_col';
  define tot / ' ' ;
run;








roc sql;
  create table complete_data as
  select
      a.NAME,
      b.MACHINE,
      coalesce(c.TOT, 0) as TOT
  from
      (select distinct NAME from alarms) a
      cross join (select distinct MACHINE from alarms) b
      left join alarms c
          on a.NAME = c.NAME and b.MACHINE = c.MACHINE
  order by NAME, MACHINE;
quit;


CORRESP REPOS
--------------------------------------------------------------------------------------------------------------------------------
https://github.com/rogerjdeangelis/utl-create-a-state-diagram-table-hash-corresp-and-transpose
https://github.com/rogerjdeangelis/utl-creating-big-N-headers-in-your-reports-corresp-clinical-ods
https://github.com/rogerjdeangelis/utl-crosstab-output-tables-from-corresp-report-not-static-tabulate
https://github.com/rogerjdeangelis/utl-proc-corresp-sort-transpose-summary-combined-with-output-table
https://github.com/rogerjdeangelis/utl-three-dimensional-crosstab-proc-freq-tabulate-corresp-and-report
https://github.com/rogerjdeangelis/utl-transposing-sorting-and-summarizing-with-a-single-proc-corresp-freq-tabulate-and-report
https://github.com/rogerjdeangelis/utl-use-freq-and-corresp-table-output-to-avoid-tabulate-static-printouts






















REPO
-------------------------------------------------------------------------------------------------------------------------------------------------
https://github.com/rogerjdeangelis/utl-create-a-state-diagram-table-hash-corresp-and-transpose
https://github.com/rogerjdeangelis/utl-create-new-variable-by-multiplying-corresponding-variables-and-summing-sas-r-python-excel
https://github.com/rogerjdeangelis/utl-creating-big-N-headers-in-your-reports-corresp-clinical-ods
https://github.com/rogerjdeangelis/utl-crosstab-output-tables-from-corresp-report-not-static-tabulate
https://github.com/rogerjdeangelis/utl-extract-row-corresponding-to-minimum-value-of-a-variable-by-group
https://github.com/rogerjdeangelis/utl-highlight-existing-cells-in-excel-sheet2-that-correspond-to-cells-in-sheet1-with-specified-value
https://github.com/rogerjdeangelis/utl-minimum-code-for-a-crosstab-output_dataset-with-sums-using-proc-corresp
https://github.com/rogerjdeangelis/utl-proc-corresp-sort-transpose-summary-combined-with-output-table
https://github.com/rogerjdeangelis/utl-three-dimensional-crosstab-proc-freq-tabulate-corresp-and-report
https://github.com/rogerjdeangelis/utl-time-series-change-in-university-enrollment-by-year-and-by-year-department-proc-corresp
https://github.com/rogerjdeangelis/utl-transposing-sorting-and-summarizing-with-a-single-proc-corresp-freq-tabulate-and-report
https://github.com/rogerjdeangelis/utl-use-freq-and-corresp-table-output-to-avoid-tabulate-static-printouts
https://github.com/rogerjdeangelis/utl_appending_two_tables_with_different_corresponding_names_without_renaming
https://github.com/rogerjdeangelis/utl_compare_corresp_vs_report_output_datasets
https://github.com/rogerjdeangelis/utl_how_to_stack_a_table_and_corresponding_bar_graph
https://github.com/rogerjdeangelis/utl_proc_corresp_crosstab
