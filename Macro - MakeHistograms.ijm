condition = "US";
filePath = "C:/Users/travermk/Desktop/Youngsil/January 22/";
Table.create("Histogram");

open(filePath+"ParasitesOnly_"+condition+".tif");
getHistogram(values, counts, 111, 0, 11100);
Table.setColumn("Values", values);

for (i = 1; i <= nSlices; i++) {
    setSlice(i);
    getHistogram(values, counts, 111, 0, 11100);
    Table.setColumn(i, counts);
}

Table.save(filePath+"Histogram_"+condition+"_Bin100.csv");
