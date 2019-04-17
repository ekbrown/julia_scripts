# julia_scripts
Julia scripts for corpus linguistics methods.

## concordancer.jl

Julia (v. 0.6) function to create a .csv file with a concordance of matches of a regular expression in a directory of .txt files (other file types in the directory are ignored). The surrounding context includes up to the number of characters specified in the 'context_size' argument or all available context within the paragraph if the specified number exceeds the number of characters available. The functions returns an array of strings, each string with tabs that separate the filename of the file in which a match was found, the paragraph number, the preceding context, the match, and the following context.

## get_collocates.jl
Julia (v1) function to retrieve the collocates of a node word within a directory of .txt files (other file types in the directory are ignored). The span width of the collocates can be configured with an integer supplied to the `span` argument. The `side` argument controls which side(s) of the node word collocates are retrieved from, with one of three strings: `left`, `right`, or `both`. With an integer, the `min_freq` argument controls the minimum frequency that collocates must have in order to be retrieved. The `stop_words` argument takes an array of words to exclude as possible collocates. The `sort_by` argument takes a string indicating how to sort the collocates, from among "freq" (frequency), "t_score", "mi" (mutual information), "log_dice" (default is "freq").


## get_dispersion.jl
Julia (v1) implementation of Stefan Th. Gries' DP (Deviation of Proportions) word dispersion algorithm. The functions takes as input a string with the pathway to the input directory with .txt files (only .txt files are read; other file types are ignored). The function returns a Julia DataFrame with columns: word, raw frequency, log frequency, DP, normalized DP. The user of the function can specify how the results are ordered, whether by frequency, range, or DP (default is DP).

## get_frequency.jl
Julia (v1) function to retrieve the frequencies of words in a directory of .txt files (other file types are ignored). This script is subsumed in the 'get_dispersion.jl' function above, but is faster because it doesn't calculate dispersion.

## get_keywords.jl
Julia (v. 1.0) script to retrieve keywords in a target corpus, based on a reference corpus. The user specifies the pathway to the target corpus directory and the pathway to the reference corpus directory, the number of keywords to retrieve, and the minimum frequency in the target corpus for words to be considered as a keyword. Only .txt files in the two directories are read in; other file types are ignored.
