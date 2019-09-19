import cclib, argparse, sys
parser = argparse.ArgumentParser(description="Process log file")
parser.add_argument("Gau_log", nargs=1); args = parser.parse_args(); parser = cclib.io.ccopen(args.Gau_log[0], logstream=sys.stderr); data = parser.parse()

# hatree to ev
print '\n'.join(map(lambda x:'%d\t%.8f'%x, enumerate(data.scfenergies/27.21138505)))