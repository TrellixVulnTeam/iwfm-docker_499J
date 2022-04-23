      SUBROUTINE ZRITS (IFLTAB, CPATH, JULS, ISTIME, JULE, IETIME,
     * ITIMES, VALUES, KVALS, NVALS, IBDATE, CUNITS, CTYPE, ISTAT)
C
C     Retrieve irregular time series data
C     Short version
C     For data quailty or user header call ZRITSX
C
      INTEGER IFLTAB(*), ITIMES(*)
      REAL VALUES(*)
      CHARACTER CPATH*(*), CUNITS*(*), CTYPE*(*)
      LOGICAL LQUAL
C
      CALL ZRITSX (IFLTAB, CPATH, JULS, ISTIME, JULE, IETIME,
     * ITIMES, VALUES, KVALS, NVALS, IBDATE, JQUAL, .FALSE., LQUAL,
     * CUNITS, CTYPE, IUHEAD, 0, NDUM, 0, ISTAT)
C
      RETURN
      END
