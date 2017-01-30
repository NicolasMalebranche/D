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
		if (checkLarge(xr,a)){
			writeln("Erweitern!");
			ulong[] yn;
			yn.length = yr.length*9;
			copyLarger(yn,yr,a);
			yr=yn;
			a*=3;
			xr.length *= 9;
		}
	}
}

void sire(const ulong[] xr, ulong[] yr){
	for (uint i=0; i<yr.length; ++i){
		ulong x = xr[i];
		yr[i] = x ? 
			(yr[i]|x) & (x>>1) & (~x>>2) &  0x1249249249249249
			: 0;
	}
}

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

bool checkLarge(ulong[] xr, const uint a){
	bool large = false;
	for (uint i = 0; i<a;)
		large = large || xr[i] || xr[$ - ++i];
	for (uint i= a; i<xr.length-1; i+=a)
		large = large || xr[i] || xr[i+1];
	return large;
}

void copyLarger(ulong[] yn, const ulong[] yr, const uint a){
	uint i_n = a+ 3*a*21*a, i_r;
	for (uint j=0; j< 21*a; ++j){
		for (uint i=0; i<a ; ++i, ++i_n, ++i_r){
			yn[i_n] = yr[i_r];
		}
		i_n += 2*a;
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

// Seitenlänge = a*21


// x==3 = (x|y) & x >> 1 & ~x >> 2
// 1001 = 9
// 0100 = 4
// 0010 = 2

