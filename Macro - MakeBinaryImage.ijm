path = "C:/Users/travermk/Desktop/Youngsil/February 12/"
blursigma = 80;
background = 100;
threshmeth = "Otsu dark"   ////Examples:  "Otsu dark"  "Otsu dark stack"  "Li dark"
method = "Otsu"

files = getFileList(path);
setBatchMode(true);

for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], ".tif")) {
		image = files[i];
		name = File.getNameWithoutExtension(path+image);
		open(path+image);
		getDimensions(width, height, channels, slices, frames);
		run("Split Channels");
		selectImage("C2-"+image);
		close("\\Others");
		run("Duplicate...", "duplicate");
		run("Gaussian Blur...", "sigma="+blursigma+" stack");
		run("Calculator Plus", "i1=C2-"+image+" i2=C2-"+name+"-1.tif operation=[Divide: i2 = (i1/i2) x k1 + k2] k1="+background+" k2=0 create");
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
		saveAs("Tiff", path+name+"_Binary.tif");
		close("*");
	}
}







