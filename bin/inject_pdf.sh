#!/usr/bin/env bash

sed -i 's#^plugins:#plugins:\n  - with-pdf:\n      output_path: .\/pdf\/lpic2book.pdf#' mkdocs.yml 

cat mkdocs.yml
