import std.stdio;

// Let's get going!
void main()
{
	life();
}

void life(){
	writeln("Hier ist Conways Spiel des Lebens!");
	ulong[] xr, yr;
	uint a = 5;
	xr.length = yr.length= a*a*21;
	writeln("Start. a=",a,", Arraygroesse=", xr.length);
	uint maxcycles = 2000;
	yr[252] = 8; yr[257]= 72; yr[262]= 9; //F-Pentomino
	
	for (uint clock=0; clock<maxcycles; clock++){
		countNeighbors(xr,yr,a);
		sire(xr,yr);
		if (checkFull(xr,a)){
			writeln("Erweitern!");
			enlarge(yr,a);
			xr.length *= 9;
		}
	}
}

// Wendet Conways Regel an: xr ist Anzahl der Nachbarn
// yr stellt den aktuellen Bestand dar
// Zellen mit genau 3 Nachbarn werden bewohnt sein
// bewohnte Zellen mit genau 2 Nachbarn bleiben bewohnt
void sire(const ulong[] xr, ulong[] yr){
	for (uint i=0; i<yr.length; ++i){
		ulong x = xr[i];
		yr[i] = x ? 
			(yr[i]|x) & (x>>1) & (~x>>2) &  0x1249249249249249
			: 0;
	}
}

// Zählt die Nachbarn (0 bis 8)
// ya ist der Bestand
// xr wird beschrieben
// a ist Länge einer Zeile
void countNeighbors(ulong[] xr, const ulong[] ya, const uint a){
	xr[] = 0;
	ulong y, y_, yl, yr;
	for (uint i=a+1; i < xr.length-a-1; ++i){
		y = ya[i];
		if (!y) continue;
		assert( i%a );   // Kein Eintrag am linken Rand
		assert((i+1)%a); //Kein Eintrag am rechten Rand
		y_ = (y << 3) + (y >> 3),
		yl = y >> 60,
		yr = y << 60; 
		xr[i-a] 	+= y + y_;
		xr[i-a-1] 	+= yl;
		xr[i-a+1] 	+= yr;
		xr[i]   	+= y_;
		xr[i-1] 	+= yl;
		xr[i+1] 	+= yr;
 		xr[i+a] 	+= y + y_;
		xr[i+a-1] 	+= yl;
		xr[i+a+1] 	+= yr;		
	}
}


// Schaut, ob Werte an den vier Rändern stehen
bool checkFull(const ulong[] xr, const uint a){
	bool large = false;
	for (uint i = 0; i<a;)
		large = large || xr[i] || xr[$ - ++i];
	for (uint i= a; i<xr.length-1; i+=a)
		large = large || xr[i] || xr[i+1];
	return large;
}


// Vergrößert das Array um den Faktor 9
// und schreibt den alten Inhalt in die Mitte des
// 3x3 Rechtecks
void enlarge(ref ulong[] y, const uint a)
in { assert(y.length%a == 0); }
body{
	uint l = y.length;
	y.length = 9*l;
	for (uint i=0, j = 3*l+a, b=a; i<l;){
		y[j] = y[i];
		y[i] = 0;
		if (++i-b) j++;
		else {
			j += 2*a+1;
			b += a;
		}
	}
}

void writeQuick(ulong[] x, const uint a){
	for (uint i=0;i<x.length;i+=a){
		ulong[] line = x[i .. i+a];
		writefln("%(%021o%)", line);
	}
}

unittest{
	writeln("Blinker Unittest");
	ulong[3*5] x,y,yo;
	y[7] =73 ;
	(y[7]<<=33)+=73;
	yo=y.dup;
	writeQuick(y,3);
	writeln("");
	countNeighbors(x,y,3);
	sire(x,y);
	writeQuick(y,3);
	writefln("");
	countNeighbors(x,y,3);
	sire(x,y);
	writeQuick(y,3);
	assert(y==yo);
}

