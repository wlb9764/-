! ���ʃA���x�h�̌v�Z
! 99/07/21 �ۍ␪�G
! 99/07/23 �ۍ␪�G  ��ł̋z���䗦�v�Z�폜
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE ALBEDO_MAIN  (
     I   NMAX          , NMAX_01       , 
     I   NTYP          , MON           , 
     I   CVR_SNW_FOR_ALBEDO , 
     I   FR_GLA_CNP_NOS                , FR_GLA_CNP_SNW         , 
     I   TMP_CNP_NOS   , TMP_CNP_SNW   , TMP_SNSK      , 
     I   DEP_SNOW      , AGE_SNOW      , ZMEAN          ,        
     I   CVR_SNW       , CVR_VEG_ms    , 
     I   ZLT_NOS       , ZLT_SNW       , 
     M   ALB_SNOW_SNW  , RAIN_1HOUR     ,    
     O   EXTK_NOS      , ABSORB_SHRT_NOS  , 
     O   REACH_GRD_NOS, 
     O   EXTK_SNW      , ABSORB_SHRT_SNW  , 
     O   REACH_GRD_SNW , 
     O   ALB_SIB_SIBMEAN )
!
      USE SIBPRM , ONLY :
     1     IDX  , 
     1     ISN  , 
     1     ICG  , 
     1     IWV  ,      ! 3 
     1     IVN  ,      ! 2 
     1     IBD  , 
     1     IDP  
!
      USE SIBVEG , ONLY : 
     1         REF_SOIL_co                   ! ���n�A���x�h (ITYP,IWV)   
!
      USE COM_STEP_SIB0109, only :
     1    SCN_SIB0109_DELT_SR   
!
      USE SIB_MONIT , ONLY : 
     1    MONIT_SIB, ICN, ICS, INA ,
     1    IMONIT_LEVEL   , 
     1    IMONIT_ALL 
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)   :: NMAX  
      INTEGER,INTENT(IN)   :: NMAX_01(3)
      INTEGER,INTENT(IN)   :: NTYP (IDX)   
      INTEGER,INTENT(IN)   :: MON                 ! ��
      REAL(8),INTENT(IN)   :: FR_GLA_CNP_NOS(IDX) ! �L���m�s�[��̕X�̊���
      REAL(8),INTENT(IN)   :: FR_GLA_CNP_SNW(IDX) ! �L���m�s�[��̕X�̊���
      REAL(8),INTENT(IN)   :: TMP_CNP_NOS  (IDX)  ! �ᖳ���L���m�s�[���x
      REAL(8),INTENT(IN)   :: TMP_CNP_SNW  (IDX)  ! �Ⴀ��L���m�s�[���x
      REAL(8),INTENT(IN)   :: TMP_SNSK     (IDX)  ! ��ʉ��x
      REAL(8),INTENT(IN)   :: ZMEAN        (IDX) ! ���˓V���p
      REAL(8),INTENT(INOUT):: AGE_SNOW  (IDX)     ! ��̔N��
      REAL(8),INTENT(IN)   :: DEP_SNOW  (IDX)     ! ��̐[�� m 
!
      REAL(8),INTENT(IN)   :: CVR_SNW   (IDX)     ! �ϐ�핢��
      REAL(8),intent(in)   :: ZLT_NOS   (IDX,ICG)           ! �t�ʐώw��
      REAL(8),intent(in)   :: ZLT_SNW   (IDX,ICG)           ! �t�ʐώw��
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)  :: 
     1     EXTK_NOS       (IDX,ICG,IVN,IBD)     , ! ���U�W�� 
     1     ABSORB_SHRT_NOS(IDX,ICG,IVN,IBD)     , ! �����Z�g�z����
     1     REACH_GRD_NOS  (IDX,IBD)               ! �n�ʓ��B��
!
      REAL(8),INTENT(OUT)  :: 
     1     EXTK_SNW       (IDX,ICG,IVN,IBD)     , ! ���U�W�� 
     1     ABSORB_SHRT_SNW(IDX,ICG,IVN,IBD)     , ! �����Z�g�z����
     1     REACH_GRD_SNW  (IDX,IBD)                ! �n�ʓ��B��

!
      REAL(8) :: 
     1     ALB_SIB_SNW    (IDX,    IVN,IBD)     , ! �A���x�h
     1     ALB_SIB_NOS    (IDX,    IVN,IBD)       ! �A���x�h
!
      REAL(8),INTENT(OUT)  :: 
     1     ALB_SIB_SIBMEAN   (IDX,IVN,IBD)        ! ���σA���x�h
!
      REAL(8),INTENT(IN) :: CVR_VEG_ms ( IDX , ICG )    ! �A���핢��
!
      REAL(8),INTENT(IN) :: CVR_SNW_FOR_ALBEDO ( IDX )   
!
! WORK
!
      REAL(8) :: ZERO_IDX   ( IDX )          ! �_�~�[�B�l�̓[���B
      REAL(8) :: ALB_GRSK   ( IDX , IVN )    ! �ᖳ���y��\�ʃA���x�h
!
      REAL(8) :: ALB_SNOW_onCNP_NOS (IDX,IVN)         
      REAL(8) :: ALB_SNOW_onCNP_SNW (IDX,IVN)         
      REAL(8) :: ALB_SNOW_NOS       (IDX,IVN)         
      REAL(8),intent(inout) :: ALB_SNOW_SNW       (IDX,IVN)         
      REAL(8),intent(inout) :: RAIN_1HOUR         (IDX)         
!
      INTEGER :: JVN
      INTEGER :: JBD
      INTEGER :: I 
!
#ifdef MONYOS
      REAL(8) :: CVR_NOS            (IDX)         
      CHARACTER(7)      :: CMARK 
      REAL(8),PARAMETER :: ONE = 1.D0 
#endif
!
      LOGICAL LFIRST
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'ALBEDO_MAIN 99/07 POCHAKA '
        LFIRST = .FALSE.
      ENDIF 
!
!  ===================
!  >> SIBVEG �̓W�J <<
!  ===================
!
!     CALL ALBEDO_EXTEND (
!    I   NMAX      , 
!    I   NTYP      , MON       , 
!    O   CVR_VEG_ms )
!
!  ==================
!  >> ��̃A���x�h <<
!  ==================
!      ��ʁA�L���m�s�[��̐�Ƃ�
!
!   ( �ᖳ����ł̃A���x�h���]�����邱��!!! )
!
        CALL ALBEDO_SNOW (  
     I    NMAX        , 
     I    NMAX_01     , 
     I    NTYP        , 
     I    TMP_SNSK    , AGE_SNOW    , 
     I    TMP_CNP_SNW , TMP_CNP_NOS , 
     I    RAIN_1HOUR  ,  
     M    ALB_SNOW_SNW, ALB_SNOW_NOS, 
     M    ALB_SNOW_onCNP_SNW        , ALB_SNOW_onCNP_NOS      )  
!
!  ==============
!  >> �ᖳ���� <<
!  ==============
!
      CALL RESET ( ZERO_IDX , IDX ) 
!
! �y��A���x�h�̐ݒ�
!
      DO JVN=1,IVN
      DO I=1,NMAX_01(3)
        ALB_GRSK (I,JVN) =   REF_SOIL_co(NTYP(I),JVN) 
     1                        * ( 1- CVR_SNW_FOR_ALBEDO(I) )  !
     1                     + ALB_SNOW_NOS (I,JVN)                 !
     1                        *  CVR_SNW_FOR_ALBEDO(I)        !
      ENDDO
      ENDDO
!
! �A���x�h�v�Z
!
      alb_sib_nos(:,:,:) = 0                         ! ������
      CALL ALBEDO_SIB  ( 
     I   MON         , 
     I   1           , NMAX_01(3) , 0          , 
     I   ALB_SNOW_onCNP_NOS       , FR_GLA_CNP_NOS        , 
     I   ALB_GRSK    , NTYP       ,  
     I   CVR_VEG_ms  ,  
     I   ZERO_IDX    , ZMEAN       , ZLT_NOS , 
     O   EXTK_NOS    , ABSORB_SHRT_NOS    , 
     O   REACH_GRD_NOS           , ALB_SIB_NOS    )
!
!  ==============
!  >> �Ⴀ��� <<
!  ==============
!
! �A���x�h
!
      alb_sib_snw(:,:,:) = 0                          ! ������
!
      CALL ALBEDO_SIB  ( 
     I   MON         , 
     I   NMAX_01(2)  , NMAX       , 1              , 
     I   ALB_SNOW_onCNP_SNW       , FR_GLA_CNP_SNW , 
     I   ALB_SNOW_SNW, NTYP       ,  
     I   CVR_VEG_ms  ,  
     I   DEP_SNOW    , ZMEAN       , ZLT_SNW , 
     O   EXTK_SNW    , ABSORB_SHRT_SNW  , 
     O   REACH_GRD_SNW             , ALB_SIB_SNW    )
!
!  ==============
!  >> ���ϑ��� << 
!  ==============
!
      DO 5000 JBD = 1,IBD 
      DO 5000 JVN = 1,IVN
      DO 5000 I   = 1,NMAX 
         ALB_SIB_SIBMEAN (I,JVN,JBD) 
     1      =    ALB_SIB_NOS (I,JVN,JBD)  * ( 1 - CVR_SNW(I) )
     1         + ALB_SIB_SNW (I,JVN,JBD)  * CVR_SNW(I) 

 5000 CONTINUE   
!
      RAIN_1HOUR(:) = 0. 
!
!  ================
!  >> �ڍ׃��j�^ << 
!  ================
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN  
!
! ��̔핢��
!
        CMARK = 'CVRSNWR' 
        CALL MONIT_SIB ( CMARK , CVR_SNW , 
     1                   INA    , SCN_SIB0109_DELT_SR, ONE )
!
        DO I=1,NMAX     
          CVR_NOS(I) = 1.D0 - CVR_SNW(I) 
        ENDDO
!
        CMARK = 'CVRNOSR' 
        CALL MONIT_SIB ( CMARK , CVR_NOS , 
     1                   INA   , SCN_SIB0109_DELT_SR, ONE )
!
! �A���x�h
!
!   ���E���B   
        CMARK = 'ALBVBR' 
        CALL MONIT_SIB ( CMARK , ALB_SIB_SIBMEAN (1,1,1)  , 
     1                   INA   , SCN_SIB0109_DELT_SR, ONE )
!
!   �ߐԁE���B   
        CMARK = 'ALBNBR' 
        CALL MONIT_SIB ( CMARK , ALB_SIB_SIBMEAN (1,2,1)  , 
     1                   INA   , SCN_SIB0109_DELT_SR, ONE )
!
!   ���E�U��
        CMARK = 'ALBVDR' 
        CALL MONIT_SIB ( CMARK , ALB_SIB_SIBMEAN (1,1,2)  , 
     1                   INA   , SCN_SIB0109_DELT_SR, ONE )
!
!   �ߐԁE�U��
        CMARK = 'ALBNDR' 
        CALL MONIT_SIB ( CMARK , ALB_SIB_SIBMEAN (1,2,2)  , 
     1                   INA   , SCN_SIB0109_DELT_SR, ONE )
!
! ��̃A���x�h
!
!   ��
        CMARK = 'ALBWVR' 
        CALL MONIT_SIB ( CMARK , ALB_SNOW_SNW (1,1)  , 
     1                   ICS   , SCN_SIB0109_DELT_SR, ONE )
!
!   �ߐ�
        CMARK = 'ALBWNR' 
        CALL MONIT_SIB ( CMARK , ALB_SNOW_SNW (1,2)  , 
     1                   ICS   , SCN_SIB0109_DELT_SR, ONE )
!
      ENDIF
#endif
!
      RETURN
      END
!=======================================================
      SUBROUTINE ALBEDO_EXTEND (
     I   NMAX      , 
     I   NTYP      , MON       , 
     O   CVR_VEG_ms )
!
! �W�J����
!
      USE SIBPRM , ONLY :
     1   IDX    ,
     1   ICG  
!
      USE SIBVEG , ONLY :
     1           CVR_VEG_mo                ! �핢�� (ITYP,IMON,ICG)
!
      IMPLICIT NONE
!
      INTEGER,INTENT(IN)   :: NMAX         ! ���i�q��
      INTEGER,INTENT(IN)   :: NTYP (IDX)  ! �A���^�C�v
      INTEGER,INTENT(IN)   :: MON          ! ��
!
      REAL(8),INTENT(OUT)  :: CVR_VEG_ms(IDX,ICG) 
!
! WORK  
!
      INTEGER :: I
      INTEGER :: IVEG
!
      LOGICAl,SAVE :: LFIRST 
!
      DATA LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'ALBEDO EXTEND 99/07 POCHAKA'
        LFIRST = .FALSE. 
      ELSE
        WRITE(6,*) 'ALBEDO EXTEND HAS ALREADY CALLED'
        STOP 999
      ENDIF
!
      DO 1000 IVEG=1,ICG
      DO 1000 I=1,NMAX
        CVR_VEG_ms(I,IVEG) = CVR_VEG_mo(NTYP(I),MON,IVEG)
 1000 CONTINUE
!
#ifdef SIB_DEBUG 
      write(6,*) mon , ntyp(1), nmax
      WRITE(6,*) 'ALBEDO EXTEND ' , cvr_veg_ms 
!     WRITE(6,*) 'ALBEDO EXTEND ' , cvr_veg_mo 
#endif
!
      RETURN
      END
!==============================================================
      SUBROUTINE MR_ALBEDO_MAIN 
!
      USE SIB_MONIT , ONLY : 
     1     IMONIT_LEVEL    , 
     1     IMONIT_ALL
!
      IMPLICIT NONE
!
      CHARACTER( 7)  :: CMARK 
      CHARACTER(32)  :: CTITLE 
      CHARACTER(13)  :: CUNIT
!
      LOGICAL,SAVE ::  LFIRST 
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'MONIT_REGIST_ALBEDO_MAIN 00/10 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN 
!
!   ��̔핢��
!
      CMARK  = 'CVRSNWR' 
      CTITLE = 'SNOW COVER ( RADIATION CALC MEAN )' 
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'CVRNOSR' 
      CTITLE = '1- SNOW COVER ( RADIATION CALC MEAN )' 
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ���E���B   
!
      CMARK  = 'ALBVBR' 
      CTITLE = 'ALBEDO VISIBLE BEEM'
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   �ߐԁE���B   
!
      CMARK  = 'ALBNBR' 
      CTITLE = 'ALBEDO NIER IR BEEM'
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ���E�U��
!
      CMARK  = 'ALBVDR' 
      CTITLE = 'ALBEDO VISIBLE DIFFUSE'
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   �ߐԁE�U��
!
      CMARK  = 'ALBNDR' 
      CTITLE = 'ALBEDO NEAR IR DIFFUSE'
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ��ʂ̃A���x�h�A��
!
      CMARK  = 'ALBWVR' 
      CTITLE = 'ALBEDO SNOW SFC VISIBLE'
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ��ʂ̃A���x�h�A�ߐ�
!
      CMARK  = 'ALBWNR' 
      CTITLE = 'ALBEDO SNOW SFC NEAR IR'
      CUNIT  = '0-1'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
      RETURN
      END
