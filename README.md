# PRA2003_Monitoring bacterial movement and populations
Aleyna Alicioglu - i6381736

## Biology Themed Exercise: Answer the following questions with the given dataset 
1. What are the average counts of each bacterial stain and their statistical uncertainties?
2. Is there any asymmetry between the normal and the mutant strain? 
3. Is there any asymmetry as a function of their momentum? 

## Week 3: Code Installation
This code will read one file with 500K events and will select the bacterial strains of interest based on its code and give the average bacteria per event together with its statistical uncertainty. 

### Description 
Each file contains data on 12 bacterial strains

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


### Getting Started
Dependences:
- To run the code, the user should have the file downloaded in the same folder as the script.
- Events that have 0 particles (e.g. "19 0") are the failed experiments and are not counted as events.

## Week 4: Data Analysis
The main results come from the analysis of the entire sample of 5M experiments. 

### Description
To calculate the results of the entire sample of 5M events, the same code from week 3 was reused. Each dataset was analysed separately as an individual sub-sample, meaning that there would be 10 sub-samples in total.

