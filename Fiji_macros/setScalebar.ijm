distance_pix = 2048;
distance_um = 211.2;
section_name = "A02 2020-015 SN 81A-NFH-Ubiquitin";
output_name = "Series002_Lng_LVCC_max_bf_scalebar.jpg";

run("Set Scale...", "distance="+d2s(distance_pix,0)+" known="+d2s(distance_um,1)+" unit=mm");
run("Scale Bar...", "width=20 height=15 font=60 color=White background=None location=[Lower Right] bold overlay");

saveAs("Jpeg", "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/Data/Thunder/"+section_name+"/"+output_name);
close();