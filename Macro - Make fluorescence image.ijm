// This macro takes a list of files and keeps only the root filename, then opens the multi-channel image and 


setBatchMode(true);
path = "C:/Users/travermk/Desktop/Youngsil/February 12/"
files = getFileList(path);
Array.print(files);

//keep only root images
for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], "_Binary.tif")) {
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
	if (endsWith(files[i], ".tif")) {
		image = files[i];
		name = File.getNameWithoutExtension(path+image);
		open(path+image);
		run("Split Channels");
		selectImage("C2-"+image);
		close("\\Others");
		saveAs("Tiff", path+name+"_Fluorescence.tif");
		close("*");
	}
}
