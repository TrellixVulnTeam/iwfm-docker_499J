      SUBROUTINE DIBIN ( IUNIT, NUMB)
C
C     DISPLAYS NUMBER NUMB AS BINARY (TO UNIT IUNIT)
C
C     PARAMETER (IBPERW=24)                                             H
      PARAMETER (IBPERW=32)                                             u
C     PARAMETER (IBPERW=16)                                             ML
      CHARACTER CVAL*(IBPERW)
C
C
      DO 20 J=1,IBPERW
      JVAL = NUMB
      K = J - IBPERW
C     KVAL = JVAL.SHIFT.K                                               H
      KVAL = ISHFT(JVAL,K)                                              MLu
C     KVAL = KVAL.AND.1                                                 H
      KVAL = IAND(KVAL,1)                                               MLu
      IF (KVAL.EQ.1) THEN
      CVAL(J:J) = '1'
      ELSE
      CVAL(J:J) = '0'
      ENDIF
 20   CONTINUE
C
      WRITE ( IUNIT, 40) CVAL(1:8),CVAL(9:16),CVAL(17:24),CVAL(25:32)   u
C     WRITE ( IUNIT, 40) CVAL(1:8),CVAL(9:16)                           ML
C     WRITE ( IUNIT, 40) CVAL(1:8), CVAL(9:16), CVAL(17:24)             H
 40   FORMAT (' VALUE = ',5(A8,2X))
C
      RETURN
      END
