path = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/Data/LH02_A04/block1/cycle5_ROI2";

s = File.separator;
roiManager("reset");
close("*");

open(path + s + "hmEM.tif");
run("8-bit");
getDimensions(width_em, height_em, channels, slices, frames);
open(path + s + "warp_IHC_to_hmEM.tif");
getDimensions(width_ihc, height_ihc, channels, slices, frames);

run("Split Channels");
selectWindow("warp_IHC_to_hmEM.tif (blue)");
close();
selectWindow("warp_IHC_to_hmEM.tif (green)");
close();
selectWindow("warp_IHC_to_hmEM.tif (red)");
if (!(width_em==width_ihc) || !(height_em==height_ihc)) {
	run("Size...", "width="+d2s(width_em,0)+" height="+d2s(height_em,0)+" depth=1 average interpolation=Bilinear");
}
run("Duplicate...", " ");
run("Gaussian Blur...", "sigma=150");

run("Invert");
setAutoThreshold("Default dark");
setOption("BlackBackground", true);
run("Convert to Mask");

run("Analyze Particles...", "size=100-Infinity pixel display clear add");

selectWindow("warp_IHC_to_hmEM.tif (red)");
run("Invert");

run("Merge Channels...", "c3=[warp_IHC_to_hmEM.tif (red)] c4=hmEM.tif create");

roiManager("Show All");

waitForUser("Check and copy pixel size");
n = getNumber("Change to 1 if you want to re-measure the ROI",0);

if (n==1){
	selectWindow("Composite");
	run("Split Channels");
	selectWindow("C1-Composite");
	roiManager("reset");
	run("Analyze Particles...", "size=100-Infinity pixel display clear add");
}

roiManager("Deselect");
roiManager("Combine");
run("Create Mask");

saveAs("Tiff", path + s + "hmEM_mask.tif");

close("*");