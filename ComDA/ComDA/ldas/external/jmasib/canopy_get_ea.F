! ���U�֘A�v�Z
! 99/07/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 99/09/28 �ۍ␪�G �o�O�����Bicheck �������Y��ǉ��B
! 99/09/28 �ۍ␪�G �I�������𕪊��Bcanopy_set_air ��
!
      SUBROUTINE CANOPY_GET_EA (
     I    NSTR         , NEND         , INSFLAG     , 
     I    ITR          , ITR_MAX      , 
     I    NTYP         , 
     I    CVR_VEG_msx  , CVR_VEG_INV_msx, 
     I    R_AC_BAR     , R_AC_BAR_INV , R_AG        , R_AG_INV    , 
     I    R_BB         , R_AIR_INV    , 
     I    R_ROOT_BAR_INV   , R_STM_BAR_PAR    , 
     I    E_AIR_SAT    , E_CNP_SAT     , E_REF     , E_SKIN_SAT   ,
     I    HUM_GRSK     , 
     I    TMP_SOIL     , 
     I    FR_H2O_CNP  , FR_H2O_GRS  , 
     I    FUNC_TMP     , 
     I    POT_SOIL     ,
     I    D_ZERO_msx   , 
     I    FAC_EVP      , 
     I    ITC          , ITC_MAX     , 
#ifdef MONYOS
     I   DELT_CNP , 
#endif
     M    ICOUNT       , INIT_EA     , 
     M    R_STM_BAR    , 
     M    FLAG_DRY_CNP , FLAG_DRY_SKIN , 
     O    E_AIR        , FLAG_TR     , FLAG_TR_ALL     , 
     O    R_ACX_BAR    , R_AGX_BAR  , R_ACX_BAR_INV, R_AGX_BAR_INV ,
     O    R_AB_INV     , 
!    O    FAC_TRNS_A   , FAC_TRNS_B , KLEV_TRNS_MAX )
     O    FAC_TRNS_A   , FAC_TRNS_B )
!
      USE SIBPRM , ONLY :
     1   IDX , 
     1   IDP , 
     1   ICG , 
     1   ITYP 
!
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)    :: NSTR 
      INTEGER,INTENT(IN)    :: NEND
      INTEGER,INTENT(IN)    :: ITR
      INTEGER,INTENT(IN)    :: ITR_MAX
      INTEGER,INTENT(IN)    :: INSFLAG 
#ifdef MONYOS
      REAL(8),INTENT(IN)   :: DELT_CNP
#endif
!
      REAL(8),INTENT(IN)   :: TMP_SOIL(IDX,IDP)
!
      REAL(8),INTENT(IN)   :: HUM_GRSK (IDX)
!
      REAL(8),INTENT(IN)   :: R_AC_BAR    (IDX) ! R_AC(�L��-�L����Ԓ�R)
      REAL(8),INTENT(IN)   :: R_AC_BAR_INV(IDX) ! R_AC(�L��-�L����Ԓ�R)
      REAL(8),INTENT(IN)   :: R_AG    (IDX)     ! R_AG(�n��-�L����Ԓ�R)
      REAL(8),INTENT(IN)   :: R_AG_INV(IDX)     ! R_AG(�n��-�L����Ԓ�R)
      REAL(8),INTENT(IN)   :: R_BB    (IDX)     ! �n�ʒ�R RSOIL
      REAL(8),INTENT(IN)   :: R_AIR_INV (IDX)     
      REAL(8),INTENT(IN)   :: R_ROOT_BAR_INV(IDX,IDP,ICG) 
!                                               ! �e�w��(�����{�z��)��R
!
      REAL(8),INTENT(IN)   :: E_REF     (IDX)   ! �Q�Ƌ�C�����C��
      REAL(8),INTENT(IN)   :: E_CNP_SAT (IDX)   ! �L���m�s�[���x�O�a�����C��
      REAL(8),INTENT(IN)   :: E_AIR_SAT (IDX)   ! �L���m�s�[��C�O�a�����C��
      REAL(8),INTENT(IN)   :: E_SKIN_SAT(IDX)   ! �n�ʉ��x�O�a�����C��
!
      REAL(8),INTENT(IN)   :: FUNC_TMP(IDX,ICG)    ! �C�E��R�̉��x�ˑ���
!
      REAL(8),INTENT(IN)   :: POT_SOIL (IDX,IDP)    ! �y���matric pot
      REAL(8),INTENT(IN)   :: D_ZERO_msx (IDX)        ! ��ʕψ�   (���G�c)
!
      REAL(8),INTENT(IN)   :: CVR_VEG_msx (IDX,ICG)  ! �A���핢��
      REAL(8),INTENT(IN)   :: CVR_VEG_INV_msx (IDX,ICG)  ! �A���핢��
      REAL(8),INTENT(IN)   :: FAC_EVP    (IDX)    ! �σ�/P_s

      REAL(8),INTENT(IN)   :: R_STM_BAR_PAR (IDX,ICG) ! 
!
      INTEGER,INTENT(IN)   :: NTYP   (IDX)       ! �A���C���f�b�N�X

      REAL(8),INTENT(IN)   :: FR_H2O_CNP (IDX)   ! �L���m�s�[�̔G��̈�̊���
      REAL(8),INTENT(IN)   :: FR_H2O_GRS (IDX)   ! �����̔G��̈�̊���
!
! INOUT
!
      REAL(8),INTENT(INOUT) :: R_STM_BAR        (IDX,ICG)
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)   :: FLAG_TR     (IDX,IDP,ICG)
      REAL(8),INTENT(OUT)   :: FLAG_TR_ALL (IDX    ,ICG)
!
      REAL(8),INTENT(OUT)   :: R_AGX_BAR        (IDX) 
      REAL(8),INTENT(OUT)   :: R_AGX_BAR_INV    (IDX) 
      REAL(8),INTENT(OUT)   :: R_ACX_BAR        (IDX) 
      REAL(8),INTENT(OUT)   :: R_ACX_BAR_INV    (IDX) 
      REAL(8),INTENT(OUT)   :: R_AB_INV         (IDX) 
!
      REAL(8),INTENT(OUT)  :: FAC_TRNS_A (IDX,IDP,ICG)  
      REAL(8),INTENT(OUT)  :: FAC_TRNS_B (IDX,IDP,ICG)  
!
      REAL(8),INTENT(OUT)  :: E_AIR  (IDX)         ! �L���m�s�[�����C��
!     INTEGER,INTENT(OUT)  :: KLEV_TRNS_MAX(IDX,ICG)
!
      REAL(8),INTENT(INOUT):: FLAG_DRY_CNP      (IDX)    
      REAL(8),INTENT(INOUT):: FLAG_DRY_SKIN     (IDX)    
      INTEGER,INTENT(IN)   :: ITC
      INTEGER,INTENT(IN)   :: ITC_MAX
!
! INOUT
!
      INTEGER,INTENT(INOUT) :: ICOUNT   
      INTEGER,INTENT(INOUT) :: INIT_EA
!
!  WORK 
!
      REAL(8)  ::  POT_LEAF     (IDX,ICG)
!
!     INTEGER,PARAMETER ::  ILP_MAX = 3
      INTEGER,PARAMETER ::  ILP_MAX = 4
      INTEGER  ::  ILP
      INTEGER  ::  IFLG 
!
      LOGICAL,SAVE :: LFIRST
!
      DATA  LFIRST /.TRUE. /
! 
!  �L���m�s�[���ӂ̐����ŋN�����Ă��邱�Ƃ��m�肷��B
!
!  �ȉ��̂��̂͌��܂��Ă��Ȃ�
!    �E �C�E��R                  R_STM_BAR
!    �E �L���m�s�[��C�̐����C��  E_AIR
!    �E ���U�� on/off             FLAG_TR  ( , FR_H2O_CNP, FR_H2O_GRS �͊��m )
!  ��̂�������A�ǂꂩ��ς���Ƒ����ς��B---> �C�e���[�V�����K�v
!
!  ���Ȃ݂ɁA
!      E_AIR , FLAG_TR --- CANOPY_STRES --> R_STM_BAR ( , FLAG_TR )  
!      R_STM_BAR   , FLAG_TR --- CANOPY_AIR   --> E_AIR 
!  �܂�
!      FLAG_TR_RESET �ł́AFLAG_TR ��y�뉷�x�����̂ݔ��f�����ă��Z�b�g����B
!
!  �Ƃ肠�����A�ȉ��̎菇�Ƃ���B
!    1) ���́A�����߂� R_STM_BAR �������l�Ƃ��ė^����B
!    2) ���U����̏󋵂� CANOPY_AIR �� E_AIR �������B
!    3) FLAG_TR �����Z�b�g
!    4) CANOPY_STRES �� R_STM_BAR   �������AFLAG_TR �𓾂�
! 
!    5) CANOPY_AIR   �� E_AIR �������B
!       max 4 ������A��������܂ł��B
!    6) FLAG_TR �����Z�b�g
!    7) CANOPY_STRES �� R_STM_BAR   �������AFLAG_TR �𓾂�
!
!    8) CANOPY_AIR   �� E_AIR �������B
!       max 4 ������A��������܂ł��B
!  �������������悤�Ȃ�A
!    ���O�̃X�e�b�v�ł� E_AIR ���Ƃ��Ă����A����������l�Ƃ��� 3 ����
!      �X�^�[�g�B
!
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_GET_EA 99/07 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF

! ==================
! >> �܂��͎�n�� <<
! ==================
!
! ================================
! >> �{�i�I�ȃC�e���[�V�����J�n <<  
! ================================
!
! ------------------
! > E_AIR �̌v�Z <
! ------------------
!
      IF ( INIT_EA .EQ. 1 ) THEN
        CALL CANOPY_AIR_ALL (
     I    NSTR       , NEND       , INSFLAG    , 
     I    CVR_VEG_msx  , CVR_VEG_INV_msx, 
     I    R_AC_BAR   , R_AC_BAR_INV , R_AG     , R_AG_INV    , 
     I    R_STM_BAR  , R_BB       , R_AIR_INV  , 
     I    FR_H2O_CNP , FR_H2O_GRS , 
     I    E_CNP_SAT  , E_REF      , E_SKIN_SAT   ,
     I    HUM_GRSK   , 
     O    FLAG_DRY_CNP , FLAG_DRY_SKIN         , 
     O    E_AIR      , 
     O    R_ACX_BAR  , R_AGX_BAR  , R_ACX_BAR_INV  , R_AGX_BAR_INV  , 
     O    R_AB_INV )
        INIT_EA = 0
      ENDIF
!
      ILP     = 0 
 4999 CONTINUE
      ILP = ILP + 1 
      ICOUNT = ICOUNT + 1 
!
! ----------------------
! > ���U�̕����������� <
! ----------------------
!     �܂��́A���x�����̑w�ȊO�͑S�w���U����Ƃ��Č��ς�B
!     �w���� TR �̌v�Z�����AFLAG_TR ��ݒ�
!
      IF ( ILP.EQ.1 ) THEN
        CALL FLAG_TR_RESET (
     I     NSTR        , NEND        , INSFLAG , 
     I     TMP_SOIL    , 
!    M     FLAG_TR     , FLAG_TR_ALL , KLEV_TRNS_MAX  )
     M     FLAG_TR     , FLAG_TR_ALL )
      ENDIF
!
      IFLG = 0 
      IF ( ITC.EQ.ITC_MAX .AND. ILP.EQ.ILP_MAX ) IFLG = 1
!
      CALL  CANOPY_STRES (
     I   NSTR        , NEND        , INSFLAG      ,
     I   ITR         , ITR_MAX     , 
!    I   IFLG_AFT_MOD_FLG  , IFLG_LAST    , IFLG_MOD_FLG  , 
     I   1                 , IFLG         , 1             , 
     I   NTYP        , 
     I   R_AC_BAR        , R_AG        ,
     I   E_CNP_SAT   , E_SKIN_SAT    , E_AIR      , E_AIR_SAT      , 
     I   FUNC_TMP    , 
     I   POT_SOIL    ,
     I   D_ZERO_msx  , 
     I   R_ROOT_BAR_INV  ,  CVR_VEG_INV_msx   , 
     I   FAC_EVP     , R_STM_BAR_PAR    , 
     I   FR_H2O_CNP  , FR_H2O_GRS  ,
#ifdef MONYOS
     I   DELT_CNP , 
#endif
     O   POT_LEAF    , R_STM_BAR       , 
!    M   FAC_TRNS_A   , FAC_TRNS_B   , KLEV_TRNS_MAX , 
     M   FAC_TRNS_A   , FAC_TRNS_B   , 
     M   FLAG_TR     , FLAG_TR_ALL )
!
! ------------------
! > E_AIR �̌v�Z <
! ------------------
!
      CALL CANOPY_AIR_ALL (
     I    NSTR       , NEND       , INSFLAG    , 
     I    CVR_VEG_msx  , CVR_VEG_INV_msx, 
     I    R_AC_BAR   , R_AC_BAR_INV , R_AG     , R_AG_INV    , 
     I    R_STM_BAR  , R_BB       , R_AIR_INV  , 
     I    FR_H2O_CNP , FR_H2O_GRS , 
     I    E_CNP_SAT  , E_REF      , E_SKIN_SAT   ,
     I    HUM_GRSK   , 
     O    FLAG_DRY_CNP , FLAG_DRY_SKIN         , 
     O    E_AIR      , 
     O    R_ACX_BAR  , R_AGX_BAR  , R_ACX_BAR_INV  , R_AGX_BAR_INV  , 
     O    R_AB_INV )
!
      IF ( ILP .LT. ILP_MAX ) GOTO 4999
!
      RETURN
      END