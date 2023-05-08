import networkx as nx
from networkx.drawing.nx_agraph import read_dot

# read the dot file as a networkx DiGraph object
G = read_dot('amboso.dot')

# set the source and destination nodes
node1 = 'BEGIN'
node2 = 'END'

# find all simple paths between node1 and node2
paths = list(nx.all_simple_paths(G, source=node1, target=node2))

# print the paths
for path in paths:
    print(' -> '.join(path))

