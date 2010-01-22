.PHONY: clean

all: book.xml

clean:
	rm -fr book.fo dist tmp

book.xml: dist/book.xml
	bin/docbook-postproc.rb --in $< --out $@
	xmllint --postvalid --xinclude --noout $@
	perl -pi -e 's/\r//' $@

dist/book.xml: dist chapters/*.asc etc/*.conf
	bin/add-ids
	asciidoc \
	    -f etc/asciidoc.conf \
	    -f etc/docbook.conf \
	    --unsafe -d book -a icons -b docbook \
	    -o $@ \
	    book.asc
	perl -pi -e 's/^\[\[.+\]\]\n//' chapters/*.asc

html: dist
	bin/add-ids
	asciidoc -f etc/html4.conf \
	    -f etc/asciidoc.conf \
	    --unsafe -d book -a toc -a numbered -a icons -a toclevels=3 \
	    -o dist/book.html \
	    book.asc
	perl -pi -e 's/^\[\[.+\]\]\n//' chapters/*.asc

# pdf: dist
# 	bin/a2x --format=pdf --fop-opts= --asciidoc-opts= \
# 	    -f etc/asciidoc.conf -f etc/docbook.conf \
# 	    -a toc -a numbered --unsafe -d book -a icons -b docbook \
# 	    --doctype=book --icons --verbose -D dist book.asc

pdf: dist
	bin/a2x --format=pdf --fop-opts= \
	    --asciidoc-opts='-f etc/asciidoc.conf -f etc/docbook.conf \
	    -a toc -a numbered -d book -a icons -b docbook' \
	    --doctype=book --icons --verbose -D dist book.asc

dist:
	mkdir dist

# # Adds or changes the first line of Scala, Java, and AspectJ files to have a comment
# # with the file's path, so it shows up in the source listing.
# process_code_examples:
# 	bin/inject-code-file-names.rb
# 
# code_examples:
# 	make -C chapters all

# def asc_list = {
#     files("book.asc", "preface.asc", "[A-Z]*.asc", "appendix*.asc", "glossary.asc", "references.asc")
# }

# // Generate a rough text outline from the *.asc files.
# target('outline) {
#     shell('command -> "grep", 'outputFile -> "outline.txt",
#           'opts -> ("""== [0-9A-Z+_"]""" :: asc_list))
# }

# target('add_ids_exper) {
#     sh("bin/add-ids tmp.asc")
#     sh("asciidoc -f etc/asciidoc.conf -f etc/docbook.conf --unsafe -d book -a icons -b docbook -o dist/tmp.xml tmp.asc")
#     sh("bin/docbook-postproc.rb tmp.xml")
#     sh("xmllint --postvalid --xinclude --noout tmp.xml")
# }
