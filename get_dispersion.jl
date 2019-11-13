#= Julia (v1) function to retrieve frequencies as well as Stefan Th. Gries' DP (Deviation of Proportions) word dispersion algorithm for words in a directory of TXT files.
Earl K. Brown, ekbrown byu edu (add appropriate characters to create email)
=#

using DataFrames

function get_dispersion(input_dir, min_freq = 1, sort_by = "dp")
    #= The function takes as input a string with the pathway to the input directory with .txt files and returns as output a Julia DataFrame with columns: word, freq, log freq, range, DP, and DP normalized.

    input_dir: A string with the pathway (whether absolute or relative) to the directory with the .txt files; other file types are ignored.
    min_freq: An integer indicating the minimum frequency for words to include (default is 1).
    sort_by: A string indicating how the results are ordered, from among "freq", "range" or "dp" (default is "dp").
    return value: A Julia DataFrame.

    For information about the DP dispersion algorithm, see:
    Gries, Stefan Th. 2008. Dispersions and adjusted frequencies in corpora. International Journal of Corpus Linguistics 13(4), 403–437.
    Lijffijt, Jeffrey & Stefan Th. Gries. 2012. Correction to "Dispersions and adjusted frequencies in corpora". International Journal of Corpus Linguistics 17(1), 147-149.
    =#

    # get filenames
    cd(input_dir)
    filenames = filter(f -> occursin(r"\.txt$"i, f), readdir())

    # create empty array to collect number of words in each file
    s = Array{Int64, 1}()

    # create dictionary to collect frequency of words in each file
    freq_by_file = Dict{Tuple, Int64}()

    # create dictionary to collect frequency of words across all files
    all_freq = Dict{String, Int64}()

    # counter for number of files
    counter = 0

    # loop over files in directory
    for f in filenames

        # increment file counter
        counter += 1

        # open connection to current file
        open(f) do infile

            # read whole file as string and make it uppercase
            whole_file = uppercase(read(infile, String))

            # get words in current file
            wds = split(whole_file, r"[^-'a-záéíóúüñ0-9]+"i, keepempty = false)

            # push number of words in current file to collector
            push!(s, length(wds))

            # loop over words in current file, pushing them to the collector dictionaries
            for wd in wds
                freq_by_file[(wd, counter)] = get(freq_by_file, (wd, counter), 0) + 1
                all_freq[wd] = get(all_freq, wd, 0) + 1
            end  # next word
        end  # close connection to current file
    end  # next file

    # get number of files in directory
    num_files = length(s)

    # convert number of words in each file to ratios
    s /= sum(s)

    # create a data frame collector to format output
    output = DataFrame(wd = String[], freq = Int64[], freq_log10 = Float64[], range = Int64[], dp = Float64[], dp_norm = Float64[])

    # loop over words and pushes DP of each word to collector
    for (k, v) in all_freq
        observed = Array{Int64, 1}()
        for j in 1:num_files
            push!(observed, get(freq_by_file, (k, j), 0))
        end
        cur_range = length(filter(x -> x > 0, observed))
        cur_dp = sum(abs.((observed / all_freq[k]) - s)) / 2
        cur_dp_norm = cur_dp / (1 - minimum(s))
        push!(output, [k, v, log10(v), cur_range, cur_dp, cur_dp_norm])
    end

    # filter by minimum frequency desired by user
    output = output[(output[!, :freq].>= min_freq),:]

    # sort data frame
    if sort_by == "freq"
        sort!(output, [order(:freq, rev = true), :wd])
    elseif sort_by == "range"
        sort!(output, [order(:range, rev = true), :wd])
    elseif sort_by == "dp"
        sort!(output, [order(:dp, rev = false), :wd])
    end

    return output

end  # end function definition

#########################
### test the function ###
#########################

input_dir = "/Users/ekb5/Corpora/USA/California/Salinas/transcripts"
min_freq = 1
sort_by = "freq"  # one of "freq", "range" or "dp"
@time results = get_dispersion(input_dir, min_freq, sort_by)  # runs function
println(results[1:10,:])
