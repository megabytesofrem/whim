#!/bin/sh

Xephyr -br -ac -noreset -softCursor -screen 800x600 :1 &
DISPLAY=:1 nimble run