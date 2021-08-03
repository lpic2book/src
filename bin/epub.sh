#!/bin/bash

cd docs &&
pandoc --toc -s *.md \
--epub-chapter-level=2 \
--epub-cover-image=images/bookcover.png \
--toc-depth=4 \
--css=./style.css --metadata title="The LPIC2 Exam Prep" -t epub -o  ../dist/lpic2.epub
