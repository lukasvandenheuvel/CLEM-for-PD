path = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/Data/LH01_A05/1_Thunder/Series013_Lng_LVCC";
out_path = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/Data/LH01_A05/Block1/cycle10_ROI1/Thunder_fluo";
s = File.separator;

pixel_size = 0.103; // um per pixel
pixel_depth = 0.3; // um per zstep

channel_array 	= newArray("ch0","ch1","ch2","ch3","ch4");
color_array 	= newArray("blue","green","yellow","magenta","gray");
LUT_array 		= newArray("CB_Blue","CB_BluishGreen","CB_Yellow","CB_ReddishPurple","Grays");
name 			= "_s0_zstack";

close("*");
setBatchMode(true);
for (i = 0; i < channel_array.length; i++) {
	ch = channel_array[i];
	File.openSequence(path + s + ch + name + s);
	run("Set Scale...", "distance=1 known="+d2s(pixel_size,3)+" unit=um");
	run(LUT_array[i]);
}


run("Merge Channels...", "c2=ch1_s0_zstack c3=ch0_s0_zstack c4=ch4_s0_zstack c6=ch3_s0_zstack c7=ch2_s0_zstack create");
setBatchMode("exit and display");
waitForUser("Select field of view");
run("Duplicate...", "duplicate");
saveAs("Tiff", out_path + s + "Thunder_composite.tif");

waitForUser("Polygon select the aggregate");
roiManager("reset");
roiManager("Add");
run("Split Channels");
close("C2-Thunder_composite.tif");
close("C3-Thunder_composite.tif");
close("C5-Thunder_composite.tif");

selectWindow("C4-Thunder_composite.tif");
run("Gaussian Blur...", "sigma=2 stack");

selectWindow("C1-Thunder_composite.tif");
run("Gaussian Blur...", "sigma=2 stack");

waitForUser("Set threshold on C1...");
selectWindow("MASK_C1-Thunder_composite.tif");
roiManager("Select", 0);
run("Clear Outside", "stack");
saveAs("Tiff", out_path + s + "C1-mask.tif");

selectWindow("C4-Thunder_composite.tif");
waitForUser("Set threshold on C4...");
selectWindow("MASK_C4-Thunder_composite.tif");
roiManager("Select", 0);
run("Clear Outside", "stack");
run("Threshold...");
saveAs("Tiff", out_path + s + "C4-mask.tif");
