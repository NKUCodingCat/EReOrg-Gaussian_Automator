set -x
python -c "import cclib, jsonschema, sys; assert (sys.version_info.major == 2 and sys.version_info.minor==7); print '\\n\\n    >>>> Python Check Passed! <<<<\\n\\n'"
if [[ $? != 0 ]]; then
    set +xe
    echo -e "\n\n================= ERROR ================= \n"
    echo -e "  PLEASE check if: "
    echo    "     \`python\` is python 2.7.x, NOW is ` ( command -v python3 &>/dev/null || echo '[Python NOT FOUND]' ) && ( python -V 2>&1 )`"
    echo    "      cclib & jsonschema had been installed"
    echo -e "\n=========================================\n\n"
    exit 1
fi
set -xe

pd="`dirname "$(realpath "$0")"`"
# bash runsp.sh "g09" "xxx.gjf"
# Usage: bash EReOrgInit.sh xxx.gjf
fullfile="$(realpath "$1")"
filename="${fullfile%.*}"
if [ -d "$filename.EOrg/" ]; then
    set +xe
    echo -e "\n\n================= ERROR ================= \n"
    echo "'$filename.EOrg/' had been existed"; echo ""
    echo "**DELETE** this directory then re-run *IF YOU WANT*"
    echo -e "\n=========================================\n\n"
    exit 1
fi

mkdir -p "$filename.EOrg/"
cp "$fullfile" "$filename.EOrg/"
python -c "import json, sys; d = json.load(open(sys.argv[1]));\
 d['GAUSSIAN']['STARTGJF'] = sys.argv[2]; d['GAUSSIAN']['TITLE'] = sys.argv[3]; \
 print json.dumps(d, indent=4, sort_keys=True)" \
"$pd/sample-config.json" "$fullfile" "`basename "$filename"`"  >  "$filename.EOrg/config.json"

set +xe
echo -e "\n\n================= SUCCESS ================= \n"
echo "INIT DONE! please do following command:"; echo ""
echo "    # if you want to edit config, run 'nano $filename.EOrg/config.json'"; echo ""
echo "    cd '$filename.EOrg/'"
echo "    bash '$pd/EReOrgRun.sh'"; echo ""; echo ""
echo "    # After run EReOrgRun.sh, please run following Command to get result"; echo ""
echo "    bash '$pd/EReOrgFinal.sh'"
echo -e "\n===========================================\n\n"