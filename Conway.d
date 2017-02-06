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
	foreach (uint i, ulong x; xr){
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
	assert(xr.length == ya.length);
	xr[] = 0;
	for (uint i=a+1; i < xr.length-a-1; ++i){
		ulong y = ya[i];
		if (!y) continue;
		assert( i%a );   // Kein Eintrag am linken Rand
		assert((i+1)%a); //Kein Eintrag am rechten Rand
		ulong y_ = (y << 3) + (y >> 3),
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
pure bool checkFull(const ulong[] xr, const uint a){
	for (uint i = 0; i<a;)
		if (xr[i] || xr[$ - ++i]) return true;
	for (uint i= a; i<xr.length-1; i+=a)
		if  (xr[i] || xr[i+1]) return true;
	return false;
}

// Vergrößert das Array um den Faktor 9
// und schreibt den alten Inhalt in die Mitte des
// 3x3 Rechtecks
void enlarge(ref ulong[] y, const uint a)
in { assert(y.length%a == 0); }
body{
	uint l = y.length;
	ulong[] yn ;
	yn.length = 9*l;
	for (uint i=0, j = 3*l+a, b=a; i<l;){
		yn[j] = y[i];
		++j;
		if (++i-b) continue;
		j += 2*a;
		b += a;
	}
	y = yn;
}

// Erzeugt ein leeres Spielfeld mit mindestens min_s Seitenlänge
void createEmpty(const uint min_s, ref ulong[] yr, ref uint a){
	a = min_s / 21 + 3;
	yr.length = a*(21*a-40); 
	yr[] = 0;
}

// Baut ein quadratisches Feld aus einem rechteckigen boolschen Array 
// Funktioniert noch nicht richtig
void createFromBool(const bool[] b, const uint bline, 
					ref ulong[] yr, ref uint a){
	if (b.length%bline) {} //Fehler werfen
	const uint a1 = b.length/bline;
	createEmpty(a1<bline?bline:a1, yr, a);
	uint lr = (21*a-bline)/2,
		 ou = (yr.length/a - a1)/2;
	for (uint i=0, kk; i<a1; i++){
		for (uint j=0; j<bline; j++){
			kk = a*(ou+i) + (lr+j)/21;
			if (b[i*bline+j]) yr[kk]++;
			yr[kk]<<=3;
		}
		yr[kk] <<= (lr%21)*3;
	}
}

// Schiebt das ganze Feld um i nach links
void shiftLeft(uint i, ulong[] x, const uint a){
	assert (x.length % a ==0);
	immutable uint idiv = i/21, im = 3*(i%21);
	for (uint j=0, d=idiv, na=a; j<x.length;){
		x[j] = d<na ? x[d] << im : 0;
		if (++d<na) x[j] |= x[d] >> (63-im);
		x[j] &= 0x7FFFFFFFFFFFFFFF;
		if (++j==na) na+=a;
	}
}


// Schiebt das ganze Feld um i nach rechts
void shiftRight(uint i, ulong[] x, const uint a){
	assert (x.length % a ==0);
	immutable uint idiv = i/21, im = 3*(i%21);
	for (int j = x.length, d=j-idiv-1, na = j-a; j--;){
		// writeln("j=",j," d=",d);
		x[j] = d<na ? 0 : x[d] >> im;
		if (d-->na) x[j] |= x[d] << (63-im);
		x[j] &= 0x7FFFFFFFFFFFFFFF;
		if (j==na) na -= a;	
	}
}


// Schreibt das Feld auf die Standardausgabe
void writeQuick(const ulong[] x, const uint a){
	for (uint i=0;i<x.length;i+=a){
		const ulong[] line = x[i .. i+a];
		writefln("%(%021o%)", line);
	}
}


// Unittests
//--------------------------------------------------------------
// Testet, ob shiftLeft und shiftRight funktionieren
unittest{
	ulong[] x =[1+8+8*8*8,	8*8*8*8*8*8*8*8*8,	0x1249249249249249,
				1+8+8*8*8,	8*8*8*8*8*8*8*8*8,	0x1249249249249249];
	ulong [] x1 = x.dup;
	shiftLeft(1,x,3);
	shiftRight(1,x,3);
	assert (x==x1);
	
	writeQuick(x,3);
	shiftLeft(21,x,3);
	shiftRight(21,x1,3);
	assert(x ==[8*8*8*8*8*8*8*8*8,	0x1249249249249249,0,
				8*8*8*8*8*8*8*8*8,	0x1249249249249249,0]);
	assert(x1==[0, 1+8+8*8*8,	8*8*8*8*8*8*8*8*8,
				0, 1+8+8*8*8,	8*8*8*8*8*8*8*8*8]);
}


unittest{
	bool[ ] b =[0,1,1,
				1,1,0,
				0,1,0];
	ulong[] y;
	uint a;
	createFromBool(b,3,y,a);
	writeln("Erzeugungstest mit a=",a);
	writeQuick(y,a);
	b = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
	createFromBool(b,b.length,y,a);
	writeln("Erzeugungstest mit a=",a);
	writeQuick(y,a);
}

unittest{
	// writeln("Blinker Unittest");
	ulong[3*5] x,y,yo;
	y[7] =73 ;
	(y[7]<<=33)+=73;
	yo=y.dup;
	// writeQuick(y,3);
	// writeln("");
	countNeighbors(x,y,3);
	sire(x,y);
	// writeQuick(y,3);
	// writefln("");
	countNeighbors(x,y,3);
	sire(x,y);
	// writeQuick(y,3);
	assert(y==yo);
}

