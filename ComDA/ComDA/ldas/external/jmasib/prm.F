! prm.F - �i�q�z�u�����肷��萔
!
! 99/05/xx �ۍ␪�G   ���f���̂����K�v�ȍ��ڂ�؂�o���B
! 99/11/12 �ۍ␪�G   ISLSCP 36X18 �p
! 2000-06-30 �L�c�p�i  IMAX, JMAX, JLMAX �ɏ]�����镔�������ɕύX
!
      MODULE PRM
!
      IMPLICIT NONE
      ! �����i�q��
      INTEGER,PARAMETER :: IMAX  = 1
      ! ��k�i�q��
      INTEGER,PARAMETER :: JMAX  = 1
      INTEGER,PARAMETER :: IDIM  = IMAX
      INTEGER,PARAMETER :: JDIM  = JMAX 
      ! ��k�o���h������
      INTEGER,PARAMETER :: JLMAX = 1 
      INTEGER,PARAMETER :: JLPHY = JLMAX 
      INTEGER,PARAMETER :: IJMAX = IMAX * JMAX / JLMAX
      INTEGER,PARAMETER :: IJPHY = IJMAX 
      INTEGER,PARAMETER :: JPHY2 = JDIM / JLPHY
      INTEGER,PARAMETER :: INTRI = 1        
      INTEGER,PARAMETER :: INTRJ = 1
      INTEGER,PARAMETER :: IRAD  = IDIM / INTRI
      INTEGER,PARAMETER :: JRAD  = JDIM / INTRJ
      INTEGER,PARAMETER :: JRD   = JRAD / JLPHY
      INTEGER,PARAMETER :: JBLK1 = JMAX / JLMAX / 2
      INTEGER,PARAMETER :: JBLK2 = JMAX / JLMAX
!
!  --------------------------------------------------------
!
      INTEGER,PARAMETER :: KMAX  = 1
      INTEGER,PARAMETER :: KMP1  = 30+1
!     INTEGER,PARAMETER :: KMP1  = KMAX+1
!
!======================================================================
!
      ! ����i�q�Ɋ�܂ŗ��i�q�����邩
      INTEGER,PARAMETER :: ISPT = 1
!
      INTEGER,PARAMETER :: INTI_3    = 1
      INTEGER,PARAMETER :: INTJ_3    = 1
      INTEGER,PARAMETER :: INTI_3ETA = 1
      INTEGER,PARAMETER :: INTJ_3ETA = 1
      INTEGER,PARAMETER :: maxi_3    = imax/inti_3
      INTEGER,PARAMETER :: maxj_3    = jmax/intj_3
      INTEGER,PARAMETER :: maxi_3eta = imax/inti_3eta
      INTEGER,PARAMETER :: maxj_3eta = jmax/intj_3eta
      INTEGER,PARAMETER :: KmaxM     = 24
!
! FOR SIB3
      INTEGER,PARAMETER :: ISBWKW = IJPHY*100
      INTEGER,PARAMETER :: ISBWKD = IJPHY*100 + 1 
!
      REAL(8),PARAMETER ::
     &  p_monit(kmaxm)                                       
     &    = (/ 1000.D0, 925.D0, 850.D0, 700.D0, 600.D0, 
     &          500.D0, 400.D0, 300.D0, 250.D0, 200.D0, 
     &          150.D0, 100.D0,  70.D0,  50.D0,  30.D0, 
     &           20.D0,  15.D0,  10.D0,   7.D0,   5.D0, 
     &            3.D0,   2.D0,   1.D0,  0.5D0 /)

      END MODULE PRM