import sys,json
# input: 
#    0 1111
#    1 22222
#    2 3333
#     ...
# Output:
#    [14, 8, 32, ...] # The idx in input

g = list(map(lambda x: (lambda z: (int(z[0]), float(z[1])))(x.split()), sys.stdin.readlines()))[:-1]
offset = 5

SORTED = []
BANSET = set()
while len(SORTED) < len(g):
    
    while True:
        SELECTABLE = list(set(g) - (set(SORTED)|set(BANSET)))
        if not SELECTABLE:
            break
        MIN = min(SELECTABLE, key=lambda x:x[1])
        SORTED.append(MIN)
        for i in g:
            if abs(i[0] - MIN[0]) <= offset:
                BANSET.add(i)
    BANSET = set()

print(json.dumps(list(map(lambda x: x[0], SORTED))))