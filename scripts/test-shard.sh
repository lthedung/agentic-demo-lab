#!/bin/sh
set -eu

node_index=${CI_NODE_INDEX:-1}
node_total=${CI_NODE_TOTAL:-1}

echo "== Parallel test shard $node_index/$node_total =="
echo "Running simulated tests assigned to shard $node_index"
echo "Shard $node_index completed"
