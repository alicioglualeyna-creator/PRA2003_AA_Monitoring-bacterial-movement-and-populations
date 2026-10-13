# PRA2003_Monitoring Bacterial Movement and Populations

**Author**: Aleyna Alicioglu(i6381736)

**Course**: Programming (PRA2003)

**University**: Maastricht University 


## Biology Themed Research Questions:
Answer the following questions with the given dataset:
1. What are the average counts of each bacterial stain and their statistical uncertainties?
2. Is there any asymmetry between the normal and the mutant strain? 
3. Is there any asymmetry as a function of their momentum?

## Dataset Description
* There are 10 data files in total, each containing 500,000 events
* All of the files are named output-Set#.txt
* Each file contains data on 12 bacterial strains, identified by a bacterial ID
    * The mutant strain for each bacteria is labelled with a negative ID number
* Each event starts with a header line
    * First value represents the experiment number
    * Second value is the number of bacteria in that experiment 



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
Notation: $k = 1, \dots, N$ is the sub-sample index ($N = 10$), $n_k$ is the number of bacteria of a given ID in sub-sample $k$, and $E_k$ is the number of valid events in sub-sample $k$ (events with 0 bacteria are excluded).

**Mean per event in one sub-sample**

$$x_k = \frac{n_k}{E_k}$$

**Mean per event (final value, average over the sub-samples)**

$$\bar{x} = \frac{1}{N} \sum_{k=1}^{N} x_k$$

**Statistical uncertainty (spread of the sub-sample results)**

$$\sigma = \sqrt{\frac{1}{N-1} \sum_{k=1}^{N} \left(x_k - \bar{x}\right)^2}$$

**Uncertainty on the mean**

$$\sigma_{\bar{x}} = \frac{\sigma}{\sqrt{N}}$$

**Total count (all sets)**

$$n_{\text{total}} = \sum_{k=1}^{N} n_k$$

**Difference between WT and mutant**

$$\Delta = \bar{x}_{\text{WT}} - \bar{x}_{\text{mutant}}$$

**Asymmetry criterion**

$$|z| \geq 3 \;\Rightarrow\; \text{asymmetry}$$



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


### Correction of the z-score (feedback: correlated measurements)

> *Feedback:* "Why do you propagate the uncertainties on your z-score as if the two measurements are fully uncorrelated?"

The WT and mutant counts are **not independent**: in every sub-sample they are counted in the *same* events. When a sub-sample happens to contain more bacteria overall, both the WT and the mutant counts go up together. The two measurements are therefore positively correlated, and the correct propagation of the uncertainty on the difference is

$$\sigma_{\Delta}^2 = \sigma_{\text{WT}}^2 + \sigma_{\text{mutant}}^2 - 2\,\text{cov}(x_{\text{WT}}, x_{\text{mutant}})$$

Leaving out the covariance term (as in Table 2) **overestimates** the uncertainty and makes the z-score too small.

Instead of estimating the covariance separately, the correlation is taken into account automatically by computing the comparison **inside each sub-sample first** and only then looking at the spread. For this the asymmetry is used:

**Asymmetry in one sub-sample**

$$A_k = \frac{n_{\text{WT},k} - n_{\text{mut},k}}{n_{\text{WT},k} + n_{\text{mut},k}}$$

**Mean asymmetry** (weighted by the number of bacteria $w_k = n_{\text{WT},k} + n_{\text{mut},k}$ in each sub-sample)

$$\bar{A} = \frac{\sum_k w_k A_k}{\sum_k w_k}$$

**Statistical uncertainty** (weighted spread of the 10 $A_k$ values)

$$\sigma_A = \sqrt{\frac{N}{N-1}\,\frac{\sum_k w_k (A_k - \bar{A})^2}{\sum_k w_k}}$$

**Corrected z-score**

$$z = \frac{\bar{A}}{\sigma_A}$$

Because $A_k$ is built from WT and mutant counts of the *same* sub-sample, any fluctuation that both share cancels in $A_k$, so $\sigma_A$ contains the covariance term. As in Week 4, the std (not the SEM) is used, which is the conservative choice.


## Week 6: Asymmetry as a Function of Momentum

### Code
| Step | File | Language | What it does |
|------|------|----------|--------------|
| 1 | `1_Deliverable6momentum.r` | R | Reads all 10 `output-Set#.txt` files in chunks of 2 million lines, keeps the bacteria with the IDs of interest, calculates $P = \sqrt{p_x^2 + p_y^2 + p_z^2}$ and writes one `momenta-Set#.csv` per sub-sample (columns `ID`, `p`). |
| 2 | `2_Deliverable6finalmomentum.py` | Python | For one WT/mutant pair (`pid1` at the top of the file): bins the momenta, computes the asymmetry and $dN/dP$ per bin per sub-sample, averages over the 10 sub-samples, saves `asymmetry-<ID>.csv`, `asymmetry-<ID>.png` and `spectrum-<ID>.png`. |



