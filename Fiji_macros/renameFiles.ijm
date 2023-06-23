channels = newArray("0","1","2","3","4");
root = "/Volumes/PROJECTS_1T/PDM/Data/LH02_A04/1_Thunder_fluo/T1/tiles";
s = File.separator;

for (c = 0; c < channels.length; c++) {
	ch = channels[c];
	folder = root + s + "ch" + ch + "_zmax_sfused";
	files = getFileList(folder);
	
	
	for (i = 0; i < files.length; i++) {
		oldname = files[i];
		
		if (oldname.contains("img")){
			split1 = split(oldname,"(img)");
			split2 = split(split1[1],"(.tif)");
			nr = split2[0];
			newname = "s" + nr + "_zmax.tif";
			success = File.rename(folder + s + oldname, folder + s + newname);
		}
	}
}
print("Done!");