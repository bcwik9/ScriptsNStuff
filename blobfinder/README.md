# blobfinder
A Blob is a shape in two-dimensional integer coordinate space where all cells have at least one adjoining cell to the right, left, top, or bottom that is also occupied. Given a 10x10 array of boolean values that represents a Blob uniformly selected at random from the set of all possible Blobs that could occupy that array, this program will determine the Blob boundaries.

General methodology was to find top, then bottom, then left, then right. Start iterating through until a 1 is located, then move on to the next boundary. Cells are only read once.

A different method might be to locate the blob structure and then iterate around the perimeter. It might be more efficient, but then it assumes that all 1s are touching, and doesn't allow for multiple blobs in one array.

One enhancement I could make is to allow txt files to be passed in as a parameter, and it will read the text file and turn it in to a blob array.


Sample 10x10 input:
```
0000000000
0011100000
0011111000
0010001000
0011111000
0000101000
0000101000
0000111000
0000000000
0000000000
```

Sample output:

Cell Reads: 44

Top: 1

Left: 2

Bottom: 7

Right: 6
