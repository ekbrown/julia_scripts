# julia_scripts
Julia scripts for corpus linguistics methods.

## concordancer.jl

Julia (v. 0.6) function to create a .csv file with a concordance of matches of a regular expression in a directory of .txt files (other file types in the directory are ignored). The surrounding context includes up to the number of characters specified in the 'context_size' argument or all available context within the paragraph if the specified number exceeds the number of characters available. The functions returns an array of strings, each string with tabs that separate the filename of the file in which a match was found, the paragraph number, the preceding context, the match, and the following context.

## find_collocates.jl

Julia (v. 0.6) function to retrieve the collocates of a node word within a directory of .txt file (other file types in the directory are ignored). The span width of the collocates can be configured with an integer supplied to the `span` argument. The `side` argument controls which side(s) of the node word collocates are retrieved from, with one of three strings: `left`, `right`, or `both`. With an integer, the `min_freq` argument controls the minimum frequency that collocates must have in order to be retrieved.

## find_collocates_v1.0.jl
Same as `find_collocates.jl` but written for Julia 1.0.

## freq_disp.jl

Julia (v. 0.6) implementation of Stefan Th. Gries' DP (Deviation of Proportions) word dispersion algorithm. The functions takes as input a string with the pathway to the input directory with .txt files (only .txt files are read; other file types are ignored). The function returns a Julia DataFrame with three columns: word, raw frequency, DP. The DataFrame is ordered in descending order by raw frequency.

For information about the DP dispersion algorithm, see:

Gries, Stefan Th. 2008. Dispersions and adjusted frequencies in corpora. *International Journal of Corpus Linguistics* 13(4), 403–437.

## get_keywords.jl

Julia (v. 1.0) script to retrieve keywords in a target corpus, based on a reference corpus. The user specifies the pathway to the target corpus directory and the pathway to the reference corpus directory, the number of keywords to retrieve, and the minimum frequency in the target corpus for words to be considered as a keyword.
