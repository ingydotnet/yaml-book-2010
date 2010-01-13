#! /usr/bin/env ruby
# Ensures that each Scala example source file starts with its file name so it
# is visible when the code is included in the book.
# usage:
#   bin/inject-code-file-names.rb 

require 'find'
require 'FileUtils'

$verbose = false

def backup_file src, dest
  FileUtils.mkdir_p File.dirname(dest)
  FileUtils.cp_r src, dest
end

def make_new_file backup, target
  lines = File.open(backup, 'r').readlines
  File.open(target, 'w') do |fout|
    fout.write "// #{target}\n"
    if lines[0].match /\/\/\s*code-examples.*/
      lines.shift
    end
    lines.each {|line| fout.write line}
  end
end

def process_file path
  puts ("Processing file: #{path}") if $verbose
  saved = "../tmp/" + path
  backup_file path, saved
  make_new_file saved, path
end

FileUtils.cd "chapters"
Find.find("code-examples") do |path|
  if FileTest.directory?(path)
    if File.basename(path)[0] == ?.
      Find.prune       # Don't look any further into this directory.
    else
      next
    end
  else
    case File.extname(path)
    when ".scala", ".java", ".aj" then process_file(path)
    else puts "Ignoring #{path}" if $verbose
    end
  end
end
