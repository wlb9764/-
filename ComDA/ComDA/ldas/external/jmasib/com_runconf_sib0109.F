      MODULE COM_RUNCONF_SIB0109

!! ���s�W���u�ݒ��� ( �W���u���ň�� )

!! ���̐ݒ�l��default�̒l�B
!! set_com_runconf�ŁA�������̒l���u�������B

! run configuration information module file
!
!
!--- FLG8       �V  SiB �֘A
!  
!  �X�̃p�b�P�[�W�̑I��   : 1 newsib 0 l3sib_mod
!
!     MJ98 �ł͑I���\ ( ����ȊO�ł� 1 �̂�? ) 
!
      INTEGER,SAVE :: JCN_SIB_ALBEDO  = 1  
      INTEGER,SAVE :: JCN_SIB_RAD2SIB = 1  
      INTEGER,SAVE :: JCN_SIB_PRESIB  = 1  
      INTEGER,SAVE :: JCN_SIB_SKIN    = 1  
      INTEGER,SAVE :: JCN_SIB_SNOW    = 1  
      INTEGER,SAVE :: JCN_SIB_SOIL    = 1  
!
!
      INTEGER,SAVE ::
!    1    JCN_SIB_MONIT_DETAIL   = 1  ,    ! �ڍ׃��j�^ on �Ȃ� 1  
     1    JCN_WAY_OF_INTEGRATION = 2  ,    ! canopy �ϕ� 2 overimp, 1 balance
     1    JCN_BAD_WTR_ADD = 1         
!
! �e���f���̎w��B �C���^�[�t�F�[�X�ŗ^���邱�ƁB
!
      INTEGER,SAVE :: JCN_SIB_UPPER_MODEL = -1
!        �I�t���C��  -1   ��C��M�[��  
!                    -2   ��C��M�L��
!        mj98         1 
!        GSM          2 
!        RSM          3  
!
      INTEGER,SAVE ::                      ! on-line             0
     1    JCN_SNOW_HEAT_EXPLICIT = 0   ,   ! ��w�M�� explicit �Ȃ� 1 
     1    JCN_SOIL_HEAT_EXPLICIT = 0   ,   ! �y��M�� explicit �Ȃ� 1 
     1    JCN_SOIL_WATER_EXPLICIT = 0  ,   ! �y�됅�� explicit �Ȃ� 1 
     1    JCN_SIB_ISLSCP = 0           ,   ! �����f�[�^���
!                                          ! online -1 
!                                          ! TEST1DIM 0, 
!                                          ! ISLSCP 1, ERA 2, 
!                                          ! Forcing 3 
     1    JCN_SIB_ISLSCP_CYCLE1987 = 0  ,  ! ISLSCP �� 1987 �N�T�C�N������
     1    JCN_SIB_ATM_CYCLE = 0         ,  ! ERA �ŔN��������Ƃ��̔N��cycle
!                                          !  900 �ȏ�Ȃ猎��
     1    JCN_IWL_SKIP    = 3           ,  ! 
     1    JCN_RRUNOFF_B   = 0           ,  ! �y��O�w������̗������� 0 ���� 1 
     1    JCN_CAP_CNP_SL  = 1           ,  ! �t���b�N�X�]���Ɏg����M��
!                                          ! 0 �������A1 ���ۂ̒l
     1    JCN_ITR_MAX     = 2           ,  ! �C�e���[�V����max ... ���ϕ��Ȃ�2
     1    JCN_INT_MNT     = 999            ! ���j�^�o�͊Ԋu
!
      REAL(8),SAVE :: 
     1    RCN_DELT_ATM     =  3600.D0 ,    
     1    RCN_DELT_CNP     =  3600.D0 ,  
!    1    RCN_DELT_SOIL    = 1800.D0 ,  
!    1    RCN_DELT_SNOW    = 1800.D0 , 
     1    RCN_DELT_SOIL    =  3600.D0 ,  
     1    RCN_DELT_SNOW    =  3600.D0 , 
     1    RCN_FACT_SS1     = 1.D0    ,
     1    RCN_DELT_SR      = 3600.D0     
     
!            ! canopy_* �� SS1 �̐ϕ����ɁA������t�@�N�^
!            ! �[���Ȃ炻�������ω������B 
!
! 20050803
!      CHARACTER(40),SAVE   :: CCN_FILENAME_VEG = '../input/GSM9603.VEG' 
	CHARACTER(40),SAVE   :: CCN_FILENAME_VEG = 'input/GSM9603.VEG' 
      !
      ! �f�o�b�O�p�Ɋe��萔�𓮓I�ɕύX���邽��
      !    LINUX �ł� ccn_trial �̏����l�� "" �ł͂Ȃ� " " �łȂ��ƌx�����o��
      ! 
      CHARACTER(8), SAVE :: CCN_TRIAL(4) = (/" ", " ", " ", " "/)
      REAL(8)     , SAVE :: RCN_TRIAL(4) = (/0., 0., 0., 0./)
!
      NAMELIST / SIB0109_COM_RUNCONF_SIB0109/       
!    1   JCN_SIB_MONIT_DETAIL  , 
!!   1   JCN_SIB_UPPER_MODEL   ,   
     1   JCN_SNOW_HEAT_EXPLICIT     ,   
     1   JCN_SOIL_HEAT_EXPLICIT     ,   
     1   JCN_SOIL_WATER_EXPLICIT     ,   
     1   JCN_SIB_ISLSCP        ,   
     1   JCN_SIB_ISLSCP_CYCLE1987     ,   
     1   JCN_SIB_ATM_CYCLE     ,   
     1   JCN_IWL_SKIP          , 
     1   JCN_RRUNOFF_B         , 
     1   JCN_CAP_CNP_SL        , 
     1   RCN_DELT_ATM          , 
     1   RCN_DELT_CNP          , 
     1   RCN_DELT_SOIL         , 
     1   RCN_DELT_SNOW         , 
     1   RCN_DELT_SR           , 
     1   RCN_FACT_SS1          , 
     1   JCN_ITR_MAX           ,
     1   CCN_FILENAME_VEG, CCN_TRIAL, RCN_TRIAL
!
      CONTAINS
!======================================================================
        SUBROUTINE COM_RUNCONF_SIB0109_INI
!
        use com_stdinout_unit , only : iunit_in , iunit_out
!
        implicit none 

         !--- �l�[�����X�g�ǂݍ��݂ɂ��ύX       
          write(6,*) 'com_runconf_sib0007_ini' 
          REWIND(iunit_in) 
          READ  (iunit_in,SIB0109_COM_RUNCONF_SIB0109)  ! read parameter values
													  !	from stdin
!
          IF      ( JCN_WAY_OF_INTEGRATION .EQ. 1 ) THEN   ! �C�e���[�V����
           JCN_ITR_MAX     = 5    ! 
           JCN_CAP_CNP_SL  = 0    ! �t���b�N�X�]���Ɏg����M���[��
          ELSE IF ( JCN_WAY_OF_INTEGRATION .EQ. 2 ) THEN   ! ���ϕ�
           JCN_ITR_MAX     = 2    ! 
           JCN_CAP_CNP_SL  = 1    ! �t���b�N�X�]���Ɏg����M�����ʂ̒l
          ENDIF
!
          WRITE(iunit_out,SIB0109_COM_RUNCONF_SIB0109)
!
        END SUBROUTINE COM_RUNCONF_SIB0109_INI
      END MODULE COM_RUNCONF_SIB0109



