! SiB �p�萔�t�@�C��
! 99/05/xx �ۍ␪�G    �܂��܂��ύX�̕K�v����
! 99/07/15 ���O�Õv
! 99/08/04 �ۍ␪�G    _c ���ɕύX�r��
!
      MODULE SIBCON
!
!
      IMPLICIT NONE
!
      PRIVATE  CAP_SKIN_c  
!
      REAL(8),SAVE ::  PIE_c  = 3.141592653589793D0
      REAL(8),SAVE ::  COSZ_MIN_c = 0.01746D0 
      REAL(8),SAVE ::  GRAV_c = 9.80665D0
      REAL(8),SAVE ::  CP_AIR_c = 1004.6D0    ! ������C�̒舳��M(J/kg/K)
      REAL(8),SAVE ::  AKAPPA_c               !  R_DRY_c / CP_AIR_c
!
      REAL(8),SAVE ::  STEFAN_c = 5.67D-8  ! Stefan-Boltzmann �萔(W/m^2/K^4)
      REAL(8),SAVE ::  STB4_c              ! 4*STEFAN_c
      REAL(8),SAVE ::  STB8_c              ! 8*STEFAN_c
!
      REAL(8),SAVE ::  TMP_FREZ_c= 273.15D0 ! �������x
!
      REAL(8),SAVE ::  EPSFAC_c             ! R_DRY_c / R_VAP_c 
!
      REAL(8),SAVE ::  CPSY_c               ! CP_AIR_c/(HL_WTR_c*EPSFAC_c) 

      REAL(8),SAVE ::  VKRMN_c      = 0.4D0   ! �J���}���萔
      REAL(8),SAVE ::  VKRMN_INV_c  = 2.5D0   ! ���t��
!
! ���x
!
!     REAL(8),SAVE ::  RHO_SOIL_c = 2650.0D0 !�y���q�i�S�y�z���j�̖��x(kg/m^3) 
!                                           CAMPBELL�̃e�L�X�g���
!    �ϐ�ɂ�����X�̖��x�̂悤�Ȃ��́B�y��̃o���N���x�i�ϐ�̔G��ᖧ�x
!    �ɑ����j�ɂ͂��̖��x�̑��ɁA�y�됅���A��C�A�y��X�̖��x�Ƒ��ݔ䂪�����
!
      REAL(8),SAVE ::  RHO_GLA_c = 917.0D0     ! �X�̖��x(kg/m^3)
      REAL(8),SAVE ::  RHO_WTR_c = 1000.0D0    ! ���̖��x(kg/m^3)
      REAL(8),SAVE ::  RHO_WTR_INV_c 
!
      REAL(8),SAVE ::  RHO_SNW_c = 200.D0      ! �H
      REAL(8),SAVE ::  RHO_SNW_INV_c 
!
!
! ��M
!
!   JCN_CAP_CNP_SL = 0 �̏ꍇ�̐�ʃX�L���̔M�e�ʁiflux �]�����Ɏg�p�j 
      REAL(8),SAVE ::  CAP_CNPX_c = 0.1 
!
      REAL(8),SAVE ::  CAP_LAI_c = 840.D0    ! �t�P�ʖʐϓ�����̔�M�F
!                                         CLAI (J/K/m^2)�E�E0.2mm�̐��̌�����CW
      REAL(8),SAVE ::  CAP_WTR_c = 4218.0D0  ! ����M�FCW (J/K/kg)
      REAL(8),SAVE ::  CAP_GLA_c = 2106.0D0  ! �X��M�FCICE (J/K/kg)
      REAL(8),SAVE ::  CAP_SOIL_BY_VOL_c= 2.39D6
                                        ! �P�ʐ[�P�ʒf�ʐϓ��S�y�z����M
!            CSOIL (J/K/m^3)   CAMPBELL�̃e�L�X�g���
!              ����͐���󌄂��܂܂Ȃ��z���ł���B 
!              ��C�̔�M�𖳎����Ă���B
!              ����� (�P�|�󌄗��j��������Ɗ����y��̔�M�ɂȂ�B
!
      REAL(8),SAVE ::  CAP_GLA_c_INV          ! CICE�̋t��
!
! �Z���E�����E���ؐ��M
!
      REAL(8),SAVE ::  SNOMEL_c =  333624.2D3    ! �X�Z��M (J/kg)*1000
                                                 ! ������s�v�B
!                                                ! HL_GLA_c-HL_WTR_c  
! 
!                            -> �܂� (J/�Z�����ɍ���1m*�f��1m^2�̐��ɂȂ�X)
!                    -> ����1m*�f��1m^2�̕X��Z�����ɂ́ASNOMEL*RHO_GLA_c/1000
      REAL(8),SAVE ::  HL_W2G_c            ! �X�Z��M (J/kg)*1000
      REAL(8),SAVE ::  HL_W2G_INV_c        ! �X�Z��M (J/kg)*1000
!
      REAL(8),SAVE ::  HL_WTR_c     = 2.507D6    !���̂O���ł̏������M (J/kg)
      REAL(8),SAVE ::  HL_GLA_c     = 2.8345D6   !�X�̂O���ł̏��ؐ��M (J/kg)
      REAL(8),SAVE ::  HL_WTR_INV_c  
      REAL(8),SAVE ::  HL_GLA_INV_c 
!
      REAL(8),SAVE ::  H2O_SAT_CNP_DEP_c = 1.D-4  ! 0.1mm 
      REAL(8),SAVE ::  H2O_SAT_GRS_DEP_c = 1.D-4  ! 0.1mm 
!     REAL(8),SAVE ::  H2O_SAT_CNP_DEP_c = 2.D-3  ! 2mm       ppp check
!     REAL(8),SAVE ::  H2O_SAT_GRS_DEP_c = 2.D-3  ! 2mm       ppp check 
!
! �M�`����
!
!
      REAL(8),SAVE ::  HDF_SOIL_c = 2.92      ! �S�y�z���M�`���� (W/m/K)
!                                          CAMPBELL�̃e�L�X�g���
!
      REAL(8),SAVE ::  HDF_WTR_c  = 0.561      ! ���M�`����   (W/m/K) pppqqq
!     REAL(8),SAVE ::  HDF_WTR_c  = 3.         ! ���M�`����   (W/m/K) ppp
      REAL(8),SAVE ::  HDF_GLA_c  = 2.24       ! �X�M�`����   (W/m/K)
      REAL(8),SAVE ::  HDF_AIR_c  = 0.0241     ! ��C�M�`���� (W/m/K)
!
!     REAL(8),SAVE ::  RAMSOL = 2.2       ! �ȑO�̓y��M�`�����B �g��Ȃ� 
!
! �C�̒萔
!
      REAL(8),SAVE ::  R_VAP_c    = 461.0D0    ! �����C�C�̒萔   (J/K/kg)
      REAL(8),SAVE ::  R_DRY_c    = 287.04D0    ! ������C�C�̒萔 (J/K/kg)
      REAL(8),SAVE ::  R_DRY_INV_c             ! ������C�C�̒萔 (J/K/kg)
      REAL(8),SAVE ::  R_BY_G_c                ! R_DRY/GRAV_c 
!
! �~���Ւf
!
      REAL(8),SAVE :: B_PR_COEF_c = 5.       ! �~���̕��z�W�� (�͂ĂȁH�j 
      REAL(8),SAVE :: A_PC_COEF_c 
      REAL(8),SAVE :: A_PL_COEF_c 
      REAL(8),SAVE :: C_PC_COEF_c 
      REAL(8),SAVE :: C_PL_COEF_c 
!
!     REAL(8),SAVE :: A_PR_COEF_S_c 
!     REAL(8),SAVE :: C_PR_COEF_S_c 
      REAL(8),SAVE :: FR_PREITC_c = 0.5 ! �C���^�[�Z�v�g�O�̒l�������銄�� 0-1
!                                       ! �_�~�[
!
      REAL(8),PARAMETER  :: CAP_SKIN_c = 2.5D4 
!
! ==========
! >> �ϐ� <<
! ==========
!
!   �핢��
!
      REAL(8),SAVE :: CVR_SNW_INV_MAX_c  = 1.D30   ! ��̔핢���t���i�_�~�[�j   
      REAL(8),SAVE :: CVR_VEG_INV_MAX_c  = 1.D30   ! 
      REAL(8),SAVE :: CVR_VEG_MIN_c      = 1.D-30  ! 
!
!   ��̕���
!
      REAL(8),SAVE :: FR_SNOWWTR_MAX_c = 0.1 ! GLA ���ɕۗL�\�ȉt���̊������
!                                            ! WTR/GLA < FR_SNOWWTR_MAX 
!
      REAL(8),SAVE :: CAP_SNSK_c  = CAP_SKIN_c   ! ��X�L���M�e��=CAP_SKIN_c 
!!      REAL(8),SAVE :: CAP_SNSK_c  = 2.5D5
!
!      JCN_CAP_CNP_SL = 0 �̏ꍇ�̐�ʃX�L���̔M�e�ʁiflux �]�����Ɏg�p�j 
      REAL(8),SAVE :: CAP_SNSKX_c =  0.1    
!
!   �N�� ( ���͂قƂ�ǃ_�~�[ ) 
!
      REAL(8),SAVE :: AGE_SNOW_MAX1_c   = 1*24*3600.D0     ! �V��w  �N���� 
      REAL(8),SAVE :: AGE_SNOW_MAX1_M_c = 1*24*3600.D0 - 1 
!
      REAL(8),SAVE :: AGE_SNOW_MAX2_c   = 10*24*3600.D0    ! "�V��w' �N����"
      REAL(8),SAVE :: AGE_SNOW_MAX2_M_c = 10*24*3600.D0 -1 
!
!     ��A���x�h��aging�̎��萔��ʍ�46��P60�ɏ]���ύX 8���ԁ�4��
!       ����������� ITUNE_ALBEDO_SNOW=1 �̂Ƃ��̂ݗL��
!!#if    ( SIB0109_OFFLINE_JMA == 1 || SIB0109_GSM_JMA  == 1 )
      REAL(8),SAVE :: AGE_SNOW_ETIME_c     = 4*86400.D0  ! ��A���x�h etime
      REAL(8),SAVE :: AGE_SNOW_ETIME_INV_c = 1.0D0/(4.*24.*60.*60.D0)
!!#else
!!      REAL(8),SAVE :: AGE_SNOW_ETIME_c     = 8*3600.D0   ! ��A���x�h etime 
!!      REAL(8),SAVE :: AGE_SNOW_ETIME_INV_c = 3.472*1.D-5    
!!#endif
!
!   �N��N���A ( ���̓_�~�[ ) 
!
      REAL(8),SAVE :: SNOWFALL_MAKE_NEW_c  = 0.25 ! �V��w�쐬�̍~���臒l  
!                                     ! 0.5kg/m**2/step �` 5cm/step 
!                                              
      REAL(8),SAVE :: SNOWFALL_RESET_NEW_c = 0.05 
                                      ! �V��w�̔N��Z�b�g�̍~���臒l  
!
!  itune_albedo_snow=3 or 4
      REAL(8),SAVE :: RAIN_1HOUR_FRESH_c = 0.02    ! kg=mm/1hour ~ 0.5mm/day
!
!  01 �� 1 �̂�������
!
      REAL(8),SAVE :: H2O_SNOW_01_1_c  = 4.D0  ! ����ȉ��Ȃ� 01 �ɂ���B 
      REAL(8),SAVE :: H2O_SNOW_01_1_INV_c   
!
!  ����o�P�c�s�����ǂ����̂������� ( �C�ی��Ɛ��l�ƂňقȂ� ) 
!
! 20050517
!      REAL(8),SAVE :: H2O_SNOW_MIN_c
#if   ( SIB0109_OFFLINE_MRI == 1 ) 
      REAL(8),SAVE :: H2O_SNOW_MIN_c   = 4.D0  ! ���ݖ����̏ꍇ
#elif ( SIB0109_OFFLINE_ALMA == 1 ) 
      REAL(8),SAVE :: H2O_SNOW_MIN_c   = 4.D0  ! ���ݖ����̏ꍇ
#elif ( SIB0109_MJ98_MRI    == 1 ) 
      REAL(8),SAVE :: H2O_SNOW_MIN_c   = 4.D0  ! ���ݖ����̏ꍇ
#elif ( SIB0109_OFFLINE_JMA == 1 ) 
      REAL(8),SAVE :: H2O_SNOW_MIN_c   = 1.D-3 ! ���݌^�f�t�H���g
#elif ( SIB0109_GSM_JMA     == 1 ) 
      REAL(8),SAVE :: H2O_SNOW_MIN_c   = 1.D-3 ! ���݌^�f�t�H���g
#endif
!
      REAL(8),SAVE :: ENG_MELT_MAX_c 

!
! �w�̐؂��
!
      REAL(8),SAVE :: H2O_SNOW_1_2a_c  = 40.  ! ����ȏ�Ȃ� 2 �w�B1,2 �w�͐ܔ�
      REAL(8),SAVE :: H2O_SNOW_2a_2b_c = 80.  ! ����ȏ�Ȃ� 2 �w�� 1 �w�͒��
      REAL(8),SAVE :: H2O_SNOW_2b_3_c  = 200. ! ����ȏ�Ȃ� 3 �w�B
!
      REAL(8),SAVE :: H2O_SNOW1_STD_c         ! H2O_OLDSNOW_2a_2b /2
      REAL(8),SAVE :: H2O_SNOW3_STD_c         ! H2O_OLDSNOW_2a_2b /2
!   
      REAL(8),SAVE :: H2O_SNOW1_MIN_c  = 10.  ! 2 �w�ȏ�̂Ƃ��� 1 �w�̍ŏ��l
      REAL(8),SAVE :: H2O_SNOW1_MAX_c  = 50.  ! 
      REAL(8),SAVE :: H2O_SNOW2_MIN_c  = 15.  
      REAL(8),SAVE :: H2O_SNOW2_MAX_c  = 1.D10 
      REAL(8),SAVE :: H2O_SNOW3_MIN_c  = 20.  
      REAL(8),SAVE :: H2O_SNOW3_MAX_c  = 50.  
!
! ==========
! >> �y�� <<
! ==========
!
!    JCN_CAP_CNP_SL = 1 �̏ꍇ�̓y��X�L���̔M�e�ʁiflux �]�����Ɏg�p�j 
      REAL(8),SAVE :: CAP_GRSKX_c =  0.1  
!
      REAL(8),SAVE :: CAP_GRSK_c = CAP_SKIN_c 
                                   ! �y��X�L���̔M�e�� = cap_skin_c 
!
      REAL(8),SAVE :: FR_SOIL_H2O_MIN_c = 0.05
      REAL(8),SAVE :: FR_SOIL_GLA_MAX_c = 0.95
!
! �y�됅���̊g�U�̃^�C�v ( �_�~�[ )
!   
!     INTEGER   :: JCN_COEF_WFLUX_SOIL_c  = 0   
!               ! 0  MILLY AND EAGLESON (1982)?   �f�t�H���g
!               ! 1  �g�U�ł͂悭����^�C�v
!
      REAL(8),SAVE :: DEP_SOIL4_c     = 10.D0    ! 10m 
      REAL(8),SAVE :: DEP_SOIL4_INV_c 
      REAL(8),SAVE :: CAP_SOIL4_c   
      REAL(8),SAVE :: CAP_SOIL4_INV_c   
      integer,save :: itune_soilfluxbottom_c = 1 ! �y���ʔM�t���b�N�X���� 
!
! �X�����n�A���x�h(�C��l�t�@�C���ł�VIS0.1 NIR=0.15�Ə��������H)
!#if    ( SIB0109_OFFLINE_JMA == 1 || SIB0109_GSM_JMA  == 1 )
      REAL(8),SAVE :: ALBEDO_ICESHEET_SOIL_VIS_c = 0.80D0
      REAL(8),SAVE :: ALBEDO_ICESHEET_SOIL_NIR_c = 0.60D0
!#endif
!
! ========================================
! >> ���ԍ��t�@�N�^�i�t���b�N�X�]�����j <<
! ========================================
!     delt_fac_* = 1 �ŃC���v���V�b�g�A > 1 �ŃI�[�o�[�C���v���V�b�g
!
! 20050517
!	REAL(8),SAVE   :: DELT_FAC_ATM_c
!	REAL(8),SAVE   :: DELT_FAC_CNP_c
#if   ( SIB0109_OFFLINE_MRI == 1 ) 
      REAL(8),SAVE   :: DELT_FAC_ATM_c = 1.5D0
      REAL(8),SAVE   :: DELT_FAC_CNP_c = 2.0D0
#elif ( SIB0109_OFFLINE_ALMA == 1 ) 
      REAL(8),SAVE   :: DELT_FAC_ATM_c = 1.5D0
      REAL(8),SAVE   :: DELT_FAC_CNP_c = 2.0D0
#elif ( SIB0109_MJ98_MRI == 1 ) 
      REAL(8),SAVE   :: DELT_FAC_ATM_c = 1.5D0
      REAL(8),SAVE   :: DELT_FAC_CNP_c = 2.0D0
#elif ( SIB0109_OFFLINE_JMA == 1 ) 
      REAL(8),SAVE   :: DELT_FAC_ATM_c = 2.0D0
      REAL(8),SAVE   :: DELT_FAC_CNP_c = 2.0D0
#elif ( SIB0109_GSM_JMA  == 1 ) 
      REAL(8),SAVE   :: DELT_FAC_ATM_c = 2.0D0
      REAL(8),SAVE   :: DELT_FAC_CNP_c = 2.0D0
#endif

      REAL(8),SAVE   :: DELT_FAC_SNOW_c  = 1.   
      REAL(8),SAVE   :: DELT_FAC_SOIL_c  = 1.  
      REAL(8),SAVE   :: DELT_FAC_SOIL_INV_c
!
! ====================
! >> 4 �{���x�̕ϐ� <<
! ====================
!
      INTEGER, PARAMETER:: QUADRUPLE = MAX(SELECTED_REAL_KIND(P=20),
     1  KIND(0.0d0))
!
      REAL(QUADRUPLE)::    HL_W2G_c_16       = 0.3275e6_QUADRUPLE 
      REAL(QUADRUPLE)::    HL_W2G_INV_c_16         
      REAL(QUADRUPLE)::    HL_GLA_c_16      = 2.8345e6_QUADRUPLE
      REAL(QUADRUPLE)::    HL_GLA_c_INV_16  
      REAL(QUADRUPLE)::    TMP_FREZ_16       = 273.15e0_QUADRUPLE
!
! ==================
! >> �`���[�j���O <<
! ==================
!
! ��̉�����@
!   ����́ASib0109/Snow/snow_wflux_pre.F �ōs�Ȃ��B
!     10 ��������ő����Ă����B
!   �N��N���A
!     Sib0109/Snow/snow_age_clear.F �Q��
!
!       0 ... ����̂�(�N���A���Ȃ�)
!       1 ... ���x�� RHO_THR1 ��菬������� 0 
!       2 ... 
!
      INTEGER,SAVE  ::  ITUNE_SNOW_AGE = 0  
!
!
!   ��N��N���A��������w�̐ᖧ�x�Ō��߂�ꍇ ( ITUNE_SNOW_AGE=1 )
!   �ɗL���ɂȂ�A�V��̕~���l
!
      REAL(8),SAVE ::  RHO_SNOW_AGECLEAR_THR_c  = 78.D0 
      REAL(8),SAVE ::  RHO_SNOW_AGECLEAR_THR_INV_c 
!
! ��̃A���x�h�v�Z���@ 
!   �ڂ����� Sib0109/Albedo/albedo_snow.F �Q��
!     0 ... ���x�݂̂Ɉˑ�
!     1 ... �N��Ɉˑ�
!     2 ... 
!     3 ... Aoki
!     4 ... 3 + Glacier special treatment 
!
      INTEGER,SAVE  ::  ITUNE_ALBEDO_SNOW = 3  
!
!     ITUNE_ALBEDO_SNOW = 0 �̎� ( ���x�݂̂Ɉˑ��̎� ) �ɈӖ�����
!
        REAL(8),SAVE :: ALB_SNOW_VIS_c       = 0.8D0
        REAL(8),SAVE :: ALB_SNOW_NIR_c       = 0.4D0 
        REAL(8),SAVE :: ALB_SNOW_FACT_TEMP_c = 0.6D0   
!
!     ITUNE_ALBEDO_SNOW = 1 ( �N��Ɉˑ��̎� ), 3, 4 �ɈӖ�����
!                                                   3,4��(_FOR_c�̂ݎg�p)
!      
        REAL(8),SAVE :: ALB_SNOW_VIS_INI_c = 0.8   ! ���A���x�h�����l
        REAL(8),SAVE :: ALB_SNOW_NIR_INI_c = 0.6   ! �ߐԃA���x�h�����l
!       REAL(8),SAVE :: ALB_SNOW_VIS_FOR_c = 0.5   ! ���A���x�h�������l
        REAL(8),SAVE :: ALB_SNOW_VIS_FOR_c = 0.6   ! ���A���x�h�������l
        REAL(8),SAVE :: ALB_SNOW_NIR_FOR_c = 0.4   ! �ߐԃA���x�h�������l
!
! �ሳ���\��Ɏg���֐��`�ł̕~���l�B
!
      REAL(8),SAVE ::  RHO_SNOW_INTG_THR_c  = 78.D0 
      REAL(8),SAVE ::  RHO_SNOW_INTG2_THR_c = 400.D0
!
! ��X�L���Ɛ�̊Ԃ̊g�U�W���t�@�N�^ ( presib_conduc_all.F )
      REAL(8),SAVE ::  FACT_HDF_SNSK_c = 1.D0  
      REAL(8),SAVE ::  FACT_HDF_SNOW_c = 1.D0  
!
! ��X�L���ł̒Z�g���߃t�@�N�^ ( 0 ���߂Ȃ��A1 ���� ) ( rad_sum_all.F )
!
!!(NPD)
!!#if    ( SIB0109_OFFLINE_JMA == 1 || SIB0109_GSM_JMA  == 1 )
      REAL(8),SAVE ::  FACT_TRANS_SR_SNOW_SKIN_c = 1.D0  
!(MRI)
!!#else
!!      REAL(8),SAVE ::  FACT_TRANS_SR_SNOW_SKIN_c = 0.D0  
!!#endif
!
! RSiB �ł̐�̔�M�]���p�ϐᐅ����
!
      REAL(8),SAVE :: WTR_EQUIV_SNOW_c = 0.05  ! 5cm 
!
! ��ʗZ�����薳�� ( snow_bottom_melt.F )
      INTEGER,SAVE  ::  ITUNE_SNOW_BOTTOM_MELT = 1   
!
! TMP_SKIN �̐ϕ����ɁA���̉��x�̉A�I�␳�̌W���B
      REAL(8),SAVE  :: FACT_HDF_GRSK_c = 1.D0     ! grsk �� soil1 
      REAL(8),SAVE ::  FACT_HDF_SOIL_c = 1.D0     ! soil* �� 
!
! skin �� ���w�̌W���̉A�I�␳�̏C��( canopy_main.F )
      REAL(8),SAVE  :: FACT_TSKIN_TOP_c = 1.D0    ! 
!
      INTEGER,SAVE :: JCN_RUNOFF_GRAV_c =  1
      REAL(8),SAVE :: COEF_SOIL_WFLUX_MIN_C = 0. 
      REAL(8),SAVE :: POT_SOIL_MIN_c = - 1.D5 
!
      real(8),save :: fact_precipi_c = 1.D0  
!
      CONTAINS 
!======================================================
      SUBROUTINE SIBCON_INI 
!
      NAMELIST / SIB0109_SIBCON /  
     1     H2O_SNOW_MIN_c , fact_precipi_c , DEP_SOIL4_c 
     1   , CAP_GRSK_c      , CAP_SNSK_c     
     1   , FR_SOIL_H2O_MIN_c , COEF_SOIL_WFLUX_MIN_c,POT_SOIL_MIN_c
     1   , DELT_FAC_ATM_c  , DELT_FAC_CNP_c 
     1   , DELT_FAC_SNOW_c , DELT_FAC_SOIL_c 
     1   , RHO_SNOW_INTG_THR_c  
     1   , RHO_SNOW_AGECLEAR_THR_c 
     1   , ITUNE_SNOW_AGE  
     1   , ITUNE_ALBEDO_SNOW 
     1   , ITUNE_SNOW_BOTTOM_MELT 
     1   , ALB_SNOW_VIS_INI_c , ALB_SNOW_NIR_INI_c 
     1   , ALB_SNOW_VIS_FOR_c , ALB_SNOW_NIR_FOR_c 
     1   , ALB_SNOW_VIS_c     , ALB_SNOW_NIR_c 
     1   , ALB_SNOW_FACT_TEMP_c 
     1   , FACT_TRANS_SR_SNOW_SKIN_c
     1   , FACT_TSKIN_TOP_c 
     1   , FACT_HDF_SNSK_c 
     1   , FACT_HDF_SNOW_c 
     1   , FACT_HDF_GRSK_c
     1   , FACT_HDF_SOIL_c
     1   , WTR_EQUIV_SNOW_c 
     1  , ITUNE_SOILFLUXBOTTOM_c, RAIN_1HOUR_FRESH_c, JCN_RUNOFF_GRAV_c
!
      READ (5,SIB0109_SIBCON)      
      WRITE(6,SIB0109_SIBCON)      
!
!
      IF ( H2O_SNOW_MIN_c .GT. H2O_SNOW_01_1_c  ) THEN
        write(6,*) 'sibcon_ini error : snow_min ' , 
     1             ' H2O_SNOW_MIN_c > H2O_SNOW_01_1_c '  , 
     1               H2O_SNOW_MIN_c, H2O_SNOW_01_1_c 
        stop 999
      ENDIF
!
!  ====================
!  >> �t���Ȃǂ̐ݒ� <<
!  ====================
!
      HL_WTR_INV_c = 1/HL_WTR_c  
      HL_GLA_INV_c = 1/HL_GLA_c  
      HL_W2G_c     = HL_GLA_c - HL_WTR_c 
      HL_W2G_INV_c = 1/HL_W2G_c
!
      CAP_GLA_c_INV  = 1/CAP_GLA_c
!
      STB4_c         = STEFAN_c * 4
      STB8_c         = STEFAN_c * 8
!
      EPSFAC_c     = R_DRY_c / R_VAP_c                   ! �� 0.622 
! 
      CPSY_c       = CP_AIR_c / ( HL_WTR_c * EPSFAC_c ) 
      AKAPPA_c     = R_DRY_c / CP_AIR_c
!
      R_DRY_INV_c    = 1 / R_DRY_c
      RHO_WTR_INV_c  = 1 / RHO_WTR_c
!
      RHO_SNW_INV_c  = 1.D0 / RHO_SNW_c            ! 01/07/01
!
      RHO_SNOW_AGECLEAR_THR_INV_c = 1.D0 / RHO_SNOW_AGECLEAR_THR_c
!
      R_BY_G_c     = R_DRY_c/GRAV_c 
!
      DELT_FAC_SOIL_INV_c = 1 / DELT_FAC_SOIL_c
!
!
      H2O_SNOW_01_1_INV_c = 1/ H2O_SNOW_01_1_c
!
      H2O_SNOW1_STD_c = H2O_SNOW_2a_2b_c/2
      H2O_SNOW3_STD_c = H2O_SNOW_2a_2b_c/2
!
      HL_W2G_INV_c_16  = 1.0_QUADRUPLE /  HL_W2G_c_16   
      HL_GLA_c_INV_16  = 1.0_QUADRUPLE /  HL_GLA_c_16  
!
!
      DEP_SOIL4_INV_c = 1/DEP_SOIL4_c
      CAP_SOIL4_c     = 0.5 * DEP_SOIL4_c * CAP_SOIL_BY_VOL_c
!                       0.5 �́A��\�I�󌄗�
      CAP_SOIL4_INV_c = 1./CAP_SOIL4_c
!
! ------------------------------------------------
! > �~���̕��z�֐��̌W�� �i�`���[�j���O�p�����^�j<
! ------------------------------------------------
!    ���ӁB����(1989) �Ƃ͒l���قȂ�
!
        A_PC_COEF_c = 5.0D0                          ! �Η��n�~�� �s�[�N�� 5 
        C_PL_COEF_c = 0.99998D0                      ! ��K�͋Ì� ��l
        A_PL_COEF_c = ( 1.D0 - C_PL_COEF_c ) * B_PR_COEF_c 
     1               / ( 1 - DEXP(-B_PR_COEF_c) )   
        C_PC_COEF_c =   1.D0 - A_PC_COEF_c   / B_PR_COEF_c  
     1                       * ( 1 - DEXP(-B_PR_COEF_c) ) 
!
#ifdef SIB_DEBUG
         write(6,*) 'sibcon_ini : rain distribution info' , 
     1             ' a_pc c_pc ' , A_PC_COEF_c , C_PC_COEF_c ,      
     1             ' a_pl c_pl ' , A_PL_COEF_c , C_PL_COEF_c ,
     1             ' integ c l ' , 
     1               A_PC_COEF_c / B_PR_COEF_c 
     1                      * ( 1.D0 - DEXP(- B_PR_COEF_c) )  
     1                + C_PC_COEF_c ,
     1               A_PL_COEF_c / B_PR_COEF_c 
     1                      * ( 1.D0 - DEXP(- B_PR_COEF_c) ) 
     1                + C_PL_COEF_c  
#endif
!
!  ��̏ꍇ
!
!       A_PR_COEF_S_c = 3.D0                         ! �s�[�N�� 3 �{
!       C_PR_COEF_S_c = 1.D0 - A_PR_COEF_S_c / B_PR_COEF_c  
!    1                       * ( 1 - EXP(-B_PR_COEF_c) ) 
!
!  ====================
!  >> ��X�̃`�F�b�N <<
!  ====================
!
! --------------------------------------
! > �~�����z�̃p�����^�Ɋւ���`�F�b�N <
! --------------------------------------
!
      IF (        A_PL_COEF_c   .LT.0. 
     1       .OR. C_PC_COEF_c   .LT.0. 
!    1       .OR. C_PR_COEF_S_c .LT.0  
     1   ) THEN
          write(6,*) 'sibcon_ini error rain distribution A '  
     1                                   , A_PL_COEF_c 
     1                                   , C_PC_COEF_c  
!    1                                   , C_PR_COEF_S_c 
          stop 999
      ENDIF
!
      IF ( 
     1          ( ABS( A_PL_COEF_c / B_PR_COEF_c 
     1                      * ( 1.D0 - DEXP(- B_PR_COEF_c) ) 
     1            + C_PL_COEF_c - 1.D0 ) 
     1           .GT. 1.D-15 )
     1       .OR.  
     1          ( ABS( A_PC_COEF_c / B_PR_COEF_c 
     1                      * ( 1.D0 - DEXP(- B_PR_COEF_c) ) 
     1            + C_PC_COEF_c -1.D0 ) 
     1            .GT. 1.D-15 ) 
!    1       .OR.  
!    1          ( ABS( A_PR_COEF_S_c / B_PR_COEF_c 
!    1                      * ( 1 - EXP(-B_PR_COEF_c)) 
!    1            + C_PR_COEF_S_c -1.D0 ) .GT. 1.D-30 ) 
     1      ) THEN
          WRITE(6,*) 'sibcon_ini ERROR rain distribution B' 
     1     ,  A_PL_COEF_c / B_PR_COEF_c * ( 1 - DEXP(- B_PR_COEF_c) ) 
     1          + C_PL_COEF_c - 1 
     1     ,  A_PC_COEF_c / B_PR_COEF_c * ( 1 - DEXP(- B_PR_COEF_c) ) 
     1          + C_PC_COEF_c - 1 
!    1     ,  A_PR_COEF_S_c / B_PR_COEF_c * ( 1 - EXP(- B_PR_COEF_c) ) 
!    1          + C_PR_COEF_S_c - 1 
          stop 999
      ENDIF
!
! --------------------------------------------------
! > ��̔N����N���A���Ȃ��̂ɁA�A���x�h�͔N��ˑ� <
! --------------------------------------------------
!
      IF ( ITUNE_ALBEDO_SNOW .EQ.1 .AND. ITUNE_SNOW_AGE.EQ.0 ) THEN
        WRITE(6,*) 'SIBCON_INI ERROR : '
        WRITE(6,*) '  SNOW AGE IS NOT CLEARED, ' 
        WRITE(6,*) '  BUT ALBEDO DEPEND ON THE SNOW AGE.'
        STOP 999
      ENDIF 
!
      ENG_MELT_MAX_c = H2O_SNOW1_MIN_c * 0.1D0 * HL_W2G_c 
!
      END SUBROUTINE SIBCON_INI 
!
      END MODULE SIBCON