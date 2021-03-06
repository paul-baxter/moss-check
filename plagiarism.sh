#/bin/bash
#Assumes:
# - 'unzip' installed
sudo echo ""
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
SUBSTRING="CMP2090M Assessment Item 1 Supporting Documentation Upload_"

#the following are MOSS options
LANGUAGE="cc"              #define c++ as language to analyse
BASE_FILES="ReadWriteFunctions.cpp"  #define source file(s) of provided code
MAX_MATCHES="10000"           #max times a piece of code can appear before being ignored

[ -d $W_DIRECTORY/cc_source_files ] || mkdir $W_DIRECTORY/cc_source_files
cp to_UTF8.sh "$W_DIRECTORY"
cd "$W_DIRECTORY"
sudo chmod a+rwx to_UTF8.sh

echo "...renaming zip files to something more sensible:"
echo ""
COUNT=0

for file in *.zip; do
	[ -f "$file" ] || echo "No matching .zip files"
	#0a: strip out useless filename info
	mv "$file" "${file/$SUBSTRING/}" 2>/dev/null #suppress errors
done
echo ""
echo "...iterating through zip files, unpacking and handling:"
echo ""
for file in *.zip; do
	[ -f "$file" ] || echo "No matching .zip files" #&& exit
	echo "	>>	$file"
	#0b: strip extension
	file=${file%.*}
	#1: unzip to temp dir
	unzip -qq "$file" -d "$file.tmp"
	chmod -R 777 "$file.tmp"	#occasionally projects where subdirectories lack permissions...
	[ -d temp_src ] || mkdir temp_src
 	#2: move all source and header files to temp dir
	# https://www.cyberciti.biz/faq/linux-unix-bsd-xargs-construct-argument-lists-utility/
	find "$file.tmp" -type f -iname "*.cpp" -exec mv "{}" "$W_DIRECTORY"/temp_src/ \; #| xargs -0 -I '{}' mv "{}" $W_DIRECTORY/temp_src/ #
	find "$file.tmp" -type f -iname "*.h" -exec mv "{}" "$W_DIRECTORY"/temp_src/ \;
	#3: concatenate file contents: first headers then sources
	cd temp_src
	OUTFILE="$file"
	touch $OUTFILE
	OUTFILE=${OUTFILE//[^a-zA-Z0-9]/_}
	OUTFILE="$OUTFILE".cc
	cat *.h >> "$OUTFILE" 2>/dev/null #suppress errors
	cat *.hpp >> "$OUTFILE" 2>/dev/null #suppress errors
	cat *.cpp >> "$OUTFILE"
	#4: modify the files if necessary
	tmpfile=$(mktemp)
	tr -cd '\11\12\15\40-\176' < "$OUTFILE" > ${tmpfile}	#remove non-printable characters
	cat ${tmpfile} > "$OUTFILE"
	rm -f ${tmpfile}
	dos2unix -f "$OUTFILE" 2>/dev/null #deal with windows line endings...
	"$W_DIRECTORY"/to_UTF8.sh $OUTFILE	 2>/dev/null #convert to utf8 if utf16
	#5: move new source file to code dir, then clean up
	mv $OUTFILE "$W_DIRECTORY"/cc_source_files/$OUTFILE
	cd ..
	rm -r "$file.tmp"
	rm -r temp_src
	COUNT=$[$COUNT +1]
done
echo ""
echo "...processed zip files: $COUNT"
echo ""
cd ..

rm "$W_DIRECTORY"/to_UTF8.sh

#send data to MOSS
./moss.sh -l "$LANGUAGE" -b "$BASE_FILES" -m "$MAX_MATCHES" -c "OOP 1819" $W_DIRECTORY/cc_source_files/*.cc

#do something with the returned data...?

echo ""
echo ""
