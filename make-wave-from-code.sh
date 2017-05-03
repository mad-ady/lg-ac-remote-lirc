#!/bin/bash

#requires sox for makewavesq.sh
#requires DemodulateOOK https://github.com/Sc00bz/DemodulateOOK
DEMODULATEOOK=../DemodulateOOK/demodulate-ook

REPORT=report.csv
echo "File, Hex, Binary" > $REPORT

for file in raw-codes/*; do
	echo $file
	wave=$file
	wave=${wave/raw-codes/raw-waves}
#	echo "$wave"
	./makewavesq.sh "$file" "$wave"
	#demodulate
	demodulated=$wave
	demodulated=${demodulated/raw-waves/demodulated}
	$DEMODULATEOOK "$wave".wav 2>/dev/null | tail -1 > "$demodulated"
	#extract demodulated hex and convert it to binary. Save the output to a csv
	hex=$(<$demodulated);
	#bc requires uppercase
	hex=${hex^^}
	binary=`echo "ibase=16; obase=2; $hex" | BC_LINE_LENGTH=0 bc | sed 's/.\{8\}/& /g'`
	echo "$file,$hex,$binary" >> $REPORT
done
