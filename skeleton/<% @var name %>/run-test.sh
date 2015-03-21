#!/bin/bash

cl --eval '(progn (ql:quickload :<% @var test %>)(load "testscr.lisp"))'
