set -xe
. ./env
pd="`dirname "$(realpath "$0")"`"

function Get_eV(){
    printf "%-60s" "$1 E(SCF) of '$2.log'"
    if [ -f "$2.log" ] && grep -q "Normal termination of Gaussian" "$2.log"; then
        echo `python "$pd/tools/log2scfenergy.py" "$2.log" | tail -n 1 | awk '{print $2}'` "eV"
    else
        echo "[Incompleted log file / file not exist]"
    fi
}

set +xe
echo -e "\n\n==================================== DATA ====================================\n"
Get_eV "E^(N)_N" "$eorg_NEUSP"
Get_eV "E^(C)_N" "$eorg_NEU_CHRSP"
Get_eV "E^(C)_C" "$eorg_CHRSP"
Get_eV "E^(N)_C" "$eorg_CHR_NEUSP"
echo -e "\n==============================================================================\n"