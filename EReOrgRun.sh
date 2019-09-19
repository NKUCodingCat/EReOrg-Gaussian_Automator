set -xe
pd="`dirname "$(realpath "$0")"`"

python "$pd/tools/configProc.py" ./config.json; . ./env

function runopt(){
    # $1 title $2 coord $3 fine Opt title $4 FOOTER
    coord="`echo $2 | base64 --decode | sed -e ':a;N;$!ba;s/\n/\\\\n/g' `"
    foot="`echo $4 | base64 --decode | sed -e ':a;N;$!ba;s/\n/\\\\n/g' `"
    cat "./$1.tpl.txt" | sed "s/<TITLE>/${1}/" | sed "s/<Coords>/${coord}/" | sed "s/<FOOTER>/${foot}/" > "./$1.gjf"
    bash "$pd/tools/runopt.sh" "$eorg_COMMAND" "./$1.gjf" "$3" "$foot" "$eorg_FINEOPTRETRY"
    if [[ $? != 0 ]]; then 
        set +xe
        echo -e "\n\n================= ERROR ================= \n"
        echo "Unable to run opt on $1.gjf"; echo ""
        echo "Please check $1.log to find problem"; echo ""
        echo "        WILL EXITED         "
        echo -e "\n=========================================\n\n"
        exit 1
    fi
    echo "`python "$pd/tools/log2xyz.py" "$1.log" | base64 -w 0 `"
}
coordNEU="`runopt "$eorg_NEU" "$eorg_coordINIT" "$eorg_NEUFINE" "$eorg_FOOTER" `"
coordCHR="`runopt "$eorg_CHR" "$coordNEU"       "$eorg_CHRFINE" "$eorg_FOOTER" `"

function runsp(){
    # $1 是title, $2 是 coord
    coord="`echo $2 | base64 --decode | sed -e ':a;N;$!ba;s/\n/\\\\n/g' `"
    foot="`echo $3 | base64 --decode | sed -e ':a;N;$!ba;s/\n/\\\\n/g' `"
    cat "./$1.tpl.txt" | sed "s/<TITLE>/${1}/" | sed "s/<Coords>/${coord}/" | sed "s/<FOOTER>/${foot}/" > "./$1.gjf"
    bash "$pd/tools/runsp.sh" "$eorg_COMMAND" "./$1.gjf"
    if [[ $? != 0 ]]; then 
        set +xe
        echo -e "\n\n================= ERROR ================= \n"
        echo "Unable to run sp on $1.gjf"; echo ""
        echo "Please check $1.log to find problem"; echo ""
        echo "This Program **will** continue run sp on other gjf"
        echo "But please do not forget to check this "
        echo -e "\n=========================================\n\n"
    fi
}

runsp "$eorg_NEUSP"     "$coordNEU" "$eorg_FOOTER"
runsp "$eorg_NEU_CHRSP" "$coordNEU" "$eorg_FOOTER"
runsp "$eorg_CHRSP"     "$coordCHR" "$eorg_FOOTER"
runsp "$eorg_CHR_NEUSP" "$coordCHR" "$eorg_FOOTER"

set +xe
echo -e "\n\n================= COMPLETED ================= \n"
echo "    Everything's done, please run followiing command for info"; echo ""
echo "        bash \"$pd/EReOrgFinal.sh\""
echo -e "\n=========================================\n\n"