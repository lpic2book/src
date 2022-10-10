#!/bin/bash
# https://github.com/lpic2book/src/issues/30
cd docs &&
pandoc --pdf-engine=xelatex \
  -V lang="en-us" -V babel-lang=english \
  -V 'mainfont:DejaVuSerif.ttf' \
         -V 'sansfont:DejaVuSans.ttf' \
         -V 'monofont:DejaVuSansMono.ttf' \
         -V 'mathfont:texgyredejavu-math.otf' \
         --include-before-body cover.tex \
         --toc -s *.md   -t pdf -o  ../dist/lpic2.pdf
