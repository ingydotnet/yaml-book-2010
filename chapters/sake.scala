// chapters/sake.scala
// Used exclusively to build the code examples and jar 'em up.

import sake.Project._

// Define some convenient variables.
val distDir = "../dist/"
val examplesDir = "code-examples"
val examplesZip = "code-examples.zip"

// If true, don't actually run any commands.
environment.dryRun = false

// If true, show stack traces when a failure happens (doesn't affect some "errors").
showStackTracesOnFailures = false

// Logging level: Info, Notice, Warn, Error, Failure
log.threshold = Level.Info

target('all -> 'build, 'zip)

target('build) {
    sakecmd('directory -> examplesDir, 'targets -> 'all)
}

target('zip -> 'remove_zip) {
    val allFiles = files(examplesDir + "/**/*")
    val buildFiles = files(examplesDir + "/**/build/**/*") ++ files(examplesDir + "/**/build")
    val svnFiles = files(examplesDir + "/**/.svn/**/*") ++ files(examplesDir + "/**/.svn")
    val zipContents = (allFiles -- buildFiles -- svnFiles).filter(x => ! files.isDirectory(x)).reduceLeft(_ + " " + _)
    sh("zip " + examplesZip + " " + zipContents)
    sh("cp " + examplesZip + " " + distDir)
}

target('remove_zip) {
    delete(examplesZip)
}

