using Dramaturg

#=

Read in a sample triple-file of:
	
	surface-form \t lemma \t pos-tag

Output a list of human-readable parsed forms.

=#

# Filepaths

input_path = "morph/test-output/test-triplets.tsv"
output_path = "morph/test-output/triplets-described.md"
error_log = "morph/test-output/triplets-desc-error.log"
markdown = true
divider = "\n------------------\n"

function trips_to_desc(input_path::String, output_path::String, error_log::String="")
   lines = readlines(input_path)
    open(output_path, "w") do out
        open(error_log, "w") do err
        		for (ln) in lines
        			if isempty(ln) 
        				continue
        			end
        			sf = string( split(ln,"\t")[1] )
        			lemma = string( split(ln,"\t")[2] )
        			postag = string( split(ln,"\t")[3] )
        			desc = describe_pos(sf, lemma, postag, markdown=markdown)
        			println(out, desc)
        			println(out, divider)
        		end 
        end 
   end
   println("$(length(lines)) human-readable parsings written to $output_path.")
end 

trips_to_desc(input_path, output_path, error_log)