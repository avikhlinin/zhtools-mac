/*
 *
 * zhtools.h - include file for zhtools
 *
 */

#ifndef	__zhtools_h
#define	__zhtools_h

#include <conf.h>

#define HELPDIR "zhhelp"

/* data type of the extra int specifying the length of a Fortran string */
#ifndef CHAR_INT
#define CHAR_INT int
#endif

/* size of a pointer in bytes (C and Fortran) used by malloc */
#ifdef SIZEOF_VOID_P
#if SIZEOF_VOID_P==4
#define ZHPOINTER integer*4
#define ZHINT int
#elif SIZEOF_VOID_P==8
#define ZHPOINTER integer*8
#define ZHINT long int
#endif
#else
#define ZHPOINTER integer
#define ZHINT int
#endif

#if defined(F95) && !defined(USE_MALLOC)

#define ZHDECL(type,name)		type, pointer :: name(:)

#define ZHMALLOC(name,nel,ftype)	allocate(name(nel))

#define ZHREALLOC_DEFS	\
	INTERFACE;FUNCTION realloc_i(p, n);INTEGER,POINTER,DIMENSION(:)::realloc_i,p;INTEGER,intent(in)::n;END FUNCTION;END INTERFACE

#define ZHREALLOC(optr,p,n,t)    	if(t.ne.'i')STOP"bad realloc";p=>realloc_i(p,n);

#define ZHFREE(name)			deallocate(name)

#define ZHVAL(x)			x

#else

#define ZHDECL(type,ptr)		ZHPOINTER ptr

#define ZHMALLOC(ptr,nel,ftype) 	call xfor_malloc(ptr,nel,ftype)

#define ZHREALLOC_DEFS

#define ZHREALLOC(optr,ptr,nel,ftype)   call xfor_realloc(optr,ptr,nel,ftype)

#define ZHFREE(ptr)			call for_free(ptr)

#define ZHVAL(x)			%val(x)

#endif

#endif /* __zhtools.h */
