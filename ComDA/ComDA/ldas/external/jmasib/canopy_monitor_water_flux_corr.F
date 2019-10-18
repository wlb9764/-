! CANOPY �̃t���b�N�X���ʂ̃��j�^�B
!    evap, subl �̃��j�^�B���E�X�ړ��ʂ̂�
!    corr ��Ɏg���B
!
! ���ӁBtrns �� trns_div �ōs�Ȃ����߁A�����ɂ͂Ȃ��B
!
      SUBROUTINE CANOPY_MNT_WATER_FLUX_CORR (
     I    DELT_CNP , 
     I    INSFLAG  , 
     I    EVAP     , SUBL     , TRNS )
!
! �A�I�␳����̐��֘A�t���b�N�X�̃��j�^�[�B
! ���܂̂Ƃ���s�v�ł�?
!
      USE SIBPRM , ONLY : IDX , ICG , ICGB 
!
      USE SIBCON , ONLY :
     1   HL_WTR_c , 
     1   HL_W2G_c 
!
      USE SIB_MONIT , ONLY : MONIT_SIB, ICN, ICS,
     1                       IMONIT_LEVEL , IMONIT_ALL
!
      IMPLICIT NONE
!
      INTEGER,INTENT(IN)   :: INSFLAG 
      REAL(8),INTENT(IN)   :: DELT_CNP
!
      REAL(8),INTENT(IN)   :: EVAP (IDX,ICGB) 
      REAL(8),INTENT(IN)   :: SUBL (IDX,ICGB) 
      REAL(8),INTENT(IN)   :: TRNS (IDX,ICG ) 
!
      CHARACTER(1)      :: CFLAG_NS_C1 
      CHARACTER(1)      :: CFLAG_NS_G1
!
      CHARACTER(7)      :: CMARK 
      REAL(8),PARAMETER :: ONE = 1.D0 
      INTEGER           :: IFLG_MON
!
      IF ( INSFLAG .EQ.0 ) THEN
        CFLAG_NS_C1 ='N'
        CFLAG_NS_G1 ='G'
        IFLG_MON    = ICN
      ELSE
        CFLAG_NS_C1 ='S'
        CFLAG_NS_G1 ='W'
        IFLG_MON    = ICS
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
! ==========
! >> ���� <<
! ==========
!
! �L���m�s�[
!
      CMARK  = 'WEVxC'
      CMARK(4:4) = CFLAG_NS_C1 
      CALL MONIT_SIB ( CMARK, EVAP(1,1) , IFLG_MON, DELT_CNP, ONE)   
!
! ����
!
      IF ( INSFLAG .EQ. 0 ) THEN
      CMARK  = 'WEVGC'
      CALL MONIT_SIB ( CMARK, EVAP(1,2) , IFLG_MON, DELT_CNP, ONE)   
      ENDIF
!
! ���n�E��
!
      CMARK  = 'WEVxC'
      CMARK(4:4) = CFLAG_NS_G1 
      CALL MONIT_SIB ( CMARK, EVAP(1,3) , IFLG_MON, DELT_CNP, ONE)   
!
! ==========
! >> ���� <<
! ==========
!
! �L���m�s�[
!
      CMARK  = 'GSLxC'
      CMARK(4:4) = CFLAG_NS_C1 
      CALL MONIT_SIB ( CMARK, SUBL(1,1) , IFLG_MON, DELT_CNP, ONE)   
!
! ����
!
      IF ( INSFLAG .EQ. 0 ) THEN
      CMARK  = 'GSLGC'
      CALL MONIT_SIB ( CMARK, SUBL(1,2) , IFLG_MON, DELT_CNP, ONE)   
      ENDIF
!
! ���n�E��
!
      CMARK  = 'GSLxC'
      CMARK(4:4) = CFLAG_NS_G1 
      CALL MONIT_SIB ( CMARK, SUBL(1,3) , IFLG_MON , DELT_CNP, ONE)   
!
! ==========
! >> ���U <<
! ==========
!
! �L���m�s�[
!
      CMARK  = 'WTRBxLF'
      CMARK(5:5) = CFLAG_NS_C1 
      CALL MONIT_SIB ( CMARK, TRNS(1,1) , IFLG_MON, DELT_CNP, ONE)   
!
! ����
!
      IF ( INSFLAG .EQ. 0 ) THEN
      CMARK  = 'WTRBGLF'
      CALL MONIT_SIB ( CMARK, TRNS(1,2) , IFLG_MON, DELT_CNP, ONE)   
      ENDIF
!
      ENDIF
!
      RETURN
      END 
!
!=========================================================
      SUBROUTINE MR_CANOPY_WATER_FLUX_CORR  
!    
      USE SIB_MONIT , ONLY : 
     1                       IMONIT_LEVEL , IMONIT_ALL
 
!
! �f�o�b�O�p�ϐ��̓o�^���
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
        WRITE(6,*) 'MONIT_REGIST_CANOPY_MONITOR_WATER_FLUX_CORR' , 
     1             ' 00/02 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      IF ( IMONIT_LEVEL .GE. IMONIT_ALL ) THEN
!
! --------
! > ���� < 
! --------
!
!  �L���m�s�[
!
      CMARK  = 'WEVNC'
      CTITLE = 'EVAP WTR CNP AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WEVSC'
      CTITLE = 'EVAP WTR CNP AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ����
!
      CMARK  = 'WEVGC'
      CTITLE = 'EVAP WTR GRS AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ���n�E��
!
      CMARK  = 'WEVLC'
      CTITLE = 'EVAP WTR BS AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WEVWC'
      CTITLE = 'EVAP WTR SNW CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! --------
! > ���� < 
! --------
!
!  �L���m�s�[
!
      CMARK  = 'GSLNC'
      CTITLE = 'SUBL GLA CNP AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'GSLSC'
      CTITLE = 'SUBL GLA CNP AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ����
!
      CMARK  = 'GSLGC'
      CTITLE = 'SUBL GLA GRS AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ���n�E��
!
      CMARK  = 'GSLLC'
      CTITLE = 'SUBL GLA BS AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'GSLWC'
      CTITLE = 'SUBL GLA SNW AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
! --------
! > ���U < 
! --------
!
!  �L���m�s�[
!
      CMARK  = 'WTRBNLF'
      CTITLE = 'TRANS WTR CNP NOS AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
      CMARK  = 'WTRBSLF'
      CTITLE = 'TRANS WTR CNP SNW AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!
!   ����
!
      CMARK  = 'WTRBGLF'
      CTITLE = 'TRANS WTR GRS AFTER CORRECT'
      CUNIT  = 'KG/M**2/S'
      CALL monit_regist_sib ( CMARK , CTITLE , CUNIT )
!    
      ENDIF
!
      RETURN
      END