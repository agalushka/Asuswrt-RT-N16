/*  *********************************************************************
    *  RM7000 Board Support Package
    *  
    *  L2 Cache initialization			File: rm7000_l2cache.S
    *  
    *  This module contains code to initialize the L1 cache.
    *  
    *  Note: all the routines in this module rely on registers only,
    *        since DRAM may not be active yet.
    *
    *  Author:  Mitch Lichtenberg (mpl@broadcom.com)
    *  
    *********************************************************************  
    *
    *  Copyright 2000,2001,2002,2003
    *  Broadcom Corporation. All rights reserved.
    *  
    *  This software is furnished under license and may be used and 
    *  copied only in accordance with the following terms and 
    *  conditions.  Subject to these conditions, you may download, 
    *  copy, install, use, modify and distribute modified or unmodified 
    *  copies of this software in source and/or binary form.  No title 
    *  or ownership is transferred hereby.
    *  
    *  1) Any source code used, modified or distributed must reproduce 
    *     and retain this copyright notice and list of conditions 
    *     as they appear in the source file.
    *  
    *  2) No right is granted to use any trade name, trademark, or 
    *     logo of Broadcom Corporation.  The "Broadcom Corporation" 
    *     name may not be used to endorse or promote products derived 
    *     from this software without the prior written permission of 
    *     Broadcom Corporation.
    *  
    *  3) THIS SOFTWARE IS PROVIDED "AS-IS" AND ANY EXPRESS OR
    *     IMPLIED WARRANTIES, INCLUDING BUT NOT LIMITED TO, ANY IMPLIED
    *     WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
    *     PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED. IN NO EVENT 
    *     SHALL BROADCOM BE LIABLE FOR ANY DAMAGES WHATSOEVER, AND IN 
    *     PARTICULAR, BROADCOM SHALL NOT BE LIABLE FOR DIRECT, INDIRECT,
    *     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
    *     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
    *     GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
    *     BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
    *     OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
    *     TORT (INCLUDING NEGLIGENCE OR OTHERWISE), EVEN IF ADVISED OF 
    *     THE POSSIBILITY OF SUCH DAMAGE.
    ********************************************************************* */

#include "sbmips.h"

		.text


/*  *********************************************************************
    *  Macros
    ********************************************************************* */

#define L2CACHE_NUMWAYS	4
#define L2CACHE_NUMIDX  128			/* RM7000 has only 16K */
#define L2CACHE_LINESIZE 32
#define L2CACHE_IDXHIGH (L2CACHE_LINESIZE*L2CACHE_NUMWAYS*L2CACHE_NUMIDX)

#define L2CACHEOP(cachename,op) ((cachename) | ((op) << 2))

#define L2C_OP_IDXINVAL     0
#define L2C_OP_IDXLOADTAG   1
#define L2C_OP_IDXSTORETAG  2
#define L2C_OP_IMPLRSVD     3
#define L2C_OP_HITINVAL     4
#define L2C_OP_FILL         5
#define L2C_OP_HITWRITEBACK 6
#define L2C_OP_FETCHLOCK    7

#define L2C		    3



/*  *********************************************************************
    *  RM7000_L2CACHE_INIT()
    *  
    *  Initialize the L1 Cache tags to be "invalid"
    *  
    *  Input parameters: 
    *  	   nothing
    *  	   
    *  Return value:
    *  	   nothing
    *  
    *  Registers used:
    *  	   t0,t1,t2,t3
    ********************************************************************* */

	
LEAF(rm7000_l2cache_init)

		dmtc0	zero,C0_TAGLO
		dmtc0	zero,C0_TAGHI


		li	t2,K1BASE
		li	t3,L2CACHE_IDXHIGH

		add     t0,t2,t3
1:		cache   L2CACHEOP(L2C,L2C_OP_IDXSTORETAG),0(t2)
		addu    t2,L2CACHE_LINESIZE
		bne     t0,t2,1b

		dmtc0	zero,C0_TAGLO,2
		dmtc0	zero,C0_TAGHI,2

		li	t2,K1BASE
		add     t0,t2,t3
1:		cache   L2CACHEOP(L2C,L2C_OP_IDXSTORETAG),0(t2)
		addu    t2,L2CACHE_LINESIZE
		bne     t0,t2,1b

		mfc0	t0,C0_CONFIG
		li	t1,0x7FFFFFFF
		and	t0,t0,t1
		mtc0	t0,C0_CONFIG

		j	ra

END(rm7000_l2cache_init)


/*  *********************************************************************
    *  RM7000_L2CACHE_INVAL_I()
    *  
    *  Invalidate the L1 ICache
    *  
    *  Input parameters: 
    *  	   nothing
    *  	   
    *  Return value:
    *  	   nothing
    *  
    *  Registers used:
    *  	   t0,t1,t2,t3
    ********************************************************************* */

	
LEAF(rm7000_l2cache_inval_i)


		li	t2,K1BASE
		li	t3,L2CACHE_IDXHIGH

		add     t0,t2,t3
1:		cache   L2CACHEOP(L2C,L2C_OP_IDXINVAL),0(t2)
		addu    t2,L2CACHE_LINESIZE
		bne     t0,t2,1b

		j	ra

END(rm7000_l2cache_inval_i)


/*  *********************************************************************
    *  RM7000_L2CACHE_FLUSH_D()
    *  
    *  Flush the entire L1 DCache (write dirty lines back to memory)
    *  
    *  Input parameters: 
    *  	   nothing
    *  	   
    *  Return value:
    *  	   nothing
    *  
    *  Registers used:
    *  	   t0,t1,t2,t3
    ********************************************************************* */

	
LEAF(rm7000_l2cache_flush)

		li	t2,K1BASE
		li	t3,L2CACHE_IDXHIGH

		li	t2,K1BASE
		add     t0,t2,t3
1:		cache   L2CACHEOP(L2C,L2C_OP_IDXINVAL),0(t2)
		addu    t2,L2CACHE_LINESIZE
		bne     t0,t2,1b

		j	ra

END(rm7000_l2cache_flush)


/*  *********************************************************************
    *  End
    ********************************************************************* */
