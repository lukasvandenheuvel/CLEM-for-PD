overlap_channel = "ch4_sfused_zmax"; // Which channel to use for computing the overlap
channels_to_fuse = newArray("ch0_sfused_zmax","ch1_sfused_zmax","ch2_sfused_zmax","ch3_sfused_zmax");
merge_channels = true;
tile_folder = "/Volumes/Lukas_1T/PDM/Data/LH02_B03/1_Thunder_fluo/T1/tiles";

channel_array 	= newArray("ch0_sfused_zmax","ch1_sfused_zmax","ch2_sfused_zmax","ch3_sfused_zmax","ch4_sfused_zmax");
color_array 	= newArray("blue","green","yellow","magenta","gray");

pixel_size = 0.103; // um per pixel
pixel_depth = 0.3; // um per zstep

s = File.separator;

run("Close All");
setBatchMode(true);
// Check if all folders exist
if (!(File.isDirectory(tile_folder + s + overlap_channel))) {
	exit("Could not find a folder "+overlap_channel+"in the tile folder!");
}
for (i = 0; i < channels_to_fuse.length; i++) {
	channel = channels_to_fuse[i];
	if (!(File.isDirectory(tile_folder + s + channel))) {
		exit("Could not find a folder "+channel+"in the tile folder!");
	}
}
// Check if channel and color arrays have equal lengths
if (!(channel_array.length==color_array.length)) {
	exit("Channel and color arrays must be of the same length!");
}

// Copy TileConfiguration.txt into the overlap channel folder
if (File.exists(tile_folder + s + "TileConfiguration.txt")){
	File.copy(tile_folder + s + "TileConfiguration.txt", tile_folder + s + overlap_channel + s + "TileConfiguration.txt");
}
else {
	exit("Could not fint a TileConfiguration.txt file in the tile folder!");
}

// Clear existing ROIs
if ( RoiManager.size > 0 ){
	roiManager("Deselect");
	roiManager("Delete");
}

// Compute overlap of overlap channel 
run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory="+tile_folder+s+overlap_channel+" layout_file=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 add_tiles_as_rois compute_overlap computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
// run("16-bit");
// Copy registered tile config to tiles folder
File.copy(tile_folder + s + overlap_channel + s + "TileConfiguration.registered.txt", tile_folder + s + "TileConfiguration.registered.txt");

//run("Enhance Contrast", "saturated=0.35");
getDimensions(width, height, channels, slices, frames);
Stack.setXUnit("um");
Stack.setYUnit("um");
Stack.setZUnit("um");
run("Properties...", "channels="+d2s(channels,0)+" slices="+d2s(slices,0)+" frames="+d2s(frames,0)+" pixel_width="+d2s(pixel_size,7)+" pixel_height="+d2s(pixel_size,7)+" voxel_depth="+d2s(pixel_depth,7));
saveAs("Tiff", tile_folder+s+overlap_channel+".tif");
// Save ROIs
roiManager("Deselect");
roiManager("Save", tile_folder+s+"RoiSet.zip");

// Fuse other channels
for (i = 0; i < channels_to_fuse.length; i++) {
	channel = channels_to_fuse[i];
	File.copy(tile_folder + s + overlap_channel + s + "TileConfiguration.registered.txt", tile_folder + s + channel + s + "TileConfiguration.registered.txt");
	run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory="+tile_folder+s+channel+" layout_file=TileConfiguration.registered.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
	// run("16-bit");
	// run("Enhance Contrast", "saturated=0.35");
	getDimensions(width, height, channels, slices, frames);
	Stack.setXUnit("um");
	Stack.setYUnit("um");
	Stack.setZUnit("um");
	run("Properties...", "channels="+d2s(channels,0)+" slices="+d2s(slices,0)+" frames="+d2s(frames,0)+" pixel_width="+d2s(pixel_size,7)+" pixel_height="+d2s(pixel_size,7)+" voxel_depth="+d2s(pixel_depth,7));
	saveAs("Tiff", tile_folder+s+channel+".tif");
}

// Merge channels on the right colors
color_str = "";
for (i = 0; i < color_array.length; i++) {
	color = color_array[i];
	if (color=="red"){
		color_str = color_str + "c1=" + channel_array[i] + ".tif ";
	}
	else if (color=="green") {
		color_str = color_str + "c2=" + channel_array[i] + ".tif ";
	}
	else if (color=="blue") {
		color_str = color_str + "c3=" + channel_array[i] + ".tif ";
	}
	else if (color=="gray") {
		color_str = color_str + "c4=" + channel_array[i] + ".tif ";
	}
	else if (color=="cyan") {
		color_str = color_str + "c5=" + channel_array[i] + ".tif ";
	}
	else if (color=="magenta") {
		color_str = color_str + "c6=" + channel_array[i] + ".tif ";
	}
	else if (color=="yellow") {
		color_str = color_str + "c7=" + channel_array[i] + ".tif ";
	}
	else{
		exit("Found unknown color in color channel!");
	}
}
run("Merge Channels...", color_str+"create");
print("Done!");
setBatchMode("exit and display");