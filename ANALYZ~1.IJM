	
	
	numPixelsToSquareEdge = 2//Distance to edge not including the center pixel
	squareDiameter=2*numPixelsToSquareEdge+1;
	
	
	debugMode=false;;//toggle to enable debugging output

	  
	items=ojGetItemNames();
	items=split(items);//dynamic way to loop over types

	for(j=0;j<lengthOf(items);j++){
		for (ch=1;ch<4;ch++){
			temp=items[j]+"_intensitySum_Ch"+ch;
			ojInitColumn(temp);
		}
	}
	
	


    for(n=1;n<=ojNObjects();n++){
		zoom=getZoom();
		ojShowObject(n);
    	yoj=ojYPos(1);
		xoj=ojXPos(1);
		ojZoom(zoom,xoj,yoj);
		skipErr=true;//This lets me skip if a user has already had an err message
    	
		for(j=0;j<lengthOf(items);j++){
			temp=items[j]+"_X";
			X=ojResult(temp,n);
			
			temp=items[j]+"_Y";
			Y=ojResult(temp,n);
			
			temp=items[j]+"_Z";
			Z=ojResult(temp,n);//FYI this Z value is not the same as the z shown in a hyperstack. it is channels*Z long. 
	
			setSlice(Z);

			for(ch=1;ch<4;ch++){
				Stack.setChannel(ch); 
		
			    makeRectangle(floor(X-numPixelsToSquareEdge),floor(Y-numPixelsToSquareEdge),squareDiameter,squareDiameter);
		  		getRawStatistics(nPixels, mean);
		  		intensitySum=nPixels*mean;
		  		temp=items[j]+"_intensitySum_Ch"+ch;
				ojSetResult(temp,n,intensitySum);
			
				if (j>0 & skipErr){ // if markers aren't moved the value is the same
					temp=items[j-1]+"_intensitySum_Ch"+ch;
					prevResult=ojResult(temp,n);
					if(intensitySum==prevResult){					
						waitForUser("Marker number "+n+" may not have been analyzed. Continue or fix and rerun");
						skipErr=false;
					}
				}
			}
			
			if (debugMode)
				waitForUser("Paused for debugging. FYI intensity is: "+intensitySum);
			
		}	
  }