#!/bin/bash
docker build -t latex-template . && docker run -v ${PWD}:/project latex-template
