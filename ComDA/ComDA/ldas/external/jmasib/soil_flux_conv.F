!  �y�뒆�̃t���b�N�X�̊m��
!  99/07/07 �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE SOIL_FLUX_CONV (
     I   NSTR          , NEND          , DELT_SOIL     , 
#ifdef MONYOS
     I   INSFLAG       ,
#endif
     I   HEAT_CONV     , 
     I   WFLUX_H       , WTR_INC       , 
     I   CAP_SOIL_INV  , 
     I   TMP_SOIL      , 
     M   ENG_SOIL      , H2O_SOIL      , TMP_SOIL4  , 
     O   RUNOFF_B     )
!
!  �y�뒆�̐ϕ��B
!    ���x�E���Ƃ��t���b�N�X���m�肷��B
!
!  �y�뒆�̐��̈ړ��ɔ����M�ɂ��Ă͉��炩�̑[�u���K�v�B�����ł�
!    (1) �e�w�̎擾�����M�t���b�N�X�������M�̏d�݂������Đ��ɕ��z
!    (2) ���Ƃ̉��x�ƁA��������M�������āA���͈ړ�
!    (3) �s������ŉ��x�ω��E���ω��v�Z
!  �Ƃ���B���̕��@�Ƃ��Ă�
!    (1) ���x�ω��E���ω��v�Z
!    (2) �V���ȉ��x�������Đ����ړ�
!    (3) ���ω��v�Z�̂��Ȃ���
!  ���v���t���B

!  �O�҂̕��@���Ƃ邱�ƂŁA�v���t�����_�E���_�͈ȉ��̒ʂ�
!    ���_
!      �E���ω��v�Z�́A(3) �̈�x�ł悢
!    ���_
!      �E0 �x�̂Ƃ��A���ω��Ɏg����M�������Đ��������Ă��܂�
!


      USE SIBPRM , ONLY :
     1   IDX   , 
     1   IDP   
!
      USE SIBCON , ONLY :
     1   CAP_WTR_c  , 
     1   TMP_FREZ_c   
     1  , rho_wtr_c 
     1  , cap_soil4_inv_c
!
      use sibveg , only :
     1  POR_SOIL_co   , DEP_SOIL_co 

!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : MONIT_SIB , ICN, ICS,INA, 
     1                       IMONIT_ALL , IMONIT_LEVEL ,
     1                       IMONIT_FLUX_COMMON, IMONIT_ALMA
#endif
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
      REAL(8),INTENT(IN)    :: DELT_SOIL
!
      REAL(8),INTENT(IN)    :: HEAT_CONV(IDX,IDP+1)  ! �M�t���b�N�X����
!
      REAL(8),INTENT(IN)    :: WFLUX_H  (IDX,IDP)    ! ���t���b�N�X��������
      REAL(8),INTENT(IN)    :: WTR_INC  (IDX,IDP)    ! �ŏI�I�Ȑ�����
!
      REAL(8),INTENT(IN)    :: TMP_SOIL     (IDX,IDP)   
      REAL(8),INTENT(IN)    :: CAP_SOIL_INV (IDX,IDP) ! �w�̔�M���v
!
#ifdef MONYOS
      INTEGER,INTENT(IN)    :: INSFLAG
#endif
!
! OUT 
!
      REAL(8)   :: HEAT_INC  (IDX,IDP+1)    ! �ŏI�I�ɂ��炤�M
      REAL(8),INTENT(INOUT)   :: RUNOFF_B (IDX)        ! ���[�ł̃����I�t
!
      REAL(8)   :: R_RUNOFF_WTR(IDX)   ! �ŉ��w������鐅�i���j
!
! INOUT 
!
      REAL(8),INTENT(INOUT) :: ENG_SOIL(IDX,IDP)
      REAL(8),INTENT(INOUT) :: H2O_SOIL(IDX,IDP)
      REAL(8),INTENT(INOUT) :: TMP_SOIL4(IDX)
!
! WORK
!
      INTEGER  :: I
      INTEGER  :: K
!
      REAL(8)  :: HFLUX_WH  (IDX,IDP)    ! ���ړ��ɔ����M�t���b�N�X
!
      REAL(8)  :: WFLUX_12                 ! ���t���b�N�X
      REAL(8)  :: WFLUX_21  
      REAL(8)  :: WFLUX_23
      REAL(8)  :: WFLUX_32
      REAL(8)  :: WFLUX_34
      REAL(8)  :: WFLUX_43
!
      REAL(8)  :: FR_HEAT_12         ! ����M���́A���鐅�̂��炤����
      REAL(8)  :: FR_HEAT_21 
      REAL(8)  :: FR_HEAT_23 
      REAL(8)  :: FR_HEAT_32 
      REAL(8)  :: FR_HEAT_34 
!
!     REAL(8)  :: HFLUX_01(IDX)
!     REAL(8)  :: HFLUX_10(IDX)
      REAL(8)  :: HFLUX_12(IDX)
      REAL(8)  :: HFLUX_21(IDX)
      REAL(8)  :: HFLUX_23(IDX)
      REAL(8)  :: HFLUX_32(IDX)
      REAL(8)  :: HFLUX_34(IDX)
      REAL(8)  :: HFLUX_43(IDX)
!
      REAL(8),PARAMETER  :: DZERO = 0.D0
!
      LOGICAL,SAVE :: LFIRST
!
#ifdef MONYOS
      CHARACTER(7)      :: CMARK 
      REAL(8),PARAMETER :: ONE = 1.D0 
!     REAL(8)           :: WORK(IDX) 
#endif
!
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN 
        WRITE(6,*) 'SOIL_FLUX_CONV 99/08 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      DO 1000 I=NSTR,NEND
!
! ==========================================
! >> �e�w�̎擾�����M�t���b�N�X�����̕��z << 
! ==========================================
!
!  ���̈ړ���
!
        WFLUX_12  = MAX ( WFLUX_H(I,1) , DZERO ) ! ��:�������Ȃ�l����
        WFLUX_21  = MIN ( WFLUX_H(I,1) , DZERO ) ! ��:������Ȃ�l����
        WFLUX_23  = MAX ( WFLUX_H(I,2) , DZERO ) 
        WFLUX_32  = MIN ( WFLUX_H(I,2) , DZERO ) 
        WFLUX_34  = MAX ( WFLUX_H(I,3) , DZERO ) 
        WFLUX_43  = MIN ( WFLUX_H(I,3) , DZERO ) ! �f�o�b�O���j�^�p
!
        RUNOFF_B    (I) = WFLUX_34 
        R_RUNOFF_WTR(I) = WFLUX_43                ! �ŉ��w������鐅
!
!  �����čs���M�̊��� 
!     FR_HEAT_12 �́A1 �ɗ����M�̂����ŁA 2 �ɍs�������󂯎�銄��
!     �����͐��ł���!!!
!     CAP_WTR_c * DELT_SOIL * WFLUX_12 ���́A�ړ����鐅�̔�M�B
!     CAP_SOIL_INV �͑w�S�̂̔�M�̋t���B
!
        FR_HEAT_12 = CAP_WTR_c * DELT_SOIL * WFLUX_12  
     1                         * CAP_SOIL_INV(I,1)  
        FR_HEAT_21 = CAP_WTR_c * DELT_SOIL * ( - WFLUX_21 ) 
     1                         * CAP_SOIL_INV(I,2)  
        FR_HEAT_23 = CAP_WTR_c * DELT_SOIL * WFLUX_23  
     1                         * CAP_SOIL_INV(I,2)  
        FR_HEAT_32 = CAP_WTR_c * DELT_SOIL * ( - WFLUX_32 ) 
     1                         * CAP_SOIL_INV(I,3)  
        FR_HEAT_34 = CAP_WTR_c * DELT_SOIL * WFLUX_34  
     1                         * CAP_SOIL_INV(I,3)  
!
! �ł��ōs�����ɂ��Ă��M�̃t���b�N�X? HFLUX_WH
!     ���ԍ��͂������Ă��Ȃ����Ƃɒ��ӁB
!
        HFLUX_12(I) 
     1      =   WFLUX_12 * CAP_WTR_c * ( TMP_SOIL(I,1) - TMP_FREZ_c )
     1        + FR_HEAT_12 * HEAT_CONV(I,1) 
        HFLUX_21(I) 
     1      =   WFLUX_21 * CAP_WTR_c * ( TMP_SOIL(I,2) - TMP_FREZ_c )
     1        - FR_HEAT_21 * HEAT_CONV(I,2) 
        HFLUX_WH(I,1) = HFLUX_12(I) + HFLUX_21(I)  
!
        HFLUX_23(I) 
     1      =   WFLUX_23 *  CAP_WTR_c * ( TMP_SOIL(I,2) - TMP_FREZ_c )
     1        + FR_HEAT_23 * HEAT_CONV(I,2) 
        HFLUX_32(I) 
     1      =   WFLUX_32 *  CAP_WTR_c * ( TMP_SOIL(I,3) - TMP_FREZ_c )
     1        - FR_HEAT_32 * HEAT_CONV(I,3) 
        HFLUX_WH(I,2) = HFLUX_23(I) + HFLUX_32(I)  
!
        HFLUX_34(I) 
     1      =   WFLUX_34  * CAP_WTR_c * ( TMP_SOIL(I,3) - TMP_FREZ_c )
     1        + FR_HEAT_34 * HEAT_CONV(I,3) 
        HFLUX_43(I) 
     1      =   WFLUX_43  *  CAP_WTR_c * ( TMP_SOIL(I,3) - TMP_FREZ_c )
        HFLUX_WH(I,3) = HFLUX_34(I) + HFLUX_43(I)
!
!       ��L�ɂ��āB 
!       �����t�����I�t������Ƃ���΁A
!       �d���������̂ő� 3 �w�̉��x�̐�������Ƃ���Ƃ����B
!
!       �� 4 �w�ɂ� H2O ���Ȃ��A���ω����l�����Ă��Ȃ����߁B
!
!       ���� 4 �w�ڂ� H2O ������Ȃ牺�̂悤�ɂȂ�??
!    1      + WFLUX_43 * CAP_WTR_c * ( TMP_SOIL(I,4) - TMP_FREZ_c )
!    1      - FR_HEAT_43 * HEAT_IN_4 
!
!  ���炤�M�̍��v
!
        HEAT_INC(I,1) = (   HEAT_CONV(I,1) 
     1                                    - HFLUX_WH(I,1) ) * DELT_SOIL
! 
        HEAT_INC(I,2) = (   HEAT_CONV(I,2) 
     1                    + HFLUX_WH(I,1) - HFLUX_WH(I,2) ) * DELT_SOIL
! 
        HEAT_INC(I,3) = (   HEAT_CONV(I,3) 
     1                    + HFLUX_WH(I,2) - HFLUX_WH(I,3) ) * DELT_SOIL
!
        HEAT_INC(I,4) = HEAT_CONV(I,4) * DELT_SOIL
        TMP_SOIL4(I)  = TMP_SOIL4(I) + HEAT_INC(I,4) * CAP_SOIL4_INV_c 
!
!          �y���l�w�͐����������A��O�w�Ƃ̐��̂��Ƃ���l���Ȃ����߁B
!
 1000 CONTINUE  
!
! ============================
! >> �e�w�̃G�l���M�[�̕ύX << 
! ============================
!
      DO K=1,IDP
      DO I=NSTR,NEND
        ENG_SOIL(I,K) = ENG_SOIL(I,K) + HEAT_INC(I,K) 
        H2O_SOIL(I,K) = H2O_SOIL(I,K) + WTR_INC (I,K) 
      ENDDO 
      ENDDO
!
! ================
! >> �ڍ׃��j�^ <<
! ================
!
#ifdef MONYOS
!
! ----------------------
! > �i�q���σt���b�N�X <
! ----------------------
!
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN   
        CMARK = 'ROFB' 
        IF ( INSFLAG.EQ.0 ) THEN
          CALL MONIT_SIB ( CMARK , RUNOFF_B, ICN, DELT_SOIL, ONE )
        ELSE
          CALL MONIT_SIB ( CMARK , RUNOFF_B, ICS, DELT_SOIL, ONE )
        ENDIF
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALMA ) THEN   
        CMARK = 'A_ROB' 
        CALL MONIT_SIB ( CMARK , RUNOFF_B, INA, DELT_SOIL, ONE )
      ENDIF

!
! --------------------
! > �X�̃t���b�N�X <
! --------------------
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN   
!
! �����̃t���b�N�X�B
!   3 �w�ڂƂ��̉��̂݁A�����ł͈����B
!   ����ȊO�� soil_wflux �Ŋi�[�ρB
!   ������Ɖ������̋�ʂ����邽�߁B
!
!   �w�Ԃ̐��t���b�N�X�ɔ����M
!
        IF ( INSFLAG.EQ.0 ) THEN
!         CMARK = 'IFLN10' 
!         CALL MONIT_SIB ( CMARK ,  HFLUX_10, ICN, DELT_SOIL , ONE)
          CMARK = 'IFLN12' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_12, ICN, DELT_SOIL , ONE)
          CMARK = 'IFLN21' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_21, ICN, DELT_SOIL , ONE)
          CMARK = 'IFLN23' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_23, ICN, DELT_SOIL , ONE)
          CMARK = 'IFLN32' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_32, ICN, DELT_SOIL , ONE)
        ELSE
!         CMARK = 'IFLS10' 
!         CALL MONIT_SIB ( CMARK ,  HFLUX_10, ICS, DELT_SOIL, ONE)      
          CMARK = 'IFLS12' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_12, ICS, DELT_SOIL, ONE)
          CMARK = 'IFLS21' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_21, ICS, DELT_SOIL, ONE)
          CMARK = 'IFLS23' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_23, ICS, DELT_SOIL, ONE)
          CMARK = 'IFLS32' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_32, ICS, DELT_SOIL, ONE)
        ENDIF
!
! ���ʃ����I�t �ƁA���̐��̃G�l���M�[
!
        IF ( INSFLAG.EQ.0 ) THEN
          CMARK = 'WRONB' 
          CALL MONIT_SIB ( CMARK , RUNOFF_B, ICN, DELT_SOIL, ONE )
          CMARK = 'IRONB' 
          CALL MONIT_SIB ( CMARK , HFLUX_34, ICN, DELT_SOIL, ONE )
        ELSE
          CMARK = 'WROSB' 
          CALL MONIT_SIB ( CMARK , RUNOFF_B, ICS, DELT_SOIL, ONE )
          CMARK = 'IROSB' 
          CALL MONIT_SIB ( CMARK , HFLUX_34, ICS, DELT_SOIL, ONE )
        ENDIF
!
!  4 -> 3 �w�ւ̐� �� ���̃G�l���M�[
!
        IF ( INSFLAG.EQ.0 ) THEN
          CMARK = 'WFLN43' 
          CALL MONIT_SIB ( CMARK , R_RUNOFF_WTR,ICN, DELT_SOIL, ONE)
          CMARK = 'IFLN43' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_43  , ICN, DELT_SOIL, ONE)
        ELSE
          CMARK = 'WFLS43' 
          CALL MONIT_SIB ( CMARK , R_RUNOFF_WTR,ICS, DELT_SOIL, ONE)
          CMARK = 'IFLS43' 
          CALL MONIT_SIB ( CMARK ,  HFLUX_43 , ICS, DELT_SOIL, ONE)
        ENDIF
!
      ENDIF
#endif
      RETURN
      END
!===============================================================
      SUBROUTINE MR_SOIL_FLUX_CONV
!
! soil_mod �ŏo�͂���f�o�b�O�p�ϐ��̓o�^���
!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : MONIT_SIB , 
     1                       IMONIT_ALL , IMONIT_LEVEL ,
     1                       IMONIT_FLUX_COMMON, IMONIT_ALMA
#endif
!
      IMPLICIT NONE
!
      CHARACTER( 7)  :: CMARK 
      CHARACTER(32)  :: CTITLE 
      CHARACTER(13)  :: CUNIT
!
      LOGICAL,SAVE ::  LFIRST 
!
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'MONIT_REGIST_SOIL_FLUX_CONV 99/09 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
! ���w�Ԃ̐��̈ړ��ɔ����M�̈ړ�
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_FLUX_COMMON ) THEN
!  �����I�t
!     ROFD = WRONB + WROSB 
!
!
        CMARK  = 'ROFB'
        CTITLE = 'Gravitational Bottom Runoff'
        CUNIT  = 'kg/m**2/s'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN   
!
!  �ᖳ��
!
!     CMARK  = 'IFLN10'
!     CTITLE = 'ENERGY WITH WTR FROM SOIL 1 TO SOIL 0 NOS'
!     CUNIT  = 'W/M**2'
!     CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLN21'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 2 TO SOIL 1 NOS'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLN32'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 3 TO SOIL 2 NOS'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLN12'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 1 TO SOIL 2 NOS'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLN23'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 2 TO SOIL 3 NOS'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  �Ⴀ��
!
!     CMARK  = 'IFLS10'
!     CTITLE = 'ENERGY WITH WTR FROM SOIL 1 TO SOIL 0 SNW'
!     CUNIT  = 'W/M**2'
!     CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLS21'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 2 TO SOIL 1 SNW'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLS32'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 3 TO SOIL 2 SNW'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLS12'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 1 TO SOIL 2 SNW'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLS23'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 2 TO SOIL 3 SNW'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! �n�������I�t �� ���̔M
!
      CMARK  = 'WRONB'
      CTITLE = 'RUNOFF FROM BOTTOM NOS'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WROSB'
      CTITLE = 'RUNOFF FROM BOTTOM SNW'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IRONB'
      CTITLE = 'HEAT OF RUNOFF FROM BOTTOM NOS'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IROSB'
      CTITLE = 'HEAT OF RUNOFF FROM BOTTOM SNW'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!  ���t���b�N�X 4->3  �Ƃ��̔M
!
      CMARK  = 'WFLN43'
      CTITLE = 'H2O FROM BOTTOM TO SOIL 3 NOS'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WFLS43'
      CTITLE = 'H2O FROM BOTTOM TO SOIL 3 SNW'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )

      CMARK  = 'IFLN43'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 4 TO SOIL 3 NOS'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'IFLS43'
      CTITLE = 'ENERGY WITH WTR FROM SOIL 4 TO SOIL 3 SNW'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALMA ) THEN
        CMARK  = 'A_ROB'
        CTITLE = 'ALMA Qsb : Gravitational Bottom Runoff'
        CUNIT  = 'kg/m**2/s'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      ENDIF

#endif
!
      RETURN
      END

