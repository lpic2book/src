#!/usr/bin/env bash

sed -i 's#^plugins:#plugins:\n  - with-pdf:\n    output_path: .\/site\/pdf\/lpic2book.pdf#' mkdocs.yml 
