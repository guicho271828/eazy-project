#!/bin/bash

sbcl=sbcl
ccl=ccl

$sbcl --eval "(progn (ql:quickload :eazy-project.test)(quit))"
$ccl --eval "(progn (ql:quickload :eazy-project.test)(quit))"
