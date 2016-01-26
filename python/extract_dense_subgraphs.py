#!/usr/bin/env python

"""Extract subgraphs from a given Weighted Directed graph.
Following the alorithm in below paper:
Gunnemann, Stephan, and Thomas Seidl. 
'Subgraph mining on directed and weighted graphs.'
Advances in Knowledge Discovery and Data Mining. Springer Berlin Heidelberg, 2010. 133-146.

Shuchu Han (shuchu.han@gmail.com)
Thu Jan 21 22:16:16 EST 2016
"""

import sys
import argparse
import math
import networkx as nx


def graph_info(G):
  print 'Graph info:'
  print 'Number of nodes: %d' % G.number_of_nodes()
  print 'Number of edges: %d' % G.number_of_edges()
  #print 'Connexted components: %d' % nx.connected_components(self)

def load_graph(G,nfname,efname):
  print 'loading nodes...' + nfname
  # load nodes from .CSV file
  with open(nfname,'r') as f:
    # skip the first line 
    next(f)
    for l in f:
      G.add_node(int(l.strip()),density=0.0,core=False)

  print 'loading edges...' + efname
  # load edges from .CSV file
  with open(efname,'r') as f:
    next(f)
    for line in f:
      t = line.strip().split(',')
      G.add_edge(int(t[0]),int(t[1]),weight=float(t[2]))

""" change the distance into similarity """
def reverse_weight(G):
  for e in G.edges_iter(data=True):
    if abs(e[2]['weight']-0.00001) < 0.00001:
      e[2]['weight'] = 100000;
    else:
      e[2]['weight'] = 1.0/e[2]['weight']
  ##debug
  #print G.edges(data='weight')

""" calculate influence """
def calc_influence(DiG,cf):
  sp = nx.all_pairs_dijkstra_path_length(DiG,cf)
  for key in sp:
    d = sp[key]
    for idx in d:
      # add influence to expect node
      dd = d[idx]/cf
      G.node[idx]['density'] += (1.0-dd*dd)*3/4 

def find_core_nodes(G,th):
  for nd in G.nodes_iter(data=True):
    if nd[1]['density'] >= th:
      nd[1]['core'] = True
    
    print nd
    





# ----------- Test ------------
def test(G):
  graph_info(G)
  #print G.nodes(data=True)
  #print G.edges(data=True)
  reverse_weight(G)
  calc_influence(G,10)
  find_core_nodes(G,3)

if __name__ == '__main__':
  if len(sys.argv) != 3:
    print 'Error, wrong number of input parameters!'
    print 'Usage: python extract_dense_subgraph.py  [nodes.csv] [edges.csv]'
    sys.exit(0) 

  # parse arguments
  arg_names = ['command','nfname','efname']
  args = dict(zip(arg_names,sys.argv))

  # load data
  G = nx.DiGraph()
  load_graph(G,args['nfname'],args['efname'])
 
  test(G)

