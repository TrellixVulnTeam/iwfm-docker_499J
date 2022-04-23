      SUBROUTINE ZRRTS ( IFLTAB, CPATH, CDATE, CTIME, NVALS, VALUES,
     * CUNITS, CTYPE, IOFSET, ISTAT)
C
C     Short version for retrieving regular interval time series data
C
C
      INTEGER IFLTAB(*)
      CHARACTER CPATH*(*), CDATE*(*), CTIME*(*), CUNITS*(*), CTYPE*(*)
      REAL VALUES(*)
      INTEGER NVALS, NUHEAD, ISTAT
      LOGICAL LQUAL
C
C
      LQUAL = .FALSE.
      NUHEAD = 0
      KUHEAD = 0
C
      CALL ZRRTSX ( IFLTAB, CPATH, CDATE, CTIME, NVALS, VALUES,
     * IQUAL, .FALSE., LQUAL, CUNITS, CTYPE, IUHEAD, KUHEAD,
     * NUHEAD, IOFSET, ICOMP, ISTAT)
C
C
      RETURN
      END
