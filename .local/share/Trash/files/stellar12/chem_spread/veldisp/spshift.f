      program spshift

      integer nvd,nind,ngal
      parameter  ( nvd=5,nind=79,ngal=7)
      character*12 fnam(nvd)
      character*9  inam(nind)
      character*20 gnam
      real  vd(nvd),d(ngal,nvd,nind),e(nvd,nind)


      data fnam / 'tmeasure.000','tmeasure.100','tmeasure.200',
     z            'tmeasure.300','tmeasure.400' /
      data vd / 0.0, 100.0, 200.0, 300.0, 400.0 /

      do i=1,nvd
         open(unit=22,file=fnam(i),status='old')
         read(22,'(a20,79a9)') gnam,(inam(k),k=1,79)
         do j=1,ngal
            read(22,'(a20,79f9.3)') gnam,(d(j,i,k),k=1,79)
         end do
         close(22)
      end do

      do i=1,nvd
         do j=1,nind
            call mdian2(d(1,i,j),ngal,e(i,j))
         end do
      end do

C     output a human-readable file of index shifts
      open(unit=23,file='spshift.out',status='unknown')
      write(23,'(a)') ' I_0   dI(100)  dI(200)  dI(300)  dI(400)'
      do i=1,nind
         write(23,'(5f9.3,2x,a9)') e(1,i),e(2,i)-e(1,i),e(3,i)-e(1,i),
     z            e(4,i)-e(1,i),e(5,i)-e(1,i),inam(i)
      end do
      close(23)

C     output a plottable file of index data as a function of velocity disp
      open(unit=24,file='spdata.out',status='unknown')
      do i=1,nvd
         write(24,'(f5.1,79f9.3)') vd(i),(e(i,k),k=1,79)
      end do
      do j=1,ngal
         do i=1,nvd
            write(24,'(f5.1,79f9.3)') vd(i),(d(j,i,k),k=1,79)
         end do         
      end do
      close(24)

      stop
      end


      SUBROUTINE MDIAN2(X,N,XMED)
      DIMENSION X(N)
      PARAMETER (BIG=1.E30,AFAC=1.5,AMP=1.5)
      A=0.5*(X(1)+X(N))
      EPS=ABS(X(N)-X(1))
      AP=BIG
      AM=-BIG
1     SUM=0.
      SUMX=0.
      NP=0
      NM=0
      XP=BIG
      XM=-BIG
      DO 11 J=1,N
        XX=X(J)
        IF(XX.NE.A)THEN
          IF(XX.GT.A)THEN
            NP=NP+1
            IF(XX.LT.XP)XP=XX
          ELSE IF(XX.LT.A)THEN
            NM=NM+1
            IF(XX.GT.XM)XM=XX
          ENDIF
          DUM=1./(EPS+ABS(XX-A))
          SUM=SUM+DUM
          SUMX=SUMX+XX*DUM
        ENDIF
11    CONTINUE
      IF(NP-NM.GE.2)THEN
        AM=A
        AA=XP+MAX(0.,SUMX/SUM-A)*AMP
        IF(AA.GT.AP)AA=0.5*(A+AP)
        EPS=AFAC*ABS(AA-A)
        A=AA
        GO TO 1
      ELSE IF(NM-NP.GE.2)THEN
        AP=A
        AA=XM+MIN(0.,SUMX/SUM-A)*AMP
        IF(AA.LT.AM)AA=0.5*(A+AM)
        EPS=AFAC*ABS(AA-A)
        A=AA
        GO TO 1
      ELSE
        IF(MOD(N,2).EQ.0)THEN
          IF(NP.EQ.NM)THEN
            XMED=0.5*(XP+XM)
          ELSE IF(NP.GT.NM)THEN
            XMED=0.5*(A+XP)
          ELSE
            XMED=0.5*(XM+A)
          ENDIF
        ELSE
          IF(NP.EQ.NM)THEN
            XMED=A
          ELSE IF(NP.GT.NM)THEN
            XMED=XP
          ELSE
            XMED=XM
          ENDIF
        ENDIF
      ENDIF
      RETURN
      END
