# ifndef KX
# define KX

typedef char*S,C;
typedef unsigned char G;
typedef short H;
typedef int I;
typedef long long J;
typedef float E;
typedef double F;
typedef void V;

typedef struct k0{
			I r;
			H t // t is the type of the K object. If t==-128 then this is an error.
			 ,u;
			union{
					G g;
					H h;
					I i;
					J j;
					E e;
					F f;
					S s;
					struct k0*k;
					struct{I n;G G0[1];};
			};
		}*K;

//#include<string.h>
// vector accessors, e.g. kF(x)[i] for float&datetime
# define kG(x)   ((x)->G0)
# define kC(x)   kG(x)
# define kH(x)   ((H*)kG(x))
# define kI(x)   ((I*)kG(x))
# define kJ(x)   ((J*)kG(x))
# define kE(x)   ((E*)kG(x))
# define kF(x)   ((F*)kG(x))
# define kS(x)   ((S*)kG(x))
# define kK(x)   ((K*)kG(x))

//      type bytes qtype    ctype  accessor
# define KB 1  // 1 boolean  char   kG
# define KG 4  // 1 byte     char   kG
# define KH 5  // 2 short    short  kH
# define KI 6  // 4 int      int    kI
# define KJ 7  // 8 long     int64  kJ
# define KE 8  // 4 real     float  kE
# define KF 9  // 8 float    double kF
# define KC 10 // 1 char     char   kC
# define KS 11 // * symbol   char*  kS
# define KP 12 // 8 timestampint64  kJ (nanoseconds from 2000.01.01)
# define KM 13 // 4 month    int    kI
# define KD 14 // 4 date     int    kI (days from 2000.01.01)
# define KZ 15 // 8 datetime double kF (days from 2000.01.01)
# define KN 16 // 8 timespan int64  kJ
# define KU 17 // 4 minute   int    kI
# define KV 18 // 4 second   int    kI
# define KT 19 // 4 time     int    kI (millisecond)

// table,dict
# define XT 98 //   x->k is XD
# define XD 99 //   kK(x)[0] is keys. kK(x)[1] is values.

# ifdef __cplusplus
	extern"C"{
# endif
extern I khpun(const S,I,const S,I)
		,khpu(const S,I,const S)
		,khp(const S,I)					// int c = khp("localhost", 1234); // Connect to a Kdb+ server on the localhost port 1234.
		,ymd(I,I,I)						// Encode a year/month/day as an int
		,dj(I);							// Create a Kdb+ date from an integer
extern V r0(K)							// Decrement the object's reference count | r0(x) 
		,sd0(I)							// Removes the callback on that socket. 
		,m9()							// Note that k objects must be freed from the thread they are allocated within, and m9() should be called when the thread is about to complete, freeing up memory allocated for that thread's pool. 
		,kclose(I);
extern S sn(S,I)						// S sn(string, n); 
		,ss(S);							// Intern a string | S ss(string); 

extern K ktj(I,J)						// Create a timestamp	| K tj(I);
		,ka(I)							// Create an atom		| K ka(I);
		,kb(I)							// Create a boolean		| K kb(I); 
		,kg(I)							// Create a byte		| K kg(I); 
		,kh(I)							// Create a short		| K kh(I); 
		,ki(I)							// Create an int		| K ki(I); 
		,kj(J)							// Create a long		| K kj(J);		
		,ke(F)							// Create a real		| K ke(F); 
		,kf(F)							// Create a float		| K kf(F); 
		,kc(I)							// Create a char		| K kc(I); 
		,ks(S)							// Create a symbol		| K ks(S); 
		,kd(I)							// Create a date		| K kd(I); 
		,kz(F)							// Create a datetime	| K kt(I); 
		,kt(I)							// Create a time		| K kz(I); 
		,sd1(I,K(*)(I))					// The void sd0(I); and K sd1(I, K(*)(I)); functions are for use with callbacks and are available only within kdb+ itself, i.e. used from a shared library loaded into kdb+. 
		,dl(V*f,I)						// The dynamic link, K dl(V* f, I n), function takes a C function that would take n K objects as arguments and return a new K object and returns a q function
		,ktn(I,I)						// Create a simple list | K ktn(type, length); 
		,knk(I,...)						// Create a mixed list | K knk(n,x,y,z); 
		,kp(S)							// Create a string | K kp(string); 
		,kpn(S,I)						// Create an empty strong of length n | K kpn(string, n); 
		,ja(K*,V*)						// Join an atom to a list | K ja(K*,V*); 
		,js(K*,S)						// Join a string to a list | K js(K*,S); 
		,jk(K*,K)						// Join another K object to a list | K jk(K*,K); 
		,k(I,const char *,...)				// k(-c,"a:2+2",(K)0); // Asynchronously set a to be 4 on the server. ; r = k(c,"b:til 100",(K)0); // Synchronously set b to be a list up to 100. 
		,xT(K)							// Create a table from a dict | K xT(K); 
		,xD(K,K)						// Create a dict | K xD(K,K); 
		,ktd(K)							// Create a simple table from a keyed table | K ktd(K); 
		,r1(K)							// Increment the object's reference count | r1(x)
		,krr(S)							// krr(S);
		,orr(S)
		,dot(K,K)						// The K dot (K x, K y) function is the same as the q function .[x;y]. 
		,b9(I,K)						// b9(preserveEnumerations,kObject);
		,d9(K);							// will deserialize the byte stream in kObject returning a new kObject. 
# ifdef __cplusplus
}
# endif

// nulls(n?) and infinities(w?)
# define nh ((I)0xFFFF8000)
# define wh ((I)0x7FFF)
# define ni ((I)0x80000000)
# define wi ((I)0x7FFFFFFF)
# ifdef WIN32
	# define nj ((J)0x8000000000000000)
	# define wj ((J)0x7FFFFFFFFFFFFFFF)
	# define nf (log(-1.0))
	# define wf (-log(0.0))
	# define isnan _isnan
	# define finite _finite
	extern double log();
# else 
	# define nj 0x8000000000000000LL
	# define wj 0x7FFFFFFFFFFFFFFFLL
	# define nf (0/0.0)
	# define wf (1/0.0)
	# define closesocket(x) close(x)
# endif

// remove more clutter
# define O printf
# define R return
# define Z static
# define P(x,y) {if(x)R(y);}
# define U(x) P(!(x),0)
# define SW switch
# define CS(n,x) case n:x;break;
# define CD default
# define DO(n,x) {I i=0,_i=(n);for(;i<_i;++i){x;}}

# define ZV Z V
# define ZK Z K
# define ZH Z H
# define ZI Z I
# define ZJ Z J
# define ZE Z E
# define ZF Z F
# define ZC Z C
# define ZS Z S

# define K1(f) K f(K x)
# define K2(f) K f(K x,K y)
# define TX(T,x) (*(T*)((G*)(x)+8))
# define xr x->r
# define xt x->t
# define xu x->u
# define xn x->n
# define xx xK[0]
# define xy xK[1]
# define xg TX(G,x)
# define xh TX(H,x)
# define xi TX(I,x)
# define xj TX(J,x)
# define xe TX(E,x)
# define xf TX(F,x)
# define xs TX(S,x)
# define xk TX(K,x)
# define xG x->G0
# define xH ((H*)xG)
# define xI ((I*)xG)
# define xJ ((J*)xG)
# define xE ((E*)xG)
# define xF ((F*)xG)
# define xS ((S*)xG)
# define xK ((K*)xG)
# define xC xG

# endif