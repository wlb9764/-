!  ��ł̉��x�̎������Ă�B
!  99/06/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE SNOW_HFLUX_IMPLICIT_EQSET (
     I  NMAX      , NMAX_01   , 
     I  NMAX_2    , NMAX_3    , NMAX_4    , 
     I  DELT_SNOW , 
     I  PHASE_SNOW       , 
     I  CAP_SNOW         , HDIFF_FLUX_H      , 
     I  HDF_SNOW_H       ,
     O  SIB_MTX_SNOW     , 
     M  HFLUX_CONV )

!  ��ł̉��x�̎������Ă�B
!
!        S1    1
!        S2    2
!        S3    3
!        S4    4
! 
!   ����
!     �E�ォ��̃t���b�N�X�͗^�����Ă���B      
!
!     �E��̑w���ƁATMP_SNSL ���̊֌W
!       �� 1 �w�̎�    TMP_SNOW(I,2)   = TMP_SNSL(I)  
!                      HDF_SNOW_H(I,1) = �ቺ�[�Ɛቺ�y��
!       �� 2 �w�̎�    TMP_SNOW(I,3)   = TMP_SNSL(I)  
!                      HDF_SNOW_H(I,2) = �ቺ�[�Ɛቺ�y��
!       �� 3 �w�̎�    TMP_SNOW(I,4)   = TMP_SNSL(I)  
!                      HDF_SNOW_H(I,3) = �ቺ�[�Ɛቺ�y��
! 
!     �ET_{frez} �ɓ������ꍇ�͂��̑w�͉��x�ω����Ȃ��Ƃ��ĕ]������B
!       PHASE_SNOW   ! ���ω� on 0 off 1
!
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    ISN      
!
      USE SIBCON , ONLY :
     1    HL_W2G_c , 
     1    DELT_FAC_SNOW_c
!
      IMPLICIT NONE 
!
! INPUT 
!
      INTEGER,INTENT(IN)    :: NMAX
      INTEGER,INTENT(IN)    :: NMAX_01(3)
!     INTEGER,INTENT(IN)    :: NMAX_02(3)
!     INTEGER,INTENT(IN)    :: NMAX_1 (3)
      INTEGER,INTENT(IN)    :: NMAX_2 (3)
      INTEGER,INTENT(IN)    :: NMAX_3 (3)
      INTEGER,INTENT(IN)    :: NMAX_4 (3)
!
!     REAL(8),INTENT(IN)    :: TMP_SNOW    (IDX,ISN)
!     REAL(8),INTENT(IN)    :: TMP_SNSL    (IDX)
!
      REAL(8),INTENT(IN)    :: PHASE_SNOW  (IDX,ISN)
!
      REAL(8),INTENT(IN)    :: DELT_SNOW
!
      REAL(8),INTENT(IN)    :: CAP_SNOW    (IDX,ISN)
!
      REAL(8),INTENT(IN)    :: HDIFF_FLUX_H(IDX,0:ISN) 
!
      REAL(8),INTENT(IN)    :: HDF_SNOW_H  (IDX,ISN)   ! �ᒆ 1-2,2-3,3-4  
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)   :: SIB_MTX_SNOW(IDX,ISN,ISN+1) 
      REAL(8),INTENT(INOUT) :: HFLUX_CONV(IDX,ISN) 
!
! WORK
      INTEGER               :: I
      REAL(8)               :: DELT_TMP 
!
      LOGICAL,SAVE :: LFIRST 
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'SNOW_HFLUX_IMPLICIT_EQSET POCHAKA 99/08/09' 
        LFIRST = .FALSE.
      ENDIF
!
      DELT_TMP = DELT_SNOW * DELT_FAC_SNOW_c
!
      CALL RESET ( SIB_MTX_SNOW , IDX*ISN*(ISN+1) )
!
!  ---------------------------------------------------
!  ����w�̎� 
!  ---------------------------------------------------
!
      DO 1100 I=NMAX_01(2),NMAX
        SIB_MTX_SNOW(I,1,1)                       ! ����w
     1     =   CAP_SNOW(I,1) 
     1       + HDF_SNOW_H(I,1) * DELT_TMP            ! ����w or �y���
     1         * PHASE_SNOW(I,1)
!
        SIB_MTX_SNOW(I,1,2)                       ! ����w
     1     = - HDF_SNOW_H(I,1) * DELT_TMP 
     1         * PHASE_SNOW(I,2)                     ! ��w�����Ȃ��ꍇ�� ��
!
        SIB_MTX_SNOW(I,1,5) =                     ! ���� �i�P�ʎ��ԓ�����j
     1      + HFLUX_CONV  (I,1)                      ! �Z�g��
     1      + HDIFF_FLUX_H(I,0)
     1      - HDIFF_FLUX_H(I,1) 
 1100 CONTINUE         
!
!  ---------------------------------------------------
!  ����w�̎� 
!  ---------------------------------------------------
!
      DO 1200 I=NMAX_2(2),NMAX
!
        SIB_MTX_SNOW(I,2,1)                        ! ���w
     1      =  - HDF_SNOW_H(I,1) * DELT_TMP             
     1              * PHASE_SNOW(I,1)
!
        SIB_MTX_SNOW(I,2,2)                        ! ���w 
     1    =   CAP_SNOW(I,2) 
     1      + HDF_SNOW_H(I,1) * DELT_TMP               ! ���w��
     1              * PHASE_SNOW(I,2)
     1      + HDF_SNOW_H(I,2) * DELT_TMP               ! ��O�w or �y���
     1              * PHASE_SNOW(I,2)
!
        SIB_MTX_SNOW(I,2,3)                         ! ��O�w
     1      =  - HDF_SNOW_H(I,2) * DELT_TMP             
     1              * PHASE_SNOW(I,3)                  ! ��w�����Ȃ��ꍇ��
!
        SIB_MTX_SNOW(I,2,5) =                       ! ����
     1      + HFLUX_CONV    (I,2)                      ! �Z�g��
     1      + HDIFF_FLUX_H  (I,1)
     1      - HDIFF_FLUX_H  (I,2)
 1200 CONTINUE         
!
!  ---------------------------------------------------
!  ���O�w�̎� 
!  ---------------------------------------------------
!
      DO 1300 I=NMAX_3(2),NMAX
!
        SIB_MTX_SNOW(I,3,2)                          ! ���w
     1      =  - HDF_SNOW_H(I,2) * DELT_TMP             
     1              * PHASE_SNOW(I,2)
!
        SIB_MTX_SNOW(I,3,3)                          ! ��O�w 
     1    =   CAP_SNOW(I,3) 
     1      + HDF_SNOW_H(I,2) * DELT_TMP                ! ���w��
     1              * PHASE_SNOW(I,3)
     1      + HDF_SNOW_H(I,3) * DELT_TMP                ! ��l�w or �y���
     1              * PHASE_SNOW(I,3)
!
        SIB_MTX_SNOW(I,3,4)                          ! ��l�w
     1      =  - HDF_SNOW_H(I,3) * DELT_TMP             
     1              * PHASE_SNOW(I,4)                   ! �O�w�����Ȃ��ꍇ��
!
        SIB_MTX_SNOW(I,3,5) =                        ! ����
     1      + HFLUX_CONV    (I,3)                       ! �Z�g��
     1      + HDIFF_FLUX_H  (I,2)
     1      - HDIFF_FLUX_H  (I,3)
 1300 CONTINUE         
!
!  ---------------------------------------------------
!  ���l�w�̎� 
!  ---------------------------------------------------
!
      DO 1400 I=NMAX_4(2),NMAX
!
        SIB_MTX_SNOW(I,4,3)                           ! ��O�w
     1      =  - HDF_SNOW_H(I,3) * DELT_TMP             
     1              * PHASE_SNOW(I,3)
!
        SIB_MTX_SNOW(I,4,4)                           ! ��l�w 
     1    =   CAP_SNOW(I,4) 
     1      + HDF_SNOW_H(I,3) * DELT_TMP                   ! ��O�w��
     1              * PHASE_SNOW(I,4)
     1      + HDF_SNOW_H(I,4) * DELT_TMP                   ! �n�ʂ�
     1              * PHASE_SNOW(I,4)
!
        SIB_MTX_SNOW(I,4,5) =                         ! ����
     1      + HFLUX_CONV    (I,4)                          ! �Z�g��
     1      + HDIFF_FLUX_H  (I,3)
     1      - HDIFF_FLUX_H  (I,4)
 1400 CONTINUE         
!
      RETURN
      END
!===============================================================
! ����̔M�̕�����������
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X

      SUBROUTINE SNOW_HFLUX_IMPLICIT_EQSLV (
     I  NMAX_01   , 
     I  NMAX_1    , NMAX_2    , NMAX_3    , NMAX_4    , 
     M  SMTX      ) 
!
!     S1  1
!     S2  2
!     S3  3
!     S4  4
!
      USE SIBPRM , ONLY : 
     1    IDX      
!
      IMPLICIT NONE 
!
! INPUT
      INTEGER,INTENT(IN)    :: NMAX_01(3)
      INTEGER,INTENT(IN)    :: NMAX_1 (3)
      INTEGER,INTENT(IN)    :: NMAX_2 (3)
      INTEGER,INTENT(IN)    :: NMAX_3 (3)
      INTEGER,INTENT(IN)    :: NMAX_4 (3)
!
! INOUT
!
      REAL(8),INTENT(INOUT) :: SMTX(IDX,4,5) 
!
! WORK
      INTEGER               :: I
      REAL(8)               :: A22I 
      REAL(8)               :: A33I 
      REAL(8)               :: A44I 
!
      LOGICAL,SAVE :: LFIRST 
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'SNOW_HFLUX_IMPLICIT_EQSLV POCHAKA 99/08/09' 
        LFIRST = .FALSE.
      ENDIF

!
! -----------
! >> ��w << 
! -----------
!
      DO 1000 I=NMAX_01(2),NMAX_1(3)
        SMTX(I,1,5) = SMTX(I,1,5) / SMTX(I,1,1) 
!       SMTX(I,1,1) = 1.
 1000 CONTINUE
!
! -----------
! >> ��w << 
! -----------
!
      DO 2000 I=NMAX_2(2),NMAX_2(3)
!
!a11  a12           a15
!a21  a22           a25
!
        A22I = 1. / SMTX(I,2,2) 
        SMTX(I,2,1) = SMTX(I,2,1) * A22I  
        SMTX(I,2,5) = SMTX(I,2,5) * A22I  
!       SMTX(I,2,2) = 1. 
!
        SMTX(I,1,1) = SMTX(I,1,1) - SMTX(I,1,2) * SMTX(I,2,1) 
        SMTX(I,1,5) = SMTX(I,1,5) - SMTX(I,1,2) * SMTX(I,2,5) 
!       SMTX(I,1,2) = 0. 
!
!a11*  0*           a15*
!a21*  1*           a25*
!
        SMTX(I,1,5) = SMTX(I,1,5) / SMTX(I,1,1)
!       SMTX(I,1,1) = 1. 
!
! 1*                a15*
!a21   1            a25
!
        SMTX(I,2,5) = SMTX(I,2,5) - SMTX(I,2,1) * SMTX(I,1,5)  
!       SMTX(I,2,1) = 0. 
 2000 CONTINUE
!
! -----------
! >> �O�w << 
! -----------
!
      DO 3000 I=NMAX_3(2),NMAX_3(3)
!
!a11  a12           a15
!a21  a22  a23      a25
!     a32  a33      a35
!
        A33I = 1. / SMTX(I,3,3) 
        SMTX(I,3,2) = SMTX(I,3,2) * A33I  
        SMTX(I,3,5) = SMTX(I,3,5) * A33I  
!       SMTX(I,3,3) = 1. 
!
        SMTX(I,2,2) = SMTX(I,2,2) - SMTX(I,2,3) * SMTX(I,3,2) 
        SMTX(I,2,5) = SMTX(I,2,5) - SMTX(I,2,3) * SMTX(I,3,5) 
!       SMTX(I,2,3) = 0. 
!
!a11  a12           a15
!a21  a22*  0*      a25*
!     a32*  1*      a35*
!
        A22I = 1. / SMTX(I,2,2) 
        SMTX(I,2,1) = SMTX(I,2,1) * A22I  
        SMTX(I,2,5) = SMTX(I,2,5) * A22I  
!       SMTX(I,2,2) = 1. 
!
        SMTX(I,1,1) = SMTX(I,1,1) - SMTX(I,1,2) * SMTX(I,2,1) 
        SMTX(I,1,5) = SMTX(I,1,5) - SMTX(I,1,2) * SMTX(I,2,5) 
!       SMTX(I,1,2) = 0. 
!
!a11*  0*           a15*
!a21*  1*           a25*
!     a32   1       a35
!
        SMTX(I,1,5) = SMTX(I,1,5) / SMTX(I,1,1)
!       SMTX(I,1,1) = 1. 
!
! 1*                a15*
!a21   1            a25
!     a32   1       a35
!
        SMTX(I,2,5) = SMTX(I,2,5) - SMTX(I,2,1) * SMTX(I,1,5)  
!       SMTX(I,2,1) = 0. 
        SMTX(I,3,5) = SMTX(I,3,5) - SMTX(I,3,2) * SMTX(I,2,5)  
!       SMTX(I,3,2) = 0. 
 3000 CONTINUE
!
! -----------
! >> �l�w << 
! -----------
!
      DO 4000 I=NMAX_4(2),NMAX_4(3)
!
!a11  a12            a15
!a21  a22  a23       a25
!     a32  a33  a34  a35
!          a43  a44  a45
!
        A44I = 1. / SMTX(I,4,4) 
        SMTX(I,4,3) = SMTX(I,4,3) * A44I  
        SMTX(I,4,5) = SMTX(I,4,5) * A44I  
!       SMTX(I,4,4) = 1. 
!
        SMTX(I,3,3) = SMTX(I,3,3) - SMTX(I,3,4) * SMTX(I,4,3) 
        SMTX(I,3,5) = SMTX(I,3,5) - SMTX(I,3,4) * SMTX(I,4,5) 
!       SMTX(I,3,4) = 0. 
!
!a11  a12            a15
!a21  a22  a23       a25
!     a32  a33*  0   a35*
!          a43*  1   a45*
!
        A33I = 1. / SMTX(I,3,3) 
        SMTX(I,3,2) = SMTX(I,3,2) * A33I  
        SMTX(I,3,5) = SMTX(I,3,5) * A33I  
!       SMTX(I,3,3) = 1. 
!
        SMTX(I,2,2) = SMTX(I,2,2) - SMTX(I,2,3) * SMTX(I,3,2) 
        SMTX(I,2,5) = SMTX(I,2,5) - SMTX(I,2,3) * SMTX(I,3,5) 
!       SMTX(I,2,3) = 0. 

!
!a11  a12            a15
!a21  a22*  0*       a25*
!     a32*  1*       a35*
!          a43   1   a45
!
        A22I = 1. / SMTX(I,2,2) 
        SMTX(I,2,1) = SMTX(I,2,1) * A22I  
        SMTX(I,2,5) = SMTX(I,2,5) * A22I  
!       SMTX(I,2,2) = 1. 
!
        SMTX(I,1,1) = SMTX(I,1,1) - SMTX(I,1,2) * SMTX(I,2,1) 
        SMTX(I,1,5) = SMTX(I,1,5) - SMTX(I,1,2) * SMTX(I,2,5) 
!       SMTX(I,1,2) = 0. 
!
!a11*  0*            a15*
!a21*  1*            a25*
!     a32   1        a35
!          a43   1   a45
!
        SMTX(I,1,5) = SMTX(I,1,5) / SMTX(I,1,1)
!       SMTX(I,1,1) = 1. 
!
! 1*                 a15*
!a21   1             a25
!     a32   1        a35
!          a43   1   a45
!
        SMTX(I,2,5) = SMTX(I,2,5) - SMTX(I,2,1) * SMTX(I,1,5)  
!       SMTX(I,2,1) = 0. 
        SMTX(I,3,5) = SMTX(I,3,5) - SMTX(I,3,2) * SMTX(I,2,5)  
!       SMTX(I,3,2) = 0. 
        SMTX(I,4,5) = SMTX(I,4,5) - SMTX(I,4,3) * SMTX(I,3,5)  
!       SMTX(I,4,3) = 0. 
 4000 CONTINUE
!
      RETURN
      END
!================================================================
! ��̊e�w�̓���M�t���b�N�X�����̌v�Z �i�z�I�]���ɁA�A�I�]���␳����������j
! �y��ւ̔M�t���b�N�X�̌v�Z
! 99/07/11 �ۍ␪�G ����
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE SNOW_HFLUX_IMPLICIT_CORR (
     I  NMAX      , NMAX_01   , NMAX_1    , 
     I  NMAX_2    , NMAX_3    , NMAX_4    , 
     I  SIB_MTX_SNOW          , 
     I  HDF_SNOW_H            , 
     I  DELT_SNOW             , PHASE_SNOW           , 
     I  CVR_SNW              ,               
     I  SRAD_BUCKET_SNOW_TO_SNSL     ,  
     M  HDIFF_FLUX_H          , 
     O  ENG_BUCKET_SNOW_TO_SNSL      , 
     M  HFLUX_CONV             )  
!
      USE SIBPRM , ONLY :
     1   IDX  , 
     1   ISN    
!
      USE SIBCON , ONLY :
     1   DELT_FAC_SNOW_c
!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : MONIT_SIB , ICS ,
     1                IMONIT_LEVEL, IMONIT_ALL ,
     1                IMONIT_FLUX_COMMON 
#endif
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)   :: NMAX
      INTEGER,INTENT(IN)   :: NMAX_01(3)    
      INTEGER,INTENT(IN)   :: NMAX_1 (3)    
      INTEGER,INTENT(IN)   :: NMAX_2 (3)    
      INTEGER,INTENT(IN)   :: NMAX_3 (3)    
      INTEGER,INTENT(IN)   :: NMAX_4 (3)    
!
      REAL(8),INTENT(IN)   :: SIB_MTX_SNOW (IDX,ISN,ISN+1)
      REAL(8),INTENT(IN)   :: HDF_SNOW_H   (IDX,ISN)
      REAL(8),INTENT(IN)   :: PHASE_SNOW   (IDX,ISN)
      REAL(8),INTENT(IN)   :: DELT_SNOW  
!
      REAL(8),INTENT(IN)   :: CVR_SNW      (IDX)
!
      REAL(8),INTENT(IN)   :: SRAD_BUCKET_SNOW_TO_SNSL(IDX) 
!
      REAL(8),INTENT(INOUT):: HDIFF_FLUX_H(IDX,0:ISN) 
!
! OUTPUT
!
      REAL(8),INTENT(OUT)  :: ENG_BUCKET_SNOW_TO_SNSL(IDX) 
!
! INOUT 
! 
      REAL(8),INTENT(INOUT):: HFLUX_CONV(IDX,ISN)  ! ��̊e�w���󂯎��M
!
! WORK
!
      INTEGER :: I
      REAL(8) :: DELT_TMP
      REAL(8) :: HDIFF_FLUX_H_CORR 
      REAL(8) :: ENG_BUC_SNOW_TO_SNSL(IDX) 
!
!
#ifdef MONYOS
      REAL(8),PARAMETER  :: ONE = 1.D0 
!     REAL(8)            :: WORK(IDX) 
      CHARACTER(7)       :: CMARK
#endif
!
      LOGICAL,SAVE :: LFIRST 
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'SNOW_HFLUX_IMPLICIT_CORR POCHAKA 99/08/09' 
        LFIRST = .FALSE.
      ENDIF
!
! �G�N�X�v���V�b�g�]���ɁA�C���v���V�b�g����������B
!
      DELT_TMP = DELT_SNOW * DELT_FAC_SNOW_c
!
! ���w
!     ��w�����Ȃ��ꍇ�� PHASE_SNOW(I,2) = 0
!    
      DO 1100 I=NMAX_01(2),NMAX
        HDIFF_FLUX_H_CORR = 
     1         HDF_SNOW_H(I,1) * DELT_TMP 
     1           * ( SIB_MTX_SNOW(I,1,5) * PHASE_SNOW(I,1) 
     1                - SIB_MTX_SNOW(I,2,5) * PHASE_SNOW(I,2) )
        HDIFF_FLUX_H(I,1) = HDIFF_FLUX_H(I,1) + HDIFF_FLUX_H_CORR
 1100 CONTINUE  
!
! ���w
!     ��w�����Ȃ��ꍇ�� PHASE_SNOW(I,3) = 0
!    
      DO 1200 I=NMAX_2(2),NMAX
        HDIFF_FLUX_H_CORR = 
     1         HDF_SNOW_H(I,2) * DELT_TMP 
     1           * ( SIB_MTX_SNOW(I,2,5) * PHASE_SNOW(I,2) 
     1                - SIB_MTX_SNOW(I,3,5) * PHASE_SNOW(I,3) )
        HDIFF_FLUX_H(I,2) = HDIFF_FLUX_H(I,2) + HDIFF_FLUX_H_CORR
 1200 CONTINUE  
!
! ��O�w
!     �O�w�����Ȃ��ꍇ�� PHASE_SNOW(I,4) = 0
!    
      DO 1300 I=NMAX_3(2),NMAX
        HDIFF_FLUX_H_CORR = 
     1         HDF_SNOW_H(I,3) * DELT_TMP 
     1           * ( SIB_MTX_SNOW(I,3,5) * PHASE_SNOW(I,3) 
     1                - SIB_MTX_SNOW(I,4,5) * PHASE_SNOW(I,4) )
        HDIFF_FLUX_H(I,3) = HDIFF_FLUX_H(I,3) + HDIFF_FLUX_H_CORR
 1300 CONTINUE  
!
! ��l�w
!    
      DO 1400 I=NMAX_4(2),NMAX
        HDIFF_FLUX_H_CORR = 
     1         HDF_SNOW_H(I,4) * DELT_TMP 
     1           *  SIB_MTX_SNOW(I,4,5) * PHASE_SNOW(I,4) 
        HDIFF_FLUX_H(I,4) = HDIFF_FLUX_H(I,4) + HDIFF_FLUX_H_CORR
 1400 CONTINUE  
!
      DO I=NMAX_01(2),NMAX_1(3)
        HDIFF_FLUX_H(I,2) = HDIFF_FLUX_H(I,1) 
        HDIFF_FLUX_H(I,3) = HDIFF_FLUX_H(I,1) 
        HDIFF_FLUX_H(I,4) = HDIFF_FLUX_H(I,1) 
      ENDDO 
      DO I=NMAX_2(2),NMAX_2(3)
        HDIFF_FLUX_H(I,3) = HDIFF_FLUX_H(I,2) 
        HDIFF_FLUX_H(I,4) = HDIFF_FLUX_H(I,2) 
      ENDDO 
      DO I=NMAX_3(2),NMAX_3(3)
        HDIFF_FLUX_H(I,4) = HDIFF_FLUX_H(I,3) 
      ENDDO 
!
      DO I=NMAX_01(2),NMAX 
        HFLUX_CONV(I,1) = HFLUX_CONV(I,1) 
     1                    + HDIFF_FLUX_H(I,0) - HDIFF_FLUX_H(I,1)  
        HFLUX_CONV(I,2) = HFLUX_CONV(I,2) 
     1                    + HDIFF_FLUX_H(I,1) - HDIFF_FLUX_H(I,2)  
        HFLUX_CONV(I,3) = HFLUX_CONV(I,3) 
     1                    + HDIFF_FLUX_H(I,2) - HDIFF_FLUX_H(I,3)  
        HFLUX_CONV(I,4) = HFLUX_CONV(I,4) 
     1                    + HDIFF_FLUX_H(I,3) - HDIFF_FLUX_H(I,4)  
      ENDDO
!
!  ========================
!  > �n�ʂւ̔M�t���b�N�X <  �i���������j
!  ========================
!
!  --------------------
!  > �M�g�U�t���b�N�X <
!  --------------------
!
      DO 2100 I=NMAX_01(2),NMAX_1(3)
        ENG_BUC_SNOW_TO_SNSL(I) 
     1      =  HDIFF_FLUX_H(I,1)   
 2100 CONTINUE  
!
      DO 2200 I=NMAX_2(2),NMAX_2(3)
        ENG_BUC_SNOW_TO_SNSL(I)  
     1      =    HDIFF_FLUX_H(I,2) 
 2200 CONTINUE  
!
      DO 2300 I=NMAX_3(2),NMAX_3(3)
        ENG_BUC_SNOW_TO_SNSL(I)  
     1      =    HDIFF_FLUX_H(I,3) 
 2300 CONTINUE  
!
      DO 2400 I=NMAX_4(2),NMAX_4(3)
        ENG_BUC_SNOW_TO_SNSL(I)  
     1      =    HDIFF_FLUX_H(I,4) 
 2400 CONTINUE  
!
!  --------------------------------
!  > �Ⴀ��E��Ȃ�������ł̕␳ <
!  --------------------------------
!     �����܂ł̌v�Z�ł� ENG_BUC_SNOW_TO_SNSL �͐Ⴀ��悾��
!     �ł̕��ϗʂł������B
!     �����Ŋi�q���ςɂ���B
!     ����炪���̂܂ܓy��ւ̓��͂ɂȂ�B
!
      ENG_BUCKET_SNOW_TO_SNSL(:) = 0.
!
      DO 3000 I=NMAX_01(2),NMAX
        ENG_BUCKET_SNOW_TO_SNSL(I) = 
     1         + ENG_BUC_SNOW_TO_SNSL(I) 
     1               * CVR_SNW(I) * DELT_SNOW
     1         + SRAD_BUCKET_SNOW_TO_SNSL(I)    
 3000 CONTINUE  
!
!  --------------
!  > �ڍ׃��j�^ <
!  --------------
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
!  �Ⴀ��y��ւ̔M
!
        CMARK  = 'HFLBWL' 
        CALL MONIT_SIB ( CMARK , ENG_BUC_SNOW_TO_SNSL,ICS,DELT_SNOW,ONE)  
      ENDIF
!
! �M�`���t���b�N�X  �i�C���v���V�b�g�␳�������Z�j
!
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
!
        CMARK  = 'HFLW12F' 
        CALL MONIT_SIB ( CMARK , HDIFF_FLUX_H(1,1), ICS, 
     1                   DELT_SNOW, ONE)  
!
        CMARK  = 'HFLW23F' 
        CALL MONIT_SIB ( CMARK , HDIFF_FLUX_H(1,2), ICS, 
     1                   DELT_SNOW, ONE)  
!
        CMARK  = 'HFLW34F' 
        CALL MONIT_SIB ( CMARK , HDIFF_FLUX_H(1,3), ICS, 
     1                   DELT_SNOW, ONE)  
!
        CMARK  = 'HFLW4LF' 
        CALL MONIT_SIB ( CMARK , HDIFF_FLUX_H(1,4), ICS, 
     1                   DELT_SNOW, ONE)  
!
      ENDIF
#endif
!
      RETURN
      END