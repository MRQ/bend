

bend_ake630_radius = 0.0005;
bend_ake630_width = 0.630;
thickness = 0.001;

/// Rauminhalt, der mit der AKE 630 festgehalten wird.
/// Möglichst simpel.
module bend_ake630_clampspace()
{
	translate([-0.1, 0, 0])
	cube(size=[0.2, bend_ake630_width, 0.1], center=true);
};

module bend_ake630_clamp_bar()
{
	rotate(90, [1, 0, 0])
	linear_extrude(height=bend_ake630_width, center=true)
	polygon(
		points=[
			[-0.000, 0.000], // eigentliche biegekante
			[-0.005, 0.007], // kante nach der schräge
			[-0.010, 0.007], // bis zur schweißnaht
			[-0.043, 0.045], // kante hinten oben
			[-0.043, 0.000] // kante hinten unten
		],
		paths=[[0,1,2, 3, 4]]
	);
};

module bend_ake630_bed()
{
	translate([-0.044/2 -0.001, 0, -0.01/2])
	cube([0.044, bend_ake630_width, 0.01], center=true);
}

module bend_ake630_bender()
{
	translate([0.012/2, 0, -0.056/2])
	cube([0.012, bend_ake630_width, 0.056], center=true);
	translate([-0.021/2, 0, -0.010/2 -0.023])
	cube([0.021, bend_ake630_width, 0.010], center=true);
};

/// Externe Funktion
module bend_brake(
	angle_deg = 90,
	anim = 1.0,
	at = [0, 0, 0],
	rot = 0
)
{
	translate(at)
	translate([-0.0002, 0, 0])
	rotate(rot, [0, 0, 1])
	bend_brake_detail(
		angle_deg = angle_deg * max(0.0, min(1.0, anim)),
		angle = angle_deg * (3.1415/180) * max(0.0, min(1.0, anim)),
		display_brake = (anim > 0.0 && anim <= 1.0),
		t = thickness,
		r1 = bend_ake630_radius,
		r2 = bend_ake630_radius + thickness,
		w = bend_ake630_width
	) {
		rotate(rot, [0, 0, -1])
		// 0.0002: empirisch ermittelte Lage der Biegestelle.
		translate([0.0002, 0, 0])
		translate(-1*at)
		child(0);
		
		bend_ake630_clampspace();
	};
	
};

module bend_brake_detail(
	angle_deg, angle, display_brake, t, r1, r2
)
{
	// unbend part (x < 0)	
	intersection() {
		child(0);
		child(1);
	};


	// bend part (x > 0)
	translate([
		sin(angle_deg) * r2,
		0,
		r2 - r2 * cos(angle_deg)
	])
	rotate(a = angle_deg, v = [0, -1, 0])
	translate([-r2 * angle, 0, 0])
	difference() {
		child(0);
		translate([r2 * angle, 0, 0])
		child(1);
	};
	
	// round part (x ~= 0)
	//color([1, 0, 0.2])
	rotate(a = angle_deg/2, v = [0, -1, 0])
	scale([2*abs(sin(angle_deg/2))/(angle+0.001), 1, 1])
	intersection() {
		child(0);
		translate([0, -w/2, -r2])
		cube([ r2 * angle, w, 2 * r2]);
	};
	
	// Visualisation
	if(display_brake)
	color([0.41, 0.51, 0.36])
	{
		translate([0, 0, t])
		bend_ake630_clamp_bar();
		
		bend_ake630_bed();
		
		translate([r2, 0, 0])
		rotate(a = angle_deg, v = [0, -1, 0])
		bend_ake630_bender();
		
	};
};



scale([1000, 1000, 1000])
{

bend_brake(30, 4*$t -2.4, at=[0.0, 0, 0], rot=-15)
bend_brake(30, 4*$t -1.2, at=[0.0, 0, 0], rot=0)
bend_brake(30, 4*$t, at=[0.0, 0, 0], rot=15)
{
	translate([0, -0.05, 0])
	cube([0.1, 0.1, 0.0005], true);

};

} // resize;

//cube();
