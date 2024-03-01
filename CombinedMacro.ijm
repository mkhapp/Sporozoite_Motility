// *********** README ***********

// This macro was generated for Youngsil Seo in early 2024 to process timelapses of
// fluorescent sporozoites.  The macro takes a folder full of 2 or 3 channel timelapse
// images (DIC, sporozoite fluorescence, and/or NK fluorescence) and determines the
// area of fluorescent sporozoites over time.

// To use this macro, put all images in the same folder. You will need the following
// inputs:
// *folder containing images
// *blur sigma
// *average background level
// *best threshold method, including whether to calculate based on stack



//Code starts here

//allow user to select inputs
Dialog.create("Choose Inputs");
Dialog.addDirectory("Images Folder", "");
Dialog.addNumber("Blur Sigma (5-100)", 40);
Dialog.addNumber("Average Background Level", 100);
Dialog.addNumber("Sporozoite Fluorescence Channel#", 2);
thresholdmethods = newArray("Otsu", "Li", "MaxEntropy");
Dialog.addChoice("Threshold Method", thresholdmethods);
Dialog.addCheckbox("Use Stack Threshold?", true);
Dialog.show();

//showProgress(progress);

path = Dialog.getString();
blursigma = Dialog.getNumber();
background = Dialog.getNumber();
channelnum = Dialog.getNumber();
method = Dialog.getChoice();
stack = Dialog.getCheckbox();
threshmeth = method + " dark";

if (stack == true) {
	threshmeth = threshmeth + " stack";
}

if (background > 65536) {
	print("Average Background Level is too high");
	exit
}


files = getFileList(path);
setBatchMode(true);

//create binary images
for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], ".tif")) {
		image = files[i];
		name = File.getNameWithoutExtension(path+image);
		open(path+image);
		rename("Working.tif");
		getDimensions(width, height, channels, slices, frames);
		run("Split Channels");
		selectImage("C"+channelnum+"-Working.tif");
		close("\\Others");
		run("Duplicate...", "duplicate");
		run("Gaussian Blur...", "sigma="+blursigma+" stack");
		run("Calculator Plus", "i1=C2-Working.tif i2=C2-Working-1.tif operation=[Divide: i2 = (i1/i2) x k1 + k2] k1="+background+" k2=0 create");
		selectImage("Result");
		close("\\Others");	
		setAutoThreshold(threshmeth);
		setOption("BlackBackground", false);
		run("Convert to Mask", "method="+method+" background=Dark");
		run("Close-", "stack");
		run("Open", "stack");
		run("Fill Holes", "stack");
		Stack.setXUnit("micron");
		run("Properties...", "channels=1 slices=1 frames="+frames+" pixel_width=0.1625000 pixel_height=0.1625000 voxel_depth=1 frame=[60.00 sec]");
		
		if (i == 0) {
			setBatchMode("exit and display");
			waitForUser("Is This A Proper Segmentation? \n \n If yes, DO NOT CLOSE IMAGE. Just press 'OK' to run on all images. \n \n If not, please press 'cancel' and try different inputs.");
			setBatchMode(true);
		}
		
		saveAs("Tiff", path+name+"_Binary.tif");
		close("*");
	}
}

//Make fluorescence image with background removed
run("Colors...", "foreground=black background=black selection=red");
for (i = 0; i < files.length; i++) {
	image = files[i];
	name = File.getNameWithoutExtension(path+image);
	binary = name+"_Binary.tif";
	fluorescence = "C"+channelnum+"-Working.tif";
	
	open(path+image);
	rename("Working.tif");
	run("Split Channels");
	selectImage(fluorescence);
	close("\\Others");
	open(path+binary);
		
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

//Measure Area Per Slice
run("Set Measurements...", "area limit redirect=None decimal=2");
Table.create("Final Results");

for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], ".tif")) {
		image = files[i];
		name = File.getNameWithoutExtension(path+image);
		open(path+name+"_FluorescenceCleared.tif");
		for (j = 1; j <= nSlices; j++) {
			setSlice(j);
			setThreshold(1, 65535);
			run("Measure");
		}
		Table.setColumn(name, Table.getColumn("Area", "Results"), "Final Results");
		run("Clear Results");
		close("*");
	}
}

Table.save(path + "Results.csv", "Final Results");

print("Finished!");
