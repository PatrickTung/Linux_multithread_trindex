#!/bin/bash

#Run script in directory with Trindex program

########################## USER INPUT ##########################
startZ=-15
endZ=15
numThreads=35
scale=3
#the input binary file
BINFILENAME="/u/data/pattung/JPARC_Nitinol/matlab/data2trindex/NiTi_A_stress3_fakemartensite.dat"
#the prefixes for the output files
INIFILENAMEPREFIX="/u/data/pattung/trindex_110120/Trindex/NiTi_2019/NiTi_A_stress3_fakemartensite_"
TXTFILENAMEPREFIX="/u/data/pattung/trindex_110120/Trindex/NiTi_2019/NiTi_A_stress3_fakemartensite_"
#shell script directory
SHELLSCRIPT="NiTi_script.sh"
################################################################

start=`date +%s`
processCounter=0

#make all the .ini files
for ((i=startZ; i<=endZ; i++)); do
	#make the iterated file names
	counter=$(($i-$startZ))
	INIFILENAME="$INIFILENAMEPREFIX$counter.ini"
	TXTFILENAME="$TXTFILENAMEPREFIX$counter.txt"

	#make the ini file
	echo "imagefile $BINFILENAME" > $INIFILENAME
	echo "omatrix 1 0 0 1 ! omatrix [o11 o12 o21 o22] " >> $INIFILENAME
	echo "!omatrix  0 1 1 0 ! omatrix [o11 o12 o21 o22] " >> $INIFILENAME
	echo "unitcell 2.898 4.108 4.646 90. 97.78 90. ! unitcell [a/AA] [b/AA] [c/AA] [alpha/deg] [beta/deg] [gamma/deg] " >> $INIFILENAME
	echo "spacegroup 11 ! spacegroup [spacegroup nr] " >> $INIFILENAME
	echo "orispecs 0. 0. 0. 0.4142 25 ! orispecs [r0_1 r0_2 r0_2 half_side_length half_divisions] in orientation space: 2*half_side:length, 2*half_divisions+1 " >> $INIFILENAME
	echo "omegacor 1 0. ! omegacor [sign_omega_rotation (+-1) omega_offset (/deg)] " >> $INIFILENAME
	echo "drange 1.1 2.1 ! dsrange [ds_min/AA] [ds_max/AA] " >> $INIFILENAME
	echo "lambdarange 1.0 3.3 ! lambdarange [min_lambda/AA] [max_lambda/AA] " >> $INIFILENAME
	echo "timeslicedelta 20 ! timeslicedelta [+- timebins in search] " >> $INIFILENAME
	echo "recorange -15 19 -18 16 $i $i " >> $INIFILENAME
	echo "!recorange -25 25 -25 25 -23 23 " >> $INIFILENAME
	echo "!recorange -17 17 -17 17 -15 15 " >> $INIFILENAME
	echo "scale $scale" >> $INIFILENAME
	echo "mapfile $TXTFILENAME" >> $INIFILENAME

	
	#keep track of which process we're on
	if (( $processCounter==$numThreads )); then
		#when the number of threads have been exceeded, then reset process counter and increment process ID
		processCounter=0
	fi
	#increment  counter for current process
	processCounter=$(($processCounter+1))
	
	#if first ini file in process, make the shell file
	if (($processCounter==1)); then
		echo "#!/bin/bash" > $SHELLSCRIPT
	fi

	#append a trindex execution in shell file
	echo "./trindex $INIFILENAME &" >> $SHELLSCRIPT
	#echo "sleep 1" >> $SHELLSCRIPT

	#if it's the end of the file or number of threads
	if (($processCounter==$numThreads || $i==endZ)); then
		echo "wait" >> $SHELLSCRIPT
		chmod +x $SHELLSCRIPT
		./$SHELLSCRIPT
	fi
	
done



play /usr/share/sounds/purple/alert.wav

end=`date +%s`
runtime=$((end-start))
echo;echo;echo;echo All processes finished! Process took $runtime seconds.; echo; echo; echo
