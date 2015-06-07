/*
  WDL - mdct.c
  Copyright (C) 2006 and later Cockos Incorporated

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

#include "eel_mdct.h"

static void mdct(EEL_F *in, EEL_F *out, int len)
{
  int k;
  EEL_F pioverlen = PI * 0.5 / (EEL_F)len;
  for (k = 0; k < len / 2; k ++)
  {
    int i;
    EEL_F d = 0.0;
    for (i = 0; i < len; i ++)
    {
      d += in[i] * cos(pioverlen * (2.0 * i + 1.0 + len * 0.5) * (2.0 * k + 1.0));
    }
    out[k] = (EEL_F)d;
  }
}

static void imdct(EEL_F *in, EEL_F *out, int len)
{
  int k;
  EEL_F fourovern = 4.0 / (EEL_F)len;
  EEL_F pioverlen = PI * 0.5 / (EEL_F)len;
  for (k = 0; k < len; k ++)
  {
    int i;
    EEL_F d = 0.0;
    for (i = 0; i < len / 2; i ++)
    {
      d += in[i] * cos(pioverlen * (2.0 * k + 1.0 + len * 0.5) * (2 * i + 1.0));
    }
    out[k] = (EEL_F)(d * fourovern);
  }
}

// MDCT/iMDCT borrowed from Vorbis, thanks xiph!


#define cPI3_8 .38268343236508977175
#define cPI2_8 .70710678118654752441
#define cPI1_8 .92387953251128675613

#define FLOAT_CONV(x) ((EEL_F) ( x ))
#define MULT_NORM(x) (x)
#define HALVE(x) ((x)*.5f)



/* 8 point butterfly (in place, 4 register) */
static void mdct_butterfly_8(EEL_F *x) {
  EEL_F r0   = x[6] + x[2];
  EEL_F r1   = x[6] - x[2];
  EEL_F r2   = x[4] + x[0];
  EEL_F r3   = x[4] - x[0];

  x[6] = r0   + r2;
  x[4] = r0   - r2;

  r0   = x[5] - x[1];
  r2   = x[7] - x[3];
  x[0] = r1   + r0;
  x[2] = r1   - r0;

  r0   = x[5] + x[1];
  r1   = x[7] + x[3];
  x[3] = r2   + r3;
  x[1] = r2   - r3;
  x[7] = r1   + r0;
  x[5] = r1   - r0;

}

/* 16 point butterfly (in place, 4 register) */
static void mdct_butterfly_16(EEL_F *x) {
  EEL_F r0     = x[1]  - x[9];
  EEL_F r1     = x[0]  - x[8];

  x[8]  += x[0];
  x[9]  += x[1];
  x[0]   = MULT_NORM((r0   + r1) * cPI2_8);
  x[1]   = MULT_NORM((r0   - r1) * cPI2_8);

  r0     = x[3]  - x[11];
  r1     = x[10] - x[2];
  x[10] += x[2];
  x[11] += x[3];
  x[2]   = r0;
  x[3]   = r1;

  r0     = x[12] - x[4];
  r1     = x[13] - x[5];
  x[12] += x[4];
  x[13] += x[5];
  x[4]   = MULT_NORM((r0   - r1) * cPI2_8);
  x[5]   = MULT_NORM((r0   + r1) * cPI2_8);

  r0     = x[14] - x[6];
  r1     = x[15] - x[7];
  x[14] += x[6];
  x[15] += x[7];
  x[6]  = r0;
  x[7]  = r1;

  mdct_butterfly_8(x);
  mdct_butterfly_8(x + 8);
}

/* 32 point butterfly (in place, 4 register) */
static void mdct_butterfly_32(EEL_F *x) {
  EEL_F r0     = x[30] - x[14];
  EEL_F r1     = x[31] - x[15];

  x[30] +=         x[14];
  x[31] +=         x[15];
  x[14]  =         r0;
  x[15]  =         r1;

  r0     = x[28] - x[12];
  r1     = x[29] - x[13];
  x[28] +=         x[12];
  x[29] +=         x[13];
  x[12]  = MULT_NORM( r0 * cPI1_8  -  r1 * cPI3_8 );
  x[13]  = MULT_NORM( r0 * cPI3_8  +  r1 * cPI1_8 );

  r0     = x[26] - x[10];
  r1     = x[27] - x[11];
  x[26] +=         x[10];
  x[27] +=         x[11];
  x[10]  = MULT_NORM(( r0  - r1 ) * cPI2_8);
  x[11]  = MULT_NORM(( r0  + r1 ) * cPI2_8);

  r0     = x[24] - x[8];
  r1     = x[25] - x[9];
  x[24] += x[8];
  x[25] += x[9];
  x[8]   = MULT_NORM( r0 * cPI3_8  -  r1 * cPI1_8 );
  x[9]   = MULT_NORM( r1 * cPI3_8  +  r0 * cPI1_8 );

  r0     = x[22] - x[6];
  r1     = x[7]  - x[23];
  x[22] += x[6];
  x[23] += x[7];
  x[6]   = r1;
  x[7]   = r0;

  r0     = x[4]  - x[20];
  r1     = x[5]  - x[21];
  x[20] += x[4];
  x[21] += x[5];
  x[4]   = MULT_NORM( r1 * cPI1_8  +  r0 * cPI3_8 );
  x[5]   = MULT_NORM( r1 * cPI3_8  -  r0 * cPI1_8 );

  r0     = x[2]  - x[18];
  r1     = x[3]  - x[19];
  x[18] += x[2];
  x[19] += x[3];
  x[2]   = MULT_NORM(( r1  + r0 ) * cPI2_8);
  x[3]   = MULT_NORM(( r1  - r0 ) * cPI2_8);

  r0     = x[0]  - x[16];
  r1     = x[1]  - x[17];
  x[16] += x[0];
  x[17] += x[1];
  x[0]   = MULT_NORM( r1 * cPI3_8  +  r0 * cPI1_8 );
  x[1]   = MULT_NORM( r1 * cPI1_8  -  r0 * cPI3_8 );

  mdct_butterfly_16(x);
  mdct_butterfly_16(x + 16);

}

/* N point first stage butterfly (in place, 2 register) */
static void mdct_butterfly_first(EEL_F *T,
                                 EEL_F *x,
                                 int points) {

  EEL_F *x1        = x          + points      - 8;
  EEL_F *x2        = x          + (points >> 1) - 8;
  EEL_F   r0;
  EEL_F   r1;

  do {

    r0      = x1[6]      -  x2[6];
    r1      = x1[7]      -  x2[7];
    x1[6]  += x2[6];
    x1[7]  += x2[7];
    x2[6]   = MULT_NORM(r1 * T[1]  +  r0 * T[0]);
    x2[7]   = MULT_NORM(r1 * T[0]  -  r0 * T[1]);

    r0      = x1[4]      -  x2[4];
    r1      = x1[5]      -  x2[5];
    x1[4]  += x2[4];
    x1[5]  += x2[5];
    x2[4]   = MULT_NORM(r1 * T[5]  +  r0 * T[4]);
    x2[5]   = MULT_NORM(r1 * T[4]  -  r0 * T[5]);

    r0      = x1[2]      -  x2[2];
    r1      = x1[3]      -  x2[3];
    x1[2]  += x2[2];
    x1[3]  += x2[3];
    x2[2]   = MULT_NORM(r1 * T[9]  +  r0 * T[8]);
    x2[3]   = MULT_NORM(r1 * T[8]  -  r0 * T[9]);

    r0      = x1[0]      -  x2[0];
    r1      = x1[1]      -  x2[1];
    x1[0]  += x2[0];
    x1[1]  += x2[1];
    x2[0]   = MULT_NORM(r1 * T[13] +  r0 * T[12]);
    x2[1]   = MULT_NORM(r1 * T[12] -  r0 * T[13]);

    x1 -= 8;
    x2 -= 8;
    T += 16;

  } while(x2 >= x);
}

/* N/stage point generic N stage butterfly (in place, 2 register) */
static void mdct_butterfly_generic(EEL_F *T,
                                   EEL_F *x,
                                   int points,
                                   int trigint) {

  EEL_F *x1        = x          + points      - 8;
  EEL_F *x2        = x          + (points >> 1) - 8;
  EEL_F   r0;
  EEL_F   r1;

  do {

    r0      = x1[6]      -  x2[6];
    r1      = x1[7]      -  x2[7];
    x1[6]  += x2[6];
    x1[7]  += x2[7];
    x2[6]   = MULT_NORM(r1 * T[1]  +  r0 * T[0]);
    x2[7]   = MULT_NORM(r1 * T[0]  -  r0 * T[1]);

    T += trigint;

    r0      = x1[4]      -  x2[4];
    r1      = x1[5]      -  x2[5];
    x1[4]  += x2[4];
    x1[5]  += x2[5];
    x2[4]   = MULT_NORM(r1 * T[1]  +  r0 * T[0]);
    x2[5]   = MULT_NORM(r1 * T[0]  -  r0 * T[1]);

    T += trigint;

    r0      = x1[2]      -  x2[2];
    r1      = x1[3]      -  x2[3];
    x1[2]  += x2[2];
    x1[3]  += x2[3];
    x2[2]   = MULT_NORM(r1 * T[1]  +  r0 * T[0]);
    x2[3]   = MULT_NORM(r1 * T[0]  -  r0 * T[1]);

    T += trigint;

    r0      = x1[0]      -  x2[0];
    r1      = x1[1]      -  x2[1];
    x1[0]  += x2[0];
    x1[1]  += x2[1];
    x2[0]   = MULT_NORM(r1 * T[1]  +  r0 * T[0]);
    x2[1]   = MULT_NORM(r1 * T[0]  -  r0 * T[1]);

    T += trigint;
    x1 -= 8;
    x2 -= 8;

  } while(x2 >= x);
}

static void mdct_butterflies(mdct_lookup *init,
                             EEL_F *x,
                             int points) {

  EEL_F *T = init->trig;
  int stages = init->log2n - 5;
  int i, j;

  if(--stages > 0) {
    mdct_butterfly_first(T, x, points);
  }

  for(i = 1; --stages > 0; i++) {
    for(j = 0; j < (1 << i); j++)
      mdct_butterfly_generic(T, x + (points >> i)*j, points >> i, 4 << i);
  }

  for(j = 0; j < points; j += 32)
    mdct_butterfly_32(x + j);

}

static void mdct_bitreverse(mdct_lookup *init,
                            EEL_F *x) {
  int        n       = init->n;
  int       *bit     = init->bitrev;
  EEL_F *w0      = x;
  EEL_F *w1      = x = w0 + (n >> 1);
  EEL_F *T       = init->trig + n;

  do {
    EEL_F *x0    = x + bit[0];
    EEL_F *x1    = x + bit[1];

    EEL_F  r0     = x0[1]  - x1[1];
    EEL_F  r1     = x0[0]  + x1[0];
    EEL_F  r2     = MULT_NORM(r1     * T[0]   + r0 * T[1]);
    EEL_F  r3     = MULT_NORM(r1     * T[1]   - r0 * T[0]);

    w1    -= 4;

    r0     = HALVE(x0[1] + x1[1]);
    r1     = HALVE(x0[0] - x1[0]);

    w0[0]  = r0     + r2;
    w1[2]  = r0     - r2;
    w0[1]  = r1     + r3;
    w1[3]  = r3     - r1;

    x0     = x + bit[2];
    x1     = x + bit[3];

    r0     = x0[1]  - x1[1];
    r1     = x0[0]  + x1[0];
    r2     = MULT_NORM(r1     * T[2]   + r0 * T[3]);
    r3     = MULT_NORM(r1     * T[3]   - r0 * T[2]);

    r0     = HALVE(x0[1] + x1[1]);
    r1     = HALVE(x0[0] - x1[0]);

    w0[2]  = r0     + r2;
    w1[0]  = r0     - r2;
    w0[3]  = r1     + r3;
    w1[1]  = r3     - r1;

    T     += 4;
    bit   += 4;
    w0    += 4;

  } while(w0 < w1);
}

void megabuf_mdct_apply_window(void *init, EEL_F *inbuf, EEL_F *outbuf)
{
  mdct_lookup *p = (mdct_lookup *)init;
  EEL_F *w;
  int cnt;
  if (!p) return;

  w = p->window;
  if (!w) return;

  cnt = p->n / 2;
  while (cnt--) *outbuf++ = *inbuf++ * *w++;
  cnt = p->n / 2;
  while (cnt--) *outbuf++ = *inbuf++ * *--w;
}



void *megabuf_mdct_init(int n) {
  mdct_lookup *lookup = (mdct_lookup *)calloc(sizeof(mdct_lookup), 1);
  int i;
  EEL_F c = (PI / (EEL_F) n);
  int   *bitrev;
  EEL_F *T, *oldw;
  int n2, log2n;
  if (!lookup) return 0;

  lookup->n = n;
  lookup->window = (EEL_F *)calloc(sizeof(EEL_F), n / 2);
  if (!lookup->window) return lookup;

  for (i = 0; i < n / 2; i ++)
  {
    lookup->window[i] = sin(c * (i + 0.5));
  }

  if (n <= 32) return lookup;
  bitrev = (int*)calloc(sizeof(int), (n / 4));
  lookup->bitrev = bitrev;
  if (!bitrev) return lookup;

  T = (EEL_F*)calloc(sizeof(EEL_F), (n + n / 4));
  lookup->trig = T;
  if (!T) return lookup;

  oldw = (EEL_F*)calloc(n, sizeof(EEL_F));
  lookup->oldw = oldw;
  if (!oldw) return lookup;

  n2 = n >> 1;
  log2n = lookup->log2n = (int)(log((double)n) / log(2.0) + 0.5);

  /* trig lookups... */

  for(i = 0; i < n / 4; i++) {
    T[i * 2] = FLOAT_CONV(cos((PI / n) * (4 * i)));
    T[i * 2 + 1] = FLOAT_CONV(-sin((PI / n) * (4 * i)));
    T[n2 + i * 2] = FLOAT_CONV(cos((PI / (2 * n)) * (2 * i + 1)));
    T[n2 + i * 2 + 1] = FLOAT_CONV(sin((PI / (2 * n)) * (2 * i + 1)));
  }
  for(i = 0; i < n / 8; i++) {
    T[n + i * 2] = FLOAT_CONV(cos((PI / n) * (4 * i + 2)) * .5);
    T[n + i * 2 + 1] = FLOAT_CONV(-sin((PI / n) * (4 * i + 2)) * .5);
  }

  /* bitreverse lookup... */

  {
    int mask = (1 << (log2n - 1)) - 1, j;
    int msb = 1 << (log2n - 2);
    for(i = 0; i < n / 8; i++) {
      int acc = 0;
      for(j = 0; msb >> j; j++)
        if((msb >> j)&i)acc |= 1 << j;
      bitrev[i * 2] = ((~acc)&mask) - 1;
      bitrev[i * 2 + 1] = acc;

    }
  }
  lookup->scale = FLOAT_CONV(4.f / n);
  return lookup;
}

void megabuf_mdct_backward(void *init, EEL_F *in, EEL_F *out) {
  mdct_lookup *lookup = (mdct_lookup *)init;
  int n, n2, n4;
  EEL_F *iX, *oX, *T;
  if (!lookup) return;
  n = lookup->n;
  if (n <= 32 || !lookup->bitrev || !lookup->trig || !lookup->oldw)
  {
    imdct(in, out, n);
    return;
  }
  n2 = n >> 1;
  n4 = n >> 2;

  /* rotate */

  iX = in + n2 - 7;
  oX = out + n2 + n4;
  T  = lookup->trig + n4;

  do {
    oX         -= 4;
    oX[0]       = MULT_NORM(-iX[2] * T[3] - iX[0]  * T[2]);
    oX[1]       = MULT_NORM (iX[0] * T[3] - iX[2]  * T[2]);
    oX[2]       = MULT_NORM(-iX[6] * T[1] - iX[4]  * T[0]);
    oX[3]       = MULT_NORM (iX[4] * T[1] - iX[6]  * T[0]);
    iX         -= 8;
    T          += 4;
  } while(iX >= in);

  iX            = in + n2 - 8;
  oX            = out + n2 + n4;
  T             = lookup->trig + n4;

  do {
    T          -= 4;
    oX[0]       =  MULT_NORM (iX[4] * T[3] + iX[6] * T[2]);
    oX[1]       =  MULT_NORM (iX[4] * T[2] - iX[6] * T[3]);
    oX[2]       =  MULT_NORM (iX[0] * T[1] + iX[2] * T[0]);
    oX[3]       =  MULT_NORM (iX[0] * T[0] - iX[2] * T[1]);
    iX         -= 8;
    oX         += 4;
  } while(iX >= in);

  mdct_butterflies(lookup, out + n2, n2);
  mdct_bitreverse(lookup, out);

  /* roatate + window */

  {
    EEL_F *oX1 = out + n2 + n4;
    EEL_F *oX2 = out + n2 + n4;
    iX = out;
    T = lookup->trig + n2;

    do {
      oX1 -= 4;

      oX1[3]  =  MULT_NORM (iX[0] * T[1] - iX[1] * T[0]);
      oX2[0]  = -MULT_NORM (iX[0] * T[0] + iX[1] * T[1]);

      oX1[2]  =  MULT_NORM (iX[2] * T[3] - iX[3] * T[2]);
      oX2[1]  = -MULT_NORM (iX[2] * T[2] + iX[3] * T[3]);

      oX1[1]  =  MULT_NORM (iX[4] * T[5] - iX[5] * T[4]);
      oX2[2]  = -MULT_NORM (iX[4] * T[4] + iX[5] * T[5]);

      oX1[0]  =  MULT_NORM (iX[6] * T[7] - iX[7] * T[6]);
      oX2[3]  = -MULT_NORM (iX[6] * T[6] + iX[7] * T[7]);

      oX2 += 4;
      iX    +=   8;
      T     +=   8;
    } while(iX < oX1);

    iX = out + n2 + n4;
    oX1 = out + n4;
    oX2 = oX1;

    do {
      oX1 -= 4;
      iX -= 4;

      oX2[0] = -(oX1[3] = iX[3]);
      oX2[1] = -(oX1[2] = iX[2]);
      oX2[2] = -(oX1[1] = iX[1]);
      oX2[3] = -(oX1[0] = iX[0]);

      oX2 += 4;
    } while(oX2 < iX);

    iX = out + n2 + n4;
    oX1 = out + n2 + n4;
    oX2 = out + n2;
    do {
      oX1 -= 4;
      oX1[0] = iX[3];
      oX1[1] = iX[2];
      oX1[2] = iX[1];
      oX1[3] = iX[0];
      iX += 4;
    } while(oX1 > oX2);
  }
}


void megabuf_mdct_forward(void *init, EEL_F *in, EEL_F *out) {
  mdct_lookup *lookup = (mdct_lookup *)init;
  int n, n2, n4, n8;
  EEL_F *oldw, *w, *w2;
  if (!lookup) return;

  n = lookup->n;
  if (n <= 32 || !lookup->bitrev || !lookup->trig || !lookup->oldw)
  {
    mdct(in, out, n);
    return;
  }
  n2 = n >> 1;
  n4 = n >> 2;
  n8 = n >> 3;
  oldw = lookup->oldw;
  w = oldw;
  w2 = w + n2;

  /* rotate */

  /* window + rotate + step 1 */

  {
    EEL_F r0;
    EEL_F r1;
    EEL_F *x0 = in + n2 + n4;
    EEL_F *x1 = x0 + 1;
    EEL_F *T = lookup->trig + n2;

    int i = 0;

    for(i = 0; i < n8; i += 2) {
      x0 -= 4;
      T -= 2;
      r0 = x0[2] + x1[0];
      r1 = x0[0] + x1[2];
      w2[i] =   MULT_NORM(r1 * T[1] + r0 * T[0]);
      w2[i + 1] = MULT_NORM(r1 * T[0] - r0 * T[1]);
      x1 += 4;
    }

    x1 = in + 1;

    for(; i < n2 - n8; i += 2) {
      T -= 2;
      x0 -= 4;
      r0 = x0[2] - x1[0];
      r1 = x0[0] - x1[2];
      w2[i] =   MULT_NORM(r1 * T[1] + r0 * T[0]);
      w2[i + 1] = MULT_NORM(r1 * T[0] - r0 * T[1]);
      x1 += 4;
    }

    x0 = in + n;

    for(; i < n2; i += 2) {
      T -= 2;
      x0 -= 4;
      r0 = -x0[2] - x1[0];
      r1 = -x0[0] - x1[2];
      w2[i] =   MULT_NORM(r1 * T[1] + r0 * T[0]);
      w2[i + 1] = MULT_NORM(r1 * T[0] - r0 * T[1]);
      x1 += 4;
    }


    mdct_butterflies(lookup, w + n2, n2);
    mdct_bitreverse(lookup, w);

    /* roatate + window */

    T = lookup->trig + n2;
    x0 = out + n2;

    for(i = 0; i < n4; i++) {
      x0--;
      out[i] = MULT_NORM((w[0] * T[0] + w[1] * T[1]) * lookup->scale);
      x0[0]  = MULT_NORM((w[0] * T[1] - w[1] * T[0]) * lookup->scale);
      w += 2;
      T += 2;
    }
  }
}
