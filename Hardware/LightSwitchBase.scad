
// Size of the outer bezel that surounds the PCB
bezelSize = 2;

// Thickness of the wall.
wallThickness = 8;

// PCB size we are trying to fit.
pcbHeight = 180;
pcbWidth = 100;
// How thick (deep) the front panel is (1.6mm FR4 PCB)
pcbThickness = 1.6;

// Overall size
height = pcbHeight + (2*bezelSize);
width = pcbWidth + (2*bezelSize);
depth = 20;



// Switch size (physical size of the light switch being covered)
switchHeight = 88;
switchWidth = 88;
switchDepth = 22;
// How much the switch body should overlap onto the base
switchOverlap = 5;

middleDepth = 10;



// How deep the inside of the box is.
baseInnerThickness = 1;

// -----------------------------------------
// -----------------------------------------
module GenericBase(xDistance, yDistance, zHeight) {
	// roundedBox([xDistance, yDistance, zHeight], 2, true);

	// Create a rectangluar base to work from that
	// is xDistance by yDistance and zHeight height.

	// This is effectivly a cube with rounded corners

	// extend the base out by 3.5 from holes by using minkowski
	// which gives rounded corners to the board in the process
	// matching the Gadgeteer design
	
	$fn=50;
	radius = 5; //bezelSize;


	translate([radius,radius,0]) {
		minkowski()
		{
			// 3D Minkowski sum all dimensions will be the sum of the two object's dimensions
			cube([xDistance-(radius*2), yDistance-(radius*2), zHeight /2]);
			cylinder(r=radius,h=zHeight/2);
		}
	}
}

// -----------------------------------------
// -----------------------------------------
module LightSwitchBase() {
	
	innerWallOffset = 4;

	difference() {
		union() 
		{
			// Outer base wall
			OuterWall();
		}		
		union() 
		{
			SwitchCutout();
			PcbCutout();
		}
	}
}

// -----------------------------------------
// Outer wall
// -----------------------------------------
module OuterWall() {

innerCutoutOffset = bezelSize + 2; // Wall thickness

	difference() {
		union() {
			GenericBase(width, height, depth);
		}
		union() {
			// Cut out the bulk of the inside of the box.
			// Outerwall padding = 5
			// Move in 5, down 5 and up 2 to provide an 
			// outline of 5x5 with 2 base.
			translate([innerCutoutOffset, innerCutoutOffset, baseInnerThickness]) {
				GenericBase(width - (innerCutoutOffset * 2), 
									height - (innerCutoutOffset *2), 
									(depth - baseInnerThickness) + 1);
			}
		}
	}
}

// -----------------------------------------
// -----------------------------------------
module SwitchCutout() {

	// Cutout smaller than the actual switch to allow for the overlap all around
	cutoutWidth = switchWidth - (switchOverlap*2);
	cutoutHeight = switchHeight - (switchOverlap*2);	

	// Padding either side of the cutout.
	paddingWidth = (width - cutoutWidth) / 2;
	paddingHeight = 15; // Fixed padding from top.

	// Switch cutout.
	// Cut out a area less wide than the switch so it sits on it 
	// keeping the box against the wall
	// -1 z to ensure it goes all the way through
	translate([paddingWidth, paddingHeight, -1]) {
		cube([cutoutWidth, cutoutHeight, 4]);
	}

	// Switch body
	// Create a block to show how the switch body sits
	// in the base.
	switchOuterPaddingWidth = (width - switchWidth) /2;
	switchOuterPaddingHeight = paddingHeight - switchOverlap;

	translate([switchOuterPaddingWidth , switchOuterPaddingHeight,1]) {
		color( [1, 0, 0, 0.90] ) {
				cube([switchWidth, switchHeight, switchDepth]);
		}
	}
}

// -----------------------------------------
// -----------------------------------------
module PcbCutout() {
	// Move to a slight offset to allow for an outer bezel.
	// and position so the top of the pcb is at the top of the base box.
	translate([bezelSize, bezelSize, depth - (pcbThickness - 0.1)]) {
		//cube([cutoutWidth, cutoutHeight, 4]);

		GenericBase(pcbWidth, pcbHeight, pcbThickness);
	}
}

// -----------------------------------------
// Add ears to the base to help prevent lift.
// -----------------------------------------
module GiveItEars() {
earSize = 12;
yFudgeForEarOverlap = -1;
earDepth = 1;
connectorWidth = 3;
connectorLength = earSize - yFudgeForEarOverlap + 2;
earOffset = -2;

	translate([0 + earSize + earOffset, -earSize + yFudgeForEarOverlap,0])  {
		cylinder(r=earSize,h=earDepth);
		cube([connectorWidth, connectorLength, earDepth]);
	}

	translate([width - earSize - earOffset, -earSize + yFudgeForEarOverlap,0]) {
		cylinder(r=earSize,h=earDepth);
		cube([connectorWidth, connectorLength, earDepth]);
	}

	translate([width - earSize - earOffset,height + earSize - yFudgeForEarOverlap,0]) {
		cylinder(r=earSize,h=earDepth);
		translate([0,-connectorLength,0] ) {
			cube([connectorWidth, connectorLength, earDepth]);
		}
	}

	translate([0 + earSize + earOffset,height + earSize - yFudgeForEarOverlap,0]) {
		cylinder(r=earSize,h=earDepth);
		translate([0,-connectorLength,0] ) {
			cube([connectorWidth, connectorLength, earDepth]);
		}
	}
}

// -----------------------------------------
// -----------------------------------------
module Debug() {

	LightSwitchBase();

	GiveItEars();
}

// Comment out when building, uncomment for debug.
Debug();