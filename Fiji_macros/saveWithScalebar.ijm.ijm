dist_in_mm = 12.42;
dist_in_pix = 9486;


run("Set Scale...", "distance="+d2s(dist_in_pix,0)+" known="+d2s(dist_in_mm,2)+" unit=mm");
// run("Scale Bar...", "width=1 height=1 thickness=100 font=150 color=White background=None location=[Lower Right] horizontal bold");

print(getInfo("image.directory") + File.separator + getInfo("image.filename"));
//saveAs("Tiff", getInfo("image.directory") + File.separator + getInfo("image.filename"));