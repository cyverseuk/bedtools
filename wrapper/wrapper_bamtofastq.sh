#!/bin/bash

function debug {
  echo "creating debugging directory"
mkdir .debug
for word in ${rmthis}
  do
    if [[ "${word}" == *.sh ]] || [[ "${word}" == lib ]]
      then
        mv "${word}" .debug;
      fi
  done
}

rmthis=`ls`
echo ${rmthis}

ARGSU=" ${type} ${prefix} ${tags}"
BAMU="${bam_file}"
INPUTSU="${BAMU}"
echo "BAM file is " "${BAMU}"
echo "arguments are "${ARGSU}
echo "inputs are "${INPUTSU}

PREU="${prefix}"
PREU="${PREU:-output}"
CMDLINEARG="bamToFastq ${tags} -i ${BAMU} "
if [ -z "${type}" ] || [ "${type}" = "SE" ]
  then
    CMDLINEARG+="-fq ${PREU} "
elif [ "${type}" = "PE" ]
  then
    CMDLINEARG+="-fq ${PREU}_1 -fq2 ${PREU}_2 "
elif [ "${type}" = "interleaved" ]
  then
    CMDLINEARG+="-fq /dev/stdout -fq2 /dev/stdout > ${PREU}.fq "

fi

echo ${CMDLINEARG};
chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/bedtools:v2.25.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
#echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/apps/bamtofastq/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit -batch-name ${PWD##*/} lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

debug

exit 0
