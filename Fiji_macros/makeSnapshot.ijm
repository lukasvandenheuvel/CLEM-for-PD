T_path = "/Volumes/Lukas_1T/PDM/Data/LH02_B06/1_Thunder_fluo/";
ROI = "ROI14";

fs = File.separator;
if (!(File.isDirectory(T_path + fs + ROI))){
	File.makeDirectory(T_path + fs + ROI);
}


run("Duplicate...", "title="+ROI+"_snapshot duplicate");
run("Scale Bar...", "width=10 height=6 thickness=15 font=20 color=White background=None location=[Lower Right] horizontal bold overlay");

waitForUser("Adjust scalebar");

saveAs("Tiff",T_path + fs + ROI + fs + ROI + "_snapshot.tif");
run("Z Project...", "projection=[Max Intensity]");

waitForUser("Adjust BC");
saveAs("PNG", T_path + fs + ROI + fs + ROI + "_snapshot_zmax.tif");
