#Assumes:
# - 'unzip' installed
echo ""
echo "**********************************************************"
echo "        CMP2090M Assignment 1 Plagiarism Tool"
echo "  Based on MOSS: http://theory.stanford.edu/~aiken/moss/"
echo "                   P. Baxter, 2018"
echo "**********************************************************"
echo ""
if [ "$#" -ne 1 ]; then
	echo ""
	echo "ERROR: "
	echo "  './plagiarism.sh {working_directory}' "
	echo ""
	echo "		{working_directory}: path containing zipped projects to analyse"
	echo ""
	exit
fi

#general options
W_DIRECTORY="$1"

#the following are MOSS options
LANGUAGE="-l cc "              #define c++ as language to analyse
BASE_FILES="-b functions.cc "  #define source file(s) of provided code
MAX_MATCHES="-m 10 "           #max times a piece of code can appear before being ignored

echo "...creating directory"
[ -d $W_DIRECTORY/cc_source_files ] || mkdir $W_DIRECTORY/cc_source_files
cd "$W_DIRECTORY"

echo "...iterating through zip files"
COUNT=0
for file in *.zip; do
	[ -f "$file" ] || echo "No matching .zip files" #&& exit
	echo "    $file"
	#1: unzip to temp dir
	unzip -qq $file -d "$file.tmp"
	[ -d temp_src ] || mkdir temp_src
 	#2: move all source and header files to temp dir
	# https://www.cyberciti.biz/faq/linux-unix-bsd-xargs-construct-argument-lists-utility/
	find "$file.tmp" -type f -iname "*.cpp" -exec mv "{}" $W_DIRECTORY/temp_src/ \; #| xargs -0 -I '{}' mv "{}" $W_DIRECTORY/temp_src/ #
	find "$file.tmp" -type f -iname "*.h" -exec mv "{}" $W_DIRECTORY/temp_src/ \;
	#3: concatenate file contents: first headers then sources
	cd temp_src
	OUTFILE="$file".cc
	touch $OUTFILE
	cat *.h >> "$OUTFILE"
	cat *.cpp >> "$OUTFILE"
	mv $OUTFILE $W_DIRECTORY/cc_source_files/$OUTFILE
	#4: move new source file to code dir
	#do more stuff
	cd ..
	rm -r "$file.tmp"
	rm -r temp_src
	COUNT=$[$COUNT +1]
done
echo "...processed zip files: $COUNT"
