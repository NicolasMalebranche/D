import std.stdio;

// Let's get going!
void main()
{
	life();
}

void life(){
	writeln("Hier ist Conways Spiel des Lebens  (4bit)!");
	world w = createFromBool(f_pentomino,3);
	writeln("Start. a=",w.a,", Arraygroesse=", w.x.length);
	//writeQuick(x,a);
	//x1=x.dup;
	uint maxcycles = 2000;
	for (uint clock=0; clock<maxcycles; clock++){
		//writeln(clock,",");
		countNeighbors(w);
		//countNeighbors3(x1,a);
		/*if (x!=x1) {
		writeQuick(x,a);writeln;
		ar [] check =x.dup;
		check[] = x1[]-x[];
		writeQuick(check,a);}
		assert(x==x1);*/
		sire(w);
		//sire(x1);
		
		if (checkFull(w)){
			writeln("Erweitern!");
		
			enlarge(w);
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
static assert(Y*0xF+1==0);

struct world {
	ar [] x; // Array, das ein rechteckiges Feld repräsentiert
	ind a;   // Länge einer Zeile von x
}


// Wendet Conways Regel an: xr ist Anzahl der Nachbarn
// x stellt den aktuellen Bestand dar
// Zellen mit genau 3 Nachbarn werden bewohnt sein
// bewohnte Zellen mit genau 2 Nachbarn bleiben bewohnt
// anders ausgedrückt: 5,6,7 gehen auf 1, die andern auf 0
void sire(world w){
	foreach (ind i,ar u ; w.x) {
		if (u)
			w.x[i] = (u|u>>1) & u>>2 & ~u>>3 & Y;
	}
}


// Zählt die Nachbarn (0 bis 8)
// x ist der Bestand
// a ist Länge einer Zeile
void countNeighbors(world w){
	const ind a = w.a;
	ind i = a, max = w.x.length-a;
	ar 	y = (w.x[i] & Y) << 1,
		y_ = (y << 4) + (y >> 4),
		yl = y >> arbits-4,
		yr = y << arbits-4;
	goto Einsprung;
	for (; i-max ; ++i){
		if (!w.x[i]) continue;
		y = (w.x[i] & Y) << 1,
		y_ = (y << 4) + (y >> 4),
		yl = y >> arbits-4,
		yr = y << arbits-4;
		w.x[i-a-1] += yl;		
		Einsprung:
		w.x[i-a]   += y + y_;
		w.x[i-a+1] += yr;
		w.x[i-1]   += yl;
		w.x[i]     += y_;
		w.x[i+1]   += yr;
		w.x[i+a-1] += yl;
 		w.x[i+a]   += y + y_;
		if (i==max) break;
		w.x[i+a+1] += yr;	
	}
}


// Schaut, ob Werte an den vier Rändern stehen
pure bool checkFull(const world w){
	for (ind i = 0; i<w.a;)
		if (w.x[i] || w.x[$ - ++i]) return true;
	for (ind i= w.a; i<w.x.length; i+=w.a)
		if (w.x[i] || w.x[i-1])
		if (w.x[i] >> arbits-4 || w.x[i-1] << arbits-4) return true;
	return false;
}

// Vergrößert das Array um den Faktor 9
// und schreibt den alten Inhalt in die Mitte des
// 3x3 Rechtecks
void enlarge(ref world w)
in { assert(w.x.length%w.a == 0); }
body{
	const ind l = w.x.length, a = w.a;
	ar[] yn ;
	yn.length = 9*l;
	for (ind i=0, j = 3*l+a, b=a; i<l;){
		yn[j] = w.x[i];
		++j;
		if (++i-b) continue;
		j += 2*a;
		b += a;
	}
	w.x = yn;
	w.a = 3*a;
}

// Erzeugt ein leeres Spielfeld mit mindestens min_s Seitenlänge
world createEmpty(const ind min_s){
	world w ;
	w.a = min_s / arlength + 3;
	w.x.length = w.a*(arlength*(w.a-2) -2); 
	w.x[] = 0;
	return w;
}

// Baut ein quadratisches Feld aus einem rechteckigen boolschen Array 
world createFromBool(const bool[] b, const uint bline){
	if (b.length%bline) {assert(0);} // Fehler werfen
	const uint a1 = b.length/bline;
	world w = createEmpty(a1<bline?bline:a1);
	uint lr = (arlength*w.a-bline)/2,
		 ou = (w.x.length/w.a - a1)/2;
	for (uint i=0, kk; i<a1; i++){
		for (uint j=0; j<bline; j++){
			kk = w.a*(ou+i) + (lr+j)/arlength;
			w.x[kk]<<=4;
			if (b[i*bline+j]) w.x[kk]++;
		}
		w.x[kk] <<= (arlength-(lr+bline)%arlength)*4;
	}
	return w;
}

// Schiebt das ganze Feld um i nach links
void shiftLeft(uint i, world w){
	assert (w.x.length % w.a ==0);
	immutable uint idiv = i/arlength, im = 4*(i%arlength);
	for (ind j=0, d=idiv, na=w.a; j<w.x.length;){
		w.x[j] = d<na ? w.x[d] << im : 0;
		if (++d<na && im) w.x[j] |= w.x[d] >> arbits-im;
		if (++j==na) na+=w.a;
	}
}


// Schiebt das ganze Feld um i nach rechts
void shiftRight(uint i, world w){
	assert (w.x.length % w.a ==0);
	immutable uint idiv = i/arlength, im = 4*(i%arlength);
	for (int j = w.x.length, d=j-idiv-1, na = j-w.a; j--;){
		w.x[j] = d<na ? 0 : w.x[d] >> im;
		if (d-->na && im) w.x[j] |= w.x[d] << arbits-im;
		if (j==na) na -= w.a;	
	}
}


// Schreibt das Feld auf die Standardausgabe
void writeQuick(const world w){
	for (uint i=0;i<w.x.length;i+=w.a){
		const ulong[] line = w.x[i .. i+w.a];
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
	world w,w1;
	ar  [] x = [0x10001  ,	0x100000000,	Y,
				0x10001  ,	0x100000000,	Y];
	ar  [] x1 = x.dup;
	w.a = w1.a = 3;
	w.x=x;
	w1.x = x1;
	shiftLeft(1,w);
	shiftRight(1,w);
	assert (x==x1);
	shiftLeft(arlength,w);
	assert(x ==[  0x100000000,	Y,0,
				  0x100000000,	Y,0]);
	w.x = x = x1;
	shiftRight(arlength,w);
	assert(x==[ 0, 0x10001,	0x100000000,
				0, 0x10001,	0x100000000]);
	w.x = x = x1;
	shiftLeft(9,w);
	shiftLeft(9,w);
	shiftLeft(8,w);
	shiftLeft(26,w1);
	assert(x==x1);
	shiftRight(19,w);
	shiftRight(7,w);
	shiftRight(26,w1);
	assert(x==x1);
}

// Testet die fromBool Methode
unittest{
	writeln("fromBool Unittest");
	bool[ ] b =[0,1,1,
				1,1,0,
				0,1,0];
	world w = createFromBool(b,3);
	// writeln("Erzeugungstest mit a=",w.a);
	// writeQuick(w);
	b = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
	w = createFromBool(b,b.length);
	foreach (uint i, ulong v;w.x){
		if (v%2) assert(w.x[i+1]>>60); 
	}
}

unittest{
	writeln("Blinker Unittest");
	bool[] b = [0,1,0,
				0,1,0,
				0,1,0];
	world w = createFromBool(b,3);
	ar[] xo = w.x.dup;
	// writeQuick(w);
	// writeln("");
	countNeighbors(w);
	sire(w);
	// writeQuick(w);
	// writefln("");
	countNeighbors(w);
	sire(w);
	// writeQuick(w);
	assert(w.x==xo);
}

unittest{
	writeln("Doppel U unittest");
	world w = createFromBool(doppel_U,7);
	bool isN;
	for (int i=0; i<54; i++){
		isN = false;
		foreach (ar u; w.x) isN = isN || u;
		assert(isN);
		countNeighbors(w);
		sire(w);
		if (checkFull(w)){
			enlarge(w);
		}
	}
	isN = false;
		foreach (ar u; w.x) isN = isN || u;
	assert(!isN);
	
}

