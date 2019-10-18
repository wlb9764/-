! �L���m�s�[���ӂ̔M�g�U�̕������𗧂Ă�
!
! 99/06/xx �ۍ␪�G
!          �t���b�N�X�̌����i�����j���`�F�b�N
!          YMPBL0 �̏o�͓͂K���ɑg���݁B�i XXXXX,YYYYY �j
! 99/07/04 ���U TRNS_N �͏����ƕʈ�����
! 99/07/16 snw , nos ���܂Ƃ߂�B���O���ς���B
!          �t���b�N�X�̌����`�F�b�N�B��������o����������Ƃ���B
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 99/08/30 �ۍ␪�G ���� RAD, SENS , EVAP �����������ɂ����̂ŁA�ύX�B
! 99/09/16 �ۍ␪�G �o�O�Œ�BEVAP_TOT �� SUBL_TOT �̔z��
!
!         
      SUBROUTINE CANOPY_FLUX_EQSET (
     I  NSTR         , NEND      , INSFLAG   , 
     I  IMONIT       , 
     I  XLAI_VEG_msx , 
     I  FR_H2O_CNP   , FR_WBH_CNP , FR_H2O_GRS   , FR_WBH_GRS  , 
     I  H2O_SAT_CNP  , H2O_SAT_GRS, 
     I  SENS         ,             DSENS_DX  , 
     I  EVAP         , SUBL      , TRNS      , DEVAP_DX  , 
     I  DRAD_DX      , 
     I  RAD_SHRT     , RAD_LONG  ,  
     I  HDF          , HDF_SKIN  , 
     I  DELT_ATM     , DELT_CNP  , 
     I  GMT          , GMQ       , P_DEL     , Q_REF     , 
     I  CAP_SOIL_TOP , FLAG_PHASE_SS1 ,     
     O  SIB_MTX   )
!
!  ���x�̎������Ă�B
!
!    ����  
!      �E�L���m�s�[�̎��ʓI�ȗʂɂ͑S�� CVR_CNP ���������Ă���B
!    
!      �E�n�ʂ���ѐ�ʃX�L���͓K���ɕ]�����邪�A
!        �n�ʑ��w�܂��͐�ʑ��w�̉��x�͗z�ɕ]������B
!
!      �EGMT, GMQ �� TMTX ���̂��Ƃł���.
!
!      �E���˂� RAD �ɑS�ē����Ă���B
!        �������A�z��������������ł���!!!
!
!      �E���� RAD �͒P�ʎ��ԓ�����̎����ʁB
!        ����ȊO�͉��������̔M�t���b�N�X�B
!
!        R     3,4
!        C     1
!        G     2 
!
!      �E�������̌`��
!           ��M x dT/dt  = �t���b�N�X����
!                            ... �ォ�痈�镪�͐��A���ɏo�镪�͕�
!        �������A�t���b�N�X�͉A�I�ɕ]������B
!        ��t �̓t���b�N�X���A�I�ɕ]�����邽�߂����ɂ������B
!        �������̉� SIB_MTX(I,J,5) �� dT/dt ���ł���B
!
      USE COM_RUNCONF_SIB0109 , ONLY : 
     1    JCN_SIB_UPPER_MODEL   
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    IWG    ,
     1    ICG    , 
     1    IEST   , 
     1    ICGB   , 
     1    ICGR  
!
      USE SIBCON , ONLY :
     1    HL_WTR_c , 
     1    HL_GLA_c , 
     1    CP_AIR_c , 
     1    GRAV_c   , 
     1    DELT_FAC_ATM_c ,  
     1    DELT_FAC_CNP_c , 
     1    CAP_CNPX_C  ,
     1    CAP_GRSK_C  ,
     1    CAP_GRSKX_C ,
     1    CAP_SNSK_C  ,
     1    CAP_SNSKX_C ,
     1    CAP_LAI_C   ,
     1    CAP_WTR_C   ,   
     1    CAP_GLA_C    
!
      USE COM_RUNCONF_SIB0109 , ONLY : 
     1    JCN_CAP_CNP_SL , 
     1    JCN_WAY_OF_INTEGRATION 
!
      USE SIB_MONIT , ONLY :
     1   IMONIT_LEVEL  , MONIT_SIB ,
     1   IMONIT_ALL    , 
     1   ICN, ICS 
!
      IMPLICIT NONE 
!
! INPUT 
!
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
      INTEGER,INTENT(IN)    :: INSFLAG 
!
      INTEGER,INTENT(IN)    :: Imonit ! 0 �Ȃ�ώZ�A���Ȃ点��
!
      REAL(8),INTENT(IN)    :: GMT(IDX,2)
      REAL(8),INTENT(IN)    :: GMQ(IDX,2)
!
      REAL(8),INTENT(IN)    :: XLAI_VEG_msx (IDX,ICG)
      REAL(8),INTENT(IN)    :: FR_H2O_CNP (IDX)
      REAL(8),INTENT(IN)    :: FR_WBH_CNP (IDX)
      REAL(8),INTENT(IN)    :: FR_H2O_GRS (IDX)
      REAL(8),INTENT(IN)    :: FR_WBH_GRS (IDX)
      REAL(8),INTENT(IN)    :: H2O_SAT_GRS (IDX)
      REAL(8),INTENT(IN)    :: H2O_SAT_CNP (IDX)
!
      REAL(8),INTENT(IN)    :: DELT_ATM        ! ��C   �p�C���v���V�b�g����
      REAL(8),INTENT(IN)    :: DELT_CNP        ! CANOPY �p�C���v���V�b�g����
!
!
      REAL(8),INTENT(INOUT)    :: SENS      (IDX,ICG)     ! ���Mflux ��������
      REAL(8),INTENT(INOUT)    :: DSENS_DX  (IDX,ICG,ICGR)   
!
!     REAL(8),INTENT(IN)       :: RAD       (IDX,ICG)  ! �P�ʎ��ԓ����ˋz����
!     REAL(8),INTENT(IN)       :: DRAD_DX_TMP(IDX,ICG,ICG) ! ���ˋz���ʕω���
      REAL(8),INTENT(IN)       :: DRAD_DX   (IDX,ICGR,ICG) ! ���ˋz���ʕω���
      REAL(8),INTENT(IN)       :: RAD_SHRT  (IDX,ICG)  ! �P�ʎ��ԓ����ˋz����
      REAL(8),INTENT(IN)       :: RAD_LONG  (IDX,ICG)  ! �P�ʎ��ԓ����ˋz����
!
      REAL(8),INTENT(INOUT)    :: EVAP      (IDX,ICGB) 
      REAL(8),INTENT(INOUT)    :: SUBL      (IDX,ICGB) 
      REAL(8),INTENT(INOUT)    :: TRNS      (IDX,ICG) 
      REAL(8),INTENT(INOUT)    :: DEVAP_DX  (IDX,IEST,ICGB,ICGR) 
!
!     REAL(8),INTENT(IN)    :: HDF       (IDX)         ! �n���t���b�N�X
      REAL(8),INTENT(IN)    :: HDF       (IDX,2)       ! �n���t���b�N�X
      REAL(8),INTENT(IN)    :: HDF_SKIN  (IDX,2)       ! �y�X�L�� - �y1
!
      REAL(8),INTENT(IN)    :: P_DEL     (IDX)         ! 
      REAL(8),INTENT(IN)    :: Q_REF     (IDX)         ! 910726
!
      REAL(8),INTENT(IN)    :: CAP_SOIL_TOP (IDX)     
      REAL(8),INTENT(IN)    :: FLAG_PHASE_SS1 (IDX)   

!
!     REAL(8),intent(in)   :: FLAG_TMPMOD_CNP  (IDX)
!     REAL(8),intent(in)   :: FLAG_TMPMOD_SKIN (IDX)
!
! OUTPUT 
!
!     REAL(8),INTENT(OUT)   :: SIB_MTX   (IDX,4,5) 
      REAL(8),INTENT(OUT)   :: SIB_MTX   (IDX,5,6)     ! XXX1 
!
!
! WORK
!
      REAL(8)               :: CAP_CNP (IDX)   
      REAL(8)               :: CAP_SKIN(IDX)   
      INTEGER               :: I
      REAL(8)               :: DELT_A
      REAL(8)               :: DELT_C
!
      REAL(8),SAVE          :: RFACT_OFFLINE_ZERO = 1.D0 
!
!
#ifdef MONYOS
! tg �� tc �̎��̃��j�^
!
      integer :: iweight 
!
      real(8) :: drlgdtg(idx)  ! ���������g�� tg �ˑ���
      real(8) :: drlcdtg(idx)  
      real(8) :: drlgdtc(idx)  
      real(8) :: drlcdtc(idx)  
!
      real(8) :: dsngdtg(idx)  ! ���������g�� tg �ˑ���
      real(8) :: dsncdtg(idx)  
      real(8) :: dsngdtc(idx)  
      real(8) :: dsncdtc(idx)  
      real(8) :: dsngdta(idx)  
      real(8) :: dsncdta(idx)  
!
      real(8) :: dltgdtg(idx)  ! ���������g�� tg �ˑ���
      real(8) :: dltcdtg(idx)  
      real(8) :: dltgdtc(idx)  
      real(8) :: dltcdtc(idx)  
      real(8) :: dltgdea(idx)  
      real(8) :: dltcdea(idx)
!  
      real(8) :: ddfgdtg(idx)
!
      CHARACTER(7)   :: CMARK 
      REAL(8),PARAMETER :: ONE = 1.D0 
#endif
!
      LOGICAL,SAVE :: LFIRST
      DATA  LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_FLUX_EQSET 99/07 POCHAKA ' , INSFLAG 
        IF ( JCN_SIB_UPPER_MODEL.EQ.-1 ) THEN  ! �I�t���C���ő�C��M����
          RFACT_OFFLINE_ZERO = 0.D0
        ENDIF
        LFIRST = .FALSE. 
      ENDIF
!
      DELT_A = DELT_ATM * DELT_FAC_ATM_c 
      DELT_C = DELT_CNP * DELT_FAC_CNP_C
!
      SIB_MTX(:,:,:) = 0.  
!
!  --------------
!  > ��M�̐ݒ� <
!  --------------
!
! �t���b�N�X�]���p�W����������
!
      IF ( JCN_CAP_CNP_SL .EQ. 0 ) THEN    
!
        IF      ( INSFLAG .EQ. 0 ) THEN               ! �ᖳ��
          DO I=NSTR,NEND 
            CAP_SKIN(I) = CAP_GRSKX_c 
            CAP_CNP (I) = CAP_CNPX_c 
          ENDDO
!
        ELSE IF ( INSFLAG .EQ. 1 ) THEN               ! ��
          DO I=NSTR,NEND 
            CAP_SKIN(I) = CAP_SNSKX_c 
            CAP_CNP (I) = CAP_CNPX_c 
          ENDDO
!
        ENDIF
!
! �t���b�N�X�]���p�W�������ۂ̒l
!
      ELSE 
!
        IF      ( INSFLAG .EQ. 0 ) THEN           ! ��Ȃ�
           
          DO I=NSTR,NEND 
            CAP_SKIN(I) = CAP_GRSK_c 
     1                    + CAP_LAI_c * XLAI_VEG_msx(I,2) 
     1                    + CAP_WTR_c * H2O_SAT_GRS(I)  
     1                         * FR_H2O_GRS(I) * FR_WBH_GRS(I)
     1                    + CAP_GLA_c * H2O_SAT_GRS(I) 
     1                         * FR_H2O_GRS(I) * (1-FR_WBH_GRS(I))
            CAP_CNP (I) =   CAP_LAI_c * XLAI_VEG_msx(I,1) 
     1                    + CAP_WTR_c * H2O_SAT_CNP(I)  
     1                         * FR_H2O_CNP(I) * FR_WBH_CNP(I)
     1                    + CAP_GLA_c * H2O_SAT_CNP(I) 
     1                         * FR_H2O_CNP(I) * (1-FR_WBH_CNP(I))
          ENDDO
!
        ELSE IF ( INSFLAG .EQ. 1 ) THEN           ! ��
!
          DO I=NSTR,NEND 
            CAP_SKIN(I) = CAP_SNSK_c 
            CAP_CNP (I) =   CAP_LAI_c * XLAI_VEG_msx(I,1) 
     1                    + CAP_WTR_c * H2O_SAT_CNP(I)  
     1                         * FR_H2O_CNP(I) * FR_WBH_CNP(I)
     1                    + CAP_GLA_c * H2O_SAT_CNP(I) 
     1                         * FR_H2O_CNP(I) * (1-FR_WBH_CNP(I))
          ENDDO
        ENDIF
      ENDIF
!
!  ---------------------------------------------------
!  �L���m�s�[���x�̎�  �i�S�� CVR_CNP ���������Ă���j
!  ---------------------------------------------------
!            DEVAP_DX   (IDX,IEST,ICG,ICGR)   
!            DSENS_DX   (IDX,     ICG,ICGR)    ! 3 �̕ω��� 2 ���󂯎��flux
!            DRAD_DX_TMP(IDX,     ICG,ICG)     ! 3 �̕ω��� 2 ���󂯎��flux
!            DRAD_DX    (IDX,     ICGR,ICG)    ! 3 �̕ω��ŕω����� 2-3 flux
!
      DO 1000 I=NSTR,NEND
!
        SIB_MTX(I,1,1)                                          ! �L�����x
     1     = CAP_CNP (I) 
     1       + ( - DSENS_DX(I,1,1) 
     1           - HL_WTR_c * ( DEVAP_DX(I,1,1,1) + DEVAP_DX(I,3,1,1) )
     1           - HL_GLA_c *   DEVAP_DX(I,2,1,1) 
     1           - ( -DRAD_DX(I,2,1)+DRAD_DX(I,3,1) )
     1          ) * DELT_C  
!
        SIB_MTX(I,1,2)                                          ! �n�ʉ��x
     1     =  (  - DSENS_DX(I,1,2) 
     1           - HL_WTR_c * ( DEVAP_DX(I,1,1,2) + DEVAP_DX(I,3,1,2) )
     1           - HL_GLA_c *   DEVAP_DX(I,2,1,2) 
     1           - ( - DRAD_DX(I,1,2) )
     1          ) * DELT_C
!
!
        SIB_MTX(I,1,4) = - DSENS_DX(I,1,3) * DELT_A             ! �Q�Ɖ��x
!
        SIB_MTX(I,1,5)                                          ! �Q�Ɣ䎼
     1     =  (  - HL_WTR_c * ( DEVAP_DX(I,1,1,3) + DEVAP_DX(I,3,1,3) )
     1           - HL_GLA_c *   DEVAP_DX(I,2,1,3) 
     1         ) * DELT_A
!
        SIB_MTX(I,1,6)                                         ! ����
     1     =  + SENS (I,1)                     
     1        + HL_WTR_c * EVAP(I,1) 
     1        + HL_GLA_c * SUBL(I,1) 
     1        + HL_WTR_c * TRNS(I,1) 
     1        + RAD_LONG (I,1) + RAD_SHRT(I,1)
!
 1000 CONTINUE
!
!
!  ---------------------------------------------------
!  �n�ʃX�L�����x�̎�  �i1-CVR_SNW �͂������Ă��Ȃ��j
!  ---------------------------------------------------
!              DEVAP_DX  (IDX,IEST,ICG,ICGR)   
!              DSENS_DX  (IDX,     ICG,ICGR)   
!              DRAD_DX   (IDX,     ICG,ICG)   
!     
      DO 2000 I=NSTR,NEND
!
        SIB_MTX(I,2,1)                      ! �L�����x
     1     = ( - DSENS_DX(I,2,1) 
     1         - HL_WTR_c * (   DEVAP_DX(I,1,2,1) + DEVAP_DX(I,3,2,1) 
     1                        + DEVAP_DX(I,1,3,1) + DEVAP_DX(I,3,3,1) )
     1         - HL_GLA_c * (   DEVAP_DX(I,2,2,1) + DEVAP_DX(I,2,3,1) )
     1         - DRAD_DX    (I,2,1) 
     1       ) * DELT_C        
!
        SIB_MTX(I,2,2)                      ! �n�ʉ��x �������t���b�N�X
     1   = CAP_SKIN(I)
     1      + ( - DSENS_DX(I,2,2) 
     1          - HL_WTR_c * (   DEVAP_DX(I,1,2,2) + DEVAP_DX(I,3,2,2) 
     1                         + DEVAP_DX(I,1,3,2) + DEVAP_DX(I,3,3,2) ) 
     1          - HL_GLA_C * (   DEVAP_DX(I,2,2,2) + DEVAP_DX(I,2,3,2) )
     1          - ( DRAD_DX(I,1,2) + DRAD_DX(I,3,2) )
     1          + HDF_SKIN(I,1) 
     1         ) * DELT_C        
!
        SIB_MTX(I,2,3) = - HDF_SKIN(I,1) * DELT_C             ! �y�뉷�x !XXX1 
!
        SIB_MTX(I,2,4) = - DSENS_DX(I,2,3) * DELT_A         ! �Q�Ɖ��x
!
!                                     DEVAP_DX  (IDX,IEST,ICGB,ICGR) 
        SIB_MTX(I,2,5)                                         ! �Q�Ɣ䎼
     1     =  ( - HL_WTR_c * (   DEVAP_DX(I,1,2,3) + DEVAP_DX(I,3,2,3) 
     1                         + DEVAP_DX(I,1,3,3) + DEVAP_DX(I,3,3,3) ) 
     1          - HL_GLA_c * (   DEVAP_DX(I,2,2,3) + DEVAP_DX(I,2,3,3) )
     1         ) * DELT_A 
!
        SIB_MTX(I,2,6)                      ! ���� �������t���b�N�X 
     1     =  + SENS(I,2)                     
     1        + HL_WTR_c * ( EVAP(I,2) + EVAP(I,3) )
     1        + HL_GLA_c * ( SUBL(I,2) + SUBL(I,3) )
     1        + HL_WTR_c * TRNS(I,2) 
     1        - HDF(I,1) 
     1        + RAD_LONG(I,2) 
     1        + RAD_SHRT(I,2) 
!
 2000 CONTINUE
!
!  ---------------------------------------------------
!  �y����w���x
!  ---------------------------------------------------
!     
      DO 3000 I=NSTR,NEND
        SIB_MTX(I,3,2) = - HDF_SKIN(I,1) * DELT_C         ! �X�L�����x
     1                     * FLAG_PHASE_SS1(I)
!
        SIB_MTX(I,3,3)                                  ! �n�ʉ��x
     1   = CAP_SOIL_TOP(I)
     1       + (  HDF_SKIN(I,1) + HDF_SKIN(I,2) ) * DELT_C        
!
        SIB_MTX(I,3,6)                      ! ���� �������t���b�N�X 
     1     =  (  HDF(I,1) - HDF(I,2) )
     1                     * FLAG_PHASE_SS1(I)
 3000 CONTINUE 
!
!  ---------------------------------------------------
!  ��C�Q�ƃ��x���i��C�ŉ��w�j���x�̎�
!  ---------------------------------------------------
!              DEVAP_DX  (IDX,IEST,ICG,ICGR)   
!              DSENS_DX  (IDX,     ICG,ICGR)   
!
      DO 4000 I=NSTR,NEND
!
        SIB_MTX(I,4,1)                                         ! �L���m�s�[
     1      = ( DSENS_DX(I,1,1) + DSENS_DX(I,2,1) ) * DELT_C 
     1        * RFACT_OFFLINE_ZERO 
!
        SIB_MTX(I,4,2)                                         ! �n��
     1      = ( DSENS_DX(I,1,2) + DSENS_DX(I,2,2) ) * DELT_C
     1        * RFACT_OFFLINE_ZERO 
!
        SIB_MTX(I,4,4)   
     1     =    GMT  (I,1)  
     1       + ( DSENS_DX(I,1,3) + DSENS_DX(I,2,3) ) * DELT_A
!
        SIB_MTX(I,4,6) = (   GMT(I,2)       
     1                     - SENS  (I,1) 
     1                     - SENS  (I,2) )
     1                   * RFACT_OFFLINE_ZERO 
!
 4000 CONTINUE         
!
!
!  ------------------------------------
!  ��C�Q�ƃ��x���i��C�ŉ��w�j�䎼�̎� ... ���̎�����I
!  ------------------------------------
!
      DO 5000 I=NSTR,NEND
!
        SIB_MTX(I,5,1)                                    ! �L���m�s�[
     1     = +  (   DEVAP_DX(I,1,1,1) + DEVAP_DX(I,2,1,1) 
     1            + DEVAP_DX(I,3,1,1)                       ! �L��
     1            + DEVAP_DX(I,1,2,1) + DEVAP_DX(I,2,2,1) 
     1            + DEVAP_DX(I,3,2,1)                       ! ��������
     1            + DEVAP_DX(I,1,3,1) + DEVAP_DX(I,2,3,1) 
     1            + DEVAP_DX(I,3,3,1)                       ! �炿
     1          ) * DELT_C 
     1        * RFACT_OFFLINE_ZERO 
!
        SIB_MTX(I,5,2)                                    ! �n��
     1     = +  (   DEVAP_DX(I,1,1,2) + DEVAP_DX(I,2,1,2) 
     1            + DEVAP_DX(I,3,1,2)                       ! �L��
     1            + DEVAP_DX(I,1,2,2) + DEVAP_DX(I,2,2,2) 
     1            + DEVAP_DX(I,3,2,2)                       ! ����
     1            + DEVAP_DX(I,1,3,2) + DEVAP_DX(I,2,3,2) 
     1            + DEVAP_DX(I,3,3,2)                       ! ���n
     1          ) * DELT_C 
     1        * RFACT_OFFLINE_ZERO 
!
        SIB_MTX(I,5,5)                                   ! �Q�Ɣ䎼
     1     =  GMQ(I,1)  
     1       +  (   DEVAP_DX(I,1,1,3) + DEVAP_DX(I,2,1,3) 
     1            + DEVAP_DX(I,3,1,3)                       ! �L��
     1            + DEVAP_DX(I,1,2,3) + DEVAP_DX(I,2,2,3) 
     1            + DEVAP_DX(I,3,2,3)                       ! ����
     1            + DEVAP_DX(I,1,3,3) + DEVAP_DX(I,2,3,3) 
     1            + DEVAP_DX(I,3,3,3)                       ! ���n
     1          ) * DELT_A
!
        SIB_MTX(I,5,6) 
     1      = ( GMQ (I,2)                   
     1          - (   EVAP(I,1) + EVAP(I,2) + EVAP(I,3)  
     1              + SUBL(I,1) + SUBL(I,2) + SUBL(I,3)  
     1              + TRNS(I,1) + TRNS(I,2) )
     1        )   
     1        * RFACT_OFFLINE_ZERO 
!
 5000 CONTINUE         
!
! ================
! >> �ڍ׃��j�^ << 
! ================
!
#ifdef MONYOS
!
      if (       imonit_level .ge. imonit_all 
     1     .and. imonit .eq. 0 ) then
!
!   �n��
!  
      do i=nstr,nend
        ddfgdtg(i) = HDF_SKIN(I,1)   
        drlgdtg(i) = - ( DRAD_DX(I,1,2) + DRAD_DX(I,3,2) )
        drlgdtc(i) = - DRAD_DX    (I,2,1) 
        dsngdtg(i) = - DSENS_DX(I,2,2) 
        dsngdtc(i) = - DSENS_DX(I,2,1) 
        dsngdta(i) = - DSENS_DX(I,2,3)
        dltgdtg(i) = 
     1          - HL_WTR_c * (   DEVAP_DX(I,1,2,2) + DEVAP_DX(I,3,2,2) 
     1                         + DEVAP_DX(I,1,3,2) + DEVAP_DX(I,3,3,2) ) 
     1          - HL_GLA_C * (   DEVAP_DX(I,2,2,2) + DEVAP_DX(I,2,3,2) )
        dltgdtc(i) = 
     1         - HL_WTR_c * (   DEVAP_DX(I,1,2,1) + DEVAP_DX(I,3,2,1) 
     1                        + DEVAP_DX(I,1,3,1) + DEVAP_DX(I,3,3,1) )
     1         - HL_GLA_c * (   DEVAP_DX(I,2,2,1) + DEVAP_DX(I,2,3,1) )
        dltgdea(i) = 
     1          - HL_WTR_c * (   DEVAP_DX(I,1,2,3) + DEVAP_DX(I,3,2,3) 
     1                         + DEVAP_DX(I,1,3,3) + DEVAP_DX(I,3,3,3) ) 
     1          - HL_GLA_c * (   DEVAP_DX(I,2,2,3) + DEVAP_DX(I,2,3,3) )

!
!   �L���m�s�[
!
        drlcdtg(i) = DRAD_DX(I,2,1) - DRAD_DX(I,3,1)
        drlcdtc(i) = DRAD_DX(I,1,2) 
        dsncdtg(i) = - DSENS_DX(I,1,2) 
        dsncdtc(i) = - DSENS_DX(I,1,1) 
        dsncdta(i) = - DSENS_DX(I,1,3)
        dltcdtg(i) = 
     1           - HL_WTR_c * ( DEVAP_DX(I,1,1,2) + DEVAP_DX(I,3,1,2) )
     1           - HL_GLA_c *   DEVAP_DX(I,2,1,2) 
        dltcdtc(i) = 
     1           - HL_WTR_c * ( DEVAP_DX(I,1,1,1) + DEVAP_DX(I,3,1,1) )
     1           - HL_GLA_c *   DEVAP_DX(I,2,1,1) 
        dltcdea(i) = 
     1           - HL_WTR_c * ( DEVAP_DX(I,1,1,3) + DEVAP_DX(I,3,1,3) )
     1           - HL_GLA_c *   DEVAP_DX(I,2,1,3) 
      enddo
!
! TG �� TC �̎��̔����W��
!
      if ( insflag.eq.0) then  
        iweight = icn
      else
        iweight = ics
      endif

!
          CMARK = 'DDFGDTG' 
          CALL MONIT_SIB ( CMARK,DDFGDTG,iweight,DELT_CNP,ONE)       
!
          CMARK = 'DRLGDTG' 
          CALL MONIT_SIB ( CMARK,DRLGDTG,iweight,DELT_CNP,ONE)       
          CMARK = 'DRLCDTG' 
          CALL MONIT_SIB ( CMARK,DRLCDTG,iweight,DELT_CNP,ONE)       
          CMARK = 'DRLGDTC' 
          CALL MONIT_SIB ( CMARK,DRLGDTC,iweight,DELT_CNP,ONE)       
          CMARK = 'DRLCDTC' 
          CALL MONIT_SIB ( CMARK,DRLCDTC,iweight,DELT_CNP,ONE)       
!
          CMARK = 'DSNGDTG' 
          CALL MONIT_SIB ( CMARK,DSNGDTG,iweight,DELT_CNP,ONE)       
          CMARK = 'DSNCDTG' 
          CALL MONIT_SIB ( CMARK,DSNCDTG,iweight,DELT_CNP,ONE)       
          CMARK = 'DSNGDTC' 
          CALL MONIT_SIB ( CMARK,DSNGDTC,iweight,DELT_CNP,ONE)       
          CMARK = 'DSNCDTC' 
          CALL MONIT_SIB ( CMARK,DSNCDTC,iweight,DELT_CNP,ONE)       
          CMARK = 'DSNGDTA' 
          CALL MONIT_SIB ( CMARK,DSNGDTA,iweight,DELT_CNP,ONE)       
          CMARK = 'DSNCDTA' 
          CALL MONIT_SIB ( CMARK,DSNCDTA,iweight,DELT_CNP,ONE)       
!
          CMARK = 'DLTGDTG' 
          CALL MONIT_SIB ( CMARK,DLTGDTG,iweight,DELT_CNP,ONE)       
          CMARK = 'DLTCDTG' 
          CALL MONIT_SIB ( CMARK,DLTCDTG,iweight,DELT_CNP,ONE)       
          CMARK = 'DLTGDTC' 
          CALL MONIT_SIB ( CMARK,DLTGDTC,iweight,DELT_CNP,ONE)       
          CMARK = 'DLTCDTC' 
          CALL MONIT_SIB ( CMARK,DLTCDTC,iweight,DELT_CNP,ONE)       
          CMARK = 'DLTGDEA' 
          CALL MONIT_SIB ( CMARK,DLTGDEA,iweight,DELT_CNP,ONE)       
          CMARK = 'DLTCDEA' 
          CALL MONIT_SIB ( CMARK,DLTCDEA,iweight,DELT_CNP,ONE)       
!
      endif
#endif
!-------------------------------------------------------
!
      RETURN
      END
!================================================================
      SUBROUTINE MR_CANOPY_FLUX_EQSET
!
      USE SIB_MONIT , ONLY : IMONIT_LEVEL, IMONIT_ALL
!
      character( 7) :: cmark 
      CHARACTER(32) :: CTITLE 
      CHARACTER(13) :: CUNIT
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
          CMARK  = 'DRLGDTG'
          CTITLE = 'DRLGDTG'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DRLCDTG'
          CTITLE = 'DRLCDTG'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DRLGDTC'
          CTITLE = 'DRLGDTC'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DRLCDTC'
          CTITLE = 'DRLCDTC'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!--
          CMARK  = 'DSNGDTG'
          CTITLE = 'DSNGDTG'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DSNCDTG'
          CTITLE = 'DSNCDTG'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DSNGDTC'
          CTITLE = 'DSNGDTC'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DSNCDTC'
          CTITLE = 'DSNCDTC'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DSNGDTA'
          CTITLE = 'DSNGDTA'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DSNCDTA'
          CTITLE = 'DSNCDTA'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!--
          CMARK  = 'DLTGDTG'
          CTITLE = 'DLTGDTG'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DLTCDTG'
          CTITLE = 'DLTCDTG'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DLTGDTC'
          CTITLE = 'DLTGDTC'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DLTCDTC'
          CTITLE = 'DLTCDTC'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DLTGDEA'
          CTITLE = 'DLTGDEA'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
          CMARK  = 'DLTCDEA'
          CTITLE = 'DLTCDEA'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!-
          CMARK  = 'DDFGDTG'
          CMARK  = 'DDFGDTG'
          CUNIT  = 'W/m**2/K' 
          CALL MONIT_REGIST_SIB ( CMARK , CTITLE , CUNIT ) 
!
      ENDIF
!         
      RETURN
      END