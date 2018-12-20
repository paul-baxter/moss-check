# moss-check

Outline process?
- ensure all submission .zip files in 
- extract source files from submission .zip
- append all files into single source file (prefixed with student id)
  -- ensure all file names have no spaces in name
  -- ensure all files are in UTF-8 encoding (http://theory.stanford.edu/~aiken/moss/to_UTF8.sh)
  -- (other checks/validation...)
- run check on all files through moss (http://theory.stanford.edu/~aiken/moss/)
- download the moss report
