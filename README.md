# PRA2003_Monitoring Bacterial Movement and Populations

**Author**: Aleyna Alicioglu(i6381736)
**Course**: Programming (PRA2003)
**Deliverable**: Week 4
**University**: Maastricht University 


## Research Questions: Biology Themed 
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
1. The week 4 slides from the course specifies sub-sampling
      a. Split the sample into sub-samples
      b. Calculate the result for each sub-sample
      c. The spread of the results are used to determine the statistical uncertainty
2. Average number per event
      a. The final value is the mean over the 10 sub-samples
4. Uncertainties
5. Asymmetry between WT and mutant
      a. Difference = mean(WT) − mean(mutant)


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

**z-score (std-based, conservative)**

$$z = \frac{\Delta}{\sqrt{\sigma_{\text{WT}}^2 + \sigma_{\text{mutant}}^2}}$$

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

| ID pair       | Pair                                                  | Difference (WT − mutant) | z-score (std-based, conservative) | Asymmetry (abs(z) ≥ 3) |
|---------------|-------------------------------------------------------|--------------------------|-----------------------------------|------------------------|
| 211 vs -211   | *E. coli* (WT vs mutant)                              | 0.0323                   | 7.10E-01                          | no                     |
| 321 vs -321   | *Bacillus subtilis* (WT vs mutant)                    | 0.00569                  | 7.80E-01                          | no                     |
| 2212 vs -2212 | *Pseudomonas aeruginosa* (WT vs antibiotic-resistant) | 0.02387                  | 7.78E+00                          | yes                    |
| 3122 vs -3122 | *S. pneumoniae* (WT vs capsule-deficient)             | 0.0049                   | 3.37E+00                          | yes                    |
| 3312 vs -3312 | *M. tuberculosis* (WT vs drug-resistant)              | 0.00044                  | 9.00E-01                          | no                     |
| 3334 vs -3334 | *Salmonella enterica* (WT vs mutant)                  | 0.00004                  | 5.40E-01                          | no                     |







