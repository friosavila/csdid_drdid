# csdid_drdid
Repository for the implementation of csdid and drdid
## Captain's log, date 5/12/2021
Im writting this for fun. Not as part of the official `csdid-drdid` Readme file. Just to keep a record of the process of how we got here.
## Background
This project started with the programming challange send by @causalinf. When he asked someone to program R's DID to Stata. He even offer a Grand Prize!. 

In my fist attempt, I tried implementing Callaway and Sant'Anna (2020), big mistake. While very clear, it was like trying running before learning how to walk. Or in DID terms: Tried to learn how to *DID* before *DRDID*. And of course, with @nickchk implementation (using `rcall`), the first wave of interest on the program dimmed down (and other Projects emerged). 

Suffice to say, we/I didnt win the prize, but, we do this for fun and academia!

## First attempt, and current stage

The second attempt was motivated by @AsjadNaqvi who started working on *DRDID*. A quick exchange with him encouraged me to re-read the first paper Sant'Anna and Zhao (2020), and try to learn how to walk. That is when things clicked, "Started to see the **MATRIX**". 

## Current status

And we are here, about 1 week when I started my serious-series-of-serious ***Mata*** programming time (Who knows the reference?), some advice from Pedro, insights and programming from Asjad, and we have a good Beta for `drdid` Stata Edition. All Panel estimators are programmed, and currently doing so for the repeated Cross-section estimators. 

I have also introduced weights, but need to double check they are being done correctly.

My insight: R is a very powerful software, and its quite quick, if you know what you are doing. Stata is easier to use, even when programming _some_ more complicated methods (In particular things like Maximum Likelihood can be very easy), but if you are into R, you can easily understand Mata (Stata's Matrix programming language).



