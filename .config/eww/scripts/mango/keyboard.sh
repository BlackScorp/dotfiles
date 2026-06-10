#!/bin/sh

mmsg get keyboardlayout | jq -r '.layout'