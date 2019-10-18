! �����E���؊֘A�v�Z   �X�Ɛ��̊���
! 99/09/28 �ۍ␪�G canopy_get_ea ���番���쐬�B
! 99/10/01 �ۍ␪�G ���n��ł̏����E���ؗ��̕ύX�B���E�X���̂܂܂̊����ɂ���
!
      SUBROUTINE CANOPY_SET_AIR  (
     I    NSTR         , NEND         , INSFLAG     , 
     I    FR_H2O_CNP   , FR_WBH_CNP   , FR_H2O_GRS  , FR_WBH_GRS  , 
     I    FR_WBH_BS    ,    
     I    FLAG_DRY_CNP , FLAG_DRY_SKIN, 
     O    XFR_WTR_CNP  , XFR_GLA_CNP  , XFR_WTR_GRS , XFR_GLA_GRS , 
     O    XFR_WTR_BS   , XFR_GLA_BS   )
!
! ����
!     �ȑO�̓C���`�L�Ȃ�����ADEG_SAT_DTG(I) 
!     ����͖{���̓C���`�L�i�{���͗�Ȃ͉̂��x�ω��ʁj�����A
!     ��ނȂ����������Ώ�������B
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
      INTEGER,INTENT(IN)    :: INSFLAG 
!
      REAL(8),INTENT(IN)   :: FR_H2O_CNP (IDX)   ! �L���m�s�[�̔G��̈�̊���
      REAL(8),INTENT(IN)   :: FR_H2O_GRS (IDX)   ! �����̔G��̈�̊���
      REAL(8),INTENT(IN)   :: FR_WBH_CNP (IDX)   ! 
      REAL(8),INTENT(IN)   :: FR_WBH_GRS (IDX)   ! 
      REAL(8),INTENT(IN)   :: FR_WBH_BS  (IDX)   ! 
      REAL(8),INTENT(IN)   :: FLAG_DRY_SKIN  (IDX) 
      REAL(8),INTENT(IN)   :: FLAG_DRY_CNP   (IDX) 
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)  :: XFR_WTR_CNP (IDX)
      REAL(8),INTENT(OUT)  :: XFR_GLA_CNP (IDX)
      REAL(8),INTENT(OUT)  :: XFR_WTR_GRS (IDX)
      REAL(8),INTENT(OUT)  :: XFR_GLA_GRS (IDX)
      REAL(8),INTENT(OUT)  :: XFR_WTR_BS  (IDX)
      REAL(8),INTENT(OUT)  :: XFR_GLA_BS  (IDX)
!
!  WORK 
!
      INTEGER  ::  I 
      REAL(8)  ::  XFR_TMP 
!
      LOGICAL,SAVE :: LFIRST
!
      DATA  LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_SET_AIR 00/02 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
!  --------------------------------------
!  > �����U�v�Z�Ɏg�����E�X�핢���̐ݒ� <
!  --------------------------------------
!               XFR_WTR_CNP ��
!               ���U���� FLAG_DRY_CNP = 1 
!
! �L���m�s�[
!
      DO 8000 I=NSTR,NEND
        XFR_TMP =  (1-FLAG_DRY_CNP(I)) 
     1              + FLAG_DRY_CNP(I)     * FR_H2O_CNP(I) 
        XFR_WTR_CNP(I) = XFR_TMP * FR_WBH_CNP(I)
        XFR_GLA_CNP(I) = XFR_TMP * (1-FR_WBH_CNP(I)) 
!
 8000 CONTINUE  
!
!  �����Ɨ��n            
!        �v check : CVR_GRS �� 1-CVR_GRS ��������K�v�̗L��
!        ������K�v�Ȃ��Ǝv���B
! 
      IF ( INSFLAG.EQ.0) THEN
      DO 8100 I=NSTR,NEND
        XFR_TMP =  (1-FLAG_DRY_SKIN(I)) 
     1              + FLAG_DRY_SKIN(I)     * FR_H2O_GRS(I) 
        XFR_WTR_GRS(I) = XFR_TMP * FR_WBH_GRS(I)
        XFR_GLA_GRS(I) = XFR_TMP * (1-FR_WBH_GRS(I)) 
        XFR_WTR_BS (I) = FR_WBH_BS(I)        
        XFR_GLA_BS (I) = 1-FR_WBH_BS(I)         
 8100 CONTINUE  
      ENDIF
!
!  ���B
!
      IF ( INSFLAG .EQ. 1 ) THEN
        DO 8200 I=NSTR,NEND 
          XFR_WTR_BS (I) = FR_WBH_BS(I)        
          XFR_GLA_BS (I) = 1 - FR_WBH_BS(I)         
 8200   CONTINUE
      ENDIF
!
      RETURN
      END
!====================================================================
      SUBROUTINE CANOPY_AIR_ALL (
     I    NSTR       , NEND       , INSFLAG    , 
     I    CVR_VEG_msx  , CVR_VEG_INV_msx, 
     I    R_AC_BAR   , R_AC_BAR_INV , R_AG     , R_AG_INV    , 
     I    R_STM_BAR  , R_BB       , R_AIR_INV  , 
     I    FR_H2O_CNP , FR_H2O_GRS , 
     I    E_CNP_SAT  , E_REF      , E_SKIN_SAT   ,
     I    HUM_REL_SKIN   , 
     M    FLAG_DRY_CNP , FLAG_DRY_SKIN     , 
     O    E_AIR      , 
     O    R_ACX_BAR  , R_AGX_BAR  , R_ACX_BAR_INV  , R_AGX_BAR_INV  , 
     O    R_AB_INV )
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
! OUTPUT 
!
      REAL(8),INTENT(INOUT):: E_AIR (IDX)   ! �L���m�s�[��Ԃ̐����C��
      REAL(8),INTENT(OUT)  :: R_ACX_BAR   (IDX)  
!                                             ! �L���m�s�[�C�E��R+���E�w��R
      REAL(8),INTENT(OUT)  :: R_ACX_BAR_INV (IDX) 
      REAL(8),INTENT(OUT)  :: R_AGX_BAR   (IDX)   ! �����C�E��R+���E�w��R
      REAL(8),INTENT(OUT)  :: R_AGX_BAR_INV (IDX)
      REAL(8),INTENT(OUT)  :: R_AB_INV (IDX)
!
! INPUT 
!
      INTEGER,INTENT(IN)   :: NSTR
      INTEGER,INTENT(IN)   :: NEND
      INTEGER,INTENT(IN)   :: INSFLAG
      REAL(8),INTENT(INOUT):: FLAG_DRY_CNP  (IDX) 
      REAL(8),INTENT(INOUT):: FLAG_DRY_SKIN (IDX)   
!
      REAL(8),INTENT(IN)   :: HUM_REL_SKIN (IDX)
!
      REAL(8),INTENT(IN)   :: FR_H2O_CNP(IDX)      ! �L���̔G�ꂽ�����̊���
      REAL(8),INTENT(IN)   :: FR_H2O_GRS(IDX)      ! �����̔G�ꂽ�����̊���
!
      REAL(8),INTENT(IN)   :: R_STM_BAR (IDX,ICG)  ! �C�E��R
!
      REAL(8),INTENT(IN)   :: R_AC_BAR     (IDX)   ! �L���E�L����Ԋ�
      REAL(8),INTENT(IN)   :: R_AC_BAR_INV (IDX)   !   ���E�w��R 
      REAL(8),INTENT(IN)   :: R_AG         (IDX)   ! �����E�n�ʂƃL����ԊԂ�
      REAL(8),INTENT(IN)   :: R_AG_INV     (IDX)   !   ���E�w��R RD 
! 
      REAL(8),INTENT(IN)   :: R_BB         (IDX)   ! ���n����̏�����RRSOIL
!
      REAL(8),INTENT(IN)   :: CVR_VEG_msx     (IDX,ICG)  ! �A���핢��
      REAL(8),INTENT(IN)   :: CVR_VEG_INV_msx (IDX,ICG)  ! �A���핢��
!
      REAL(8),INTENT(IN)   :: R_AIR_INV (IDX)      ! �L����ԂƑ�C�ŉ��w�Ԓ�R
!
      REAL(8),INTENT(IN)   :: E_CNP_SAT   (IDX)      ! TC �ł̖O�a�����C��
      REAL(8),INTENT(IN)   :: E_SKIN_SAT  (IDX)      ! TG �ł̖O�a�����C��
      REAL(8),INTENT(IN)   :: E_REF       (IDX)      ! �Q�ƃ��x���ł̐����C��
!
! INOUT
!
      INTEGER :: ICHECK    (IDX)
!
!  WORK 
!
      INTEGER  ::  I 
      INTEGER  ::  IDEWCO  
!
      REAL(8)  ::  EGF     (IDX)   
      REAL(8)  ::  ECF     (IDX)   
!
      REAL(8)  ::  DONE
      REAL(8)  ::  DEWC 
      REAL(8)  ::  DEWG 
!
      LOGICAL,SAVE :: LFIRST
!
      DATA  DONE / 1.D0 /
      DATA  LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_AIR_ALL 99/09 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      DO I=NSTR,NEND 
        ICHECK(I) = 1 
      ENDDO
!
! ------------------
! > E_AIR �̌v�Z <
! ------------------
!
!     FLAG_DRY_CNP=1,FLAG_DRY_SKIN=1 
!       -> FLAG_DRY_CNP=1,FLAG_DRY_SKIN=0 
!          -> FLAG_DRY_CNP=0,FLAG_DRY_SKIN=1 
!             -> FLAG_DRY_CNP=0,FLAG_DRY_SKIN=0  
!     ���O�a�i���U����j = 1 
!
      IDEWCO = 0 
!
 3000 CONTINUE                ! <<<----------------------------------  C
!
#ifdef SIB_DEBUG 
      IF ( IDEWCO .EQ. 4 ) THEN
        write(6,*) 'canopy_set_air error idewco=4 nstr nend icheck ',
     1             nstr,nend,
     1             icheck(nstr:nend)
        stop 999
      ENDIF
#endif
!
        IDEWCO = IDEWCO + 1
!
        CALL CANOPY_AIR ( 
     I    NSTR       , NEND       , INSFLAG    , ICHECK     , 
     I    FLAG_DRY_CNP  , FLAG_DRY_SKIN        , 
     I    CVR_VEG_msx  , CVR_VEG_INV_msx, 
     I    R_AC_BAR   , R_AC_BAR_INV , R_AG     , R_AG_INV    , 
     I    R_STM_BAR  , R_BB       , R_AIR_INV  , 
     I    FR_H2O_CNP , FR_H2O_GRS , 
     I    E_CNP_SAT  , E_REF      , E_SKIN_SAT   ,
     I    HUM_REL_SKIN     , 
     O    E_AIR      , 
     O    R_ACX_BAR  , R_AGX_BAR  , R_ACX_BAR_INV  , R_AGX_BAR_INV  , 
     O    R_AB_INV )
!
      DO 3200 I=NSTR,NEND
        IF ( ICHECK(I).EQ.1 ) THEN    
          ECF (I) = SIGN ( DONE , E_CNP_SAT (I)-E_AIR(I) ) ! �ߖO�a-1 ���O�a1 
          EGF (I) = SIGN ( DONE , E_SKIN_SAT(I)-E_AIR(I) )
          DEWC    = FLAG_DRY_CNP (I)  * 2.0D0 - 1.0D0    ! ���O�a 1 
          DEWG    = FLAG_DRY_SKIN(I)  * 2.0D0 - 1.0D0    
          ECF (I) = ECF(I) * DEWC
          EGF (I) = EGF(I) * DEWG
        END IF
 3200 CONTINUE
!
#ifdef CORRECT
      DO 3300 I=NSTR,NEND 
        IF ( ( ECF(I).GT.0.0D0 .AND. EGF(I).GT.0.0D0 )
     1        .OR. ( IDEWCO.EQ.4 )                         ) THEN
          ICHECK(I)=0
        END IF
 3300 CONTINUE
#else
      DO 3300 I=NSTR,NEND 
        IF ( ECF(I).GT.0.0D0 .AND. EGF(I).GT.0.0D0 )  THEN 
          ICHECK(I)=0
        END IF
 3300 CONTINUE
#endif
!
      DO 3400 I=NSTR,NEND            ! ��ł́AFLAG_DRY_SKIN = 0. �݂̂ł悢
        IF ( ICHECK(I).EQ.1 ) THEN 
          IF     (     FLAG_DRY_CNP (I).GT.0.5D0 
     1           .AND. FLAG_DRY_SKIN(I).GT.0.5D0 ) THEN     
            FLAG_DRY_CNP(I)  = 1.0D0
            FLAG_DRY_SKIN(I) = 0.0D0
          ELSEIF (     FLAG_DRY_CNP(I).GT.0.5D0
     1           .AND. FLAG_DRY_SKIN(I).LT.0.5D0 ) THEN     
            FLAG_DRY_CNP(I)  = 0.0D0
            FLAG_DRY_SKIN(I) = 1.0D0
          ELSEIF (     FLAG_DRY_CNP(I) .LT.0.5D0
     1           .AND. FLAG_DRY_SKIN(I).GT.0.5D0 ) THEN     
            FLAG_DRY_CNP(I)  = 0.0D0
            FLAG_DRY_SKIN(I) = 0.0D0
          ELSEIF (     FLAG_DRY_CNP(I) .LT.0.5D0
     1           .AND. FLAG_DRY_SKIN(I).LT.0.5D0 ) THEN     
            FLAG_DRY_CNP (I) = 1.0D0
            FLAG_DRY_SKIN(I) = 1.0D0
          ENDIF
        ENDIF
 3400 CONTINUE
!
#include "noparallel_fixedform"
      DO  I=NSTR,NEND            ! ��ł́AFLAG_DRY_SKIN = 0. �݂̂ł悢
        IF ( ICHECK(I).EQ.1 ) THEN 
          GOTO 3000                   ! --------------- >>> C
        ENDIF
      ENDDO

!
      RETURN
      END





