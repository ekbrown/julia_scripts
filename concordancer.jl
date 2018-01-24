#=
Julia function to create a .csv file with a concordance of matches of a regular expression in a directory of .txt files (other file types in the directory are ignored). The surrounding context includes up to the number of characters specified in the 'context_size' argument or all available context within the paragraph if the specified number exceeds the number of characters available. The functions returns an array of strings, each string with tabs that separate the filename of the file in which a match was found, the paragraph number, the preceding context, the match, and the following context.

(c) 2018 Earl K. Brown, ekbrown@byu.edu
=#

function concord(input_dir, search_regex, context_size = 50)

    file_names = filter(r"\.txt$"i, readdir(input_dir))

    # initializes collector array and pushes headers to it
    all_output = ["FILE\tPARA\tPRE\tMATCH\tPOST"]

    # loops over files
    for i in file_names

        # reads in current file
        cur_file = string(input_dir, "/", i)
        f = open(cur_file)
        cur_text = readstring(f)
        close(f)

        # deletes tabs in the file and splits up the file into paragraphs
        cur_text = replace(cur_text, r"\t", s" ")
        cur_text = split(cur_text, "\n")

        # loops over paragraphs in current file
        para_num = 0  # paragraph counter
        for j in cur_text
            para_num += 1  # increment paragraph counter

            # searches for regex in current paragraph and returns an iterator object
            hits = eachmatch(search_regex, j)

            # loops over hits in current paragraph
            for k in hits
                offset_start = k.offset
                offset_end = k.offset + length(k.match)

                # preceding context
                pre = try
                    j[offset_start - context_size:offset_start - 1]
                catch BoundsError
                    j[1:offset_start - 1]
                end

                # following context
                post = try
                    j[offset_end:offset_end + context_size]
                catch BoundsError
                    j[offset_end:end]
                end

                # creates output string and pushes it to the collector array
                cur_output = string(i, "\t", para_num, "\t", pre, "\t", k.match, "\t", post)
                push!(all_output, cur_output)

            end  # next hit in current paragraph; end k loop
        end  # next paragraph; end j loop
    end  # next file; end i loop

    return(all_output)

end  # function definition

### tests function
input_dir = "/pathway/to/directory"
search_regex = r"[REGEX HERE]"i  # case-insensitive search

results = concord(input_dir, search_regex)

writedlm("/pathway/to/output.csv", results, '\n', quotes=false, comments=false)
println("All done!")
