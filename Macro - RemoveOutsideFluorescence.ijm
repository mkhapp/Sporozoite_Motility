run("Colors...", "foreground=black background=black selection=red");
setBatchMode(true);
path = "C:/Users/travermk/Desktop/Youngsil/February 12/"
files = getFileList(path);

//keep only root files
for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], "_Binary.tif")) {
		files = Array.deleteValue(files, files[i]);
	}
}

for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], "_Fluorescence.tif")) {
		files = Array.deleteValue(files, files[i]);
	}
}

for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], ".nd2")) {
		files = Array.deleteValue(files, files[i]);
	}
}

//process images
for (i = 0; i < files.length; i++) {
	image = files[i];
	name = File.getNameWithoutExtension(path+image);
	binary = name+"_Binary.tif";
	fluorescence = name+"_Fluorescence.tif";
	open(path+image);
	open(path+binary);
	open(path+fluorescence);
	for (j = 1; j <= nSlices; j++) {
		selectWindow(binary);
		setSlice(j);
		setThreshold(1, 255);
		run("Analyze Particles...", "size=5-Infinity add");
		resetThreshold;
		if (roiManager("count")>0) {
			roiManager("select", Array.getSequence(roiManager("count")));
			roiManager("Combine");
			roiManager("add");
			roiManager("select", Array.getSequence(roiManager("count")-1));
			roiManager("delete");
			roiManager("deselect");
			run("Select None");
	
			selectWindow(fluorescence);
			setSlice(j);
			roiManager("Select", 0);
			run("Clear Outside", "slice");
			roiManager("deselect");
			run("Select None");
	
			roiManager("reset");
		}
	}
	selectWindow(fluorescence);
	saveAs("Tiff", path+name+"_FluorescenceCleared.tif");
	close("*");
}
