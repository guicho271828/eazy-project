#!/bin/bash

sbcl=sbcl
ccl=ccl

$sbcl --eval "(progn (ql:quickload :eazy-project.test)(ql:quickload :eazy-project)(quit))"
$ccl --eval "(progn (ql:quickload :eazy-project.test)(ql:quickload :eazy-project)(quit))"
