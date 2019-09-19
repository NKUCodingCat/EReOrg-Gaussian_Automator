# generate filenames, export to env
# parse gjf and add header & footer in template
# extract geom into GLOBAL

# Copied from https://github.com/jaimergp/easymecp/blob/master/easymecp/easymecp.py
# Modified 
import base64, jsonschema
def gaussian_input_file_splitter(path):
    d = {}
    section = 0
    header, geom, footer = [], None, []
    # Parse Gaussian input files into header(s), geometry and footer
    with open(path) as f:
        for line in f:
            # Detect sections
            if not line.strip():
                section += 1

            # Assign lines to sections
            # <HEADER>
            if section <= 1:
                header.append(line)
            elif section == 2:
                if not line.strip():
                    header.append(line)
                elif geom is None:
                    header.append(line)
                    geom = []
            # </HEADER>
            # <GEOM>
                else:
                    # Everything above is part of the header
                    geom.append(line)
            # </GEOM>
            # <FOOTER>
            elif section >= 3:
                footer.append(line)
            #</FOOTER>

    return tuple(map(base64.b64encode, [''.join(header), ''.join(geom), ''.join(footer)]))

def gen_tpl(cpu, mem, comment, chr_and_mul):
    return "%%NProcShared=%d\n%%chk=<TITLE>.chk\n%%MEM=%s\n%s\n\n<TITLE>\n\n%s\n<Coords>\n<FOOTER>\n"%\
            (             cpu,                          mem, comment,       chr_and_mul )

schema = {
    "type": "object",
    "properties": {
        "POLICY":{
            "type": "object",
            "properties": {
                "FAILED_FINE_OPT_RETRY": {"type": "integer"},
            },
            "required": ["FAILED_FINE_OPT_RETRY", ],
            "additionalProperties": False
        },
        "GAUSSIAN":{
            "type": "object",
            "properties": {
                "COMMAND": {"type": "string"},
                "TITLE":   {"type": "string"},
                "STARTGJF":{"type": "string"},
                "CPUS":    {"type": "integer"},
                "MEM":     {"type": "string"},
                "COMMENTS":{
                    "type": "object",
                    "properties": {
                        "SP":      {"type": "string"},
                        "OPT":     {"type": "string"},
                        "FINE_OPT":{"type": "string"},
                    },
                    "required": ["SP", "OPT", "FINE_OPT"],
                    "additionalProperties": False
                },
                "CHARGE_AND_MULTIPLICITY":{
                    "type": "object",
                    "properties": {
                        "NEURAL":  {"type": "string"},
                        "CHARGED": {"type": "string"},
                    },
                    "required": ["CHARGED", "NEURAL"],
                    "additionalProperties": False
                }
            },
            "required": ["COMMAND", "TITLE", "STARTGJF", "CPUS", "MEM", "COMMENTS", "CHARGE_AND_MULTIPLICITY"],
            "additionalProperties": False
        },
    },
    "required": ["POLICY", "GAUSSIAN"],
    "additionalProperties": False
}
# ===============================================================

import json, argparse, os
parser = argparse.ArgumentParser(description="Process log file")
parser.add_argument("cfg_json", type=file); args = parser.parse_args()

ROOT = os.path.split(os.path.realpath(__file__))[0]

D = json.load( args.cfg_json )
# Some **jsonschema** here
jsonschema.validate(D, schema = schema)

GAU = D['GAUSSIAN']
cpu, mem, comment, chr_and_mul, TITLE = GAU['CPUS'], GAU['MEM'], GAU['COMMENTS'], GAU['CHARGE_AND_MULTIPLICITY'], GAU["TITLE"]
_, geom, footer = gaussian_input_file_splitter(GAU["STARTGJF"])

envs = [
    ("eorg_NEU",       "%s-neu.opt"%TITLE,      gen_tpl(cpu, mem, comment['OPT'],      chr_and_mul['NEURAL'])),
    ("eorg_NEUFINE",   "%s-neu.opt.fine"%TITLE, gen_tpl(cpu, mem, comment['FINE_OPT'], chr_and_mul['NEURAL'])),
    ("eorg_CHR",       "%s-chr.opt"%TITLE,      gen_tpl(cpu, mem, comment['OPT'],      chr_and_mul['CHARGED'])),
    ("eorg_CHRFINE",   "%s-chr.opt.fine"%TITLE, gen_tpl(cpu, mem, comment['FINE_OPT'], chr_and_mul['CHARGED'])),
    ("eorg_NEUSP",     "%s-neu.sp"%TITLE,       gen_tpl(cpu, mem, comment['SP'],       chr_and_mul['NEURAL'])),
    ("eorg_CHRSP",     "%s-chr.sp"%TITLE,       gen_tpl(cpu, mem, comment['SP'],       chr_and_mul['CHARGED'])),
    ("eorg_CHR_NEUSP", "%s-chr.neu.sp"%TITLE,   gen_tpl(cpu, mem, comment['SP'],       chr_and_mul['NEURAL'])),
    ("eorg_NEU_CHRSP", "%s-neu.chr.sp"%TITLE,   gen_tpl(cpu, mem, comment['SP'],       chr_and_mul['CHARGED'])),
]

for env, f, tpl in envs:
    os.environ[env] = f
    with open("%s.tpl.txt"%f, "w") as f:
        f.write(tpl)

os.environ['eorg_COMMAND'] = GAU['COMMAND']
os.environ['eorg_FINEOPTRETRY'] = str(D['POLICY']['FAILED_FINE_OPT_RETRY'])
os.environ['eorg_coordINIT'] = ''.join(geom)
os.environ['eorg_FOOTER'] = ''.join(footer)

os.system(". '%s/env.sh' --source-only; cat /dev/null > ./env; env_save ./env"%ROOT)