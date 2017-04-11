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

ARGSU=" ${hist} ${depth} ${counts} ${mean} ${same_strand} ${diff_strand} ${a_overlap} ${b_overlap} ${r_overlap} ${e_overlap} ${split} ${nonamecheck} ${sorted} ${bed} ${header} "
AFILEU="${a_file}"
BFILEU=`echo ${b_file} | sed -e 's/ /, /g'`
GENOMEU="${genome}"
INPUTSU="${AFILEU}, ${BFILEU}, ${GENOMEU}"
echo "A file is " "${AFILEU}"
echo "B file is " "${BFILEU}"
echo "arguments are "${ARGSU}
echo "inputs are "${INPUTSU}

INDEXU="${index}"
FASTA_INDEXU="${fasta_index}"
IN_NAMEU="${in_name}"
H5DUMPU="${h5dump}"
SINGLEU="${single}"
FRAG_LENU="${frag_len}"
SDU="${sd}"
#echo ${output}


if [ -n "${r_overlap}" ]
  then
    if [ -z "${a_overlap}" ]
      then
        >&2 echo "-r must be used with -f"
        debug
        exit 1;
    fi
fi

if [ -n "${e_overlap}" ]
  then
    if [ -z "${a_overlap}" ]
      then
        >&2 echo "-r must be used with -f"
        debug
        exit 1;
    fi
fi

CMDLINEARG=""
CMDLINEARG+="coveragebed ${ARGSU} ${GENOMEU} ${AFILEU} ${BFILEU}"
echo ${CMDLINEARG};
chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/bedtools:v2.25.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
#echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/apps/bedtools/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit -batch-name ${PWD##*/} lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

debug

exit 0
