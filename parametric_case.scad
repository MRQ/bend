/********************** Gehäuse-Dimensionen *************************/
// innenmaße in mm
length = 100;
width = 75;
height = 50;

// breite der laschen, maximal brick_height
flange = 10;

// höhe der unteren Elektronik, muss größer-gleich flange sein
lower_mount_height = 20;
// lochpositionen untere ebene, von der Mitte aus.
lower_mount_holes_left = [-10, +10];
lower_mount_holes_right = [0];

/********************** Werkzeug-Dimensionen *************************/
// maße des klemmstempels
brick_height = 15;
brick_depth = 21;

// kontour der oberen klemmwange
module upper_tool()
{
	polygon(
		points=[
			[0,0], // eigentliche biegekante
			[5, 7], // kante nach der schräge
			[10, 7], // bis zur schweißnaht
			[43, 45], // kante hinten oben
			[43, 0] // kante hinten unten
		],
		paths=[[0,1,2, 3, 4]]
	);
}

// obere klemme mit klotz
module upper_tool_with_brick()
{
	translate([0, brick_height, 0]) upper_tool();
	square([brick_depth, brick_height]);
}

// ob in der Animation bei Biegevorgängen die Position
// der Abkantbank angezeigt werden sollt
show_tool = true;

/********************** Code *************************/
//translate([0, 0, 0.5*height])
//color("grey") cube([length, width, height ], true);

bend1 = 90 * max(0, min(1, $t * 5 - 0));
bend2 = 90 * max(0, min(1, $t * 5 - 1));
bend3 = 90 * max(0, min(1, $t * 5 - 2));
bend4 = 90 * max(0, min(1, $t * 5 - 3));
echo (bend1);
echo (bend2);
echo (bend3);
echo (bend4);

// mittelteil
translate([-0.5 * length, -0.5 * width, 0]) square([length, width]);

if(show_tool && bend2 != 0 && bend2 != 90)
	for(dir = [-1, 1]) {
		translate([0, -0.5 * width * dir, 0])
		rotate(90 * dir, [0, 0, 1]) rotate(90, [1, 0, 0])
		linear_extrude(height = length + 2 * height, center = true)
		upper_tool();
	}

// seitenteil vorne/hinten
for (rot1 = [0, 180]) {
	rotate(rot1, [0, 0, 1])
	translate([0.5 * length, 0, 0])
	rotate(bend4, [0, -1, 0]){
		// seitenteile
		color("green")
		translate([0, -0.5 * width, 0])
			square([height, width]);
		// obere lasche
		translate([height, -0.5 * width, 0]) rotate(bend3, [0, -1, 0])
			square([flange, width]);
		if(show_tool && bend3 != 0 && bend3 != 90)
			translate([height, 0, 0])
			rotate(180, [0, 0, 1]) rotate(90, [1, 0, 0])
			linear_extrude(height=width, center=true) upper_tool_with_brick();		
		// seitliche laschen
		translate([0.5*height, 0, 0])	for (dir1 = [1, -1]) {
			multmatrix([
				[1,    0, 0, 0],
				[0, dir1, 0, 0],
				[0,    0, 1, 0],
				[0,    0, 0, 1]
			])
			translate([-0.5*height, 0.5*width, 0]) rotate(bend2, [1, 0, 0])
			square([height, flange]);
		}
		if(show_tool && bend4 != 0 && bend4 != 90)
			rotate(90, [1, 0, 0])
			linear_extrude(height=width, center=true) upper_tool_with_brick();
	}
}

// seitenteil links/rechts
color("red")
for (rot1 = [0, 180]) {
	rotate(rot1, [0, 0, 1])
	translate([0, -0.5*width, 0])
	rotate(bend2, [-1, 0, 0])
	{
		translate([-0.5*length, -lower_mount_height, 0]){
			// befestigungslaschen
			rotate(bend1, [-1, 0, 0]) {
				difference()
				//assign()
				{
					translate([0.5*length, 0, 0])
					{
						if(rot1 == 0) {
							for(x = lower_mount_holes_left) {
								translate([x, -0.5*flange, 0])
								square([flange, flange], true);
							}
						}
						else {
							for(x = lower_mount_holes_right) {
								translate([x, -0.5*flange, 0])
								square([flange, flange], true);
							}
						}
					}
					// werkzeug drehen, positionieren und projezieren
					projection(cut = true)
					for(dir = [-1,  1])
						multmatrix([
							[0, dir, 0, 0.5*length * (1 - dir)],
							[ 0, 0, 1, 0],
			           		[1, 0, 0, -lower_mount_height],
							[ 0, 0, 0, 1]
			               ])
						linear_extrude(height = 3*flange, center=true)
						minkowski() {
							upper_tool_with_brick();
							square([1, 1], true);
						}
				}
			}
			if(show_tool && bend1 != 0 && bend1 != 90)
				rotate(90, [0, 0, 1])	rotate(90, [1, 0, 0])
				linear_extrude(height = length, center=false)
				upper_tool();
			// grundlasche
			difference()
			//assign()
			{
				square([length, lower_mount_height]);
				for(dir = [-1,  1])
					multmatrix([
						[0, dir, 0, 0.5*length * (1 - dir)],
		           		[-1, 0, 0, lower_mount_height],
						[ 0, 0, 1, 0],
						[ 0, 0, 0, 1]
		               ])
					minkowski() {
						upper_tool_with_brick();
						square([1, 1], true);
					}
			}
		}
	}
	if(1 == 2) for(dir = [-1, 1]) {
		multmatrix([
			[0, dir, 0, -0.5*length * dir],
           		[-1, 0, 0, 0],
			[ 0, 0, 1, 0],
			[ 0, 0, 0, 1]
               ])
		minkowski() {
			upper_tool_with_brick();
			square([1, 1], true);
		}
	}
}
