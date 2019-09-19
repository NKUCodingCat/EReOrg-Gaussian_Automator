import cclib, argparse, sys; parser = argparse.ArgumentParser(description="Process log file");
parser.add_argument("Gau_log", nargs=1); args = parser.parse_args(); parser = cclib.io.ccopen(args.Gau_log[0], logstream=sys.stderr); data = parser.parse(); 
if hasattr(data, 'vibfreqs') and not filter(lambda x: x<0, data.vibfreqs.tolist()):
    print "TRUE"
else:
    print "FALSE"
