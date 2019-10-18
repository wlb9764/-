! ���͂��߂� SiB �p�����^�ύX�ɔ����M�E���̏o����
! 99/07/13 �ۍ␪�G ����
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE PRESIB_MONTH_INI_CHECK 
!
! ���͂��߂� CVR_VEG �� XLAI ���ω����āA�G�l���M�[�E���̃\�[�X�E�V���N��
! �ł���B
! �i����ł͖O�a���ɑ΂��銄����\�񂵂Ă���A���̒l�͕ύX�����Ƃ��Ă���B�j
! �����̃\�[�X�E�V���N�ʂ��v�Z�A���j�^����B
!
      LOGICAL,SAVE :: LFIRST
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'PRESIB_MONTH_INI_CHECK 99/07 POCHAKA'
        WRITE(6,*) 'PRESIB_MONTH_INI_CHECK IS DUMMY NOW'
        LFIRST = .FALSE.
      ENDIF
!
#ifdef AAAAAA
!
!===================================
! >> �O�̃X�e�b�v�ł̒l�̓ǂݍ��� << 
!===================================
!     XLAI_mo , CVR_VEG_mo �̕ύX�ɔ����ϓ��B
!
!=================================
! >> Lai �̕ύX�ɔ����ω��� <<
!=================================
!
      CALL MOD_CANOPY_ENG (
     I   1                , NMAX_01(3)      ,
     I   NTYP_cs          , 
     I   XLAI_CNP_ms      , XLAI_CNP_OLD_mo , 
!    I   CVR_CNP_ms       , CVR_CNP_OLD_mo  , 
     I   FR_WTR_CNP_NOS   , FR_GLA_CNP_NOS  , TMP_CNP_NOS    , 
     O   ADD_H2O_CNP_NOS  , ADD_ENG_CNP_NOS  )

      CALL MOD_CANOPY_ENG (
     I   1                , NMAX_01(3)      ,
     I   NTYP_cs          , 
     I   XLAI_GRS_ms      , XLAI_GRS_OLD_mo , 
!    I   CVR_GRS_ms       , CVR_GRS_OLD_mo  , 
     I   FR_WTR_GRS_NOS   , FR_GLA_GRS_NOS  , TMP_GRS_NOS    , 
     O   ADD_H2O_GRS_NOS  , ADD_ENG_GRS_NOS  )
!
      CALL MOD_CANOPY_ENG (
     I   NMAX_01(2)       , NMAX            ,
     I   NTYP_cs          , 
     I   XLAI_CNP_ms      , XLAI_CNP_OLD_mo , 
!    I   CVR_CNP_ms       , CVR_CNP_OLD_mo  , 
     I   FR_WTR_CNP_SNW   , FR_GLA_CNP_SNW  , TMP_CNP_SNW    , 
     O   ADD_H2O_CNP_SNW  , ADD_ENG_CNP_SNW  )

      CALL MOD_CANOPY_ENG (
     I   NMAX_01(2)       , NMAX            ,
     I   NTYP_cs          , 
     I   XLAI_GRS_ms      , XLAI_GRS_OLD_mo , 
!    I   CVR_GRS_ms       , CVR_GRS_OLD_mo  , 
     I   FR_WTR_GRS_SNW   , FR_GLA_GRS_SNW  , TMP_GRS_SNW    , 
     O   ADD_H2O_GRS_SNW  , ADD_ENG_GRS_SNW  )

#endif
!
      RETURN
      END
!====================================================================
! LAI ( CVR_CNP, CVR_GRS) �̕ύX�ɔ����L���m�s�[�̎��G�l���M�[�̕ύX
! CVR_SNW �͂����Ă��Ȃ��B
!
      SUBROUTINE MOD_CANOPY_ENG 
#ifdef AAAAAA
     I ( NSTR             , NEND            ,
     I   NTYP_cs          , 
     I   XLAI_VEG_ms      , XLAI_VEG_OLD_mo , 
!    I   CVR_VEG_ms       , CVR_VEG_OLD_mo  , 
     I   FR_WTR_VEG       , FR_GLA_VEG      , TMP_VEG       , 
     O   ADD_H2O_VEG      , ADD_ENG_VEG     )
!
      USE SIBPRM , ONLY :
     1   IDX     , 
     1   ITYP 
!
      USE SIBCON , ONLY :
     1   TMP_FREZ_c  , 
     1   HL_GLA_c   , 
     1   CAP_LAI_c  ,
     1   CAP_WTR_c  ,
     1   CAP_GLA_c  ,
     1   RHO_WTR_c  
!
! INPUT
!
      INTEGER,INTENT(IN)    :: NSTR 
      INTEGER,INTENT(IN)    :: NEND
      INTEGER,INTENT(IN)    :: NTYP_cs         (IDX)
      REAL(8),INTENT(IN)    :: TMP_VEG         (IDX)
      REAL(8),INTENT(IN)    :: FR_WTR_VEG      (IDX)
      REAL(8),INTENT(IN)    :: FR_GLA_VEG      (IDX)
      REAL(8),INTENT(IN)    :: XLAI_VEG_ms     (IDX)
      REAL(8),INTENT(IN)    :: XLAI_VEG_OLD_mo (ITYP)
!     REAL(8),INTENT(IN)    :: CVR_VEG_ms      (IDX)
!     REAL(8),INTENT(IN)    :: CVR_VEG_OLD_mo  (ITYP)
!
! OUTPUT
!
      REAL(8),INTENT(OUT)   :: ADD_H2O_VEG     (IDX)
      REAL(8),INTENT(OUT)   :: ADD_ENG_VEG     (IDX)
!
! WORK
!
      INTEGER    :: I
      INTEGER    :: J
      REAL(8)    :: ADD_LAI
!     REAL(8)    :: ADD_CVR
      REAL(8)    :: CAP
!  
      DO 1000 I=NSTR,NEND
        J = NTYP_cs(I) 
        ADD_LAI = XLAI_VEG_ms(I) - XLAI_VEG_OLD_mo(J)
!       ADD_CVR = CVR_VEG_ms (I) - CVR_VEG_OLD_mo (J)
!
        IF ( ADD_LAI .NE. 0. ) THEN
          ADD_H2O_VEG (I) 
     1        =  ADD_LAI 
     1           * ( FR_WTR_VEG(I) + FR_GLA_VEG(I) ) 
     1           * H2O_SAT_VEG(I)                    ! �Ⴊ����ꍇ�␳�ς�
!
          CAP =   CAP_LAI_c 
     1          + CAP_WTR_c * FR_WTR_VEG(I) * H2O_SAT_VEG(I) 
     1          + CAP_GLA_c * FR_GLA_VEG(I) * H2O_SAT_VEG(I) 
!
          ADD_ENG_VEG(I)
     1        = ADD_LAI
     1          * (   CAP * ( TMP_VEG (I) - TMP_FREZ_c ) 
     1              - HL_GLA_c * FR_GLA_VEG(I) * H2O_SAT_VEG(I) )
        ELSE
          ADD_H2O_VEG(I) = 0. 
          ADD_ENG_VEG(I) = 0. 
        ENDIF
 1000 CONTINUE
!
#endif
      RETURN
      END