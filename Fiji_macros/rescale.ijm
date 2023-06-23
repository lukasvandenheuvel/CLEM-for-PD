//setTool("zoom");
rescale = 0.1; 	//
pixel_size = 4.23; // Pixel size in nm


filedir = getInfo("image.directory");
filename = File.getNameWithoutExtension(filedir + getInfo("image.filename"));

getDimensions(width, height, channels, slices, frames);
new_width = round(rescale*width);
new_height = round(rescale*height);

pixel_size_um = pixel_size / 1000;
run("Set Scale...", "distance=1 known="+d2s(pixel_size_um,5)+" unit=um");
run("Enhance Contrast...", "saturated=0.35 equalize");

run("Scale...", "x="+d2s(rescale,1)+" y="+d2s(rescale,1)+" width="+d2s(new_width,0)+" height="+d2s(new_height,0)+" interpolation=Bicubic average create");
run("Scale Bar...", "width=10 height=6 thickness=20 font=40 color=White background=None location=[Lower Right] horizontal bold overlay");

saveAs("Tiff", filedir + filename + "_small_scalebar.tif");
