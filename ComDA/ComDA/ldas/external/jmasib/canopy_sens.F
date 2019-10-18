! ���M�t���b�N�X�v�Z
! 
! 99/06/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE CANOPY_SENS (
     I  NSTR        , NEND          ,
     I  ITR         , ITR_MAX       , 
#ifdef MONYOS
     I  DELT_CNP    , INSFLAG       , 
#endif 
     I  R_AIR_INV   , R_AC_BAR_INV  , R_AG_INV     , R_SUM_INV , 
     I  RHO_CP      , FAC_CORTMP    , 
     I  TMP_CNP     , TMP_SKIN      , TMP_AIR     , 
!    I  FLAG_TMPMOD_CNP   , FLAG_TMPMOD_SKIN    ,  
     o  dta_dtc , dta_dtg , dta_dtr ,
     O  SENS        , 
     O  DSENS_DX    ) 
!
! ���M�p�̌W������сA�z�ɕ]���������M
!
! ����
!   �E�n�ʂƐ�ʂ̌��M�ɂ́A(1-Cs) �� Cs �Ƃ������Ă��Ȃ��B
!
!   �E�L���E�L����Ԃ̊Ԃ̒�R ( 1/r_ac_bar_inv ) �́A
!     ���M�v�Z���ɂ� /2 ���Ďg�p�B
!     �t�̗��ʂ��猰�M�͏o�邩��B
!
!   �E�t���b�N�X����т��̉��x�Ȃǔ����͂�������������� ( AIR -> CNP or GRD )
!
      USE SIBPRM , ONLY : 
     1    IDX     , 
     1    ICG     , 
     1    ICGR
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY: MONIT_SIB, ICN,ICS,INN,INS,
     1     IMONIT_LEVEL    , 
     1     IMONIT_ALL      , IMONIT_ALMA 
#endif
!
      IMPLICIT NONE 
!
! INPUT 
! 
      REAL(8),INTENT(IN)    :: R_AIR_INV(IDX)  ! 1/r_air       (=1/ra)
      REAL(8),INTENT(IN)    :: R_AC_BAR_INV (IDX)  ! 1/r_acs   (=1/rb)
      REAL(8),INTENT(IN)    :: R_AG_INV (IDX)  ! 1/r_ag        (=1/rd) 
      REAL(8),INTENT(IN)    :: R_SUM_INV(IDX)  ! 1/r_ag        (=1/rd) 
      REAL(8),INTENT(IN)    :: RHO_CP     (IDX)  ! RCP
      REAL(8),INTENT(IN)    :: FAC_CORTMP (IDX)  ! BPS,TMP_REF �̋C���␳
      REAL(8),INTENT(IN)    :: TMP_CNP   (IDX) 
      REAL(8),INTENT(IN)    :: TMP_SKIN   (IDX)   ! �X�L�����x
      REAL(8),INTENT(IN)    :: TMP_AIR   (IDX) 
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
      INTEGER,INTENT(IN)    :: ITR
      INTEGER,INTENT(IN)    :: ITR_MAX
!
!     REAL(8),INTENT(IN)    :: FLAG_TMPMOD_CNP  (IDX)  ! �L�����ω��� 0 �ʏ� 1 
!     REAL(8),INTENT(IN)    :: FLAG_TMPMOD_SKIN (IDX)  ! �n�ʑ��ω��� 0 �ʏ� 1
!
#ifdef MONYOS
      REAL(8),INTENT(IN)    :: DELT_CNP 
      INTEGER,INTENT(IN)    :: INSFLAG             ! �ᖳ�� 0 ����  1
#endif     
!
! OUTPUT 
!
      REAL(8),INTENT(OUT)   :: SENS     (IDX,ICG)       ! ���MFLUX�A��������
      REAL(8),INTENT(OUT)   :: DSENS_DX (IDX,ICG,ICGR)     
!
! WORK 
!
      REAL(8),intent(out)   :: DTA_DTC (IDX) 
      REAL(8),intent(out)   :: DTA_DTG (IDX) 
      REAL(8),intent(out)   :: DTA_DTR (IDX) 
      REAL(8)               :: FAC
      INTEGER               :: I
!
#ifdef MONYOS
      REAL(8),PARAMETER :: ONE = 1. 
      CHARACTER(7)      :: CMARK 
      real(8) :: work(idx) 
#endif
!
      LOGICAL,SAVE :: LFIRST
      DATA  LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_SENS 99/07 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      DO 1000 I=NSTR,NEND
!
! ���M�̕]�� �i ����܂łƈႢ�A���ԏd�݂������Ȃ��t���b�N�X�ł��邱�Ƃɒ��� )
!
        SENS(I,1) = RHO_CP(I) * ( TMP_AIR(I) - TMP_CNP(I) ) 
     1              * R_AC_BAR_INV(I) 
     1              * 2                           ! ��R�������Ȃ̂�  
!
        SENS(I,2) = RHO_CP(I) * ( TMP_AIR(I) - TMP_SKIN(I) )
     1              * R_AG_INV(I)                 ! CVR �����ĂȂ�
                                                  ! �t�����n����ʂƍl����
!
! ���M�֘A�̌W��  ( HxDTy .. �P�� Ty �ω��ŁAx �̂��炤���M�����銄�� )
!       ������ĂȂɁH �z���g�ɉ��x���ς�銄���H�H�H
!
        FAC = R_SUM_INV(I)
!
        DTA_DTC(I)  =  FAC * R_AC_BAR_INV (I)
!    1                     * FLAG_TMPMOD_CNP  (I)
     1                     * 2                    ! ��R�������Ȃ̂�  
!
        DTA_DTG(I)  =  FAC * R_AG_INV (I)      
!    1                     * FLAG_TMPMOD_SKIN  (I)
!
        DTA_DTR(I)  =  FAC * R_AIR_INV(I) * FAC_CORTMP (I)
!
! DSENS(IDX,ICG,ICGR)
!
        DSENS_DX(I,1,1) 
     1      = R_AC_BAR_INV(I) * RHO_CP(I)
     1         * ( DTA_DTC(I) - 1 )
!    1         * FLAG_TMPMOD_CNP(I) 
     1         * 2                                          ! ��R������
!
        DSENS_DX(I,1,2) 
     1      = R_AC_BAR_INV(I) * RHO_CP(I) * DTA_DTG(I) 
     1         * 2                                          ! ��R������
        DSENS_DX(I,1,3) 
     1      = R_AC_BAR_INV(I) * RHO_CP(I) * DTA_DTR(I) 
     1         * 2                                          ! ��R������
!
        DSENS_DX(I,2,1) 
     1      = R_AG_INV(I) * RHO_CP(I) * DTA_DTC(I) 
!
        DSENS_DX(I,2,2) 
     1      = R_AG_INV(I) * RHO_CP(I) 
     1          * ( DTA_DTG(I) - 1 ) 
!    1          * FLAG_TMPMOD_SKIN (I) 
!
        DSENS_DX(I,2,3) 
     1      = R_AG_INV(I) * RHO_CP(I) * DTA_DTR(I) 
!
 1000 CONTINUE
!
#ifdef KILLSENS
      call reset ( sens , idx*icg )          
      call reset ( dsens_dx , idx*icg*icgr ) 
#endif
!
! ================
! >> �ڍ׃��j�^ <<
! ================
! 
#ifdef MONYOS
      IF ( ITR.EQ.ITR_MAX) THEN
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
!   ���ӁB�Ⴀ���E������̖ʐς����݂� INSFLAG �ŁB
!
        IF ( INSFLAG.EQ.0) THEN
          CMARK  = 'HSNN0'                     
          CALL MONIT_SIB ( CMARK , SENS(1,1) ,ICN, DELT_CNP , ONE )
          CMARK  = 'HSNG0'                      
          CALL MONIT_SIB ( CMARK , SENS(1,2) ,ICN, DELT_CNP , ONE )
          CMARK  = 'TMPAIRN'                      
          CALL MONIT_SIB ( CMARK , TMP_AIR   ,INN, DELT_CNP , ONE )
        ELSE
          CMARK  = 'HSNS0'                     
          CALL MONIT_SIB ( CMARK , SENS(1,1) ,ICS, DELT_CNP , ONE )
          CMARK  = 'HSNW0'                      
          CALL MONIT_SIB ( CMARK , SENS(1,2) ,ICS, DELT_CNP , ONE )
          CMARK  = 'TMPAIRS'                      
          CALL MONIT_SIB ( CMARK , TMP_AIR   ,INS, DELT_CNP , ONE )
        ENDIF

      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALMA ) THEN
        CMARK = 'A_ACOND' 
        WORK(:) = 0. 
        IF ( INSFLAG.EQ.0) THEN
          DO I=NSTR,NEND
            WORK(:) = 1./R_SUM_INV(I) 
          ENDDO       
          call MONIT_SIB ( CMARK , WORK ,ICN, DELT_CNP , ONE )          
        ELSEIF ( INSFLAG.EQ.1) THEN
          DO I=NSTR,NEND
            WORK(:) = 1./R_SUM_INV(I) 
          ENDDO       
          call MONIT_SIB ( CMARK , WORK ,ICS, DELT_CNP , ONE )          
        ENDIF
      ENDIF 
!
      ENDIF
#endif
!
      RETURN
      END
!=========================================================
      SUBROUTINE MR_CANOPY_SENS
!
#ifdef MONYOS
      USE SIB_MONIT, ONLY : 
     1     IMONIT_LEVEL    , 
     1     IMONIT_ALL      , IMONIT_ALMA
#endif
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
        WRITE(6,*) 'MONIT_REGIST_CANOPY_SENS 99/08 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
#ifdef MONYOS
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
! CNP �ł̏����� SENSCNP 
!
      CMARK  = 'HSNN0'
      CTITLE = 'CANOPY SENSIBLE HEAT NOS explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'HSNS0'
      CTITLE = 'CANOPY SENSIBLE HEAT SNW explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! �����E���n �ł̌��M
!
      CMARK  = 'HSNG0'
      CTITLE = 'GROUND SENSIBLE HEAT explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! ��ł̌��M
!
      CMARK  = 'HSNW0'
      CTITLE = 'SNOW SENSIBLE HEAT explicit'
      CUNIT  = 'W/M**2'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!---------------------------------------------------------------
!
! TMP_AIR 
!
      CMARK  = 'TMPAIRN'
      CTITLE = 'TMP AIR NOS (NOT GRID MEAN)'
      CUNIT  = 'K'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'TMPAIRS'
      CTITLE = 'TMP AIR SNW (NOT GRID MEAN)'
      CUNIT  = 'K'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALMA ) THEN
        CMARK  = 'A_ACOND'
        CTITLE = 'ALMA : Maybe Acond'
        CUNIT  = 'm/s'
        CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
      ENDIF 

#endif
!
      RETURN
      END
