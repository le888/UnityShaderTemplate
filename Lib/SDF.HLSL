#ifndef _SDF_HLSL_
#define _SDF_HLSL_

//https://iquilezles.org/articles/
//https://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float dot2( in float2 v ) { return dot(v,v); }
float dot2( in float3 v ) { return dot(v,v); }
float ndot( in float2 a, in float2 b ) { return a.x*b.x - a.y*b.y; }

float sdSphere( float3 p, float s )
{
    return length(p)-s;
}

float sdBox( float3 p, float3 b )
{
    float3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdRoundBox( float3 p, float3 b, float r )
{
    float3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdBoxFrame( float3 p, float3 b, float e )
{
    p = abs(p  )-b;
    float3 q = abs(p+e)-e;
    return min(min(
        length(max(float3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
        length(max(float3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
        length(max(float3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float sdTorus( float3 p, float2 t )
{
    float2 q = float2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

float sdCappedTorus( float3 p, float2 sc, float ra, float rb)
{
    p.x = abs(p.x);
    float k = (sc.y*p.x>sc.x*p.y) ? dot(p.xy,sc) : length(p.xy);
    return sqrt( dot(p,p) + ra*ra - 2.0*ra*k ) - rb;
}

float sdLink( float3 p, float le, float r1, float r2 )
{
    float3 q = float3( p.x, max(abs(p.y)-le,0.0), p.z );
    return length(float2(length(q.xy)-r1,q.z)) - r2;
}

float sdCylinder( float3 p, float3 c )
{
    return length(p.xz-c.xy)-c.z;
}

float sdCone( float3 p, float2 c, float h )
{
    // c is the sin/cos of the angle, h is height
    // Alternatively pass q instead of (c,h),
    // which is the point at the base in 2D
    float2 q = h*float2(c.x/c.y,-1.0);
    
    float2 w = float2( length(p.xz), p.y );
    float2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0 );
    float2 b = w - q*float2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0 );
    float k = sign( q.y );
    float d = min(dot( a, a ),dot(b, b));
    float s = max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y)  );
    return sqrt(d)*sign(s);
}
//not exact!
float sdConeFast( float3 p, float2 c, float h )
{
    float q = length(p.xz);
    return max(dot(c.xy,float2(q,p.y)),-h-p.y);
}

float sdCone( float3 p, float2 c )
{
    // c is the sin/cos of the angle
    float2 q = float2( length(p.xz), -p.y );
    float d = length(q-c*max(dot(q,c), 0.0));
    return d * ((q.x*c.y-q.y*c.x<0.0)?-1.0:1.0);
}

float sdPlane( float3 p, float3 n, float h )
{
    // n must be normalized
    return dot(p,n) + h;
}

float sdHexPrism( float3 p, float2 h )
{
    const float3 k = float3(-0.8660254, 0.5, 0.57735);
    p = abs(p);
    p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
    float2 d = float2(
         length(p.xy-float2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
         p.z-h.y );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdTriPrism( float3 p, float2 h )
{
    float3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float sdCapsule( float3 p, float3 a, float3 b, float r )
{
    float3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

float sdVerticalCapsule( float3 p, float h, float r )
{
    p.y -= clamp( p.y, 0.0, h );
    return length( p ) - r;
}

float sdCappedCylinder( float3 p, float h, float r )
{
    float2 d = abs(float2(length(p.xz),p.y)) - float2(r,h);
    return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdRoundedCylinder( float3 p, float ra, float rb, float h )
{
    float2 d = float2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
    return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
}

float sdCappedCone( float3 p, float h, float r1, float r2 )
{
    float2 q = float2( length(p.xz), p.y );
    float2 k1 = float2(r2,h);
    float2 k2 = float2(r2-r1,2.0*h);
    float2 ca = float2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
    float2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot2(ca),dot2(cb)) );
}

float sdCappedCone( float3 p, float3 a, float3 b, float ra, float rb )
{
    float rba  = rb-ra;
    float baba = dot(b-a,b-a);
    float papa = dot(p-a,p-a);
    float paba = dot(p-a,b-a)/baba;
    float x = sqrt( papa - paba*paba*baba );
    float cax = max(0.0,x-((paba<0.5)?ra:rb));
    float cay = abs(paba-0.5)-0.5;
    float k = rba*rba + baba;
    float f = clamp( (rba*(x-ra)+paba*baba)/k, 0.0, 1.0 );
    float cbx = x-ra - f*rba;
    float cby = paba - f;
    float s = (cbx<0.0 && cay<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(cax*cax + cay*cay*baba,
                       cbx*cbx + cby*cby*baba) );
}

float sdSolidAngle( float3 p, float2 c, float ra )
{
    // c is the sin/cos of the angle
    float2 q = float2( length(p.xz), p.y );
    float l = length(q) - ra;
    float m = length(q - c*clamp(dot(q,c),0.0,ra) );
    return max(l,m*sign(c.y*q.x-c.x*q.y));
}

float sdCutSphere( float3 p, float r, float h )
{
    // sampling independent computations (only depend on shape)
    float w = sqrt(r*r-h*h);

    // sampling dependant computations
    float2 q = float2( length(p.xz), p.y );
    float s = max( (h-r)*q.x*q.x+w*w*(h+r-2.0*q.y), h*q.x-w*q.y );
    return (s<0.0) ? length(q)-r :
           (q.x<w) ? h - q.y     :
                     length(q-float2(w,h));
}

float sdCutHollowSphere( float3 p, float r, float h, float t )
{
    // sampling independent computations (only depend on shape)
    float w = sqrt(r*r-h*h);

    // sampling dependant computations
    float2 q = float2( length(p.xz), p.y );
    return ((h*q.x<w*q.y) ? length(q-float2(w,h)) : 
                            abs(length(q)-r) ) - t;
}

float sdDeathStar( float3 p2, float ra, float rb, float d )
{
    // sampling independent computations (only depend on shape)
    float a = (ra*ra - rb*rb + d*d)/(2.0*d);
    float b = sqrt(max(ra*ra-a*a,0.0));

    // sampling dependant computations
    float2 p = float2( p2.x, length(p2.yz) );
    if( p.x*b-p.y*a > d*max(b-p.y,0.0) )
        return length(p-float2(a,b));
    else
        return max( (length(p            )-ra),
                   -(length(p-float2(d,0.0))-rb));
}

float sdRoundCone( float3 p, float r1, float r2, float h )
{
    // sampling independent computations (only depend on shape)
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);

    // sampling dependant computations
    float2 q = float2( length(p.xz), p.y );
    float k = dot(q,float2(-b,a));
    if( k<0.0 ) return length(q) - r1;
    if( k>a*h ) return length(q-float2(0.0,h)) - r2;
    return dot(q, float2(a,b) ) - r1;
}

float sdRoundCone( float3 p, float3 a, float3 b, float r1, float r2 )
{
    // sampling independent computations (only depend on shape)
    float3  ba = b - a;
    float l2 = dot(ba,ba);
    float rr = r1 - r2;
    float a2 = l2 - rr*rr;
    float il2 = 1.0/l2;

    // sampling dependant computations
    float3 pa = p - a;
    float y = dot(pa,ba);
    float z = y - l2;
    float x2 = dot2( pa*l2 - ba*y );
    float y2 = y*y*l2;
    float z2 = z*z*l2;

    // single square root!
    float k = sign(rr)*rr*rr*x2;
    if( sign(z)*a2*z2>k ) return  sqrt(x2 + z2)        *il2 - r2;
    if( sign(y)*a2*y2<k ) return  sqrt(x2 + y2)        *il2 - r1;
    return (sqrt(x2*a2*il2)+y*rr)*il2 - r1;
}
//not exact!
float sdEllipsoid( float3 p, float3 r )
{
    float k0 = length(p/r);
    float k1 = length(p/(r*r));
    return k0*(k0-1.0)/k1;
}
float sdVesicaSegment( in float3 p, in float3 a, in float3 b, in float w )
{
    float3  c = (a+b)*0.5;
    float l = length(b-a);
    float3  v = (b-a)/l;
    float y = dot(p-c,v);
    float2  q = float2(length(p-c-y*v),abs(y));
    
    float r = 0.5*l;
    float d = 0.5*(r*r-w*w)/w;
    float3  h = (r*q.x<d*(q.y-r)) ? float3(0.0,r,0.0) : float3(-d,0.0,d+w);
 
    return length(q-h.xy) - h.z;
}

float sdRhombus( float3 p, float la, float lb, float h, float ra )
{
    p = abs(p);
    float2 b = float2(la,lb);
    float f = clamp( (ndot(b,b-2.0*p.xz))/dot(b,b), -1.0, 1.0 );
    float2 q = float2(length(p.xz-0.5*b*float2(1.0-f,1.0+f))*sign(p.x*b.y+p.z*b.x-b.x*b.y)-ra, p.y-h);
    return min(max(q.x,q.y),0.0) + length(max(q,0.0));
}
//not exact
float sdOctahedron( float3 p, float s)
{
    p = abs(p);
    return (p.x+p.y+p.z-s)*0.57735027;
}
float sdPyramid( float3 p, float h )
{
    float m2 = h*h + 0.25;
    
    p.xz = abs(p.xz);
    p.xz = (p.z>p.x) ? p.zx : p.xz;
    p.xz -= 0.5;

    float3 q = float3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
  
    float s = max(-q.x,0.0);
    float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
    
    float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
    float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
    
    float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
    
    return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));
}
float udTriangle( float3 p, float3 a, float3 b, float3 c )
{
    float3 ba = b - a; float3 pa = p - a;
    float3 cb = c - b; float3 pb = p - b;
    float3 ac = a - c; float3 pc = p - c;
    float3 nor = cross( ba, ac );

    return sqrt(
      (sign(dot(cross(ba,nor),pa)) +
       sign(dot(cross(cb,nor),pb)) +
       sign(dot(cross(ac,nor),pc))<2.0)
       ?
       min( min(
       dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
       dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
       dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
       :
       dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}
float udQuad( float3 p, float3 a, float3 b, float3 c, float3 d )
{
    float3 ba = b - a; float3 pa = p - a;
    float3 cb = c - b; float3 pb = p - b;
    float3 dc = d - c; float3 pc = p - c;
    float3 ad = a - d; float3 pd = p - d;
    float3 nor = cross( ba, ad );

    return sqrt(
      (sign(dot(cross(ba,nor),pa)) +
       sign(dot(cross(cb,nor),pb)) +
       sign(dot(cross(dc,nor),pc)) +
       sign(dot(cross(ad,nor),pd))<3.0)
       ?
       min( min( min(
       dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
       dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
       dot2(dc*clamp(dot(dc,pc)/dot2(dc),0.0,1.0)-pc) ),
       dot2(ad*clamp(dot(ad,pd)/dot2(ad),0.0,1.0)-pd) )
       :
       dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}


//op


//combinations
//https://iquilezles.org/articles/distfunctions/
float opUnion( float d1, float d2 ) { return min(d1,d2); }
float opSubtraction( float d1, float d2 ) { return max(-d1,d2); }
float opIntersection( float d1, float d2 ) { return max(d1,d2); }

//圆滑操作
float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) - k*h*(1.0-h); }

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return lerp( d2, -d1, h ) + k*h*(1.0-h); }

float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return lerp( d2, d1, h ) + k*h*(1.0-h); }


//法线计算
// float3 calcNormal(float3 pos,float epsilon = 0.01)
// {
//     float2 e = float2(1.0,-1.0)*0.5773;
//     return normalize(e.xyy*map(pos + e.xyy*epsilon) + 
//                      e.yyx*map(pos + e.yyx*epsilon) + 
//                      e.yxy*map(pos + e.yxy*epsilon) + 
//                      e.xxx*map(pos + e.xxx*epsilon));
// }
// float3 calcNormal2(float3 pos,float epsilon = 0.01)
// {
//     float3 normal;
//     normal.x = (map(pos + float3(epsilon, 0, 0)) - map(pos - float3(epsilon, 0, 0))) / (2.0 * epsilon);
//     normal.y = (map(pos + float3(0, epsilon, 0)) - map(pos - float3(0, epsilon, 0))) / (2.0 * epsilon);
//     normal.z = (map(pos + float3(0, 0, epsilon)) - map(pos - float3(0, 0, epsilon))) / (2.0 * epsilon);
//     normal = normalize(normal);
//     return normal;
// }


// https://gist.github.com/DomNomNom/46bb1ce47f68d255fd5d
// Compute the near and far intersections using the slab method.
// No intersection if tNear > tFar.
float2 intersectAABB(float3 rayOrigin, float3 rayDir, float3 boxMin, float3 boxMax)
{
    float3 tMin = (boxMin - rayOrigin) / rayDir;
    float3 tMax = (boxMax - rayOrigin) / rayDir;
    float3 t1 = min(tMin, tMax);
    float3 t2 = max(tMin, tMax);
    float tNear = max(max(t1.x, t1.y), t1.z);
    float tFar = min(min(t2.x, t2.y), t2.z);
    return float2(tNear, tFar);
}

bool intersectAABB(float3 rayOrigin, float3 rayDir, float3 boxMin,
                               float3 boxMax, out float2 tNearFar)
{
    float3 tMin = (boxMin - rayOrigin) / rayDir;
    float3 tMax = (boxMax - rayOrigin) / rayDir;
    float3 t1 = min(tMin, tMax);
    float3 t2 = max(tMin, tMax);
    float tNear = max(max(t1.x, t1.y), t1.z);
    float tFar = min(min(t2.x, t2.y), t2.z);
    tNearFar = float2(tNear, tFar);

    return tFar > tNear;
}


//shadow

/* //withMap map里面表示场景的sdf
// https://iquilezles.org/articles/rmshadows
float calcHardShadow(float3 ro, float3 rd, float mint, float maxt)
{
    float t = mint;
    for (int i = 0; i < 256 && t < maxt; i++)
    {
        float h = map(ro + rd * t);
        //到达物体表面=》有物体遮挡
        if (h < 0.001)
            return 0.0;
        t += h;
    }
    return 1.0;
}

// https://iquilezles.org/articles/rmshadows
float calcSoftShadow(float3 ro, float3 rd, float mint, float maxt, float k)
{
    float res = 1.0;
    float t = mint;
    for (int i = 0; i < 256 && t < maxt; i++)
    {
        float h = map(ro + rd * t);
        if (h < 0.001)
            return 0.0;
        res = min(res, k * h / t);
        t += h;
    }
    return res;
}
*/
#endif
