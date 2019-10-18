! ��̔핢���E�ϐ�[�̕ω��ɔ��� H2O�E�G�l���M�[�̕ω��������j�^����B
!     �������A�y������̐��E�G�l���M�[�̏����͏����B
!     --- �L���m�s�[�E�����̕ې��ʕω�
!
! 99/10/14 �ۍ␪�G �V�K
!
      SUBROUTINE SNOWMOD_MAIN (
     I   NMAX             , 
     I   NTYP             , MON                 , 
     I   CVR_SNW          , CVR_SNW_NEXT        , 
     I   INFO_SNOW        , INFO_SNOW_NEXT      , 
     I   DEP_SNOW         , DEP_SNOW_NEXT       , 
     I   TMP_SOIL_NEXT    , 
     I   TMP_SNOW_NEXT   , 
     M   TMP_CNP_NOS_NEXT , FR_WTR_CNP_NOS_NEXT , FR_GLA_CNP_NOS_NEXT , 
     M   TMP_CNP_SNW_NEXT , FR_WTR_CNP_SNW_NEXT , FR_GLA_CNP_SNW_NEXT ,
     M   TMP_GRSK_NEXT    , FR_WTR_GRS_NEXT     , FR_GLA_GRS_NEXT     , 
     M   TMP_SNSK_NEXT    )
!
! �E����
!   ���̃o�P�c�͂��̃^�C�~���O�ŃN���A�����̂ŁA�C���̕K�v�����B
!   ����̃o�P�c�� cvr_snw ���̕ω��ɂ́A��`�ɂ���Ė����B
!
      USE SIBPRM , ONLY :
     1   IDX  , 
     1   ITYP , 
     1   IDP  , 
     1   ISN
!
      USE SIBVEG , ONLY :
     1           XLAI_mo                    , !              (ITYP,IMON,ICG)
     1           D_ZERO_mo                  , ! ��ʕψ� d   (ITYP,IMON)  
     1           Z2_mo                      , 
     1           Z1_mo                       
!
      USE SIBCON , ONLY :
     1           TMP_FREZ_c        ,
     1           HL_W2G_c        ,
     1           CAP_GLA_c       ,
     1           CAP_WTR_c       ,
     1           CAP_LAI_c       , 
     1           RHO_WTR_c       ,
     1           H2O_SAT_CNP_DEP_c ,
     1           H2O_SAT_GRS_DEP_c , 
     1           CAP_GRSK_c       ,
     1           CAP_SNSK_c       
!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : MONIT_SIB, INA , 
     1                       IMONIT_LEVEL , IMONIT_ALL
#endif
!
      IMPLICIT NONE
!
      REAL(8),INTENT(INOUT) :: TMP_CNP_NOS_NEXT    (IDX)  ! �L���m�s�[���x
      REAL(8),INTENT(INOUT) :: TMP_CNP_SNW_NEXT    (IDX)  ! �L���m�s�[���x
      REAL(8),INTENT(INOUT) :: FR_WTR_CNP_SNW_NEXT (IDX)  ! �L���m�s�[������
      REAL(8),INTENT(INOUT) :: FR_GLA_CNP_SNW_NEXT (IDX)  ! �L���m�s�[�X����
      REAL(8),INTENT(INOUT) :: FR_WTR_CNP_NOS_NEXT (IDX)  ! �L���m�s�[������
      REAL(8),INTENT(INOUT) :: FR_GLA_CNP_NOS_NEXT (IDX)  ! �L���m�s�[�X����
      REAL(8),INTENT(INOUT) :: TMP_GRSK_NEXT       (IDX)  ! �n�ʉ��x
      REAL(8),INTENT(INOUT) :: FR_WTR_GRS_NEXT     (IDX)  ! �n�ʐ�����
      REAL(8),INTENT(INOUT) :: FR_GLA_GRS_NEXT     (IDX)  ! �n�ʕX����
      REAL(8),INTENT(INOUT) :: TMP_SNSK_NEXT       (IDX)  ! �n�ʉ��x
!
      INTEGER,INTENT(IN)    :: INFO_SNOW_NEXT      (IDX)
      INTEGER,INTENT(IN)    :: INFO_SNOW           (IDX)
      REAL(8),INTENT(IN)    :: CVR_SNW_NEXT        (IDX)
      REAL(8),INTENT(IN)    :: CVR_SNW             (IDX)
!
      REAL(8),INTENT(IN)    :: DEP_SNOW     (IDX,ISN+1)   ! �ϐ�w�̌���(m)
      REAL(8),INTENT(IN)    :: DEP_SNOW_NEXT(IDX,ISN+1)   ! �ϐ�w�̌���(m)
      REAL(8),INTENT(IN)    :: TMP_SOIL_NEXT(IDX,IDP)     
      REAL(8),INTENT(IN)    :: TMP_SNOW_NEXT(IDX)
!
      INTEGER,INTENT(IN)    :: NMAX 
      INTEGER,INTENT(IN)    :: MON
      INTEGER,INTENT(IN)    :: NTYP(IDX) 
!
! WORK
!     
      INTEGER     :: I
      REAL(8)     :: SDEP
      REAL(8)     :: SDEP_NEXT
      REAL(8)     :: XZ 
      REAL(8)     :: FAC 
      REAL(8)     :: FAC_NEXT 
!
      REAL(8)     :: ADD_LAI_CNP_SNW (IDX) 
      REAL(8)     :: ADD_LAI_CNP_NOS (IDX) 
      REAL(8)     :: ADD_LAI_GRS     (IDX) 
!
      REAL(8),PARAMETER :: ZERO = 0.D0
!
#ifdef MONYOS
      REAL(8),PARAMETER  :: ONE = 1.D0 
      REAL(8)            :: WORK(IDX) 
      CHARACTER(7)       :: CMARK
#endif
!
      LOGICAL,SAVE :: LFIRST
      DATA LFIRST / .TRUE. /
!
      IF ( LFIRST ) THEN 
        WRITE(6,*) 'SNOWMOD_MAIN 99/10 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
! INFO_SNOW �̉��
!    ���Ȃ�ΐႠ��A�V�Ⴊ����΋����� 2N , �V�Ⴊ�Ȃ���� 2N+1 
!    -999  �K�v�Ȃ�Εs��
!      -2  ��Ȃ�  ����o�P�c�ɂ���
!      -1  �ᖳ��
!       0  ���� 01 
!       1  1 �w
!       2  2 �w
!       3  3 �w
!       4  4 �w
!
! ================================
! >> �ᖳ���i�q�ɐႪ�������Ƃ� <<
! ================================
!
      DO I = 1,NMAX
        IF ( INFO_SNOW_NEXT(I).GE.0 .AND. INFO_SNOW(I).LT.0 ) THEN
          FR_WTR_CNP_SNW_NEXT(I) = FR_WTR_CNP_NOS_NEXT (I)
          FR_GLA_CNP_SNW_NEXT(I) = FR_GLA_CNP_NOS_NEXT (I)
          TMP_CNP_SNW_NEXT   (I) = TMP_CNP_NOS_NEXT    (I)
!
          TMP_SNSK_NEXT      (I) = TMP_SNOW_NEXT       (I)
        ENDIF
      ENDDO
!
! ======================================
! >> �S�ʐ�i�q�ɐ�Ȃ��悪�������Ƃ� <<
! ======================================
!
      DO I = 1,NMAX
        IF ( INFO_SNOW_NEXT(I).LE.0 .AND. INFO_SNOW(I).GE.1 ) THEN
          FR_WTR_CNP_NOS_NEXT(I) = FR_WTR_CNP_SNW_NEXT (I)
          FR_GLA_CNP_NOS_NEXT(I) = FR_GLA_CNP_SNW_NEXT (I)
          TMP_CNP_NOS_NEXT   (I) = TMP_CNP_SNW_NEXT    (I)
!
          TMP_GRSK_NEXT      (I) = TMP_SOIL_NEXT       (I,1)
          IF ( TMP_GRSK_NEXT (I) .GE. TMP_FREZ_c ) THEN
            FR_WTR_GRS_NEXT(I) = 1. 
            FR_GLA_GRS_NEXT(I) = 0. 
          ELSE 
            FR_WTR_GRS_NEXT(I) = 0. 
            FR_GLA_GRS_NEXT(I) = 1. 
          ENDIF
        ENDIF
      ENDDO
!
! ============================
! >> �␳�ʁE�ω��ʂ̃��j�^ <<
! ============================
!
!  �ʐςȂǂ̕ω��� �i�S�i�q�ɑ΂��銄���A�S�i�q�E�SLAI �ɑ΂��銄�� �j
!
      DO I = 1,NMAX
        XZ        = Z2_mo( NTYP(I) , MON ) - Z1_mo( NTYP(I) , MON ) 
        SDEP      = MIN ( DEP_SNOW(I,5) - Z1_mo( NTYP(I) , MON ) 
     1                    , XZ * 0.95D0 )
        SDEP      = MAX ( SDEP , ZERO )
        FAC       = 1.0D0 - SDEP      / XZ    
!
        SDEP_NEXT = MIN ( DEP_SNOW_NEXT(I,5)- Z1_mo( NTYP(I) , MON ) 
     1                    , XZ * 0.95D0 )
        SDEP_NEXT = MAX ( SDEP_NEXT , ZERO )
        FAC_NEXT  = 1.0D0 - SDEP_NEXT / XZ              
!
        ADD_LAI_CNP_SNW (I) 
     1       = ( CVR_SNW_NEXT(I) * FAC_NEXT  - CVR_SNW(I) * FAC )
     1         * XLAI_mo (NTYP(I),MON,1) 
        ADD_LAI_CNP_NOS (I) 
     1       = ( - CVR_SNW_NEXT(I) + CVR_SNW(I) )
     1         * XLAI_mo (NTYP(I),MON,1) 
        ADD_LAI_GRS (I) 
     1       = ( - CVR_SNW_NEXT(I) + CVR_SNW(I) )
     1         * XLAI_mo (NTYP(I),MON,2) 
      ENDDO
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
!  �Ⴀ��L���m�s�[�ł̐��̕ω��� 
!
        DO I=1,NMAX
          WORK(I) 
     1      = ADD_LAI_CNP_SNW(I) 
     1        * RHO_WTR_c * H2O_SAT_CNP_DEP_c 
     1        * ( FR_WTR_CNP_SNW_NEXT (I) + FR_GLA_CNP_SNW_NEXT (I) )
        ENDDO
        CMARK = 'WADSS' 
        CALL MONIT_SIB ( CMARK , WORK , INA , ONE , ONE )  
!
!  �ᖳ���L���m�s�[�ł̐��̕ω���
!
        DO I=1,NMAX
          WORK(I) 
     1      = ADD_LAI_CNP_NOS(I) 
     1        * RHO_WTR_c * H2O_SAT_CNP_DEP_c 
     1        * ( FR_WTR_CNP_NOS_NEXT (I) + FR_GLA_CNP_NOS_NEXT (I) )
        ENDDO
        CMARK = 'WADNS' 
        CALL MONIT_SIB ( CMARK , WORK , INA , ONE , ONE )  
!
!  �ᖳ�������ł̐��̕ω���
!
        DO I=1,NMAX
          WORK(I) 
     1      = ADD_LAI_GRS(I) 
     1        * RHO_WTR_c * H2O_SAT_GRS_DEP_c 
     1        * ( FR_WTR_GRS_NEXT (I) + FR_GLA_GRS_NEXT (I) )
        ENDDO
        CMARK = 'WADGS' 
        CALL MONIT_SIB ( CMARK , WORK , INA , ONE , ONE )  
!
!  �Ⴀ��L���m�s�[�ł̃G�l���M�[�̕ω���
!
        DO I=1,NMAX
          WORK(I) 
     1      = (    CAP_LAI_c 
     1           + CAP_WTR_c * FR_WTR_CNP_SNW_NEXT (I) 
     1                       * RHO_WTR_c * H2O_SAT_CNP_DEP_c 
     1           + CAP_GLA_c * FR_GLA_CNP_SNW_NEXT (I) 
     1                       * RHO_WTR_c * H2O_SAT_CNP_DEP_c 
     1        )
     1         * ADD_LAI_CNP_SNW(I) 
     1         * ( TMP_CNP_SNW_NEXT(I) - TMP_FREZ_c )
     1        - HL_W2G_c * FR_GLA_CNP_SNW_NEXT (I) 
     1                   * RHO_WTR_c * H2O_SAT_CNP_DEP_c 
     1                   * ADD_LAI_CNP_SNW(I) 
        ENDDO
        CMARK = 'EADSS' 
        CALL MONIT_SIB ( CMARK , WORK , INA , ONE , ONE )  
!
!  �ᖳ���L���m�s�[�ł̃G�l���M�[�̕ω���
!
        DO I=1,NMAX
          WORK(I) 
     1      = (    CAP_LAI_c 
     1           + CAP_WTR_c * FR_WTR_CNP_NOS_NEXT (I) 
     1                       * RHO_WTR_c * H2O_SAT_CNP_DEP_c 
     1           + CAP_GLA_c * FR_GLA_CNP_NOS_NEXT (I) 
     1                       * RHO_WTR_c * H2O_SAT_CNP_DEP_c 
     1        )
     1         * ADD_LAI_CNP_NOS(I) 
     1         * ( TMP_CNP_NOS_NEXT(I) - TMP_FREZ_c )
     1        - HL_W2G_c * FR_GLA_CNP_NOS_NEXT (I) 
     1                   * RHO_WTR_c * H2O_SAT_CNP_DEP_c 
     1                   * ADD_LAI_CNP_NOS(I) 
        ENDDO
        CMARK = 'EADNS' 
        CALL MONIT_SIB ( CMARK , WORK , INA , ONE , ONE )  
!
!  ��X�L���ł̃G�l���M�[�̕ω���
!    ( �Ⴀ��悪�����邱�Ƃɂ��A��X�L���ʂ��ω����邱�Ƃɂ��A
!      �Ⴀ���̃G�l���M�[�ω��� ) 
! 
        DO I=1,NMAX
          WORK(I) 
     1      =  CAP_SNSK_c 
     1         * ( CVR_SNW_NEXT (I) - CVR_SNW(I) )
     1         * ( TMP_SNSK_NEXT(I) - TMP_FREZ_c )
        ENDDO
        CMARK = 'EADWS' 
        CALL MONIT_SIB ( CMARK , WORK , INA , ONE , ONE )  
!
!  �ᖳ���n�ʁE�����ł̃G�l���M�[�̕ω���
!    ( �ᖳ���悪�����邱�Ƃɂ��A�y��X�L���������ω����邱�Ƃɂ��A
!      �ᖳ����̃G�l���M�[�ω��� ) 
! 
        DO I=1,NMAX
          WORK(I) 
     1      = - CAP_GRSK_c * ( CVR_SNW_NEXT(I) - CVR_SNW(I) )
     1                      * ( TMP_GRSK_NEXT(I) - TMP_FREZ_c ) 
     1        + (    
     1           + CAP_LAI_c 
     1           + CAP_WTR_c * FR_WTR_GRS_NEXT (I) 
     1                       * RHO_WTR_c * H2O_SAT_GRS_DEP_c 
     1           + CAP_GLA_c * FR_GLA_GRS_NEXT (I) 
     1                       * RHO_WTR_c * H2O_SAT_GRS_DEP_c 
     1          )
     1           * ADD_LAI_GRS(I) 
     1           * ( TMP_GRSK_NEXT(I) - TMP_FREZ_c )
     1        - HL_W2G_c * FR_GLA_GRS_NEXT (I) 
     1                   * RHO_WTR_c * H2O_SAT_GRS_DEP_c 
     1                   * ADD_LAI_GRS(I) 
        ENDDO

        CMARK = 'EADGS' 
        CALL MONIT_SIB ( CMARK , WORK , INA , ONE , ONE )  
!
      ENDIF
#endif
!       
      RETURN
      END
!==================================================================
      SUBROUTINE MR_SNOWMOD_MAIN
!
#ifdef MONYOS
      USE SIB_MONIT , ONLY : 
     1                       IMONIT_LEVEL , IMONIT_ALL
#endif
!
! SNOWMOD_MAIN �ŏo�͂���f�o�b�O�p�ϐ��̓o�^���
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
        WRITE(6,*) 'MONIT_REGIST_SNOWMOD_MAIN 99/10 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
! ---------------------------------------------------------
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
      CMARK  = 'WADSS' 
      CTITLE = 'H2O ADD ON SNW-CANOPY BY CVRSNW CHANGE'
      CUNIT  = 'KG/S/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WADNS' 
      CTITLE = 'H2O ADD ON NOS-CANOPY BY CVRSNW CHANGE'
      CUNIT  = 'KG/S/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )

      CMARK  = 'WADGS' 
      CTITLE = 'H2O ADD ON GRASS BY CVRSNW CHANGE'
      CUNIT  = 'KG/S/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'EADSS' 
      CTITLE = 'ENERGY WITH H2O ADD ON SNW-CANOPY BY CVRSNW CHANGE'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'EADNS' 
      CTITLE = 'ENERGY WITH H2O ADD ON NO-CANOPY BY CVRSNW CHANGE'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'EADWS' 
      CTITLE = 'ENERGY ADD OF SNOW SKIN BY CVRSNW CHANGE'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'EADGS' 
      CTITLE = 'ENERGY WITH H2O ADD ON GRASS BY CVRSNW CHANGE'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
#endif
!
      RETURN
      END