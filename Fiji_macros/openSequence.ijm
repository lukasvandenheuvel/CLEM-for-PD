path = "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/Data/LH01_A02/1_Thunder/Series005";
s = File.separator;

pixel_size = 0.103; // um per pixel
pixel_depth = 0.3; // um per zstep

channel_array 	= newArray("ch0","ch1","ch2","ch3","ch4");
color_array 	= newArray("blue","green","yellow","magenta","gray");
name 			= "_s0_zstack";

close("*");
setBatchMode(true);
for (i = 0; i < channel_array.length; i++) {
	ch = channel_array[i];
	File.openSequence(path + s + ch + name + s);
	run("Set Scale...", "distance=1 known="+d2s(pixel_size,3)+" unit=um");
}

// Merge channels on the right colors
color_str = "";
for (i = 0; i < color_array.length; i++) {
	color = color_array[i];
	if (color=="red"){
		color_str = color_str + "c1=" + channel_array[i] + name + " ";
	}
	else if (color=="green") {
		color_str = color_str + "c2=" + channel_array[i] + name + " ";
	}
	else if (color=="blue") {
		color_str = color_str + "c3=" + channel_array[i] + name + " ";
	}
	else if (color=="gray") {
		color_str = color_str + "c4=" + channel_array[i] + name + " ";
	}
	else if (color=="cyan") {
		color_str = color_str + "c5=" + channel_array[i] + name + " ";
	}
	else if (color=="magenta") {
		color_str = color_str + "c6=" + channel_array[i] + name + " ";
	}
	else if (color=="yellow") {
		color_str = color_str + "c7=" + channel_array[i] + name + " ";
	}
	else{
		exit("Found unknown color in color channel!");
	}
}
run("Merge Channels...", color_str+"create");
print("Done!");
setBatchMode("exit and display");