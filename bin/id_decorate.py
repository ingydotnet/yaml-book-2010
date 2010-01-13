#!/usr/bin/env python
# encoding: utf-8
"""
id_decorate.py

Created by Keith Fahlgren on Tue Mar  3 06:36:58 PST 2009
Copyright (c) 2009 O'Reilly Media. All rights reserved.

Note: 
  * XIncluded files that refine the selection with XPointer will have @ids
    added to all of the file, not just the referenced section.
  * This adds a DocBook 4.4 DOCTYPE to every file
"""

import logging
import os.path
import sys

from lxml import etree

log = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

BLOCKISH = [
    'abstract',
    'address',
    'appendix',
    'article',
    'authorblurb',
    'bibliography',
    'biblioentry',
    'bibliolist',
    'blockquote',
    'bridgehead',
    'callout',
    'calloutlist',
    'chapter',
    'classsynopsis',
    'cmdsynopsis',
    'colophon',
    'constraintdef',
    'constructorsynopsis',
    'dedication',
    'destructorsynopsis',
    'epigraph',
    'equation',
    'example',
    'fieldsynopsis',
    'figure',
    'formalpara',
    'funcsynopsis',
    'glossary',
    'glossentry',
    'glosslist',
    'highlights',
    'important',
    'index',
    'informalequation',
    'informalexample',
    'informalfigure',
    'informaltable',
    'itemizedlist',
    'listitem',
    'literallayout',
    'lot',
    'member',
    'methodsynopsis',
    'msgset',
    'orderedlist',
    'para',
    'part',
    'preface',
    'procedure',
    'productionset',
    'programlisting',
    'programlistingco',
    'qandaset',
    'refentry',
    'reference',
    'refsect1',
    'refsect2',
    'refsect3',
    'refsection',
    'remark',
    'screen',
    'screenco',
    'screenshot',
    'sect1',
    'sect2',
    'sect3',
    'sect4',
    'sect5',
    'section',
    'seglistitem',
    'segmentedlist',
    'setindex',
    'sidebar',
    'simpara',
    'simplelist',
    'simplesect',
    'synopsis',
    'table',
    'task',
    'toc',
    'variablelist',
    'varlistentry',
]


blockish_xpath_str = "[not(@id)]|".join(BLOCKISH) + '[not(@id)]'

xslt_tree = etree.XML('''<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" 
              encoding="UTF-8"
              doctype-public="-//OASIS//DTD DocBook XML V4.4//EN"
              doctype-system="http://www.oasis-open.org/docbook/xml/4.4/docbookx.dtd"/>
  <xsl:param name="filename">x</xsl:param>
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="%s">
    <xsl:copy>
      <xsl:attribute name="id">
        <xsl:value-of select="$filename"/>              
        <xsl:text>_</xsl:text>
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
''' % (blockish_xpath_str))

find_xincludes_not_for_text = etree.XPath("//xi:include[not(@parse = 'text')]", namespaces={'xi': "http://www.w3.org/2001/XInclude"})
parser = etree.XMLParser(load_dtd=True)

def decorate(filename):
    log.info("Adding @ids to '%s'" % filename)
    # Do _not_ call xinclude()
    try:
        doc = etree.parse(filename, parser) 
    except etree.XMLSyntaxError, e: 
        # No DOCTYPE, bummer
        doc = etree.parse(filename)

    base, _ = os.path.splitext(os.path.basename(filename))
    result = doc.xslt(xslt_tree, filename="'%s'" % base)
    # We're done with this file, move on to the next
    f = open(filename, "w")
    result.write(f)
    f.close()

    log.info("Locating XIncludes in %s" % filename)
    for xinclude in find_xincludes_not_for_text(doc):
        referenced_filename = xinclude.get('href')
        decorate(referenced_filename)

def main():
    if len(sys.argv) == 1:
        sys.exit("Usage: id_decorate <book.xml>")
    for filename in sys.argv[1:]:
        decorate(filename)

if __name__ == "__main__":
    main()

