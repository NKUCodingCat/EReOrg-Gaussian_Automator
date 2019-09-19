# bash runsp.sh "g09" "xxx.gjf"
# optFINE gjf will running in the name of original gjf
set -xe
COMMAND="$1"
fullfile="$(realpath "$2")"
filename="${fullfile%.*}"
Log="$filename".log

"$COMMAND" "$fullfile"

if [ -f "$Log" ] && grep -q "Normal termination of Gaussian" "$Log"; then
    exit 0
else 
    exit 1
fi