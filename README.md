# EReOrg-Gaussian_Automator
 
## Requirement
```
    Linux & python 2.7.x (MacOS? damn it)
    jsonschema
    cclib
```

## Setup
```
python -m pip install -r requirement.txt --user -i https://pypi.tuna.tsinghua.edu.cn/simple --trust-host pypi.tuna.tsinghua.edu.cn
```
***(If you are not in china, delete -i and following things)***

IF your python *DO NOT* have `pip`, just run:
```
curl https://bootstrap.pypa.io/get-pip.py | python - --user -i https://pypi.tuna.tsinghua.edu.cn/simple --trust-host pypi.tuna.tsinghua.edu.cn
```
before you run `python -m pip install ...`

***(If you are not in china, delete -i and following things)***

We are planning to upgrade python from 2.x to 3.x, but `get-pip.py` might be buggy when using 3.6 or somewhat upper ([pypa/get-pip#43](https://github.com/pypa/get-pip/issues/43), [pypa/get-pip#44](https://github.com/pypa/get-pip/issues/44))

## Usage

Assuming that you have had a gjf file. To init job, you should run:
```
bash EReOrgInit.sh aaa.gjf
```

If everything goes right, you will get:
```
================= SUCCESS =================

INIT DONE! please do following command:

    # if you want to edit config, run 'nano <Some Dir>/config.json'

    cd '<Some Dir>/'
    bash '</some/other/path..>/EReOrgRun.sh'


    # After run EReOrgRun.sh, please run following Command to get result

    bash '</some/other/path..>/EReOrgFinal.sh'

===========================================
```

Then you should follow the guide, modify json if you need, then run 
```
# just copy from outputs
    cd '<Some Dir>/'
    bash '</some/other/path..>/EReOrgRun.sh'
```
***You need to gurantee that the value of `COMMAND` entry in config.json is point to some gaussian executable(e.g. g09, g16...)***

then if nothing goes wrong, you will have...
```
================= COMPLETED ================= 

    Everything's done, please run followiing command for info

        bash '</some/other/path..>/EReOrgFinal.sh'

=========================================
```

Run the command and ...
```
==================================== DATA ====================================

E^(N)_N E(SCF) of '<xxx>-neu.sp.log'                        -3738.77835114 eV
E^(C)_N E(SCF) of '<xxx>-neu.chr.sp.log'                    -3738.57519919 eV
E^(C)_C E(SCF) of '<xxx>-chr.sp.log'                        -3738.58002815 eV
E^(N)_C E(SCF) of '<xxx>-chr.neu.sp.log'                    -3738.77269343 eV

==============================================================================
```

HOORAY!