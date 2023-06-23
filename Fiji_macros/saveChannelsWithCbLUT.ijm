path = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/Data/LH02_A03/block2/cycle14_ROI1";
file = "warp_thunder_s001_z53_to_warp_lmEM_to_hmEM.tif";

close("*");
s = File.separator();
fname = File.getNameWithoutExtension(file);

if (!(File.isDirectory(path+s+"Figure"))){
	File.makeDirectory(path+s+"Figure");
	print("Made new directory");
}

open(path + s + file);
run("Stack to Images");

selectWindow(fname+"-0001");
run("CB_BluishGreen");
run("Enhance Contrast", "saturated=0.35");

selectWindow(fname+"-0002");
run("CB_Blue");
run("Enhance Contrast", "saturated=0.35");

selectWindow(fname+"-0003");
run("Grays");
run("Enhance Contrast", "saturated=0.35");

selectWindow(fname+"-0004");
run("CB_ReddishPurple");
run("Enhance Contrast", "saturated=0.35");

selectWindow(fname+"-0005");
run("CB_Yellow");
run("Enhance Contrast", "saturated=0.35");

run("Merge Channels...", "c2="+fname+"-0001"+" c3="+fname+"-0002 create keep");

waitForUser("Contrast?");

selectWindow(fname+"-0001");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0001.tif");
run("RGB Color");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0001-rgb.tif");
close();

selectWindow(fname+"-0002");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0002.tif");
run("RGB Color");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0002-rgb.tif");
close();

selectWindow(fname+"-0003");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0003.tif");
run("RGB Color");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0003-rgb.tif");
close();

selectWindow(fname+"-0004");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0004.tif");
run("RGB Color");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0004-rgb.tif");
close();

selectWindow(fname+"-0005");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0005.tif");
run("RGB Color");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0005-rgb.tif");
close();

selectWindow("Composite");
run("RGB Color");
saveAs("Tiff", path+s+"Figure"+s+fname+"-0001-0002-rgb.tif");
close();
selectWindow("Composite");
close();