#=
Julia implementation of Stefan Th. Gries' DP (Deviation of Proportions) word dispersion algorithm. The functions takes as input a string with the pathway to the input directory with .txt files (only .txt files are read; other file types are ignored). The function returns a Julia DataFrame with three columns: word, raw frequency, DP. The DataFrame is ordered in descending order by raw frequency.

For information about the DP dispersion algorithm, see:
Gries, Stefan Th. 2008. Dispersions and adjusted frequencies in corpora. International Journal of Corpus Linguistics 13(4), 403–437.

(c) 2018 Earl K. Brown, ekbrown@byu.edu
=#

# imports library to work with tabular data
using DataFrames

# defines function
function get_freq_disp(input_dir)

    # changes working directory and gets file names
    cd(input_dir)
    file_names = [i for i in readdir() if ismatch(r"\.txt$"i, i)]

    # creates empty array to collect number of words in each file
    s = []

    # creates dictionary to collect frequency of words in each file
    freq_by_file = Dict()

    # counter for number of files
    counter = 0

    # loops over files in directory
    for i in file_names

        # increments counter
        counter += 1

        # opens connection to current file
        fin = open(i)

        # slurps in the whole file and converts to uppercase
        cur_file = uppercase(readstring(fin))
        close(fin)

        # splits the file into words
        wds = split(cur_file, r"[^-'a-záéíóúüñ0-9]+"i, keep = false)

        # pushes number of words in current file to collector
        push!(s, length(wds))

        # loops over words in current file, pushing them to dictionary
        for j in wds
            freq_by_file[(j, counter)] = get(freq_by_file, (j, counter), 0) + 1
        end

    end  # next file in directory; i for loop

    # gets number of files in directory and total number of words in directory
    num_files = length(s)
    total_num_wds = sum(s)

    # converts number of words in each file to percentages
    s = s / total_num_wds

    # creates dictionary of all freqs
    all_freq = Dict{String,Int64}()
    for (k, v) in freq_by_file
        all_freq[k[1]] = get(all_freq, k[1], 0) + v
    end

    # creates empty dictionary to collect DP of words
    dp = Dict()

    # loops over words and pushes DP of each to collector
    for i in keys(all_freq)
        observed = []
        for j in 1:num_files
            push!(observed, get(freq_by_file, (i, j), 0))
        end
        dp[i] = (sum(abs.((observed / all_freq[i]) - s))) / 2
    end

    # creates a data frame collector to format output
    output = DataFrame(wd = AbstractString[], freq = Int64[], dp = Float64[])
    for (k, v) in all_freq
        push!(output, [k, v, dp[k]])
    end

    # sorts data frame in descending order of freq, and then ascending of word
    sort!(output, cols = [order(:freq, rev = true), :wd])

    return output

end  # end function definition

### test the function
input_dir = "pathway/to/directory"
output_file = "/pathway/to/file/filename.csv"
results = get_freq_disp(input_dir)  # runs function
writetable(output_file, results)  # writes DataFrame to hard drive
println("All done!")
