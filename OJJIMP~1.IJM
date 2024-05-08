//This will open the csv file you imported and put into the prepared ojj file
//note composite must be on
open();
loadedTitle=getInfo("window.title");
IJ.renameResults(loadedTitle,"Results")
updateResults();

	ojInitTextColumn("originalMarker");
	ojInitTextColumn("originalID");
	ojInitTextColumn("origProjectName");
	
	for (n=0; n<nResults; n++){
	
		id=getResult("Imageid", n);
		ojShowImage(id);
		setSlice(getResult("Z", n));
		ojSetComposite(true);//just in case composite is off
		ojSwitchToItem("Synapse");
		ojSetMarker(getResult("X", n), getResult("Y", n)); 
		ojSetMarker(getResult("X", n), getResult("Y", n));
		ojSetMarker(getResult("X", n), getResult("Y", n));
		             
		ojSetResult("originalMarker",n+1,getResultString("MarkerName", n));
		ojSetResult("originalID",n+1,getResult("Marker", n));
		ojSetResult("origProjectName",n+1,getResultString("projectName", n));
	}
	updateResults();
