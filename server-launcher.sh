#!/bin/bash

echo<<EOF
Please launch loapeat on sub-server for launch swank server at port 4005
EOF

ssh -L 4005:localhost:4005 aburatani

