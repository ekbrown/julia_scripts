# julia_scripts
Julia scripts for corpus linguistics methods.

## concordancer.jl

Julia function to create a .csv file with a concordance of matches of a regular expression in a directory of .txt files (other file types in the directory are ignored). The surrounding context includes up to the number of characters specified in the 'context_size' argument or all available context within the paragraph if the specified number excedes the number of characters available. The functions returns an array of strings, each string with tabs that separate the filename of the file in which a match was found, the paragraph number, the preceding context, the match, and the following context.

## freq_disp.jl

Julia implementation of Stefan Th. Gries' DP (Deviation of Proportions) word dispersion algorithm. The functions takes as input a string with the pathway to the input directory with .txt files (only .txt files are read; other file types are ignored). The function returns a Julia DataFrame with three columns: word, raw frequency, DP. The DataFrame is ordered in descending order by raw frequency.

For information about the DP dispersion algorithm, see:

Gries, Stefan Th. 2008. Dispersions and adjusted frequencies in corpora. *International Journal of Corpus Linguistics* 13(4), 403–437.
