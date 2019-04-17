#=
Julia (v1) function to get frequencies of words in a directory of TXT files.
Earl K. Brown, ekbrown byu edu (add appropriate characters to create email)
=#

using DataFrames

function get_frequency(pathway, sort_by = "freq")
    #=
    The function takes as input a string with the pathway to the directory with .txt files and returns as output a Julia DataFrame.

    pathway: A string with the (absolute or relative) pathway to the directory with the .txt files; other file types are ignored.
    sort_by: A string indicating how the frequencies should be ordered, from among "freq" (frequency) in descending order, or "alpha" (alphabetical order) in ascending order (default is "freq").
    return value: A Julia DataFrame with three columns: word, raw frequency, log frequency (base 10).
    =#

    # get filenames
    cd(pathway)
    filenames = [f for f in readdir() if occursin(r"\.txt$"i, f)]

    # loop over files, collecting frequencies along the way
    freqs = Dict{String, Int64}()
    for filename in filenames
        open(filename) do infile
            cur_file = uppercase(read(infile, String))  # convert to uppercase
            wds = split(cur_file, r"[^-'A-ZÁÉÍÓÚÜÑ]+"i)  # get words in current file
            for wd in wds
                freqs[wd] = get(freqs, wd, 0) + 1
            end  # next word
        end  # close file connection
    end  # next filename

    # push dictionary to data frame
    freqs_df = DataFrame(word = String[], freq = Int64[], log_freq = Float64[])
    for (k, v) in freqs
        push!(freqs_df, [k, v, log10(v)])
    end

    # sort as desired by user of function
    if sort_by == "freq"
        sort!(freqs_df, [order(:freq, rev = true), :word])
    elseif sort_by == "alpha"
        sort!(freqs_df, [order(:word)])
    end

    return freqs_df
end

### test the function
dir = "/Users/ekb5/Corpora/USA/California/Salinas/transcripts/"
sort_by = "freq"
@time freqs = get_frequency(dir, sort_by)
println(freqs[1:10,:])
