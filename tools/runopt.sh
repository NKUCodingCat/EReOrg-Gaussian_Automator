# bash runsp.sh "g09" "xxx.gjf" "<opt name>" $4 FOOTER
set -xe
COMMAND="$1"
fullfile="$(realpath "$2")"
filename="${fullfile%.*}"
Log="$filename".log
bckLog="$Log".bck
FINEOPT="$3"
FOOTER="$4"
LIMIT="$5"
Counter=0
pd="`dirname "$(realpath "$0")"`"

ISRETRYINGFLAG="FALSE"

"$COMMAND" "$fullfile"

while [ $Counter -lt $LIMIT ]; do
    if [ -f "$Log" ] && grep -q "Normal termination of Gaussian" "$Log"; then
        if [ "TRUE" == `python "$pd/checkopt.py" "$Log"` ]; then
            # Success status
            exit 0
        else
            if [ "TRUE" != $ISRETRYINGFLAG ]; then
                ISRETRYINGFLAG="TRUE"
                cp "$Log" "$bckLog"
                # generate coords
                INDEX="`python "$pd/log2scfenergy.py" "$bckLog" | python "$pd/selectidx.py"`"
                LEN=`echo "$INDEX"   | python -c "import json,sys; print(len(json.loads(sys.stdin.read())))"`
                (>&2 echo -e "\n\n >> [INFO] There are $LEN candidates to retry << \n\n")
            fi
        fi

    else
        if [ "TRUE" != $ISRETRYINGFLAG ]; then
            (>&2 echo -e "\n\n >> [ERROR] GAUSSIAN IS TERMINATED ABNORMALLY. << \n\n")
            exit 1
        fi
    fi

    # Replace coord
    LEN=`echo "$INDEX"   | python -c "import json,sys; print(len(json.loads(sys.stdin.read())))"`
    if [ $LEN -le 0 ]; then
        (>&2 echo -e "\n\n >> [ERROR] NO MORE CANDIATES TO RETRY << \n\n")
        exit 1
    fi
    NEXT=`echo "$INDEX"  | python -c "import json,sys; print(json.loads(sys.stdin.read())[0])"`
    INDEX=`echo "$INDEX" | python -c "import json,sys; print(json.dumps(json.loads(sys.stdin.read())[1:]))"`
    coord="$( python "$pd/log2xyz.py" "$bckLog" -n $NEXT | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' )"

    mv "$fullfile" "${fullfile}-bck-${Counter}"
    mv "$Log"      "${Log}-bck-${Counter}"
    
    (>&2 echo -e "\n\n >> [INFO] RETRYING $(($Counter+1)) / $LIMIT - Using #$NEXT structure... << \n\n")
    cat "./$FINEOPT.tpl.txt" | sed "s/<TITLE>/${FINEOPT}/" | sed "s/<Coords>/${coord}/" | sed "s/<FOOTER>/${FOOTER}/" > "${fullfile}"
    "$COMMAND" "$fullfile"
	Counter=$(($Counter+1))
done
(>&2 echo -e "\n\n >> [INFO] UNABLE TO FIND AVAILABLE STRUCTURE w/o NEGATIVE FREQ. << \n\n")
exit 1