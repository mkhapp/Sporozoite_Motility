path = "C:/Users/travermk/Desktop/Youngsil/February 12/"

setBatchMode(true);
run("Set Measurements...", "area limit redirect=None decimal=2");
Table.create("Final Results");
files = getFileList(path);

for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], "_FluorescenceCleared.tif")) {
		image = files[i];
		name = File.getNameWithoutExtension(path+image);
		nameroot = split(name, "_");
		open(path+image);
		for (j = 1; j <= nSlices; j++) {
			setSlice(j);
			setThreshold(1, 65535);
			run("Measure");
		}
		Table.setColumn(nameroot[0], Table.getColumn("Area", "Results"), "Final Results");
		run("Clear Results");
		close("*");
	}
}

Table.save(path + "Results.csv", "Final Results");