# Julia (1.0) script to retrieve the collocates of a node word
# in a directory of .txt files on the user hard drive.
# Only .txt files are used; other files in the directory are ignored.

# (c) 2018 Earl K. Brown, ekbrown@byu.edu

# usage: find_collocates(
# dir_with_txt: directory with the .txt files,
# node_wd: the node word whose collocates are desired,
# span: the width in words of the span around the node word (default is 4),
# side: which side of the node word: "left", "right", "both" (default),
# min_freq: the minimum frequency of the collocates to retrieve (default is 2)
# )


using DataFrames

function find_collocates(dir_with_txt, node_wd, span = 4, side = "both", min_freq = 2)

    # verify arguments given by user

    if !isa(node_wd, Regex)
       error("In the call to find_collocates, you need to supply a regular expression (e.g. r'\bword\b'i) to the argument 'node_wd'.")
    end

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

    # end data verification

    # creates collector dictionary
    freqs_dict = Dict{String,Int64}()

    # gets .txt filenames
    original_working_dir = pwd()
    cd(dir_with_txt)
    filenames = filter(x -> occursin(r"\.txt$"i, x), readdir())

    for i in filenames
        open(i) do fin
            for ln in eachline(fin)

                # checks whether the node word is in the current line
                if occursin(node_wd, ln)

                    # split up current line into words
                    wds = split(ln, r"[^-'a-z]"i, keepempty = false)

                    # loop over the words in the current line
                    for j in 1:length(wds)

                        # if the current word matches the node word
                        if occursin(node_wd, wds[j])

                            # loop over the collocates within the span
                            for k in span_to_search

                                # if the current span word is the node word
                                if k == 0
                                    continue
                                end  # if current span word is the node word itself

                                # try to get the next collocate word, if it doesn't fall outside the range of the words in the current line
                                try
                                    collocate_wd = uppercase(wds[j + k])
                                    freqs_dict[collocate_wd] = get(freqs_dict, collocate_wd, 0) + 1
                                catch BoundsError
                                    continue
                                end  # try catch block
                            end  # next collocate word
                        end  # if current word is node word
                    end  # next word in current line
                end  # if match is found in current line
            end
        end
    end

    # push dictionary to data frame
    freqs_df = DataFrame(collocate = String[], freq = Int64[])
    for (k, v) in freqs_dict
        push!(freqs_df, [k, v])
    end

    # limit results to minimum frequency
    freqs_df = freqs_df[freqs_df[:, :freq] .>= min_freq, :]

    # sort in descending order by frequency, then in ascending order by collocate
    sort!(freqs_df, [order(:freq, rev = true), order(:collocate)])

    # change to original working directory
    cd(original_working_dir)

    return freqs_df

end  # end function definition

### test the function
dir_with_txt = "/pathway/to/directory"
node_wd = r"\bword\b"i  # as regex, with any flags that the user wants
span = 4
side = "both"
min_freq = 3

@time results = find_collocates(dir_with_txt, node_wd, span, side, min_freq)
println(results)
