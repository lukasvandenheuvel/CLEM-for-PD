
run("Duplicate...", "title=fx");
run("Duplicate...", "title=fy");

selectWindow("fx");
run("Convolve...", "text1=[1 2 1\n0 0 0\n-1 -2 -1\n] normalize");
run("Square");

selectWindow("fy");
run("Convolve...", "text1=[1 0 -1\n2 0 -2\n1 0 -1\n] normalize");
run("Square");

imageCalculator("Add create 32-bit", "fx","fy");
run("Square Root");
