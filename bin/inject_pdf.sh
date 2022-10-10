#!/usr/bin/env bash

# Wrapperscript to correctly replace yaml
# can't do this from within the github actions as
# it's interpreted as yaml
sed -i 's#^plugins:#plugins:\n  - with-pdf:\n      output_path: .\/pdf\/lpic2book.pdf#' mkdocs.yml 
