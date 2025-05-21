#!/bin/bash
cd "$(dirname $0)"
../bin/qbsolv -i factoring.qubo -m -T 21 -v1 -a d -t 10
