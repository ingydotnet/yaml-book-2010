#! /usr/bin/env ruby
# Hack to postprocess Docbook XML to make it pass xmllint for PDF generation and
# make other changes we want that we (that is I, Dean Wampler...) could not coerce
# Asciidoc to do.
#
# usage:
#   bin/docbook-postproc.rb --in input_book.xml --out output_book.xml \
#        [--keep-lang-attib] [--no-varlistglossentry-ids]
#
# By default, (without any arguments), the script reads the old dist/book.xml 
# and writes the new book.xml to the current working directory, where the 
# O'Reilly tool chain expects to find it. The script also does the following
# transformations, by default:
#  1) Strips substrings 'language="\w+"\s+' attributes from any tags (but should
#     only be <programlisting> tags).
#  2) Adds ids to <varlistentry> tags.
#  3) Adds ids to <glossentry> tags.
#
# The optional command line arguments do the following: 
#  --in input_book.xml    The input Docbook file (default: dist/book.xml)
#  --out output_book.xml  The output Docbook file (default: book.xml)
#  --keep-lang-attib      Don't remove the "language = '...'" attributes from
#                         <programlisting> tags.
#  --no-varlistglossentry-ids  Don't add ids to <varlistentry> and <glossentry> tags.
#
# Note: There's some confusion about whether or not the "language" attributes
# in the <programlisting> tags have to be removed. They are necessary for
# syntax highlighting.

def make_id str
  str.strip.downcase.gsub(/\W+/, "-").gsub(/^-+/, '').gsub(/-+$/, '')
end

# defaults:
inbook = "dist/book.xml"
outbook = "book.xml"
strip_lang_attrib    = true
add_varlistglossentry_ids = true

# hack! Replace with a Ruby lib for command-line argument handling. TODO
next_arg_in_book  = false
next_arg_out_book = false
ARGV.each do |arg| 
  if (next_arg_in_book)
    inbook = arg
    next_arg_in_book = false
  elsif (next_arg_out_book)
    outbook = arg
    next_arg_out_book = false
  else
    case arg
    when /-+in/                  then next_arg_in_book  = true
    when /-+out/                 then next_arg_out_book = true
    when /-+keep-lang-attib/     then strip_lang_attrib = false
    when /-+no-varlistglossentry-ids/ then add_varlistglossentry_ids = false
    else puts "Unrecognized option: #{arg}"; exit 1
    end
  end
end
puts "Input Docbook file:  #{inbook}"
puts "Output Docbook file: #{outbook}"
puts "Strip language attributes in <programminglisting> tags? #{strip_lang_attrib}"
puts "Add ids to <varlistentry> and <glossentry> tags? #{add_varlistglossentry_ids}"

File.open("#{inbook}", 'r') do |fin|
  buffer = ""
  lastid = ""
  File.open("#{outbook}", 'w') do |fout|
    fin.each_line do |line|
      if line.match(/<(varlist|gloss)entry>/) && add_varlistglossentry_ids
        buffer = line
      elsif line.match(/<(gloss)?term>/) && add_varlistglossentry_ids
        buffer += line
      elsif buffer.length > 0
        begin
          buffer += line
          m = line.match(/<([^>]+)>([^<]+)<\/\1>/)
          if m.nil?
            lastid = make_id line
          else
            lastid = make_id m[2]
          end
          fout.write(buffer.gsub(/<((varlist|gloss)entry)/, '<\1 id="\1-'+lastid+'"'))
          buffer = ""
        rescue
          puts "Failed to parse XML for <varlistentry> to insert id:"
          puts "id: #{lastid}"
          puts "current line (#{$.}): #{line}"
          puts "buffer of text: #{buffer}"
          raise
        end
      elsif line.match(/programlisting.*language=/) && strip_lang_attrib
        fout.write(line.gsub(/language="\w+"\s+/, ''))
      else
        fout.write(line)
      end
    end
  end
end
