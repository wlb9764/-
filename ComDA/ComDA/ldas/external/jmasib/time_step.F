      MODULE TS

      LOGICAL,SAVE      :: LFIRST
      DATA LFIRST / .TRUE. /

      contains

      SUBROUTINE TIME_STEP_RESET()
      
      LFIRST = .TRUE.

      END SUBROUTINE TIME_STEP_RESET

      SUBROUTINE TIME_STEP ( 
     I   DELT_MODEL, DUMMY_SCALAR, IDSTAR   , IDEND    , 
     M              FSEC0    , FSECP    , 
     M   KTM      , KT0      , KTP      , 
     M   ISTEP    ,
     M   IDATE    , ID_NEXT  , ID_NOW   , ID_PRE   , 
     M   RDAY     , RSEC     
#ifdef MONYOS
     M   , TOTMON 
#endif
     1   ) 
!
      USE COM_STEP , ONLY :
     O   ICNSW                     ,
     O   ICNIR                     ,
     O   ICNMNTMON                 , 
     O   ICNFST                    , 
     O   ICNLAST                   , 
     O   SCN_DELT                  ,
     O   SCN_2DELTX                 
!    O   SCNDTSW 
!
      USE COM_RUNCONF , ONLY :
     1   JCNIMNT      

      USE COM_RUNCONF_SIB0109 , ONLY :
     1   JCN_IWL_SKIP , 
     1   RCN_DELT_SOIL 
!
      USE CALENDAR , ONLY : 
     1     CALENDAR_RUN_GETKT ,
     1     CALENDAR_RUN_GETID
      USE MESSAGE
!
!
      IMPLICIT NONE 
!
      REAL(8),INTENT(IN)      :: DELT_MODEL
      REAL(8),INTENT(IN)      :: DUMMY_SCALAR
      INTEGER,INTENT(IN)      :: IDSTAR (5)
      INTEGER,INTENT(IN)      :: IDEND  (5)
!
      REAL(8),INTENT(INOUT)   :: FSEC0  
      REAL(8),INTENT(INOUT)   :: FSECP
      INTEGER,INTENT(INOUT)   :: IDATE  (5)
      INTEGER,INTENT(INOUT)   :: ID_NOW (5)
      INTEGER,INTENT(INOUT)   :: ID_PRE (5)
      INTEGER,INTENT(INOUT)   :: ID_NEXT(5)
      INTEGER,INTENT(INOUT)   :: KTM
      INTEGER,INTENT(INOUT)   :: KT0
      INTEGER,INTENT(INOUT)   :: KTP
      INTEGER,INTENT(INOUT)   :: ISTEP 
!
      REAL(8),INTENT(OUT)     :: RDAY   ! 1�N�ł̂��̓��̑��Έʒu       0-1
      REAL(8),INTENT(INOUT)   :: RSEC   ! 1���ł̂��̃X�e�b�v�̑��Έʒu 0-1
!

!
#ifdef MONYOS
      REAL(8),INTENT(INOUT)   :: TOTMON
#endif
!
      INTEGER   :: KT_LAG
      INTEGER   :: IS
      INTEGER   :: ID_WORK(5)
      INTEGER   :: ID_WORK_1 (5)
      INTEGER   :: ID_WORK_2 (5)
!
      REAL(8),SAVE      :: RDAY_TOT
      REAL(8),SAVE      :: RDAY_SAVE
      REAL(8),PARAMETER :: RSEC_TOT = 86400.D0
!
!
      IF ( LFIRST ) THEN
!        WRITE(6,*) 'TIME_STEP 99/11 POCHAKA' ,
!     1              dummy_scalar            ! only for avoid the ERROR MESSAGE
!
        KT_LAG = 0 
        CALL CALENDAR_RUN_GETID ( IDSTAR , ID_NEXT , KT_LAG )
        KT_LAG = -1 
        CALL CALENDAR_RUN_GETID ( IDSTAR , ID_NOW  , KT_LAG )
!
      ENDIF
!
! ���v�������߂�
!  
      FSEC0  = FSECP 
      KTM    = KT0 
      KT0    = KTP 
      FSECP  = FSECP + DELT_MODEL  
      KTP    = INT(FSECP + 1.) / 3600 
      ISTEP  = ISTEP + 1 
!
! �������������߂ɁA�����ɂȂ����Ƃ��ɂ͕b�𒼂�
!
      IF ( KT0 .NE. KTM ) THEN
        FSEC0 = INT ( FSEC0 + 0.1 ) / 3600 * 3600 
        FSECP = FSEC0 + DELT_MODEL  
!       FSECM = FSEC0 - DELT_MODEL                   ! ���͂���ł悢
      ENDIF
!
! ID_NOW ���̍X�V
!
      KT_LAG = 0 
      CALL CALENDAR_RUN_GETID ( ID_NOW  , ID_PRE , KT_LAG )
      CALL CALENDAR_RUN_GETID ( ID_NEXT , ID_NOW , KT_LAG )
      IF ( KTP .NE. KT0 ) THEN 
        KT_LAG = 1 
        ID_WORK(:) = ID_NEXT(:)
        CALL CALENDAR_RUN_GETID ( ID_WORK , ID_NEXT , KT_LAG )
      ENDIF   
!
! �Z�g���˗p�ARSEC RDAY 
!
      IF ( LFIRST .OR. ID_PRE(1).NE.ID_NOW(1) ) THEN  
!                                            ! �N���ς������ RDAY_TOT �ύX
        KT_LAG = 0 
        CALL CALENDAR_RUN_GETID ( ID_NOW , ID_WORK_1 , KT_LAG )
        ID_WORK_1(2) = 1 
        ID_WORK_1(3) = 1 
        ID_WORK_1(4) = 0 
        KT_LAG = 0 
        CALL CALENDAR_RUN_GETID ( ID_WORK_1 , ID_WORK_2 , KT_LAG )
!
        ID_WORK_2(1) = ID_WORK_1(1) + 1 
        CALL CALENDAR_RUN_GETKT ( ID_WORK_1 , ID_WORK_2 , 3 , KT_LAG )
        RDAY_TOT = KT_LAG * 1.D0 
      ENDIF
!
      IF ( LFIRST .OR. ID_PRE(3).NE.ID_NOW(3) ) THEN  
!                                            ! �����ς������ RDAY �ύX
        KT_LAG = 0 
        CALL CALENDAR_RUN_GETID ( ID_NOW , ID_WORK_1 , KT_LAG )
        ID_WORK_1(2) = 1 
        ID_WORK_1(3) = 1 
        ID_WORK_1(4) = 0 
        CALL CALENDAR_RUN_GETKT ( ID_WORK_1 , ID_NOW , 3 , KT_LAG )
        RDAY_SAVE = KT_LAG / RDAY_TOT
      ENDIF
      RDAY = RDAY_SAVE 
!
!#ifdef SIB_DEBUG
!      write(6,*) 'TIMESTEP ktm  ' , ktm , kt0 , ktp , fsecp  
!      write(6,*) 'TIMESTEP rday        ' , rday 
!#endif
!
      IF ( LFIRST ) THEN
        RSEC = ( FSEC0 - INT ( FSEC0 + 0.1 ) / 3600 * 3600  
     1         + ID_NOW(4) * 3600.D0                     ) / RSEC_TOT
!        write(6,*) 'TIMESTEP rsec1        ' , rsec
      ELSE 
!#ifdef SIB_DEBUG
!        write(6,*) 'TIMESTEP rsec2        ' , rsec
!#endif
        RSEC = RSEC + DELT_MODEL / RSEC_TOT
!#ifdef SIB_DEBUG
!        write(6,*) 'TIMESTEP rsec2        ' , rsec
!#endif
        IF ( KT0 .NE. KTM ) THEN
          CALL RSEC_CLEAN ( RSEC ) 
        ENDIF
      ENDIF
!
! �t���O�ݒ�
!
      IF     ( JCN_IWL_SKIP.EQ.1 .OR. JCN_IWL_SKIP.EQ.-1 ) THEN 
!       �Z�g���ˁE�y���Ƃ��A�S�X�e�b�v�v�Z
!
        ICNSW                  = 1         
        SCN_DELT               = delt_model
!
      ELSEIF ( JCN_IWL_SKIP.EQ.2 .OR. JCN_IWL_SKIP.EQ.-2) THEN 
!       ! ���ˌv�Z�ꎞ�Ԃ����A�y��͑S�X�e�b�v�v�Z
!
        IF ( KTM .NE. KT0 ) THEN      ! ������ 
          ICNSW  = 1         
        ELSE 
          ICNSW  = 0         
        ENDIF
!
        SCN_DELT               = delt_model
!
      ELSEIF ( JCN_IWL_SKIP.EQ.3 .OR. JCN_IWL_SKIP.EQ.-3 ) THEN  
!                                     ! ���˂ƃ��j�^�� 1 ���Ԃ���
!                                     ! �y��Ɛ���ƂтƂсB
!
        IF ( KTM .NE. KT0 ) THEN      ! ������ 
          ICNSW  = 1         
        ELSE 
          ICNSW  = 0         
        ENDIF
!
        SCN_DELT               = delt_model
      ELSE
        write(6,*) 'time_step error  jcn_iwl_skip ' , jcn_iwl_skip
        stop 999
      ENDIF

      SCN_2DELTX   = SCN_DELT   ! offline �p�B
                                ! delt_atm �� 2 �{�ɂ�������ł͂����ς���
!
      ICNIR = ICNSW 
!
!     SCNDTSW = 3600.D0         ! �Z�g���ԍ��A����͂���ł����B  
!
! ���j�^�t���O
!
      IF  ( JCN_IWL_SKIP >= 1 ) THEN 
        IF      ( JCNIMNT .LT.900 .AND. 
     1            KTP.NE.KT0 .AND. MOD(KTP,JCNIMNT).EQ.0 ) THEN
          ! ���������ŁA KTP ���������j�^�Ԋu�̔{���Ȃ�
	  ! �������j�^�o��
          ICNMNTMON   = 1
	ELSE IF ( JCNIMNT >= 900 .AND. ID_NOW(2) /= ID_NEXT(2) ) THEN
          ! �������j�^�Ԋu�����ɑ傫���l�ŁA���̃X�e�b�v�Ō����ς��Ȃ�
          ICNMNTMON   = 1
        ELSE 
          ICNMNTMON   = 0
        ENDIF
      ELSE 
        ICNMNTMON = 1 
      ENDIF
!
! �g�����j�^�p�A����
!
#ifdef MONYOS
      TOTMON = TOTMON + delt_model
#endif
!
!  IDATE �̍X�V
! 
      IF (       KT0.NE.KTM 
     1     .AND. ID_NOW(2).EQ.1                               ! 000728 
     1     .AND. ID_NOW(3).EQ.2 .AND. ID_NOW(4).EQ.0 ) THEN
!
        WRITE(6,*) 'TIME_STEP IDATE IS MODIFIED FROM ' , IDATE  
        KT_LAG = 0 
        CALL CALENDAR_RUN_GETID( ID_NOW , IDATE , KT_LAG )
        IDATE(3) = 1 
        WRITE(6,*) '                            TO   ' , IDATE  
!
        KTM = 23 
        KT0 = 24 
        KTP = KT0 + (DELT_MODEL+0.1) / 3600.D0 
!-------correction by POCHAKA 2000 5/31------------
        FSEC0 = 86400.0D0
        FSECP = FSEC0 + DELT_MODEL
      ENDIF
!
!#ifdef SIB_DEBUG 
!      IF ( ID_NOW(3) .NE. ID_PRE(3) ) THEN
!        WRITE(6,"(a,i4.4,2('-',i2.2),a)")
!     1    '--- NEW DAY ', ID_NOW(1:3), ' ---'
!      ENDIF
!#endif
      CALL MESSAGE_SETIDATE(ID_NOW)

!#ifdef SIB_DEBUG
!      WRITE(6,1000)  ISTEP,
!     1           ID_NOW ,
!     1           ICNSW  ,
!     1           ICNMNTMON
! 1000 FORMAT ('ISTEP=', i8, ' ID=', i4.4, 4('-', i2.2), ' ICNSW=',
!     ,  i4, ' IcnMntMon=', i4)
!#     endif
!
! ICNFST  ( mj98 �ɂ����� )
!
      IF ( LFIRST ) THEN 
        ICNFST = 1 
      ELSE 
        ICNFST = 0
      ENDIF 
!
! ICNLAST
!
      ICNLAST = 0
      IF ( 
     1                     ( IDEND(1) .EQ. ID_NEXT(1) )
     1               .AND. ( IDEND(2) .EQ. ID_NEXT(2) )
     1               .AND. ( IDEND(3) .EQ. ID_NEXT(3) )
     1               .AND. ( IDEND(4) .EQ. ID_NEXT(4) )
     1            ) THEN
        ICNLAST = 1
      ENDIF
!
      IF ( LFIRST ) THEN
        LFIRST = .FALSE. 
      ENDIF
!
      RETURN
      END SUBROUTINE TIME_STEP
!===============================================================
      SUBROUTINE RSEC_CLEAN ( RSEC )
!
!  RSEC ���ꎞ�Ԃ��Ƃɂ��ꂢ�ɂ���
!
      IMPLICIT NONE
!
      REAL(8),INTENT(INOUT) :: RSEC 
      REAL(8),PARAMETER     :: DSEC_MIN = 1.D-3
!
! �`�F�b�N
!   RSEC �� 3600./86400. �̔{���ɋɂ߂ċ߂����Ƃ��m�F  
!  
      IF (       INT ( RSEC*24 + DSEC_MIN +1. ) 
     1      .EQ. INT ( RSEC*24 - DSEC_MIN +1. ) ) THEN
        write(6,*) 'RSEC_CLEAN CHECK ERROR RSEC ' , RSEC , 
     1               RSEC*24 + DSEC_MIN , 
     1               RSEC*24 - DSEC_MIN ,
     1               INT(RSEC*24 + DSEC_MIN+1.) , 
     1               INT(RSEC*24 - DSEC_MIN+1.) 
        stop 999
      ENDIF
!
!  RSEC �� 1 �ȏ�Ȃ� 1 �������B
!
      IF ( RSEC .GT. 0.9999D0 ) then
        RSEC = RSEC - 1.
      ENDIF       
!
!  RSEC �� 3600./RSEC_TOT �̔{���ɂ���B
!
      RSEC = INT ( RSEC * 24 + 2*DSEC_MIN ) / 24.D0 
!
      RETURN
      END SUBROUTINE RSEC_CLEAN

      end module TS
      
