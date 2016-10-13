Protein Data: A list of identified proteins with relative abundances in 3 different conditions.
Anaysis: Identify the proteins that have been identified in all 3 conditions. Generate heatmap to visualize the variation of their abundance among the conditions. Calculate the coefficient of variation of the relative abundances for each protein, and added the CV in the heatmap (sorting by CV lowest to highest values). The lower the CV, the lower the variation and the more red it is. Similarly, the lower the abundance, the more red it is.
Graphing: Used Rinruby gem, gplots R package.

Peptide Data: A list of identified peptides with their spectral counts, in 3 different conditions.
Anaysis: Identify the unique peptides that have been identified in all 3 conditions, in combinations of 2, and in single conditions. Calculate the total counts and generate Venn diagram for the common peptides.
Graphing: Used Rinruby gem, VennDiagram R package.