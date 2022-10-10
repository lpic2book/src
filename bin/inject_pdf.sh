#!/usr/bin/env bash

yq e -i '.plugins += {"with-pdf": {"output_path": "./site/lpic2book.pdf"}}' mkdocs.yaml
