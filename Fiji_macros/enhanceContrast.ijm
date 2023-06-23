setBatchMode(true);

outFileName = File.getNameWithoutExtension(getTitle()) + " bc.jpg";
outDir = getDir("image");
s = File.separator;

run("Duplicate...", outFileName);
run("Enhance Contrast...", "saturated=0.3 equalize");
saveAs("Jpeg", outDir + s + outFileName);

setBatchMode("exit and display");