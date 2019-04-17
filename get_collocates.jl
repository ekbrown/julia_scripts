#= Julia (v1.0+) function to retrieve the collocates of a node word
Earl K. Brown, ekbrown byu edu (add appropriate characters to create email)
=#

using DataFrames, Languages

function find_collocates(dir_with_txt, node_wd, stop_words = [], span = 4, side = "both", min_freq = 2, sort_by = "freq")
    #=
    dir_with_txt: a string indicating the directory with the TXT files.
    node_wd: a string with the node word whose collocates are desired.
    stop_words: an array with words to exclude as possible collocates.
    span: an integer with the width in words of the span around the node word (default is 4).
    side: a string indicating which side, or both, of the node word to look for collocates,
        from among "both", "left", "right" (default is "both").
    min_freq: an integer giving the minimum frequency of the collocates (default is 2).
    sort_by: a string indicating the metric to order the collocates, from among
        "freq" (frequency), "t_score", "mi" (mutual information), "log_dice" (default is "freq").
    =#

    ### verify arguments given by user
    if !isa(node_wd, String)
       error("In the call to find_collocates, you need to supply a String to the argument 'node_wd'.")
    end
    node_wd = uppercase(node_wd)

    if span <= 0 || !isa(span, Integer)
       error("In the call to find_collocates(), you need to supply a positive integer to the argument 'span'.")
    end

    if lowercase(side) == "both"
        span_to_search = -span:span
    elseif lowercase(side) == "left"
        span_to_search = -span:-1
    elseif lowercase(side) == "right"
        span_to_search = 1:span
    else
        error("In the call to find_collocates(), you need to specify 'side' as either 'left', 'right', or 'both'.")
    end

    stop_words = uppercase.(stop_words)
    ### end data verification

    # create collector dictionaries
    freqs_collocates = Dict{String,Int64}()
    freqs_wds = Dict{String, Int64}()

    # get TXT filenames
    cd(dir_with_txt)
    filenames = filter(x -> occursin(r"\.txt$"i, x), readdir())

    # create collector for total words in all files
    count_wds = 0

    # loop over files
    for f in filenames

        # open connection to current file
        open(f) do fin

            # read whole file as string and make it uppercase
            whole_file = uppercase(read(fin, String))

            # split up current file into words
            wds = split(whole_file, r"[^-'a-z]"i, keepempty = false)

            # loop over words in current file
            for j in 1:length(wds)

                # increment frequency counter for current word and total word counter
                freqs_wds[wds[j]] = get(freqs_wds, wds[j], 0) + 1
                count_wds += 1

                # checks whether the current word is the node word
                if node_wd == wds[j]

                    # loop over the collocates within the span
                    for k in span_to_search

                        # if the current span word is the node word itself
                        if k == 0
                            continue
                        end

                        # try to get the next collocate word, if it doesn't fall outside the range of the words in the current file
                        try
                            collocate_wd = wds[j + k]

                            # if the collocate word is not a stopword, add to collocate collector
                            if !in(collocate_wd, stop_words)
                                freqs_collocates[collocate_wd] = get(freqs_collocates, collocate_wd, 0) + 1
                            end
                        catch BoundsError
                            continue
                        end  # try catch block
                    end  # next collocate word
                end  # if match is found in current file
            end  # next index over words
        end  # close connection to current file
    end  # next file in directory

    # push dictionary to data frame
    freqs_df = DataFrame(collocate = String[], freq = Int64[], t_score = Float64[], mi = Float64[], log_dice = Float64[])
    for (k, v) in freqs_collocates

        # add collocate word is above minimum frequency specified by the user
        if v >= min_freq

            # calculate word association metrics and push to collector DataFrame
            t_score = (v - ((freqs_wds[node_wd] * freqs_wds[k]) / count_wds)) / sqrt(v)
            mi = log2((v * count_wds) / (freqs_wds[node_wd] * freqs_wds[k]))
            log_dice = 14 + log2((2 * v) / (freqs_wds[node_wd] + freqs_wds[k]))
            push!(freqs_df, [k, v, t_score, mi, log_dice])
        end
    end

    # sort in descending order by association metric, then in ascending order by collocate
    if sort_by == "freq"
        sort!(freqs_df, [order(:freq, rev = true), order(:collocate)])
    elseif sort_by == "t_score"
        sort!(freqs_df, [order(:t_score, rev = true), order(:collocate)])
    elseif sort_by == "mi"
        sort!(freqs_df, [order(:mi, rev = true), order(:collocate)])
    elseif sort_by == "log_dice"
        sort!(freqs_df, [order(:log_dice, rev = true), order(:collocate)])
    end

    return freqs_df

end  # end function definition

### test the function
dir_with_txt = "/Users/ekb5/Corpora/gen_conf_trunc"
node_wd = "prophet"  # as a string
# stop_words = stopwords(Languages.English())
stop_words = []
span = 4
side = "both"
min_freq = 1
sort_by = "log_dice"

@time results = find_collocates(dir_with_txt, node_wd, stop_words, span, side, min_freq, sort_by)
println(results[1:10,:])
