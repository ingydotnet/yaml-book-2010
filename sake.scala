import sake.Project._

// If true, don't actually run any commands.
environment.dryRun = false

// If true, show stack traces when a failure happens (doesn't affect "errors").
showStackTracesOnFailures = false

// Logging level: Info, Notice, Warn, Error, Failure
log.threshold = Level.Info

target('all -> List('book, 'code_examples))

target('book -> List('clean, 'add_ids, 'docbook, 'xmllint))

target('clean -> 'tmpclean) {
    delete("book.fo" :: "book.xml" :: files("dist/book.*"))
}

target('tmpclean) {
    deleteRecursively("tmp")
}

target('add_ids) {
    sh("bin/add-ids")
}

target('docbook -> 'before) {
    sh("asciidoc -f etc/asciidoc.conf -f etc/docbook.conf --unsafe -d book -a icons -b docbook -o dist/book.xml book.asc")
}

target('html -> 'before) {
    sh("""asciidoc -f etc/html4.conf -f etc/asciidoc.conf --unsafe -d book -a toc -a numbered -a icons -a toclevels=3 
       -o dist/book.html book.asc""")
}

// See section 28.1 of the Asciidoc.pdf manual.
// WARNING: generates lots of warnings and errors, but it appears to work okay.
// It would be nice to fix those problems. Do they indicate issues we'll have with the
// real production workstream?
target('pdf -> 'before) {
        shell('command -> "bin/a2x",
              'opts -> List("--format=pdf", "--fop-opts=",
                        "--asciidoc-opts=-f etc/asciidoc.conf -f etc/docbook.conf -a toc -a numbered --unsafe -d book -a icons -b docbook",
                        "--doctype=book", "--icons", "--verbose", "-D", "dist", "book.asc"))
}

target('xmllint) {
    sh("bin/docbook-postproc.rb --in dist/book.xml --out book.xml")
    sh("xmllint --postvalid --xinclude --noout book.xml")
}

target('before -> List('dist, 'process_code_examples)) {
    mkdir("dist")
}

target('dist) {
    mkdir("dist")
}

target('process_code_examples) {
    // Adds or changes the first line of Scala, Java, and AspectJ files to have a comment
    // with the file's path, so it shows up in the source listing.
    sh("bin/inject-code-file-names.rb")
}

target('code_examples) {
    sakecmd('directory -> "chapters", 'targets -> "all")
}

def asc_list = {
    files("book.asc", "preface.asc", "[A-Z]*.asc", "appendix*.asc", "glossary.asc", "references.asc")
}

// Generate a rough text outline from the *.asc files.
target('outline) {
    shell('command -> "grep", 'outputFile -> "outline.txt",
          'opts -> ("""== [0-9A-Z+_"]""" :: asc_list))
}

target('add_ids_exper) {
    sh("bin/add-ids tmp.asc")
    sh("asciidoc -f etc/asciidoc.conf -f etc/docbook.conf --unsafe -d book -a icons -b docbook -o dist/tmp.xml tmp.asc")
    sh("bin/docbook-postproc.rb tmp.xml")
    sh("xmllint --postvalid --xinclude --noout tmp.xml")
}