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

## Captain's log, data 5/22/2021

And its Alive!! The first version of *CSDID* is now up and working. A lot thanks to Pedro and Brant, who were kind of enough to talk on details of code and logic behind their programs. 

In fact yesterday (5/21/2021) I had a long chat with Brant on how to estimate IF's (Influence functions) for proportions! And Voala, `csdid` is done.

I have to say It was a fun task. I started from CS(2021) and failed. They have lots of material there, which compounds when you think interms of multiple periods. But once Asjad started working on `drdid`, which encorage my own coding, I realized it was gonna be far easier to start with SZ(2020). It was, after all, the building block (Lego!) required by `CSDID`. 

I should say, I probably would have had a harder time understanding this, if not for an even earlier work on **Unconditional Quantile Regressions** (Firpo, Fortin and Lemieux 2009) who introduced me to understanding what **RIF's** and **IF's** are. And of course, that led me to the generalization with **RIF regressions** (`ssc install rif`). 

Now, I think I'm done with the development part, since I ll be taking a short vacation next week. And I need to get back to other projects (DID with macro data; Structural Labor Supply and taxes; imputation and interval reported income in Grenada; semi-mixture beta regressions with tax and survey data; and last but not least, going back to my QREGRESSION explanation blog!.I also have the generalization of Quantile regression via Method of moments and FE! ).

And of course, work work (Povery and time use in Africa, Levy!)

So I may step aside with this project for a bit, or come back any now and then to add safe guards.

Alright, if you are reading this. thank you!





