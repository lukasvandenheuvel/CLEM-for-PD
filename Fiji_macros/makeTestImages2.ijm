img_nr = 85;

getSelectionBounds(x, y, width, height);
path = getInfo("image.directory") + getTitle();
text = d2s(img_nr,0) + ", " + d2s(x,0) + ", " + d2s(y,0) + ", " + d2s(width,0) + ", " + d2s(height,0) + ", " + path;
String.copy(text);

run("Duplicate...", " ");
saveAs("Tiff", "/Users/lukasvandenheuvel/Documents/EPFL/MA4/PDM/EM_snapshots/img"+d2s(img_nr,0)+".tif");