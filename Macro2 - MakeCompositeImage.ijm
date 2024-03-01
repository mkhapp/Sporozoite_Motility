setBatchMode(true);
path = "C:/Users/travermk/Desktop/Youngsil/February 2/"
files = getFileList(path);

for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], ".tif")) {
		image = files[i];
		name = File.getNameWithoutExtension(path+image);
		open(path+image);
		run("Make Composite");
		run("RGB Color", "frames");
		saveAs("Tiff", path+name+"_Tracking.tif");
		close("*");
	}
}
