import std.stdio;

// Let's get going!
void main()
{
	life();
}

void life(){
	writeln("Hier ist Conways Spiel des Lebens  (4bit)!");
	ulong[] x,x1;
	uint a ;
	createFromBool(f_pentomino,3,x,a);
	writeln("Start. a=",a,", Arraygroesse=", x.length);
	writeQuick(x,a);
	x1=x.dup;
	uint maxcycles = 2000;
	for (uint clock=0; clock<maxcycles; clock++){
		writeln(clock,",");
		countNeighbors(x,a);
		countNeighbors2(x1,a);
		if (x!=x1) {
		writeQuick(x,a);writeln;
		ar [] check =x.dup;
		check[] = x1[]-x[];
		writeQuick(check,a);}
		assert(x==x1);
		sire(x);
		sire(x1);
		
		if (checkFull(x,a)){
			writeln("Erweitern!");
		
			enlarge(x,a);
			enlarge(x1,a);
			a*=3;
		}
	}
}

// Beispiel-Startkonfigurationen
immutable bool[]  
 f_pentomino = [0,1,1,
				1,1,0,
				0,1,0],
 doppel_U= [1,1,1,0,1,1,1,
			1,0,0,0,0,0,1,
			1,1,1,0,1,1,1];

// Felder in Conways Spiel des Lebens werden bitwise gespeichert
// ein Feld entspricht 4 Bits
// das Bit ganz rechts zeigt an, ob das Feld bewohnt ist
// die andern 3 Bits zählen bis zu 8 Nachbarn.

// Das ganze lebt auf 64-Bit oder 32-Bit unsigned integer

alias ind = uint; // Indextyp
alias ar  = ulong; //oder uint
enum ind arbits = ar.sizeof * 8;
enum ind arlength = ar.sizeof * 2;
enum ar Y = 0x1111111111111111; // nur die rechten Bits sind 1
enum ar X = 0xEEEEEEEEEEEEEEEE; // nur die linken Bits sind 1
static assert(X+Y+1==0);

// Wendet Conways Regel an: xr ist Anzahl der Nachbarn
// x stellt den aktuellen Bestand dar
// Zellen mit genau 3 Nachbarn werden bewohnt sein
// bewohnte Zellen mit genau 2 Nachbarn bleiben bewohnt
// anders ausgedrückt: 5,6,7 gehen auf 1, die andern auf 0
void sire(ar[] x){
	foreach (ind i,ar u ; x) {
		if (u)
			x[i] = (u|u>>1) & u>>2 & ~u>>3 & Y;
	}
}


// Zählt die Nachbarn (0 bis 8)
// x ist der Bestand
// a ist Länge einer Zeile
void countNeighbors(ar[] x, const ind a){
	for (ind i=a+1, max=x.length-a-1; i < max; ++i){
		ar y = (x[i] & Y) << 1;
		if (!y) continue;
		assert( i%a );   // Kein Eintrag am linken Rand
		assert((i+1)%a); //Kein Eintrag am rechten Rand
		ar y_ = (y << 4) + (y >> 4),
			  yl = y >> arbits-4,
			  yr = y << arbits-4; 
		x[i-a] 	+= y + y_;
		x[i-a-1]+= yl;
		x[i-a+1]+= yr;
		x[i]   	+= y_;
		x[i-1] 	+= yl;
		x[i+1] 	+= yr;
 		x[i+a] 	+= y + y_;
		x[i+a-1]+= yl;
		x[i+a+1]+= yr;		
	}
}

// Alternativer Nachbarzähler
void countNeighbors2(ar[] x,  const ind a){
	assert (x.length % a ==0);
	ar u, left;
	for (ind i=1; i < x.length-a; ++i){
		x[i] 	+= x[i+a] << 1;
		u = x[i] & Y;
		x[i+a]	+= u << 1;
		u   	+= x[i];
		assert (u == (u&X));
		x[i-1] 	+= u >> arbits-4;
		x[i] 	+= (u<<4) + (u>>4); 
		x[i]	+= (left << arbits-4);
		left = u;
	}
	for (ind i=x.length-a; i<x.length; ++i){
		u = ((x[i]&Y) << 1) +x[i];
		x[i] += (u<<4) + (u>>4) + (left<< arbits-4); 
		x[i-1] += u >> arbits-4;
		left = u;
	}
}


// Schaut, ob Werte an den vier Rändern stehen
pure bool checkFull(const ar[] xr, const ind a){
	for (ind i = 0; i<a;)
		if (xr[i] || xr[$ - ++i]) return true;
	for (ind i= a; i<xr.length; i+=a)
		if  (xr[i] || xr[i-1]) return true;
		//if (xr[i] >> arbits-4 || xr[i-1] << arbits-4) return true;
	return false;
}

// Vergrößert das Array um den Faktor 9
// und schreibt den alten Inhalt in die Mitte des
// 3x3 Rechtecks
void enlarge(ref ar[] y, const ind a)
in { assert(y.length%a == 0); }
body{
	ind l = y.length;
	ar[] yn ;
	yn.length = 9*l;
	for (ind i=0, j = 3*l+a, b=a; i<l;){
		yn[j] = y[i];
		++j;
		if (++i-b) continue;
		j += 2*a;
		b += a;
	}
	y = yn;
}

// Erzeugt ein leeres Spielfeld mit mindestens min_s Seitenlänge
void createEmpty(const ind min_s, ref ar[] x, ref ind a){
	a = min_s / arlength + 3;
	x.length = a*(arlength*(a-2) -2); 
	x[] = 0;
}

// Baut ein quadratisches Feld aus einem rechteckigen boolschen Array 
void createFromBool(const bool[] b, const uint bline, 
					ref ulong[] x, ref uint a){
	if (b.length%bline) {assert(0);} // Fehler werfen
	const uint a1 = b.length/bline;
	createEmpty(a1<bline?bline:a1, x, a);
	uint lr = (arlength*a-bline)/2,
		 ou = (x.length/a - a1)/2;
	for (uint i=0, kk; i<a1; i++){
		for (uint j=0; j<bline; j++){
			kk = a*(ou+i) + (lr+j)/arlength;
			x[kk]<<=4;
			if (b[i*bline+j]) x[kk]++;
		}
		x[kk] <<= (arlength-(lr+bline)%arlength)*4;
	}
}

// Schiebt das ganze Feld um i nach links
void shiftLeft(uint i, ulong[] x, const uint a){
	assert (x.length % a ==0);
	immutable uint idiv = i/arlength, im = 4*(i%arlength);
	for (uint j=0, d=idiv, na=a; j<x.length;){
		x[j] = d<na ? x[d] << im : 0;
		if (++d<na && im) x[j] |= x[d] >> arbits-im;
		if (++j==na) na+=a;
	}
}


// Schiebt das ganze Feld um i nach rechts
void shiftRight(uint i, ulong[] x, const uint a){
	assert (x.length % a ==0);
	immutable uint idiv = i/arlength, im = 4*(i%arlength);
	for (int j = x.length, d=j-idiv-1, na = j-a; j--;){
		// writeln("j=",j," d=",d);
		x[j] = d<na ? 0 : x[d] >> im;
		if (d-->na && im) x[j] |= x[d] << arbits-im;
		if (j==na) na -= a;	
	}
}


// Schreibt das Feld auf die Standardausgabe
void writeQuick(const ulong[] x, const uint a){
	for (uint i=0;i<x.length;i+=a){
		const ulong[] line = x[i .. i+a];
		if (arlength == 16)
		writefln("%(%016x%)", line);
		else 
		writefln("%(%08x%)", line);
	}
}


// Unittests
//--------------------------------------------------------------
// Testet, ob shiftLeft und shiftRight funktionieren
unittest{
	writeln("Shift Unittest");
	ulong[] x =[0x10001  ,	0x100000000,	Y,
				0x10001  ,	0x100000000,	Y];
	ulong [] x1 = x.dup;
	//writeQuick(x,3);
	shiftLeft(1,x,3);
	//writeQuick(x,3);
	shiftRight(1,x,3);
	//writeQuick(x,3);
	assert (x==x1);
	shiftLeft(arlength,x,3);
	//writeQuick(x,3);
	assert(x ==[0x100000000,	Y,0,
				0x100000000,	Y,0]);
	x = x1;
	shiftRight(arlength,x,3);
	assert(x==[0, 0x10001,	0x100000000,
				0, 0x10001,	0x100000000]);
	x = x1;
	shiftLeft(9,x,3);
	shiftLeft(9,x,3);
	shiftLeft(8,x,3);
	shiftLeft(26,x1,3);
	assert(x==x1);
	shiftRight(19,x,3);
	shiftRight(7,x,3);
	shiftRight(26,x1,3);
	assert(x==x1);
}

// Testet die fromBool Methode
unittest{
	writeln("fromBool Unittest");
	bool[ ] b =[0,1,1,
				1,1,0,
				0,1,0];
	ulong[] y;
	uint a;
	createFromBool(b,3,y,a);
	// writeln("Erzeugungstest mit a=",a);
	// writeQuick(y,a);
	b = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
	createFromBool(b,b.length,y,a);
	foreach (uint i, ulong v;y){
		if (v%2) assert(y[i+1]>>60); 
	}
}

unittest{
	writeln("Blinker Unittest");
	bool[] b = [0,1,0,
				0,1,0,
				0,1,0];
	ar[] x;
	ind a;
	createFromBool(b,3,x,a);
	ar[] xo = x.dup;
	// writeQuick(x,3);
	// writeln("");
	countNeighbors(x,a);
	sire(x);
	// writeQuick(x,3);
	// writefln("");
	countNeighbors(x,a);
	sire(x);
	// writeQuick(x,3);
	assert(x==xo);
}

unittest{
	writeln("Doppel U unittest");
	ar[] x,x1;
	ind a;
	createFromBool(doppel_U,7,x,a);
	x1 = x.dup;
	bool isN;
	for (int i=0; i<54; i++){
		isN = false;
		foreach (ar u; x) isN = isN || u;
		assert(isN);
		countNeighbors(x,a);
		countNeighbors2(x1,a);
		assert(x==x1);
		sire(x);
		sire(x1);
		if (checkFull(x,a)){
			writeln("Erweitern!");
			enlarge(x,a);
			enlarge(x1,a);
			a *= 3;
		}
	}
	isN = false;
		foreach (ar u; x) isN = isN || u;
	assert(!isN);
	
}

