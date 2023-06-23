// !Before you run this script, make sure your image is open!
// ----------------------------------------------------------
// This script will ask you to draw reference points and shapes on an image using the multi-point tool.
// It will then save the coordinates into an XML file, which can be read by the LMD.
// ----------------------------------------------------------

// Init
s = File.separator;
outFileName = File.getNameWithoutExtension(getTitle()) + "_LMD_coordinates.xml";

// Make dialog
Dialog.create("LMD coordinates");
Dialog.addDirectory("Choose output directory", getInfo("image.directory"));
Dialog.addString("Choose output filename", outFileName);
Dialog.addNumber("How many shapes do you want to draw?", 1);
Dialog.show();

// Get all variables
outDir = Dialog.getString();
outFileName = Dialog.getString();
nShapes = Dialog.getNumber();
nCalibration = 3; // There are 3 calibration points

run("Set Measurements...", "  redirect=None decimal=3");

// Delete ROIs if they exist
if ( roiManager("count") > 0 ) {
	roiManager("Deselect");
	roiManager("Delete");
}
roiManager("Show All");

xmlString = "<ImageData>\n<GlobalCoordinates>1</GlobalCoordinates>\n";

// Calibration points
setTool("multipoint");
for (c = 0; c < nCalibration; c++) {
	run("Clear Results");
	run("Select None");
	waitForUser("Use the multi-point tool to indicate calibration point "+d2s(c+1,0)+". \nNote! Do the calibration at the LMD in the same order as the one you use now. \nPress OK when ready.");
	run("Measure");
	roiManager("add");
	
	// Check that only one point was drawn
	if (nResults != 1) {
		exit("Please draw only one calibration point at a time! Run again to re-try.")
	}
	X = getResult("X", 0);
	Y = getResult("Y", 0);
	newLineX = "<X_CalibrationPoint_"+d2s(c+1,0)+">"+d2s(X,0)+"</X_CalibrationPoint_"+d2s(c+1,0)+">";
	newLineY = "<Y_CalibrationPoint_"+d2s(c+1,0)+">"+d2s(Y,0)+"</Y_CalibrationPoint_"+d2s(c+1,0)+">";
	xmlString = xmlString + newLineX + "\n" + newLineY + "\n";
}

xmlString = xmlString + "<ShapeCount>" + d2s(nShapes,0) + "</ShapeCount>\n";

// Loop over the number of shapes
setTool("multipoint");
for (s = 0; s < nShapes; s++) {
	xmlString = xmlString + "<Shape_" + d2s(s+1,0) + ">\n";
	
	// Ask the user to draw the shape, then measure it.
	run("Clear Results");
	run("Select None");
	waitForUser("Use the multi-point tool to draw the corners of shape "+d2s(s+1,0)+". Press OK when ready.");
	run("Measure");
	roiManager("add");
	
	// Add the number of points to XML file
	xmlString = xmlString + "<PointCount>" + d2s(nResults,0) + "</PointCount>\n";
	xmlString = xmlString + "<TransferID>ROI" + d2s(s+1,0) + "</TransferID>\n";
	xmlString = xmlString + "<CapID>A1</CapID>\n";
	
	// Loop over all points beloning to shape s
	for (i = 0; i < nResults(); i++) {
		X = getResult("X", i);
		Y = getResult("Y", i);
		newLineX = "<X_"+d2s(i+1,0)+">"+d2s(X,0)+"</X_"+d2s(i+1,0)+">";
		newLineY = "<Y_"+d2s(i+1,0)+">"+d2s(Y,0)+"</Y_"+d2s(i+1,0)+">";
		xmlString = xmlString + newLineX + "\n" + newLineY + "\n";
	}
	xmlString = xmlString + "</Shape_" + d2s(s+1,0) + ">\n";
}
xmlString = xmlString + "</ImageData>";

run("Clear Results");
run("Select None");

// Check if output file does not yet exist
outPath = outDir + outFileName;
if (File.exists(outPath)){
	File.delete(outPath);
	print("Overwriting existing XML file "+outPath);
}

// Print results to XML file
file = File.open(outPath);
print(file, xmlString);

print("Done! Results are saved to "+outPath);