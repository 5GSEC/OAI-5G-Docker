#!/bin/bash

colosseumcli rf stop

if [ "$1" == "nr78" ]; then
	colosseumcli rf start 10011 -c
else
	colosseumcli rf start $1 -c
fi
