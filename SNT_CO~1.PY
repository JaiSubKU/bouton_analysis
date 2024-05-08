#@File traces_file
#@LogService log
#@UIService ui

from sc.fiji.snt import Tree
from org.scijava.log import LogLevel

# load traces file: since file may contain one or more rooted structures
# (trees), we'll use a convenience method that handles multiple trees in
# a single file (or directory). For details:
# https://javadoc.scijava.org/Fiji/sc/fiji/snt/Tree.html
trees = Tree.listFromFile(str(traces_file))
if not trees:
    ui.showDialog("Could not retrieve coordinates. Not a valid file?")
else:
    for tree in trees:
        log.log(LogLevel.INFO, 'Processing %s...' % tree.getLabel())
        # now print all nodes in the tree
        for node in tree.getNodes():
            log.log(LogLevel.INFO, node)
    ui.getDefaultUI().getConsolePane().show()