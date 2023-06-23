path_to_archive = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/EM_snapshots/archive-ROI-ids.txt";
path_to_snapshots = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/EM_snapshots";
path_outptut = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/Figures/ext_fig_aggregates";

text = File.openAsString(path_to_archive);
lines = split(text,"\n");


s = File.separator;

for (i = 1; i < 2; i++) {
	entries = split(lines[i],", ");
	Array.print(entries);
	snapshot_name = "img"+entries[0]+".tif";
	roi_path = entries[5];
	roi_id = entries[14];
	
	snapshot_path = path_to_snapshots + s + snapshot_name;
	open(snapshot_path);
	getDimensions(width, height, channels, slices, frames);
	pixel_size = 3 / width;

	open(roi_path);
	Stack.setXUnit("um");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+d2s(pixel_size,5)+" pixel_height="+d2s(pixel_size,5)+" voxel_depth=1");
	getDimensions(width, height, channels, slices, frames);
	run("Size...", "width=2048 height="+d2s(2048*height/width,0)+" depth=1 constrain average interpolation=Bilinear");
	run("Scale Bar...", "width=10 height=7 thickness=60 font=14 color=White background=None location=[Lower Right] horizontal bold hide overlay");
	
	waitForUser("contrast");
	
	close("*");
	
}

