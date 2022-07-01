      SUBROUTINE ZRREC (IUNIT, IREC, IARRAY, NWORDS, ISWAP,
     *                  ISTAT, JSTAT)
C
C     Reads physical record from disk
C
C     Written by Bill Charley at HEC, 1984.
C
      INTEGER IARRAY(NWORDS)
C
      CHARACTER C1*4, C2*4
      EQUIVALENCE (C1,I1), (C2,I2)
      COMMON /ZDSSSZ/ IARY2(128)
C
      INCLUDE 'zdssnz.h'
C
      INCLUDE 'zdssmz.h'
C
C
C
      INTEGER(8) IOFSET, IPOS
C
      IF (MLEVEL.GE.10) WRITE (MUNIT, 20) IUNIT, IREC
C     WRITE (MUNIT, 20) IUNIT, IREC
 20   FORMAT (T3,'+++++DSS+++Debug: Physical  Read;  Unit',I5,
     * '  Record',I8)
C
C
      ISTAT = 0
      JSTAT = 0
C
C
      IOFSET = (INT(IREC, 8)-1) * 512
      CALL seekf64 (IUNIT, 0, IOFSET, IPOS, ISTAT)
      IF (ISTAT.NE.0) THEN
         IF ((IREC.GT.0).AND.(IOFSET.LT.0)) WRITE(MUNIT, 50)
 50      FORMAT(/' ***** DSS: Maximum file size limit reached *****'/)
         GO TO 800
      ENDIF
      IF (ISWAP.EQ.0) THEN
         CALL readf (IUNIT, IARRAY, 508, ISTAT, NTRANS)
C
C        On Windows computers, if the network fails on a remote drive,
C        the status will be returned as 22.  Try a few more times
C        before erroring out
C        IF (ISTAT.EQ.22) THEN                                          d
C           DO 30 I=1,10                                                d
C              CALL WAITS (1.5)                                         d
C              CALL readf (IUNIT, IARRAY, 508, ISTAT, NTRANS)           d
C              IF (ISTAT.NE.22) GO TO 40                                d
C30         CONTINUE                                                    d
C           IF (MLEVEL.GE.1) WRITE (MUNIT, 35) IUNIT                    d
C35         FORMAT (' ERROR:  Network Failure for unit ', I5)           d
C40         CONTINUE                                                    d
C        ENDIF                                                          d
      ELSE
         CALL readf (IUNIT, IARY2,  508, ISTAT, NTRANS)
      ENDIF
      IF ((ISTAT.EQ.0).AND.(NTRANS.NE.508)) ISTAT = -1
C     CALL READF (IUNIT, IARRAY, NRECL, ISTAT, NTRANS)                  c
C     IF ((ISTAT.EQ.0).AND.(NTRANS.NE.NRECL)) ISTAT = -1                c
C
C     Switch bytes for big endian computers
      IF (ISWAP.NE.0) THEN
      DO 60 I=1,NWORDS
      I1 = IARY2(I)
      C2(1:1) = C1(4:4)
      C2(2:2) = C1(3:3)
      C2(3:3) = C1(2:2)
      C2(4:4) = C1(1:1)
      IARRAY(I) = I2
 60   CONTINUE
      ENDIF
C
C
C
 800  CONTINUE
C     If an error occured, find out what it was, and save it
C     in the common error message area
      IF (ISTAT.NE.0) THEN
C          CALL GERROR (CERRMS)
         WRITE(MUNIT, 900)
 900      FORMAT(/' ***** DSS: GERROR CALLED ON LINUX  *****'/)
          IERRMS = IERRNO ()
      ENDIF
C
      RETURN
      END
