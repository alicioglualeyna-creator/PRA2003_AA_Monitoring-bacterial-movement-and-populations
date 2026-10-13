# PRA2003_Monitoring Bacterial Movement and Populations

**Author**: Aleyna Alicioglu(i6381736)

**Course**: Programming (PRA2003)

**Presentation Group**: R1

**University**: Maastricht University 

## Project Background:
The 10 data files are from a bacterial tracking experiment. For every bacterial strain there is a wild type (WT, positive ID) and a mutant (negative ID).

## Biology Themed Research Questions:
Answer the following questions with the given dataset:
1. What are the average counts of each bacterial stain and their statistical uncertainties?
2. Is there any asymmetry between the normal and the mutant strain? 
3. Is there any asymmetry as a function of their momentum?

## Dataset Description
* There are 10 data files in total, each containing 500,000 events
      * These 10 files were treated as subsamples
* All of the files are named output-Set#.txt
* Each file contains data on 12 bacterial strains, identified by a bacterial ID
    * The mutant strain for each bacteria is labelled with a negative ID number
* Each event starts with a header line
    * First value represents the experiment number
    * Second value is the number of bacteria in that experiment
    * px, py, pz, ID 
* Some events consisted of 0 bacteria and where excluded from the calculations



| Bacterial ID | Bacterial strain |
|--------------|------------------|
| 211          | *E. coli* WT (wild type) |
| -211         | *E. coli* mutant |
| 321          | *Bacillus subtilis* WT |
| -321         | *Bacillus subtilis* mutant |
| 2212         | *Pseudomonas aeruginosa* WT |
| -2212        | *Pseudomonas aeruginosa* antibiotic-resistant |
| 3122         | *Streptococcus pneumoniae* |
| -3122        | Capsule-deficient *Streptococcus pneumoniae* |
| 3312         | *Mycobacterium tuberculosis* |
| -3312        | Drug-resistant *Mycobacterium tuberculosis* |
| 3334         | *Salmonella enterica* |
| -3334        | *Salmonella* mutant |


## Week 3: Code Installation
This code will read one file with 500K events and will select the bacterial strains of interest based on its code and give the average bacteria per event together with its statistical uncertainty. 

### Getting Started
**Dependences**
* The file is very large, make sure that there is enough disk space available.
* To run the code, the user should have the file downloaded in the same folder as the script.

**Data Handling**
* Events with 0 particles (e.g. "19 0") are the failed experiments and are not counted as events.
    * They will not be counted towards the total average.

## Week 4: Data Analysis
The main results come from the analysis of the entire sample of 5M events. 

**Description**
To calculate the results of the entire sample of 5M events, the same code from week 3 was reused. Each dataset was analysed separately as an individual sub-sample, meaning that there would be 10 sub-samples in total.

### Method
1. The week 4 slides from the course specify sub-sampling:
    1. Split the sample into sub-samples (one per data file)
    2. Calculate the result for each sub-sample
    3. Use the spread of the results to determine the statistical uncertainty
2. Average number per event is calculated for every bacterial ID in each sub-sample.
3. The final value is the mean over the 10 sub-samples, and its uncertainty follows from their spread.
4. WT and mutant strains are compared using the difference of their means and a z-score.


### Formulas
Average number per event in one sub-sample ($n$ = bacteria counted, $E$ = valid events):

$$x = \frac{n}{E}$$

Standard deviation of the 10 sub-samples:

$$\sigma = \sqrt{\frac{\sum (x_i - \bar{x})^2}{N-1}}, \qquad N = 10$$

Asymmetry (positive means more WT, negative means more mutant, 0 means equal):

$$A = \frac{N_{WT} - N_{mut}}{N_{WT} + N_{mut}}$$

Significance (how many standard deviations the asymmetry is away from 0):

$$z = \frac{A}{\sigma_A}$$

I call it an asymmetry if $|z| \geq 3$.



### Results

**Table 1: Average count per event for each strain**

| ID    | Strain                                        | Mean per event | Stat. uncertainty | Uncertainty on mean (std / √N) | Total count (all sets) | N sub-samples |
|-------|-----------------------------------------------|----------------|-------------------|--------------------------------|------------------------|---------------|
| 211   | *E. coli* WT                                  | 19.94951       | 3.27E-02          | 1.04E-02                       | 92,126,688             | 10            |
| -211  | *E. coli* mutant                              | 19.91722       | 3.19E-02          | 1.01E-02                       | 91,977,542             | 10            |
| 321   | *Bacillus subtilis* WT                        | 2.50915        | 4.77E-03          | 1.51E-03                       | 11,587,227             | 10            |
| -321  | *Bacillus subtilis* mutant                    | 2.50346        | 5.50E-03          | 1.74E-03                       | 11,560,946             | 10            |
| 2212  | *Pseudomonas aeruginosa* WT                   | 1.20803        | 1.90E-03          | 5.99E-04                       | 5,578,693              | 10            |
| -2212 | *Pseudomonas aeruginosa* antibiotic-resistant | 1.18416        | 2.41E-03          | 7.62E-04                       | 5,468,447              | 10            |
| 3122  | *Streptococcus pneumoniae*                    | 0.2766         | 1.07E-03          | 3.39E-04                       | 1,277,330              | 10            |
| -3122 | Capsule-deficient *S. pneumoniae*             | 0.2717         | 9.85E-04          | 3.11E-04                       | 1,254,690              | 10            |
| 3312  | *Mycobacterium tuberculosis*                  | 0.03944        | 2.83E-04          | 8.93E-05                       | 182,139                | 10            |
| -3312 | Drug-resistant *M. tuberculosis*              | 0.039          | 4.03E-04          | 1.27E-04                       | 180,104                | 10            |
| 3334  | *Salmonella enterica*                         | 0.00119        | 4.16E-05          | 1.31E-05                       | 5,482                  | 10            |
| -3334 | *Salmonella* mutant                           | 0.00115        | 5.18E-05          | 1.64E-05                       | 5,318                  | 10            |

**Table 2: Asymmetry between WT and mutant strains**

| ID pair       | Pair                                                  | Difference (WT − mutant) | z-score (uncorrelated) | Asymmetry (abs(z) ≥ 3) |
|---------------|-------------------------------------------------------|--------------------------|------------------------|------------------------|
| 211 vs -211   | *E. coli* (WT vs mutant)                              | 0.0323                   | 0.71                   | no                     |
| 321 vs -321   | *Bacillus subtilis* (WT vs mutant)                    | 0.00569                  | 0.78                   | no                     |
| 2212 vs -2212 | *Pseudomonas aeruginosa* (WT vs antibiotic-resistant) | 0.02387                  | 7.78                   | yes                    |
| 3122 vs -3122 | *S. pneumoniae* (WT vs capsule-deficient)             | 0.0049                   | 3.37                   | yes                    |
| 3312 vs -3312 | *M. tuberculosis* (WT vs drug-resistant)              | 0.00044                  | 0.90                   | no                     |
| 3334 vs -3334 | *Salmonella enterica* (WT vs mutant)                  | 0.00004                  | 0.54                   | no                     |


### Correction of the z-score (feedback)

> *Feedback:* "Why do you propagate the uncertainties on your z-score as if the two measurements are fully uncorrelated?"

In my first version I compared WT and mutant like this:

$$z = \frac{\bar{x}_{WT} - \bar{x}_{mut}}{\sqrt{\sigma_{WT}^2 + \sigma_{mut}^2}}$$

This formula assumes WT and mutant are **independent**. They are not: they are counted in the **same events**. If one data file has more bacteria overall, it has more WT *and* more mutants. So the WT and mutant numbers go up and down together.

When you take the difference, that shared up-and-down cancels out, so the real uncertainty on the difference is **smaller** than my old formula said. The full formula has an extra covariance term:

$$\sigma_{\Delta}^2 = \sigma_{WT}^2 + \sigma_{mut}^2 - 2\,\text{cov}(WT, mut)$$

**What I changed:** instead of calculating the WT and mutant uncertainty separately and adding them, I now calculate the difference and the asymmetry **inside each sub-sample first**, and then take the standard deviation of those 10 values. That way the correlation is automatically included.



## Week 6: Asymmetry as a Function of Momentum

### Code
| Step | File | Language | What it does |
|------|------|----------|--------------|
| 1 | `1_Deliverable6momentum.r` | R | Reads all 10 `output-Set#.txt` files in chunks of 2 million lines, keeps the bacteria with the IDs of interest, calculates $P = \sqrt{p_x^2 + p_y^2 + p_z^2}$ and writes one `momenta-Set#.csv` per sub-sample (columns `ID`, `p`). |
| 2 | `2_Deliverable6finalmomentum.py` | Python | Python was used for data visualization. For one ID pair (`pid1` at the top of the file): bins the momenta, computes the asymmetry and $dN/dP$ per bin per sub-sample, averages over the 10 sub-samples, saves `asymmetry-<ID>.csv`, `asymmetry-<ID>.png` and `spectrum-<ID>.png`. |

**Step 1 – momentum.** For every bacterium:

$$P = \sqrt{p_x^2 + p_y^2 + p_z^2} \qquad \text{(unit: } 10^{-20}\text{ kg m/s)}$$

**Step 2 – bins.** I split the momentum into ranges (bins). Where there are lots of bacteria (low momentum) the bins are narrow, and where there are few (high momentum) they are wider, so every bin has enough bacteria. The first bin starts at 0 so nobody is left out, and everything above the last edge goes into one extra bin (the grey area in the plots). I used the same bins for all 10 sub-samples.

| Pair | Bin edges |
|------|-----------|
| 211 | 0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4, 6, 8, 12, 16, 24, 32 |
| 321 | 0, 0.5, 1, 1.5, 2, 2.5, 3, 4, 6, 8, 12, 16, 24, 40 |
| 2212, 3122, 3312 | 0, 1, 1.5, 2, 2.5, 3, 4, 6, 8, 12, 16 |
| 3334 | 0, 1, 2, 3, 4.5, 7, 10, 15, 21 |

**Step 3 – per bin.** In every bin of every sub-sample I count WT and mutants and calculate $A$. Then I average over the 10 sub-samples, and the standard deviation is the error bar.

**How to read the plots:**
* green dot = average asymmetry in that momentum bin
* vertical bar = uncertainty (std), horizontal bar = width of the bin
* pink band = overall asymmetry of the pair (all momenta together)
* red dashed line = no asymmetry (equal WT and mutant)
* grey area = the extra bin with all the highest momenta

  
| Pair | Bins edges |
|------|-----------|
| 211 / -211   | 0, 0.25, 0.5, 0.75, 1, 1.5, 2, 3, 4, 6, 8, 12, 16, 24, 32 |
| 321 / -321   | 0, 0.5, 1, 1.5, 2, 2.5, 3, 4, 6, 8, 12, 16, 24, 40 |
| 2212 / -2212 | 0, 1, 1.5, 2, 2.5, 3, 4, 6, 8, 12, 16 |
| 3122 / -3122 | 0, 1, 1.5, 2, 2.5, 3, 4, 6, 8, 12, 16 |
| 3312 / -3312 | 0, 1, 1.5, 2, 2.5, 3, 4, 6, 8, 12, 16 |
| 3334 / -3334 | 0, 1, 2, 3, 4.5, 7, 10, 15, 21 |


### Plots

In every asymmetry plot: green points = mean asymmetry of the 10 sub-samples in each bin, vertical bar = statistical uncertainty, horizontal bar = bin width, pink band = overall asymmetry of the pair (all momenta) ± its uncertainty, red dashed line = no asymmetry, grey area = open last bin.

#### *E. coli* (211 / -211)
<img width="625" height="362" alt="Screenshot 2026-10-13 at 20 16 42" src="https://github.com/user-attachments/assets/875b9d75-1a6f-423c-8229-cbdaaec069bd" />

<img width="628" height="392" alt="Screenshot 2026-10-13 at 20 16 55" src="https://github.com/user-attachments/assets/fa7ee533-e43d-4d47-8cd5-afe2947cf1fd" />

Almost 0 at the lowest momenta, then it slowly increases, up to about 0.006 above P = 32. The error bars are tiny because *E. coli* is by far the most common strain. *(Note: this plot shows the SEM instead of the std.)*

#### *Bacillus subtilis* (321 / -321)
<img width="508" height="323" alt="Screenshot 2026-10-13 at 18 48 22" src="https://github.com/user-attachments/assets/d21f1852-2730-40fa-bfe3-3e59e2ba151f" />

<img width="505" height="330" alt="Screenshot 2026-10-13 at 18 48 42" src="https://github.com/user-attachments/assets/5ee2a66a-77b4-47f4-8554-47f800e2fea8" />

Close to 0 for most momenta. There is a small rise at high momentum, but it isn't above 3σ, so I don't count it as an asymmetry.

#### *Pseudomonas aeruginosa* (2212 / -2212)
<img width="658" height="404" alt="Screenshot 2026-10-13 at 18 52 49" src="https://github.com/user-attachments/assets/fe884201-8ecb-4717-9484-8ab275eeee25" />

<img width="699" height="430" alt="Screenshot 2026-10-13 at 19 00 34" src="https://github.com/user-attachments/assets/c1651e6e-8bc9-4c4b-8542-a20f573c7c52" />

Every point is above 0, so there are more WT than antibiotic-resistant bacteria **at every momentum**. The asymmetry also goes up with momentum: about 0.008 below P = 3 and about 0.015 above P = 16. So the difference is biggest for the fastest-moving bacteria.


#### *Streptococcus pneumoniae* (3122 / -3122)
<img width="637" height="408" alt="Screenshot 2026-10-13 at 20 17 51" src="https://github.com/user-attachments/assets/7f300d94-a22e-4565-a6a1-c22821de85d5" />

<img width="624" height="430" alt="Screenshot 2026-10-13 at 20 18 12" src="https://github.com/user-attachments/assets/668ecb94-d4ec-4954-9bb3-3e07e500b127" />


All points are above 0. A straight-line fit gives a positive slope of (5.1 ± 1.6) × 10⁻⁴ (3.2σ), so the asymmetry gets bigger with momentum.

#### *Mycobacterium tuberculosis* (3312 / -3312)
<img width="650" height="407" alt="Screenshot 2026-10-13 at 19 00 56" src="https://github.com/user-attachments/assets/bcc35324-7aa5-4bea-aebb-88b5b9375782" />

<img width="637" height="400" alt="Screenshot 2026-10-13 at 19 01 23" src="https://github.com/user-attachments/assets/17f8cd2d-cd11-4e87-a266-1c05158ad690" />


All bins are compatible with zero and with each other; the error bars (≈ ±0.015–0.025) are large because this strain is rare. No momentum dependence can be seen. Most points are a bit above 0, but every error bar crosses the red line and the pink band touches 0 as well. The error bars are about 5 times bigger than for *P. aeruginosa*, because there are about 30 times fewer bacteria. So I can't claim an asymmetry, and I don't see it change with momentum.

#### *Salmonella enterica* (3334 / -3334)
<img width="638" height="402" alt="Screenshot 2026-10-13 at 19 02 06" src="https://github.com/user-attachments/assets/c76c89a8-2c70-4a07-a88f-d31246afa983" />

<img width="628" height="382" alt="Screenshot 2026-10-13 at 19 02 24" src="https://github.com/user-attachments/assets/39a88487-f218-4c9c-a427-ed0ce571a0e9" />

The points jump around 0 with huge error bars (there are only ~1,000 bacteria per file). No asymmetry and no momentum trend.



### Limitations
* For *M. tuberculosis* and *Salmonella* the data cannot exclude an asymmetry of the same size as in the other strains because they few bacteria to measure it.
* Varied bin lengths because bins have different statistical weights
* Set 10 complications because its a smaller set and can be removed for future research

  
## Conclusion

** Do we see any bacteria asymmetry?: Yes, for three of the six pairs.**

| Pair | Overall asymmetry | Momentum dependence | Verdict |
|------|-------------------|---------------------|---------|
| *E. coli* | 0.0008, z > 5 | increases with $P$ | **asymmetry** |
| *B. subtilis* | 0.0011 ± 0.0007, z = 1.6 | hint at high $P$, not significant | no asymmetry |
| *P. aeruginosa* | 0.0100 ± 0.0010, z = 10.0 | present at all $P$, mild rise | **asymmetry** |
| *S. pneumoniae* | 0.0089 ± 0.0011, z = 8.4 | increases with $P$ (slope 3.2σ) | **asymmetry** |
| *M. tuberculosis* | 0.0056 ± 0.0062, z = 0.9 | none visible | no asymmetry |
| *Salmonella* | 0.0152 ± 0.0293, z = 0.5 | none visible | no asymmetry |

* In all three significant cases the asymmetry is **positive**: there are more WT than mutant bacteria (the antibiotic-resistant *P. aeruginosa* and the capsule-deficient *S. pneumoniae* are less abundant than their WT).




