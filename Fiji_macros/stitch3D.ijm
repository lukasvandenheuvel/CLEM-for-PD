T_path = "/Volumes/Lukas_1T/PDM/Data/LH02_A03/1_Thunder_fluo/T2";
ROI = "ROI19";
s_array = newArray(8,15); //newArray(12,13);
//s_array[0] = 15;
channel_array = newArray("ch0","ch1","ch2","ch3","ch4");
//channel_array = newArray("ch4");
color_array = newArray("blue","green","yellow","magenta","gray");

pixel_size = 0.103; // um per pixel
pixel_depth = 0.3; // um per zstep

close("*");
setBatchMode(true);
fs = File.separator;
ROI_path = T_path + fs + ROI;
tile_path = T_path + fs + "tiles";

if (!(File.isDirectory(ROI_path))) {
	print("Made ROI directory: "+ ROI_path);
	File.makeDirectory(ROI_path);
}


// If there is only 1 tile, just open the 4 sequences and merge
if (s_array.length == 1) {
	s = s_array[0];
	for (c = 0; c < channel_array.length; c++) {
		ch = channel_array[c];
		File.openSequence(tile_path + fs + ch + "_s" + d2s(s,0) + "_zstack");
		getDimensions(width, height, channels, slices, frames);
		Stack.setXUnit("um");
		Stack.setYUnit("um");
		Stack.setZUnit("um");
		run("Properties...", "channels="+d2s(channels,0)+" slices="+d2s(slices,0)+" frames="+d2s(frames,0)+" pixel_width="+d2s(pixel_size,7)+" pixel_height="+d2s(pixel_size,7)+" voxel_depth="+d2s(pixel_depth,7));
		saveAs("Tiff", ROI_path + fs + ch + "_sfused_zstack.tif");
	}
}

else{ // There are more than 1 files, so let's stitch them
	tileconfig_path = tile_path + fs + "TileConfiguration.registered.txt";
	tileconfig = File.openAsString(tileconfig_path);
	lines = split(tileconfig, "\n");
	
	// Find the coordinates of the first tile and save them
	x0 = -1;
	y0 = -1;
	for (l = 0; l < lines.length; l++) {
		if (lines[l].contains("s"+d2s(s_array[0],0)+"_zmax.tif")){
			split1 = split(lines[l],"(, )");
			splitx = split(split1[0],"(");
			x0 = parseFloat(splitx[1]);
			splity = split(split1[1],")");
			y0 = parseFloat(splity[0]);
		}
	}
	if ((x0==-1) & (y0==-1)) {
		error("Tile s"+d2s(s_array[0],0)+"_zmax.tif not found in TileConfiguration.registered.txt!")
	}
	// Make new ROI config file
	roiconfig = "# Define the number of dimensions we are working on\ndim = 3\n\n# Define the image coordinates\n";
	for (i = 0; i < s_array.length; i++) {
		s = s_array[i];
		for (l = 0; l < lines.length; l++) {
			if (lines[l].contains("s"+d2s(s,0)+"_zmax.tif")){
				split1 = split(lines[l],"(, )");
				splits = split(split1[0],"_zmax");
				s_string = splits[0];
				splitx = split(split1[0],"(");
				x = parseFloat(splitx[1]);
				splity = split(split1[1],")");
				y = parseFloat(splity[0]);
				
				newx = x - x0;
				newy = y - y0;
				roiconfig = roiconfig + s_string + "_zstack.tif; ; (" + d2s(newx,5) + ", " + d2s(newy,5) + ", 0.0)\n";
			}
		}
	}
	// Save new config file
	File.saveString(roiconfig, ROI_path + fs + "TileConfiguration.registered.txt");
	
	for (c = 0; c < channel_array.length; c++) {
		ch = channel_array[c];
		// Load z-sequences and save them as zstack
		for (i = 0; i < s_array.length; i++) {
			s = s_array[i];
			File.openSequence(tile_path + fs + ch + "_s" + d2s(s,0) + "_zstack");
			saveAs("Tiff", ROI_path + fs + "s" + d2s(s,0) + "_zstack.tif");
			close();
		}
		// Stitch
		run("Grid/Collection stitching", "type=[Positions from file] order=[Defined by TileConfiguration] directory="+ROI_path+" layout_file=TileConfiguration.registered.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
		run("Grays");
		// Set units
		getDimensions(width, height, channels, slices, frames);
		Stack.setXUnit("um");
		Stack.setYUnit("um");
		Stack.setZUnit("um");
		run("Properties...", "channels="+d2s(channels,0)+" slices="+d2s(slices,0)+" frames="+d2s(frames,0)+" pixel_width="+d2s(pixel_size,7)+" pixel_height="+d2s(pixel_size,7)+" voxel_depth="+d2s(pixel_depth,7));
		saveAs("Tiff", ROI_path + fs + ch + "_sfused_zstack.tif");
		// Remove individual tile files
		for (i = 0; i < s_array.length; i++) {
			s = s_array[i];
		 	File.delete(ROI_path + fs + "s" + d2s(s,0) + "_zstack.tif");
		}
	}
}

// Merge channels on the right colors
color_str = "";
for (i = 0; i < color_array.length; i++) {
	color = color_array[i];
	if (color=="red"){
		color_str = color_str + "c1=" + channel_array[i] + "_sfused_zstack.tif ";
	}
	else if (color=="green") {
		color_str = color_str + "c2=" + channel_array[i] + "_sfused_zstack.tif ";
	}
	else if (color=="blue") {
		color_str = color_str + "c3=" + channel_array[i] + "_sfused_zstack.tif ";
	}
	else if (color=="gray") {
		color_str = color_str + "c4=" + channel_array[i] + "_sfused_zstack.tif ";
	}
	else if (color=="cyan") {
		color_str = color_str + "c5=" + channel_array[i] + "_sfused_zstack.tif ";
	}
	else if (color=="magenta") {
		color_str = color_str + "c6=" + channel_array[i] + "_sfused_zstack.tif ";
	}
	else if (color=="yellow") {
		color_str = color_str + "c7=" + channel_array[i] + "_sfused_zstack.tif ";
	}
	else{
		exit("Found unknown color in color channel!");
	}
}
run("Merge Channels...", color_str+"create");
print("Done!");
setBatchMode("exit and display");

waitForUser("Select ROI");

run("Duplicate...", "title="+ROI+"_snapshot duplicate");
run("Scale Bar...", "width=10 height=6 thickness=15 font=20 color=White background=None location=[Lower Right] horizontal bold overlay");

waitForUser("Adjust scalebar");

saveAs("Tiff",T_path + fs + ROI + fs + ROI + "_snapshot.tif");
run("Z Project...", "projection=[Max Intensity]");

waitForUser("Adjust BC");
saveAs("PNG", T_path + fs + ROI + fs + ROI + "_snapshot_zmax.tif");