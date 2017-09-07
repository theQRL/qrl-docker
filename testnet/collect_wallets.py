#!/usr/bin/env python
from collections import OrderedDict

sources = [ './volumes/node{}/.qrl/output'.format(i) for i in range(1, 6) ]
wallets = []
for s in sources:
    with open(s) as f:
        wallets.append(f.readline().strip())

wallets = sorted(wallets)
with open('./testnet/genesis.yml', 'w') as f:
    f.write("genesis_info:\n")
    for w in wallets:
        f.write("  {} : {}\n".format(w, 10000))

# determine winner??
