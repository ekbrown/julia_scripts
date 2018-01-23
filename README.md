# julia_scripts
Julia script, mostly for corpus linguistics methods.

## freq_disp.jl

Julia implementation of Stefan Th. Gries' DP (Deviation of Proportions) word dispersion algorithm. The functions takes as input a string with the pathway to the input directory with .txt files (only .txt files are read; other file types are ignored). The function returns a Julia DataFrame with three columns: word, raw frequency, DP. The DataFrame is ordered in descending order by raw frequency.

For information about the DP dispersion algorithm, see:
Gries, Stefan Th. 2008. Dispersions and adjusted frequencies in corpora. International Journal of Corpus Linguistics 13(4), 403–437.

