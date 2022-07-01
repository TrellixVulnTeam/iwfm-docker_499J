      SUBROUTINE ZSWAP (IN, IOUT)
C
C     Swaps bytes within a integer word
C     This is used for DSS files that are not
C     on a native "Endian" machine
C
      INTEGER   IN, IOUT, I1, I2
C
      CHARACTER C1*4, C2*4
      EQUIVALENCE (I1, C1), (I2, C2)
C
C
      I1 = IN
      C2(4:4) = C1(1:1)
      C2(3:3) = C1(2:2)
      C2(2:2) = C1(3:3)
      C2(1:1) = C1(4:4)
      IOUT = I2
C
      RETURN
      END
      SUBROUTINE ZSWAPW (IDATA, NDATA)
C
C     Swaps all ints in IDATA.
C
      INTEGER IDATA(NDATA)
C
      DO 20 I=1,NDATA
         CALL ZSWAP(IDATA(I), IDATA(I))
 20   CONTINUE
C
      RETURN
      END
