C     ---------------------------------------
C
C     DSS Character common block
      CHARACTER CVERS*10, CPROG*10, CDATE*10, CTIME*10, CDSS*10
      CHARACTER CTAG*12, CRNTAG*12, CFDATE*12, CSIZE*12, CKPATH*400
      CHARACTER CRTYPE(45)*3, CRDESC(45)*50, CINTYP(10)*20
      CHARACTER CEXTYP(10)*20
      COMMON /ZDSSCZ/ CVERS, CPROG,  CDATE,  CTIME, CDSS, CTAG,
     * CFDATE, CSIZE, CRNTAG, CKPATH, CRTYPE, CRDESC, CINTYP, CEXTYP
C
C     ---------------------------------------
