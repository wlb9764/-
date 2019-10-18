      SUBROUTINE GSWP2_SUNANG ( 
     I     RDAY     , RSEC    , 
     I     GLON     , GLAT    , 
     O     COSZ         )
!
! �{���ɂ���ł����Ă���̂��H  �v�`�F�b�N
!
      USE PRM , ONLY : 
     1     IDIM , JDIM 
!
      IMPLICIT NONE 
!
! INPUT 
!
      REAL(8),INTENT(IN)  :: RDAY           ! ��N�ɂ����邻�̓��̈ʒu
      REAL(8),INTENT(IN)  :: RSEC           ! ����ɂ����邻�̏u�Ԃ̈ʒu  
      REAL(4),INTENT(IN)  :: GLON(IDIM)     ! �o�x�i�P�ʁA�x�j
      REAL(4),INTENT(IN)  :: GLAT(JDIM)     ! �ܓx�i�P�ʁA�x�j
!
! OUTPUT
!
      REAL(8),INTENT(OUT) :: COSZ  ( IDIM,JDIM ) ! cos(�V���p)
!
! WORK
!
      REAL(8),SAVE :: EPSORB 
      REAL(8),SAVE :: EQNORB
      REAL(8),SAVE :: PERORB
      REAL(8),SAVE :: ECCORB
      REAL(8),SAVE :: B1
      REAL(8),SAVE :: B2
      REAL(8),SAVE :: B3
!
      INTEGER      :: I
      INTEGER      :: J
      REAL(8)      :: EM 
      REAL(8)      :: OMG 
      REAL(8)      :: DELTS
      REAL(8)      :: ANGHR 
      REAL(8),save :: PIE_c
!
      LOGICAL   LFIRST
      DATA      LFIRST  / .TRUE. /
      DATA      EPSORB / 23.45D0    /     !" orbital incline angle
      DATA      EQNORB / 77.64D0    /     !" longitude of periherion
      DATA      PERORB /  2.32D0    /     !" long. of perigee
      DATA      ECCORB /  0.01672D0 /     !" eccentricity
*
      IF ( LFIRST ) THEN
        LFIRST = .FALSE.
        B1 = 2.D0         *ECCORB
     1         - 1.D0/4.D0    *ECCORB**3
     1         + 5.D0/96.D0   *ECCORB**5
        B2   = 5.D0/4.D0    *ECCORB**2
     1         - 11.D0/24.D0  *ECCORB**4
        B3 = 13.D0/12.D0  *ECCORB**3
     1     - 645.D0/940.D0*ECCORB**5
!
        pie_c = DATAN(1.D0) * 4
        write(6,*) pie_c 
!
      END IF
!
      EM    = ( RDAY - PERORB/360 )*2*PIE_c 
      OMG   = EM + B1*SIN( EM ) + B2*SIN( 2.*EM ) + B3*SIN( 3*EM )
      DELTS = ASIN(    SIN( EPSORB/180*PIE_c )
     1               * SIN( OMG-EQNORB/180*PIE_c )  )
!
      DO 2000 J = 1, JDIM
      DO 2000 I = 1, IDIM
	! ���z�̎��p: 1����2�Α������A�쒆���� 0 �ƂȂ�
        ANGHR = RSEC*2*PIE_c - PIE_c + GLON(I)/180*PIE_c
        COSZ( I,J ) = SIN(GLAT(J)/180*PIE_c) * SIN(DELTS)
     &              + COS(GLAT(J)/180*PIE_c) * COS(DELTS)*COS(ANGHR)
 2000 CONTINUE
!
      RETURN
      END