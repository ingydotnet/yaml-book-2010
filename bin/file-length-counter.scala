// Script that measure line lengths and if any lines are greater
// than 80, prints the length, line number, file name, and the line itself.
// usage:
//   scala file-length-counter.scala list_of_files
//
// Adapted from code-examples/AppDesign/options-nulls/file-printer-refactored-script.scala 

import java.io._

class ScalaIOException(cause: Throwable) extends RuntimeException(cause)

class ScalaBufferedReader(in: Reader) extends BufferedReader(in) {
    def inputLine() = readLine() match {
        case null => None
        case line => Some(line)
    }
}

object ScalaBufferedReader {
    def apply(file: File) = try {
         new ScalaBufferedReader(new FileReader(file))
    } catch {
        case ex: IOException => throw new ScalaIOException(ex)
    }
}

class FileLineCounter(val file: File) {

    def print() = {
        format("length: line#: file: line:\n")
        loop(1, ScalaBufferedReader(file))
    }
    
    private def loop(lineNumber: Int, reader: ScalaBufferedReader): Unit = {
        reader.inputLine() match {
            case None => 
            case Some(line) => {
                if (line.length > 80) {
                    format("%6d: %5d: %s: <%s>\n", 
                        line.length, lineNumber, file.getName, line)
                }
                loop(lineNumber+1, reader)
            }
        }
    }
}

// Process the command-line arguments (file names):
args.foreach { fileName =>
    new FileLineCounter(new File(fileName)).print();
}