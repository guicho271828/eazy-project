#!/bin/bash

sbcl=sbcl
ccl=ccl

testmain (){
    for cl in $sbcl $ccl
    do
        $cl --load testscr.lisp
    done
}

testmain 2> err.log | tee out.log
awk '/Fail: 0 /{c++;} END{print c; if (c!=2){ exit 1 }}' out.log

