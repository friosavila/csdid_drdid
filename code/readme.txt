TITLE
      'CSDID': Module for the estimation of Difference-in-Difference models with Multiple time periods.

DESCRIPTION/AUTHOR(S)
      
    'CSDID' is a command that implements Callaway and Sant'Anna (2021) estimator for DID models with multiple time periods.
    The main idea of CSDID is that consistent estimations for ATT's can be obtained by ignoring 2x2 DID design that compare late treated units with earlier treated units. In the presence of heterogeneous and dynamic effects, this type of comparison can severely bias the estimation of Treatment effects.
    CSDID at its core uses DRDID for the estimation of all 2x2 DID designs to estimate all relevant ATTGT's (Average treatment effects of the treated for group G at time T). Post estimation commands can be used to obtain important aggregations.
    CSDID can be used with panel data and repeated cross-section. 
	      
      KW: Differences in Differences
      KW: DID
      KW: Event Studies
      KW: csdid
      KW: drdid
      
      Requires: Stata version 14, drdid
      
      Author:  Fernando Rios-Avila, Levy Economics Institute of Bard College
      Support: email  friosavi@levy.org
      
      Author:  Pedro H.C. Sant'Anna, Vanderbilt University and Microsoft

      Author:  Brantly Callaway, University of Georgia


Files:
csdid.ado; csdid_estat.ado; csdid_plot.ado; 
_gcsgvar.ado; tsvmat.ado;
csdid_stats.ado; csdid_table.ado; csdid.sthlp;
csdid_postestimation.sthlp