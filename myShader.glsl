#version 140
#define PROCESSING_COLOR_SHADER

uniform float iGlobalTime;
uniform vec3 iResolution;
uniform vec4 iMouse;

out vec4 fragColor;

#define AO
#define SHADOWS

#define SHADES 5.0

mat3 rotX(float d){
    float s = sin(d);
    float c = cos(d);
    return mat3(1.0, 0.0, 0.0,
                0.0,   c,  -s,
                0.0,   s,   c );
}

mat3 rotY(float d){
    float s = sin(d);
    float c = cos(d);
    return mat3(  c, 0.0,  -s,
                0.0, 1.0, 0.0,
                s, 0.0,   c );
}

float closeObj = 0.0;

vec2 vecMin(vec2 a, vec2 b){
    if(a.x <= b.x){
        return a;
    }
    return b;
}

vec2 mapMat(vec3 p){
    vec3 q = p;
    q -= vec3(0.5 * cos(iGlobalTime), 0.0, 0.5 * sin(iGlobalTime));
    vec3 r = p;
    r -= vec3(-2.5 * cos(iGlobalTime), 0.0, -2.5 * sin(iGlobalTime));
    r *= rotY(iGlobalTime);
    vec2 sphere = vec2(length(q) - 1.0, 2.0);
    vec2 sphereb = vec2(length(r) - 1.0, 3.0);
    vec2 hplane = vec2(p.y + 1.0, 1.0);
    vec2 vplane = vec2(-p.z + 4.0, 1.0);
    
    return vecMin(sphere, vecMin(sphereb, vecMin(hplane, vplane)));
}

float map(vec3 p){
    return mapMat(p).x;
}

float trace(vec3 ro, vec3 rd){
    float t = 0.0;
    float d = 0.0;
    vec2 c;
    int inter = 0;
    for(int i = 0; i < 2000; i++){
        c = mapMat(ro + rd * t);
        d = c.x;
        if(d < 0.0001){
            inter = 1;
            break;
        }
        t += d;
        if(t > 50.0){
            break;
        }
    }
    closeObj = c.y;
    if(inter == 0){
        t = -1.0;
    }
    return t;
}

vec3 normal(vec3 p){
    return normalize(vec3(map(vec3(p.x + 0.0001, p.yz)) - map(vec3(p.x - 0.0001, p.yz)),
                          map(vec3(p.x, p.y + 0.0001, p.z)) - map(vec3(p.x, p.y - 0.0001, p.z)),
                          map(vec3(p.xy, p.z + 0.0001)) - map(vec3(p.xy, p.z - 0.0001))));
}

vec3 camPos = vec3(0.0, 1.0, 0.0);
vec3 lightPos = vec3(0.0, 1.0, -1.0);

vec3 diff(vec3 c, float k, vec3 p){
    vec3 n = normal(p);
    vec3 l = normalize(lightPos - p);
    return c * k * max(0.0, dot(n, l));
}

float shadow(vec3 ro, vec3 rd){
    float t = 0.2;
    float d = 0.0;
    float shadow = 1.0;
    for(int iter = 0; iter < 1000; iter++){
        d = map(ro + rd * t);
        if(d < 0.0001){
            return 0.0;
        }
        if(t > length(ro - lightPos) - 0.5){
            break;
        }
        shadow = min(shadow, 128.0 * d / t);
        t += d;
    }
    return shadow;
}

float occlusion(vec3 ro, vec3 rd){
    float k = 1.0;
    float d = 0.0;
    float occ = 0.0;
    for(int i = 0; i < 25; i++){
        d = map(ro + 0.1 * k * rd);
        occ += 1.0 / pow(2.0, k) * (k * 0.1 - d);
        k += 1.0;
    }
    return 1.0 - clamp(1.0 * occ, 0.0, 1.0);
}

vec3 colInterp(vec3 bcol, vec3 ecol, vec3 inCol, float s){
    float st = 1.0 / SHADES;
    float avg = inCol.x * SHADES;
    float band = ceil(avg) / SHADES;
    if(s != 1.0){
        band = max(0.0, band - st);
    }
    return mix(bcol, ecol, band);
}

vec3 palette(float id, vec3 inCol, float s){
    if(id == 1.0){
        vec3 mcol = vec3(0.95);
        vec3 bcol = mcol / 4.0;
        return colInterp(bcol, mcol, inCol, s);
    }
    if(id == 2.0){
        vec3 mcol = vec3(0.874510, 0.490196, 0.376471);
        vec3 bcol = mcol / 4.0;
        return colInterp(bcol, mcol, inCol, s);
    }
    if(id == 3.0){
        vec3 mcol = vec3(0.929412, 0.882353, 0.788235);
        vec3 bcol = mcol / 4.0;
        return colInterp(bcol, mcol, inCol, s);
    }
    return vec3(0.0, 1.0, 0.0);
}

float s = 1.0;
float ao = 1.0;

vec3 colour(vec3 p, float id){
    
#ifdef SHADOWS
    float s = shadow(p, normalize(lightPos - p));
#endif
    
#ifdef AO
    float ao = occlusion(p, normal(p));
#endif
    
    return palette(id, diff(vec3(1.0), 1.0, p) * ao, s);
}

float lastx = 0.0;
float lasty = 0.0;

void main(){
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    camPos = vec3(0.0 , 0.0, -5.0);
    lightPos = vec3(2.0, 2.0, -6.0);
    lastx += iMouse.x - 0.5;
    lasty += iMouse.y - 0.5;
    vec3 ro = camPos;
    vec3 rd = normalize(rotY(radians(lastx)) * rotX(radians(lasty)) * vec3(uv, 1.0));
    float d = trace(ro, rd);
    vec3 c = ro + rd * d;
    vec3 col = vec3(1.0);
    //If intersected
    if(d > 0.0){
        col = colour(c, closeObj);
        col *= 1.0 / exp(d * 0.1);
    }else{
        col = vec3(0.0);
    }
    fragColor = vec4(col,1.0);
}