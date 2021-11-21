#!/bin/sh

Xephyr -br -ac -noreset -softCursor -screen 1280x800 :1 &
DISPLAY=:1 nimble run