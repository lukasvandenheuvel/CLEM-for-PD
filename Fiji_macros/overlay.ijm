// To run this script, you need:
// (1) The BigWarp plugin;
// (2) This script: https://github.com/saalfeldlab/bigwarp/blob/master/scripts/Apply_Bigwarp_Xfm_FOV.groovy
// Copy it into the FIJI Plugins/Scripts folder, then restart Fiji.

rescale = 0.2; 	// 
//pixel_size = 4.23; // Pixel size in nm of hmEM

folder = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/Data/LH02_A03/block2/cycle14_ROI1/"; // Make sure path ends with '/'
to_warp_name = "thunder_s001_z53.tif";
warp_to_hmEM = true;

File.setDefaultDir(folder); // Set default directory to folder
run("Close All");
setBatchMode(true);

to_warp_path = folder + to_warp_name;
lmEM_path = folder + "lmEM.tif";
hmEM_path = folder + "hmEM.tif";
out_path = folder;
landmarks_file = folder + "landmarks_lmEM_to_hmEM.csv"
to_warp = File.getNameWithoutExtension(to_warp_path);
s = File.separator;

// Open hmEM image to get pixel size
open(hmEM_path);
rename("hmEM");
w = getWidth();
h = getHeight();
makeRectangle(round(w/2)-2000, h-100, 2000, 100);
run("Duplicate...", "title=pixelSize");
setBatchMode("show");
pixel_size = getNumber("Pixel size in nm ", 2.433);
pixel_size_um = pixel_size / 1000;
close("pixelSize");
selectWindow("hmEM");
run("Select None");
setBatchMode(true);

// Open IHC image
open(to_warp_path);
rename("WARP");

// Open IHC image
open(lmEM_path);
rename("lmEM");

// Register IHC with low-magnification EM
String.copy("landmarks_"+to_warp+"_to_lmEM.csv"); // Copy landmarks name to clipboard, makes it easy to export landmarks with the correct name
run("Big Warp", "moving_image=[WARP] target_image=[lmEM] moving=[] moving_0=[] target=[] target_0=[] landmarks=[] apply");
waitForUser("BigWarp registration","Register images. Then export the moving image.");

// Register low-magnification EM with high-magnification EM
selectWindow("hmEM");
String.copy("landmarks_lmEM_to_hmEM.csv"); // Copy landmarks name to clipboard, makes it easy to export landmarks with the correct name
run("Big Warp", "moving_image=[lmEM] target_image=[hmEM] moving=[] moving_0=[] target=[] target_0=[] landmarks=[] apply");
waitForUser("BigWarp registration","Register images. Export landmarks as "+landmarks_file);
close("lmEM");

// Save warped IHC image
selectWindow("WARP channel 1_WARP channel 1_xfm_0");
rename("warp_"+to_warp+"_to_lmEM");
saveAs("Tiff", out_path + s + "warp_"+to_warp+"_to_lmEM.tif");
close("WARP");

if (warp_to_hmEM) {
	// Apply same transform to IHC
	print("Transforming the WARP using the lmEM-to-hmEM transform ...");
	run("Apply Bigwarp Xfm", "landmarkspath="+landmarks_file+" movingpath="+out_path+s+"warp_"+to_warp+"_to_lmEM.tif targetpath=["+hmEM_path+"] transformtype=[Thin Plate Spline] interptype=Linear nthreads=1 isvirtual=false");
	
	// Save transformed IHC
	selectWindow("warp_"+to_warp+"_to_lmEM.tif channel 1_warp_"+to_warp+"_to_lmEM.tif channel 1_xfm_0");
	rename("warp_"+to_warp+"_to_hmEM");
	saveAs("Tiff", out_path + s + "warp_"+to_warp+"_to_hmEM.tif");

	// Rescale transformed IHC
	getDimensions(width, height, channels, slices, frames);
	new_width = round(rescale*width);
	new_height = round(rescale*height);

	print("Downsizing warp-to-hmEM ...");
	//run("Set Scale...", "distance=1 known="+d2s(pixel_size_um,6)+" unit=um");
	//run("Scale...", "x="+d2s(rescale,1)+" y="+d2s(rescale,1)+" width="+d2s(new_width,0)+" height="+d2s(new_height,0)+" interpolation=Bicubic average create process");
	run("Size...", "width="+d2s(new_width,0)+" height="+d2s(new_height,0)+" depth="+d2s(channels,0)+" constrain average interpolation=Bilinear");
	saveAs("Tiff", out_path + s + "warp_"+to_warp+"_to_hmEM_small.tif");
	close("warp_"+to_warp+"_to_hmEM.tif");
}

// Rescale hmEM
print("Downsizing hmEM ...");
selectWindow("hmEM");
getDimensions(width, height, channels, slices, frames);
new_width = round(rescale*width);
new_height = round(rescale*height);
run("Size...", "width="+d2s(new_width,0)+" height="+d2s(new_height,0)+" depth=1 constrain average interpolation=Bilinear");
run("Set Scale...", "distance=1 known="+d2s(pixel_size_um/rescale,6)+" unit=um");
//run("Scale...", "x="+d2s(rescale,1)+" y="+d2s(rescale,1)+" width="+d2s(new_width,0)+" height="+d2s(new_height,0)+" interpolation=Bicubic average create");
run("Scale Bar...", "width=10 height=6 thickness=20 font=40 color=White background=None location=[Lower Right] horizontal bold overlay");
saveAs("Tiff", out_path + s + "hmEM_small_scalebar.tif");

run("Enhance Contrast...", "saturated=0.35 equalize");
saveAs("Tiff", out_path + s + "hmEM_small_scalebar_bc.tif");

close("hmEM");
setBatchMode("exit and display");
print("Done!");