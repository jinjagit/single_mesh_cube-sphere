# Cube-sphere with 1 continuous mesh

Given that Godot seems to handle more than 64k vertices per mesh (which can be a limitation on 32 bit architecture / software), one of the main reasons to separate a cube-sphere into 6 separate faces is no longer a concern.

This repo creates a single-mesh cube-sphere of the specified resolution (vertices per cube edge), with the vertex spacing adjusted to best equalize the size of the grid quads.