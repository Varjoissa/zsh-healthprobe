#!/bin/bash

store=$(cat $path_store 2>/dev/null | grep $name)
if [ -z "$store" ]; then
    echo " $name " >> $path_store
fi