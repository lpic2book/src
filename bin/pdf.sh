#!/bin/bash

cd docs &&
pandoc --pdf-engine=xelatex \
  -V lang="en-us" -V babel-lang=english \
  -V 'mainfont:DejaVuSerif.ttf' \
         -V 'sansfont:DejaVuSans.ttf' \
         -V 'monofont:DejaVuSansMono.ttf' \
         -V 'mathfont:texgyredejavu-math.otf' \
         --include-before-body cover.tex \
--toc -s *.md   -t pdf -o  ../dist/lpic2.pdf && open ../dist/lpic2.pdf
