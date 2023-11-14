$fa = 1;                            // fa and fs are for rendering quality                      
$fs = 0.01;                         

g_screw_hole_spacing = 105;         // distance between fan screw holes
g_screw_hole_size = 5.5;	        // screw hole size
g_outer_size = 120;	                // size of outer square
g_corner_cut_radius = 5;	        // radius of circle drawn around square to round off the corners
g_outer_circle_diameter = 126;	    // diameter of actual fan
g_inner_circle_diameter = 40;	    // diameter of center support circle
g_outer_thickness = 2;		        // Thickness of square outer frame
g_inner_thickness = 2;		        // Vane thickness - should be less than outer_thickness so the fan blades will not hit
g_stand_thickness= 2;               // thickness of the 
g_stand_height=30;

g_vane_count = 8;			        // how many vanes from the center they should be
g_vane_width = 2;                   // how thick the fan vanes are
g_ring_count = 2;                   // how many additional vane support rings there should be
g_ring_width = 2;                   // and how thick they are

// some calculated values
g_vane_angle = 360 / g_vane_count;
// ring_spacing defines the CENTER of each ring (radius)
g_ring_spacing = (g_outer_circle_diameter - g_inner_circle_diameter+g_ring_width)/(g_ring_count+1)/2;
//ring_spacing = outer_circle_diameter;

g_hole_outer_edge = (g_outer_size - g_screw_hole_spacing) /2;
tiny = 0.128;                       // a small value to help with z-fighting in preview

// module for creating a rectangle with rounded corners
module rounded_corners(x, y, z, fillet, center=true)
{
    union () {
    translate (v=[fillet, fillet])
        cylinder(z, fillet, fillet);
    
    translate (v=[fillet, y-fillet])
        cylinder(z, fillet, fillet);
    
    translate (v=[x-fillet, fillet])
        cylinder(z, fillet, fillet);
    
    translate (v=[x-fillet, y-fillet])
        cylinder(z, fillet, fillet);
    
    translate (v=[fillet, 0])
        cube( [x-(fillet*2), y, z]);
    
    translate (v=[0, fillet])
        cube([x, y-(fillet*2), z]);
    }
}

module fan_center (outer_thickness, outer_circle_diameter, outer_size, ring_width) 
{
    // cut the main center hole
    intersection()
    {
        cylinder(h=outer_thickness, r=outer_circle_diameter/2);
        translate(v=[-outer_size/2+ring_width, -outer_size/2+ring_width, 0])
            cube([outer_size-ring_width*2, outer_size-ring_width*2, outer_thickness]);
    }
}

module stand (outer_thickness, inner_thickness, height) 
{
    difference () 
    {
        cylinder(h=height, r=outer_thickness/2);
        
        translate([0, 0, -tiny/2])
            cylinder(h=height+tiny, r=inner_thickness/2);
    }
}


module plate (outer_size, outer_thickness, corner_cut_radius, outer_circle_diameter, ring_width, hole_spacing, hole_size) {
    difference()
    {
               
        rounded_corners(outer_size, outer_size, outer_thickness, corner_cut_radius);
        
        // cut the screw holes
        clean_height= outer_thickness+tiny;

        hole_outer_edge = (outer_size - hole_spacing) /2;
        
        translate(v=[hole_outer_edge, hole_outer_edge, -tiny/2])
            cylinder(h=clean_height, r=hole_size/2);
        translate(v=[hole_outer_edge, hole_outer_edge+hole_spacing, -tiny/2])
            cylinder(h=clean_height, r=hole_size/2);
        translate(v=[hole_outer_edge+hole_spacing,hole_outer_edge, -tiny/2])
            cylinder(h=clean_height, r=hole_size/2);
        translate(v=[hole_outer_edge+hole_spacing, hole_outer_edge+hole_spacing, -tiny/2])
            cylinder(h=clean_height, r=hole_size/2);
        
        // cut out fan center
        translate (v=[outer_size/2, outer_size/2, -tiny/2])
            fan_center(outer_thickness+tiny, outer_circle_diameter, outer_size, ring_width);
                
    }
}

// main plate
plate (g_outer_size, g_outer_thickness, g_corner_cut_radius, g_outer_circle_diameter, g_ring_width, g_screw_hole_spacing, g_screw_hole_size);

g_stand_outer_size = g_screw_hole_size + g_stand_thickness + 2;

// stands
translate(v=[g_hole_outer_edge, g_hole_outer_edge, g_outer_thickness-tiny/2])
    stand (g_stand_outer_size, g_screw_hole_size+2, g_stand_height);
translate(v=[g_hole_outer_edge, g_hole_outer_edge+g_screw_hole_spacing, g_outer_thickness-tiny/2])
    stand (g_stand_outer_size, g_screw_hole_size+2, g_stand_height);
translate(v=[g_hole_outer_edge+g_screw_hole_spacing,g_hole_outer_edge, g_outer_thickness-tiny/2])
    stand (g_stand_outer_size, g_screw_hole_size+2, g_stand_height);
translate(v=[g_hole_outer_edge+g_screw_hole_spacing, g_hole_outer_edge+g_screw_hole_spacing, g_outer_thickness-tiny/2])
    stand (g_stand_outer_size, g_screw_hole_size+2, g_stand_height);

translate (v=[g_outer_size/2, g_outer_size/2, g_outer_thickness-g_inner_thickness]) {
    // the inner circle
    cylinder(h=g_inner_thickness, r=g_inner_circle_diameter/2);

    // vanes
    // rotate for aesthetics
    rotate([0,0,g_vane_angle/2])
    for (angle = [0 : g_vane_angle : 360] )
        {
            rotate([0,0,angle])
            translate(v=[0,-g_vane_width/2,0])
            cube(size=[g_outer_circle_diameter/2, g_vane_width, g_inner_thickness]);
        }
        
    // circles
    for (x = [1 : g_ring_count ])
    {
        difference()
        {
            cylinder(h=g_inner_thickness, r=g_inner_circle_diameter/2 + (g_ring_spacing * x) + (g_ring_width/2));
            translate (v=[0, 0, -tiny/2])
                cylinder(h=g_inner_thickness+tiny, r=g_inner_circle_diameter/2 + (g_ring_spacing * x) - (g_ring_width/2));
        }
    }
	
}
