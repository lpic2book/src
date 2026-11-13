# funny convention in this file: suffixes are added to filename, not replacing suffix of source.
# so if source is a.dot, then products are a.dot.svg and a.dot.svg.png

# some browsers are buggy while displaying svg-files without a background. 
# White is understood then. This looks silly. Also convert must be told 
# explicitely that the svg is transparent.

%.dot.svg: %.dot
	dot -Tsvg $(<) -O 

%.pdf: %.dot.svg
	inkscape -z -D --export-pdf=$(@) $(<) 

%.dot.svg.png: %.dot.svg
	convert -transparent white $(<) $(@)

all: all-png all-svg all-pdf

dotfiles:=204-LVM.dot 205-7.dot 205-network.dot 205-vpnhops.dot 207-exwrks.dot 208-apachessl.dot 208-pubkey.dot 209-ourgroup.dot 210-dhcp.dot 210-megafix.dot 212-HOOKS.dot 212-IPCHAINS.dot 212-IPTABLES.dot 212-IPTFW.dot 212-NAT.dot 212-DNAT.dot 212-DNAT2.dot 212-SSHPFW.dot 213-linker1.dot 213-linker2.dot 213-linker3.dot 213-linker4.dot 213-partitiontable.dot

svgfiles=$(dotfiles:.dot=.dot.svg)
pdffiles=$(dotfiles:.dot=.pdf)
pngfiles=$(dotfiles:.dot=.dot.svg.png)

all-svg: $(svgfiles)

all-png: $(pngfiles) 

all-pdf: $(svgfilesforpdf) $(pdffiles)

clean:
	rm -f $(pngfiles) $(svgfiles)

help:
	echo "$(pngfiles)"
	echo "Converts .dot files to svg and converts svg to png. Depends on: dot (graphviz) and convert (imagemagick). Segmentation Faults for convert are expected on CentOS, although images are converted."
