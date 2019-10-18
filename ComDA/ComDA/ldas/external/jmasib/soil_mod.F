! 99/07/07 �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 2000-09-11 �L�c�p�i  ���̏�������̒ǉ��ɔ������{��������
!
      SUBROUTINE SOIL_MOD (
     I   NMAX, FACT_WGT_H2O, INFO_SNOW_NEXT, 
     M   TMP_SOIL, TMP_SNSL, 
     M   FR_WTR_SOIL, FR_WTR_SNSL, FR_GLA_SOIL, FR_GLA_SNSL) 
!
! �y�됅��E�X�䂪�����I�ɂ��肦�Ȃ��l�ɂȂ��Ă���ꍇ�̏��u������B
! ���x�ɂ��Ă��������炩�̏��u���Ȃ���邩������Ȃ��B
!
! �V�����X�e�b�v�̐ϐ�핢���ő�1�w�̐��E�X���ĕ��z�������Ƃōs���B
!
! ����ł͈ȉ��̏��u�����Ă���B�����ŊܗL���Ƃ͋󌄂ɑ΂����ł���B
! �ϐ��ɑ΂��鏈�����܂Ƃ߂Ă��悢���Aabc �̏��Ԃ�ς��Ă͂����Ȃ��B
!
!   a �y��t���ܗL�� �����ł���ꍇ�����I�� 0 �ɂ���
!   b �y��X�ܗL�� �����ł���ꍇ�����I�� 0 �ɂ���
!   c �y�됅��(�t��+�X)���ܗL�� �� 1 �𒴂���ꍇ 1 �ɂ���
!
!   d �y�둍����(�t��+�X)�ܗL�� ��
!     �� 0.05 �������� SIBCON::FR_SOIL_H2O_MIN) ��菬�����Ƃ��ɁA
!     �������x�� H2O ��^���� 0.05 �ɂȂ�悤�ɂ���
!
! �y�둍�����Ɋւ��鋭���␳���͂Ȃ�ׂ����݂̑��ݓx�ŕ��z���Ă���B
! ���Ă�
!
!   e �y��X�ܗL���� 0.95 (�������� SIBCON::FR_SOIL_GLA_MAX) �𒴂���
!     �Ƃ��� 0.95 �ɂȂ�悤�ɂ���
!
! ������Ă����B����͍��̂Ƃ������Ă��Ȃ��B
!
! �������Ɋւ��đ��x����͎��s���Ă��Ȃ����A�� SOIL_MOD �ɂ���ׂ�
! �C���Ώۂ̂����W�߂����Ȃ��悤�ɂ��Ă���̂ŁA�L�����ƍl������B
! SR8000 �ɂĔz�������� DO ���[�v�Ɠ��l�ɋ^���x�N�g�����E���񉻂�
! �ΏۂƂȂ邱�Ƃ͊m�F���Ă���B
!
      USE SIBPRM , ONLY :
     1   IDX   , 
     1   IDP   
!
      USE SIBCON , ONLY :
     1    FR_SOIL_H2O_MIN_c  , 
     1    FR_SOIL_GLA_MAX_c  , 
     1    RHO_WTR_c        , 
     1    CAP_GLA_c        , 
     1    CAP_WTR_c        , 
     1    TMP_FREZ_c       , 
     1    HL_W2G_c         
!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : MONIT_SIB_NEXT , ICN , ICS ,
     1                       IMONIT_LEVEL , IMONIT_ALL
#endif
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER, INTENT(IN):: NMAX
      REAL(8), INTENT(IN):: FACT_WGT_H2O(IDX, IDP)  ! �󌄗�x���̔�d
      INTEGER, INTENT(IN):: INFO_SNOW_NEXT(IDX)
!
! INOUT
!
      ! �y��̉��x
      REAL(8), INTENT(INOUT) :: TMP_SOIL   (IDX,IDP) 
      REAL(8), INTENT(INOUT) :: TMP_SNSL   (IDX,IDP) 
      ! �y�됅��
      REAL(8), INTENT(INOUT) :: FR_WTR_SOIL(IDX,IDP) 
      REAL(8), INTENT(INOUT) :: FR_WTR_SNSL(IDX,IDP) 
      ! �y��X��
      REAL(8), INTENT(INOUT) :: FR_GLA_SOIL(IDX,IDP) 
      REAL(8), INTENT(INOUT) :: FR_GLA_SNSL(IDX,IDP) 
!
! WORK
!
      REAL(8):: H2O_MOD_SOIL(IDX,IDP)
      REAL(8):: H2O_MOD_SNSL(IDX,IDP)
      REAL(8):: ENG_MOD_SOIL(IDX,IDP)
      REAL(8):: ENG_MOD_SNSL(IDX,IDP)
      ! ����t���O
      LOGICAL:: BARESOIL_FLAG (IDX)    ! ���������i�q�����^
      LOGICAL:: UNDERSNOW_FLAG(IDX)    ! �ϐ������i�q�����^
      ! �z��T���p DO �ϐ�
      INTEGER:: I
      INTEGER:: K
      ! �z��T�����ɉ��Z�r�����ʂ�u���ϐ��BPOPTION TLOCAL ���Ă悢
      REAL(8):: WTR_MOD  ! �����␳�� W/m2
      REAL(8):: GLA_MOD  ! �X�␳�� W/m2
      REAL(8):: H2O_MOD  ! �X+���␳�� W/m2
      REAL(8):: FR_H2O  ! �X+�� �̑΋󌄔� 0--1
      REAL(8):: FR_H2O_MOD  ! �X+�� �̑΋󌄔�̕␳��
      REAL(8):: FR_WTR_MOD
      REAL(8):: FR_GLA_MOD
      REAL(8):: LIQUID_RATIO  ! �X+���␳��z�����邽�߂� ��/(�X+��)
!
#ifdef MONYOS
      CHARACTER(7)      :: CMARK 
#endif
      REAL(8), PARAMETER :: UNITY = 1.0_8
!
#ifdef SIB_DEBUG
      INTEGER            :: IERR_COUNT
      REAL(8)            :: XERR_SUM
#endif
!
      LOGICAL, SAVE:: LFIRST = .TRUE.
      IF (LFIRST) THEN 
        WRITE(6, *) 'SOIL_MOD 2000-09-13 TOYODA'
        LFIRST = .FALSE. 
      ENDIF

      H2O_MOD_SOIL(:,:) = 0.0_8
      H2O_MOD_SNSL(:,:) = 0.0_8
      ENG_MOD_SOIL(:,:) = 0.0_8
      ENG_MOD_SNSL(:,:) = 0.0_8

!
! ����t���O
!
      BARESOIL_FLAG (1:NMAX) = (INFO_SNOW_NEXT(1: NMAX) <= 0)
      UNDERSNOW_FLAG(1:NMAX) = (INFO_SNOW_NEXT(1: NMAX) >= 0)

! ====================
! ���̐��܂��͕X��r�����鏈��
! ====================
! �������� DO ���[�v�ŏ����Ă����B�C��������������l���悤�B
!
! ----------
! > ����� <
! ----------
!
#ifdef SIB_DEBUG
      IERR_COUNT = 0 
      XERR_SUM   = 0.
#endif      
!
      DO, K = 1, IDP
      DO, I = 1, NMAX
        IF (.NOT. BARESOIL_FLAG(I)) CYCLE   
!
        IF ( FR_WTR_SOIL(I,K) < 0.0_8 ) THEN
          WTR_MOD = -FR_WTR_SOIL(i, K) * FACT_WGT_H2O(i, K)
          FR_WTR_SOIL(i, K) = 0.0_8
          H2O_MOD_SOIL(i, K) = WTR_MOD
          ENG_MOD_SOIL(i, K) = WTR_MOD * CAP_WTR_C *
     1      (TMP_SOIL(i, K) - TMP_FREZ_c)
#ifdef SIB_DEBUG
          IERR_COUNT = IERR_COUNT + 1
          XERR_SUM   = XERR_SUM   + WTR_MOD**2
#endif
        ENDIF
!
        IF (FR_GLA_SOIL(i, K) < 0.0_8) THEN
          GLA_MOD = -FR_GLA_SOIL(i, K) * FACT_WGT_H2O(i, K)
          FR_GLA_SOIL(i, K) = 0.0_8
          H2O_MOD_SOIL(i, K) = H2O_MOD_SOIL(i, K) + GLA_MOD
          ENG_MOD_SOIL(i, K) = ENG_MOD_SOIL(i, K) + GLA_MOD *
     *      (-HL_W2G_C + CAP_GLA_C * (TMP_SOIL(i, K) - TMP_FREZ_c))
!    *      (-HL_W2G_C * CAP_GLA_C * (TMP_SOIL(i, K) - TMP_FREZ_c))
#ifdef SIB_DEBUG
          IERR_COUNT = IERR_COUNT + 1
          XERR_SUM   = XERR_SUM   + GLA_MOD**2
#endif
        ENDIF
      ENDDO
      ENDDO

! ----------
! > �L��� <
! ----------
! 
      DO, K = 1, IDP
      DO, i = 1, NMAX
        IF (.NOT. UNDERSNOW_FLAG(i)) CYCLE
!
        IF (FR_WTR_SNSL(i,k) < 0.0_8) THEN
          WTR_MOD = -FR_WTR_SNSL(i,k) * FACT_WGT_H2O(i,k)
          FR_WTR_SNSL (i,k) = 0.0_8
          H2O_MOD_SNSL(i,k) = WTR_MOD
          ENG_MOD_SNSL(i,k) = WTR_MOD * CAP_WTR_C *
     *      (TMP_SNSL(i,k) - TMP_FREZ_c)
#ifdef SIB_DEBUG
          IERR_COUNT = IERR_COUNT + 1
          XERR_SUM   = XERR_SUM   + WTR_MOD**2
#endif
        ENDIF
!
        IF (FR_GLA_SNSL(i,k) < 0.0_8) THEN
          GLA_MOD = -FR_GLA_SNSL(i,k) * FACT_WGT_H2O(i,k)
          FR_GLA_SNSL(i,k) = 0.0_8
          H2O_MOD_SNSL(i,k) = H2O_MOD_SNSL(i,k) + GLA_MOD
          ENG_MOD_SNSL(i,k) = ENG_MOD_SNSL(i,k) + GLA_MOD *
     1      (-HL_W2G_C + CAP_GLA_C * (TMP_SNSL(i,k) - TMP_FREZ_c))
!    1      (-HL_W2G_C * CAP_GLA_C * (TMP_SNSL(i,k) - TMP_FREZ_c))
#ifdef SIB_DEBUG
          IERR_COUNT = IERR_COUNT + 1
          XERR_SUM   = XERR_SUM   + GLA_MOD**2
#endif
        ENDIF
      ENDDO
      ENDDO
!
#ifdef SIB_DEBUG
      IF ( IERR_COUNT .GT. 0 ) THEN
        WRITE(6,*) 'SOIL_MOD H2O IS LACKED' , IERR_COUNT , XERR_SUM   
      ENDIF
#endif

! ===================
! H2O ���ʋK�� (���)
! ===================

! �����
!
      DO, K = 1, IDP
      DO, i = 1, NMAX

        IF (.NOT. BARESOIL_FLAG(i)) CYCLE
!
        FR_H2O = FR_WTR_SOIL(i, K) + FR_GLA_SOIL(i, K)
        IF (FR_H2O <= UNITY) CYCLE
! �␳�J�n
        FR_H2O_MOD = UNITY - FR_H2O
        H2O_MOD = FACT_WGT_H2O(i, K) * FR_H2O_MOD
        H2O_MOD_SOIL(i, K) = H2O_MOD_SOIL(i, K) + H2O_MOD
! ���BFR_H2O �͑傫�����邭�炢������[�����͋N�����Ȃ�
        LIQUID_RATIO = FR_WTR_SOIL(i, K) / FR_H2O
        FR_WTR_MOD = FR_H2O_MOD * LIQUID_RATIO
        FR_GLA_MOD = FR_H2O_MOD * (UNITY - LIQUID_RATIO)

        GLA_MOD = FR_GLA_MOD * FACT_WGT_H2O(i, K)                ! 000915
!
        ENG_MOD_SOIL(i, K) = ENG_MOD_SOIL(i, K) +
     +    (TMP_SOIL(i, K) - TMP_FREZ_c) * FACT_WGT_H2O(i, K) *
     *    (FR_WTR_MOD * CAP_WTR_C + FR_GLA_MOD * CAP_GLA_C) -
     -    GLA_MOD * HL_W2G_C
        FR_WTR_SOIL(i, K) = FR_WTR_SOIL(i, K) + FR_WTR_MOD
        FR_GLA_SOIL(i, K) = FR_GLA_SOIL(i, K) + FR_GLA_MOD
#ifdef SIB_DEBUG
        write(6, *) 'soil_mod: excessive soil H2O reduced i=', i,
     ,    ' k=', k, ' fr_wtr_mod=', fr_wtr_mod,
     ,    ' fr_gla_mod=', fr_gla_mod , 
     1    'ENGMOD = ' ,   ENG_MOD_SOIL(i,K) 
#endif
      ENDDO
      ENDDO

      ! �L���
      DO, K = 1, IDP
      DO, i = 1, NMAX
        ! �␳���ׂ��łȂ��ꍇ�͎��i�q��
        IF (.NOT. UNDERSNOW_FLAG(i)) CYCLE
        FR_H2O = FR_WTR_SNSL(i,k) + FR_GLA_SNSL(i,k)
        IF (FR_H2O <= UNITY) CYCLE
        ! �␳�J�n
        FR_H2O_MOD = UNITY - FR_H2O
        H2O_MOD = FACT_WGT_H2O(i,k) * FR_H2O_MOD
        H2O_MOD_SNSL(i,k) = H2O_MOD_SNSL(i,k) + H2O_MOD
        ! FR_H2O �͑傫�����邭�炢������[�����͋N�����Ȃ�
        LIQUID_RATIO = FR_WTR_SNSL(i,k) / FR_H2O
        FR_WTR_MOD = FR_H2O_MOD * LIQUID_RATIO
        FR_GLA_MOD = FR_H2O_MOD * (UNITY - LIQUID_RATIO)
!
        GLA_MOD    = FR_GLA_MOD * FACT_WGT_H2O(i, k)              ! 000915
!
        ENG_MOD_SNSL(i,k) = ENG_MOD_SNSL(i,k) +
     +    (TMP_SNSL(i,k) - TMP_FREZ_c) * FACT_WGT_H2O(i, k) *
     *    (FR_WTR_MOD * CAP_WTR_C + FR_GLA_MOD * CAP_GLA_C) -
     -    GLA_MOD * HL_W2G_C
        FR_WTR_SNSL(i,k) = FR_WTR_SNSL(i,k) + FR_WTR_MOD
        FR_GLA_SNSL(i,k) = FR_GLA_SNSL(i,k) + FR_GLA_MOD
#ifdef SIB_DEBUG
        write(6, *) 'soil_mod: excessive snsl H2O reduced i=', i,
     ,    ' fr_wtr_mod=', fr_wtr_mod, ' fr_gla_mod=', fr_gla_mod,
     ,    ' fr_wtr=', fr_wtr_snsl(i,k), ' fr_gla=', fr_gla_snsl(i,k) ,
     1    'H2O_MOD = ' ,   H2O_MOD_SNSL(i,k) ,
     1    'ENG_MOD = ' ,   ENG_MOD_SNSL(i,k) ,
     1    (TMP_SNSL(i,k) - TMP_FREZ_c) , FACT_WGT_H2O(i,k) , 
     1     FR_WTR_MOD * CAP_WTR_C , FR_GLA_MOD * CAP_GLA_C , 
     1     GLA_MOD * HL_W2G_C

#endif
      ENDDO
      ENDDO

! ===================
! H2O ���ʋK�� (���� ... �p�~����邩��)
! ===================
!     ����Ƃ̃R�[�f�B���O��̎�ȑ���͐��X�̕��z���
!     ����ɂ�����[�����}�~�ɂ���B

      ! �����
      DO, K = 1, IDP
      DO, i = 1, NMAX
        ! �␳���ׂ��łȂ��ꍇ�͎��i�q��
        IF (.NOT. BARESOIL_FLAG(i)) CYCLE
        FR_H2O = FR_WTR_SOIL(i, K) + FR_GLA_SOIL(i, K)
        IF (FR_H2O >= FR_SOIL_H2O_MIN_c) CYCLE
        ! �␳�J�n
        FR_H2O_MOD = FR_SOIL_H2O_MIN_c - FR_H2O
        H2O_MOD = FACT_WGT_H2O(i, K) * FR_H2O_MOD
        H2O_MOD_SOIL(i, K) = H2O_MOD_SOIL(i, K) + H2O_MOD
        ! ���z��̌���
        IF (FR_H2O /= 0.0_8) THEN
          LIQUID_RATIO = FR_WTR_SOIL(i, K) / FR_H2O
        ELSE IF (TMP_SOIL(i, K) > TMP_FREZ_c) THEN
          LIQUID_RATIO = UNITY
        ELSE IF (TMP_SOIL(i, K) == TMP_FREZ_c) THEN
          LIQUID_RATIO = 0.5_8
        ELSE
          LIQUID_RATIO = 0.0_8
        ENDIF
!
        FR_WTR_MOD = FR_H2O_MOD * LIQUID_RATIO
        FR_GLA_MOD = FR_H2O_MOD * (UNITY - LIQUID_RATIO)
        GLA_MOD    = FR_GLA_MOD * FACT_WGT_H2O(i, k)             
        ENG_MOD_SOIL(i, K) = ENG_MOD_SOIL(i, K) +
     +    (TMP_SOIL(i, K) - TMP_FREZ_c) * FACT_WGT_H2O(i, K) *
     *    (FR_WTR_MOD * CAP_WTR_C + FR_GLA_MOD * CAP_GLA_C) -
     -    GLA_MOD * HL_W2G_C
        FR_WTR_SOIL(i, K) = FR_WTR_SOIL(i, K) + FR_WTR_MOD
        FR_GLA_SOIL(i, K) = FR_GLA_SOIL(i, K) + FR_GLA_MOD
#ifdef SIB_DEBUG
        write(6, *) 'soil_mod: soil H2O supplement i=', i,
     ,    ' k=', k,
     ,    ' fr_wtr_mod=', fr_wtr_mod, ' fr_gla_mod=', fr_gla_mod
#endif
      ENDDO
      ENDDO

      ! �L���
      DO, K = 1, IDP
      DO, i = 1, NMAX
        ! �␳���ׂ��łȂ��ꍇ�͎��i�q��
        IF (.NOT. UNDERSNOW_FLAG(i)) CYCLE
        FR_H2O = FR_WTR_SNSL(i,k) + FR_GLA_SNSL(i,k)
        IF (FR_H2O >= FR_SOIL_H2O_MIN_c) CYCLE
        ! �␳�J�n
        FR_H2O_MOD = FR_SOIL_H2O_MIN_c - FR_H2O
        H2O_MOD = FACT_WGT_H2O(i,k) * FR_H2O_MOD
        H2O_MOD_SNSL(i,k) = H2O_MOD_SNSL(i,k) + H2O_MOD
        ! ���z��̌���
        IF (FR_H2O /= 0.0_8) THEN
          LIQUID_RATIO = FR_WTR_SNSL(i,k) / FR_H2O
        ELSE IF (TMP_SOIL(i,k) > TMP_FREZ_c) THEN
          LIQUID_RATIO = UNITY
        ELSE IF (TMP_SOIL(i,k) == TMP_FREZ_c) THEN
          LIQUID_RATIO = 0.5_8
        ELSE
          LIQUID_RATIO = 0.0_8
        ENDIF
        !
        FR_WTR_MOD = FR_H2O_MOD * LIQUID_RATIO
        FR_GLA_MOD = FR_H2O_MOD * (UNITY - LIQUID_RATIO)
        GLA_MOD    = FR_GLA_MOD * FACT_WGT_H2O(i, k)             
        ENG_MOD_SNSL(i,k) = ENG_MOD_SNSL(i,k) +
     +    (TMP_SNSL(i,k) - TMP_FREZ_c) * FACT_WGT_H2O(i,k) *
     *    (FR_WTR_MOD * CAP_WTR_C + FR_GLA_MOD * CAP_GLA_C) -
     -    GLA_MOD * HL_W2G_C
        FR_WTR_SNSL(i,k) = FR_WTR_SNSL(i,k) + FR_WTR_MOD
        FR_GLA_SNSL(i,k) = FR_GLA_SNSL(i,k) + FR_GLA_MOD
#ifdef SIB_DEBUG
        write(6, *) 'soil_mod: snsl H2O supplement ik=', i,k,
     ,    ' fr_wtr_mod=', fr_wtr_mod, ' fr_gla_mod=', fr_gla_mod
#endif
      ENDDO
      ENDDO

! ================
! >> �ڍ׃��j�^ <<
! ================

#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
! �y�됅�̕␳�� ver2 
!
        CMARK = 'WADLN1'
        CALL MONIT_SIB_NEXT(CMARK, H2O_MOD_SOIL(1,1), ICN, UNITY, UNITY) 
        CMARK = 'WADLS1'
        CALL MONIT_SIB_NEXT(CMARK, H2O_MOD_SNSL(1,1), ICS, UNITY, UNITY) 
!
        CMARK = 'WADLN2'
        CALL MONIT_SIB_NEXT(CMARK, H2O_MOD_SOIL(1,2), ICN, UNITY, UNITY)     
        CMARK = 'WADLS2'
        CALL MONIT_SIB_NEXT(CMARK, H2O_MOD_SNSL(1,2), ICS, UNITY, UNITY)     
!
        CMARK = 'WADLN3'
        CALL MONIT_SIB_NEXT(CMARK, H2O_MOD_SOIL(1,3), ICN, UNITY, UNITY)
        CMARK = 'WADLS3'
        CALL MONIT_SIB_NEXT(CMARK, H2O_MOD_SNSL(1,3), ICS, UNITY, UNITY)
!
! �G�l���M�[�̕␳�� 
!
        CMARK = 'HADLN1C' 
        CALL MONIT_SIB_NEXT(CMARK, ENG_MOD_SOIL(1,1), ICN, UNITY, UNITY)
        CMARK = 'HADLS1C' 
        CALL MONIT_SIB_NEXT(CMARK, ENG_MOD_SNSL(1,1), ICS, UNITY, UNITY)
!
        CMARK = 'HADLN2C' 
        CALL MONIT_SIB_NEXT(CMARK, ENG_MOD_SOIL(1,2), ICN, UNITY, UNITY)
        CMARK = 'HADLS2C' 
        CALL MONIT_SIB_NEXT(CMARK, ENG_MOD_SNSL(1,2), ICS, UNITY, UNITY)
!
        CMARK = 'HADLN3C' 
        CALL MONIT_SIB_NEXT(CMARK, ENG_MOD_SOIL(1,3), ICN, UNITY, UNITY)
        CMARK = 'HADLS3C' 
        CALL MONIT_SIB_NEXT(CMARK, ENG_MOD_SNSL(1,3), ICS, UNITY, UNITY)
      ENDIF
!
#endif

      END SUBROUTINE SOIL_MOD
!===============================================================
      SUBROUTINE MR_SOIL_MOD
!
! soil_mod �ŏo�͂���f�o�b�O�p�ϐ��̓o�^���
!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : 
     1                       IMONIT_LEVEL , IMONIT_ALL
#endif
!
      IMPLICIT NONE
!
      CHARACTER(7):: CMARK 
      CHARACTER(32):: CTITLE 
      CHARACTER(13):: CUNIT
!
      LOGICAL, SAVE::  LFIRST 
!
!
      DATA LFIRST /.TRUE./
!
      IF (LFIRST) THEN
        WRITE(6, *) 'MONIT_REGIST_SOIL_MOD 99/09 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
!  ���̕␳��   
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN   
!
      CMARK = 'WADLN1'
      CTITLE = 'H2O MODIFY IN SOIL 1 NOS (SOILMOD)'
      CUNIT = 'KG/M**2/S'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'WADLS1'
      CTITLE = 'H2O MODIFY IN SOIL 1 SNW (SOILMOD)'
      CUNIT = 'KG/M**2/S'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'WADLN2'
      CTITLE = 'H2O MODIFY IN SOIL 2 NOS (SOILMOD) '
      CUNIT = 'KG/M**2/S'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'WADLS2'
      CTITLE = 'H2O MODIFY IN SOIL 2 SNW (SOILMOD) '
      CUNIT = 'KG/M**2/S'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'WADLN3'
      CTITLE = 'H2O MODIFY IN SOIL 3 NOS (SOILMOD) '
      CUNIT = 'KG/M**2/S'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'WADLS3'
      CTITLE = 'H2O MODIFY IN SOIL 3 SNW (SOILMOD) '
      CUNIT = 'KG/M**2/S'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
! �G�l���M�[�␳
!
      CMARK = 'HADLN1C'
      CTITLE = 'ENG WITH H2O MODIFY IN SOIL 1 NOS (SOILMOD) '
      CUNIT = 'W/M**2'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'HADLS1C'
      CTITLE = 'ENG WITH H2O MODIFY IN SOIL 1 SNW (SOILMOD) '
      CUNIT = 'W/M**2'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'HADLN2C'
      CTITLE = 'ENG WITH H2O MODIFY IN SOIL 2 NOS (SOILMOD) '
      CUNIT = 'W/M**2'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'HADLS2C'
      CTITLE = 'ENG WITH H2O MODIFY IN SOIL 2 SNW (SOILMOD) '
      CUNIT = 'W/M**2'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'HADLN3C'
      CTITLE = 'ENG WITH H2O MODIFY IN SOIL 3 NOS (SOILMOD) '
      CUNIT = 'W/M**2'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      CMARK = 'HADLS3C'
      CTITLE = 'ENG WITH H2O MODIFY IN SOIL 3 SNW (SOILMOD) '
      CUNIT = 'W/M**2'
      CALL monit_regist_sib(CMARK, CTITLE, CUNIT)
!
      ENDIF
#endif
!
      RETURN
      END SUBROUTINE MR_SOIL_MOD