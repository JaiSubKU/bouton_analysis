//This program will export a CSV file to the project folder that will be loaded for synapse counting


	//the below fills out the column headers
	if (nResults>=0) run("Clear Results");     // Check whether the results table is empty, if not clear it.
		i = nResults;    // variable for counting, initialising with 0
		setResult("MarkerNumb", 0, 0);
		setResult("Imageid", 0,0 );
		setResult("X", 0, 0);
		setResult("Y", 0, 0);
		setResult("Z", 0, 0);
		setResult("MarkerName",0,0 );
		
	rowCounter=0;
	for (n=1; n<=ojNObjects(); n++) {

		ojShowObject(n);
		name=ojSelectedItemName();

		
		//skip ones we dont want to quantify
		//skpped will have 0,0,0 coordinates
   		if(name!="Landmark"){
			
			setResult("Marker", rowCounter, ojResult("ObjectRelativeID", n));
			pName=ojGetProjectName();
			imNum=ojOwnerIndex(n);
			
			setResult("projectName",rowCounter , pName);
			setResult("Imageid", rowCounter, imNum );
			setResult("MarkerName", rowCounter, name);
			
			X=ojXPos(1);
			Y=ojYPos(1);
			Z=ojZPos(1);
			setResult("X",rowCounter, X);
			setResult("Y", rowCounter, Y);
			setResult("Z", rowCounter, Z);
					
			rowCounter++;
		}
   }
   updateResults();

selectWindow("Results"); 
Name=ojGetProjectName();
Path=ojGetProjectPath();
Name=Path+"/"+Name+" Exported Spines with PSD for Size Analysis.csv";
print(Name);
saveAs("results",Name);