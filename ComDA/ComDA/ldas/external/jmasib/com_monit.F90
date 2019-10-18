MODULE com_monit

  USE prm,ONLY : &
    imax,        &
    jmax,        &
    kmax,        &
    ijmax,       &
    jlmax,       &
    maxi_3,      &
    maxj_3,      &
    maxi_3eta,   &
    maxj_3eta,   &
    inti_3,      &! 3D    monitor, i interval
    intj_3,      &! 3D    monitor, j interval
    inti_3eta,   &! 3Deta monitor, i interval
    intj_3eta,   &! 3Deta monitor, j interval
    kmaxm,       &! 3D    monitor, p_monit(kmaxm)
    p_monit       ! 3D    monitor, monitor levels

  IMPLICIT NONE

! suffix : _2    ( 2D monitor )
!          _3    ( 3D monitor )
!          _3eta ( 3D model level monitor )
!          _day  ( daily monitor )
!          _6hr  ( 6 hourly monitor )
!          _glob ( global mean monitor )

!--  monit_ini �œo�^�ł��郂�j�^�ϐ��̐��̃��~�b�g�B
!--  ����Ȃ��Ƃ��́A���𑝂₵�Ă��悢�B
  INTEGER,PARAMETER :: limit_2    = 1000     !-- 76 used
  INTEGER,PARAMETER :: limit_3    = 100     !-- 41 used
  INTEGER,PARAMETER :: limit_3eta = 50      !--  1 used
  INTEGER,PARAMETER :: limit_day  = 50      !--  7 used
  INTEGER,PARAMETER :: limit_6hr  = 50      !--  9 used
  INTEGER,PARAMETER :: limit_glob = 50      !-- 15 used

!--  ����̏��߂����Aday_first = .TRUE.
!--  ����ȊO�ł́Aday_first = .FALSE.
!--  monit_day_maxmin�Ŏg�p�B
  LOGICAL,SAVE :: day_first

!--  monit_make_pfull�Ōv�Z�����B
!--  monit_add_3�ȂǂŁAp�ʂɓ��}����ۂɎg�p����B
  REAL(8),SAVE :: paa(ijmax,kmaxm)
  REAL(8),SAVE :: pbb(ijmax,kmaxm)
  INTEGER,SAVE :: klev(ijmax,kmaxm)

!--  �R�̃}�X�N�B
!--  �R�̏�łP�A�R�̉��łO�B
  REAL(8),SAVE :: wmsk (ijmax,kmaxm)  !-dynamics order
  REAL(8),SAVE :: wmskp(ijmax,kmaxm)  !-physcs order

!--  wmsk,wmskp��SNAP SHOT�B
  REAL(8),SAVE :: snp_wmsk (ijmax,jlmax,kmaxm)  !-dynamics order
  REAL(8),SAVE :: snp_wmskp(ijmax,jlmax,kmaxm)  !-physcs order

!--  wmsk,wmskp�̐ώZ�B
  REAL(8),SAVE :: sum_wmsk (ijmax,jlmax,kmaxm)  !-dynamics order
  REAL(8),SAVE :: sum_wmskp(ijmax,jlmax,kmaxm)  !-physcs order
  REAL(8),SAVE :: sum_wmsk_day (ijmax,jlmax,kmaxm) ! for daily monitor
  REAL(8),SAVE :: sum_wmskp_day(ijmax,jlmax,kmaxm) ! for daily monitor
  REAL(8),SAVE :: sum_wmsk_6hr (ijmax,jlmax,kmaxm) ! for 6hourly monitor
  REAL(8),SAVE :: sum_wmskp_6hr(ijmax,jlmax,kmaxm) ! for 6hourly monitor


!--  �o�^�������j�^�ϐ��̐��B
!--  monit_regist���Q�ƁB
  INTEGER,SAVE :: mxptr_2    = 0
  INTEGER,SAVE :: mxptr_3    = 0
  INTEGER,SAVE :: mxptr_3eta = 0
  INTEGER,SAVE :: mxptr_day  = 0
  INTEGER,SAVE :: mxptr_6hr  = 0
  INTEGER,SAVE :: mxptr_glob = 0

!--  �o�^���邪�A�t�@�C���o�͂��Ȃ����j�^�ϐ��̐��B
!--  monit_regist���Q�ƁB
  INTEGER,SAVE :: mxptr_nouse_2    = 0
  INTEGER,SAVE :: mxptr_nouse_3    = 0
  INTEGER,SAVE :: mxptr_nouse_3eta = 0
  INTEGER,SAVE :: mxptr_nouse_day  = 0
  INTEGER,SAVE :: mxptr_nouse_6hr  = 0
  INTEGER,SAVE :: mxptr_nouse_glob = 0

!--  ���j�^�ϐ��̐ώZ�ʁB
!--  monit_add_* �̃T�u���[�`���ŐώZ����B
  REAL(8),POINTER :: sum_2(:,:,:)
  REAL(8),POINTER :: sum_3(:,:,:,:)
  REAL(8),POINTER :: sum_3eta(:,:,:,:)
  REAL(8),POINTER :: sum_day(:,:,:)
  REAL(8),POINTER :: sum_6hr(:,:,:)
  REAL(8),SAVE    :: sum_glob(limit_glob)

!XX  REAL(8),SAVE :: sum_2(ijmax,jlmax,limit_2)
!XX  REAL(8),SAVE :: sum_3(ijmax,jlmax,kmaxm,limit_3)
!XX  REAL(8),SAVE :: sum_3eta(ijmax,jlmax,kmax,limit_3eta)
!XX  REAL(8),SAVE :: sum_day(ijmax,jlmax,limit_day)
!XX  REAL(8),SAVE :: sum_6hr(ijmax,jlmax,limit_6hr)
!XX  REAL(8),SAVE :: sum_glob(limit_glob)

!--  �t�@�C���ɏo�͂��邩���Ȃ����̃t���b�O�B
!--  1 : �o�͂���B   0 : �o�͂����B
  INTEGER,SAVE :: ldisk_2(limit_2)
  INTEGER,SAVE :: ldisk_3(limit_3)
  INTEGER,SAVE :: ldisk_3eta(limit_3eta)
  INTEGER,SAVE :: ldisk_day(limit_day)
  INTEGER,SAVE :: ldisk_6hr(limit_6hr)
  INTEGER,SAVE :: ldisk_glob(limit_glob)

!--  ���j�^�ϐ��̃L�[���[�h�B
!--  monit_add_* �ȂǂŎg�p�B
  INTEGER  ( 8),SAVE :: ikwd_2(limit_2)
  CHARACTER( 8),SAVE :: ckwd_2(limit_2)
! CHARACTER( 7),SAVE :: ckwd_2(limit_2)
  CHARACTER( 7),SAVE :: ckwd_3(limit_3)
  CHARACTER( 7),SAVE :: ckwd_3eta(limit_3eta)
  CHARACTER( 7),SAVE :: ckwd_day(limit_day)
  CHARACTER( 7),SAVE :: ckwd_6hr(limit_6hr)
  CHARACTER( 7),SAVE :: ckwd_glob(limit_glob)
  EQUIVALENCE ( IKWD_2 , CKWD_2 )

!--  �t�@�C���o�͂��Ȃ����j�^�ϐ��̃L�[���[�h�B
!--  monit_add_* �ȂǂŎg�p�B
! CHARACTER( 7),SAVE :: ckwd_nouse_2(limit_2)
  CHARACTER( 8),SAVE :: ckwd_nouse_2(limit_2)
  INTEGER  ( 8),SAVE :: Ikwd_nouse_2(limit_2)
  CHARACTER( 7),SAVE :: ckwd_nouse_3(limit_3)
  CHARACTER( 7),SAVE :: ckwd_nouse_3eta(limit_3eta)
  CHARACTER( 7),SAVE :: ckwd_nouse_day(limit_day)
  CHARACTER( 7),SAVE :: ckwd_nouse_6hr(limit_6hr)
  CHARACTER( 7),SAVE :: ckwd_nouse_glob(limit_glob)
!
  EQUIVALENCE(CKWD_NOUSE_2,IKWD_NOUSE_2)

!--  'LAND' or 'SEA' or 'BOTH'
  CHARACTER( 4),SAVE :: cmask_2(limit_2)
  CHARACTER( 4),SAVE :: cmask_3(limit_3)
  CHARACTER( 4),SAVE :: cmask_3eta(limit_3eta)
  CHARACTER( 4),SAVE :: cmask_day(limit_day)
  CHARACTER( 4),SAVE :: cmask_6hr(limit_6hr)
  CHARACTER( 4),SAVE :: cmask_glob(limit_glob)

!--  time flag.   'AVR' or 'SNP'
  CHARACTER( 3),SAVE :: ctflag_2(limit_2)
  CHARACTER( 3),SAVE :: ctflag_3(limit_3)
  CHARACTER( 3),SAVE :: ctflag_3eta(limit_3eta)
  CHARACTER( 3),SAVE :: ctflag_day(limit_day)
  CHARACTER( 3),SAVE :: ctflag_6hr(limit_6hr)
  CHARACTER( 3),SAVE :: ctflag_glob(limit_glob)

!--  �o�̓��x���ʁB
  INTEGER,SAVE :: lev_day(limit_day)  !-- daily monitor
  INTEGER,SAVE :: lev_6hr(limit_6hr)  !-- 6hourly monitor

!--  ���j�^�ϐ��̐����B
  CHARACTER(32),SAVE :: ctitle_2(limit_2)
  CHARACTER(32),SAVE :: ctitle_3(limit_3)
  CHARACTER(32),SAVE :: ctitle_3eta(limit_3eta)
  CHARACTER(32),SAVE :: ctitle_day(limit_day)
  CHARACTER(32),SAVE :: ctitle_6hr(limit_6hr)
  CHARACTER(32),SAVE :: ctitle_glob(limit_glob)

!--  ���j�^�ϐ��̒P�ʁB
  CHARACTER(13),SAVE :: cunit_2(limit_2)
  CHARACTER(13),SAVE :: cunit_3(limit_3)
  CHARACTER(13),SAVE :: cunit_3eta(limit_3eta)
  CHARACTER(13),SAVE :: cunit_day(limit_day)
  CHARACTER(13),SAVE :: cunit_6hr(limit_6hr)
  CHARACTER(13),SAVE :: cunit_glob(limit_glob)

!--  ���j�^�ϐ��̃o���h�̎����B
!--  'PH' ( physics order )  or 'DY' ( dynamics order )
  CHARACTER(2),SAVE :: corder_2(limit_2)
  CHARACTER(2),SAVE :: corder_3(limit_3)
  CHARACTER(2),SAVE :: corder_3eta(limit_3eta)
  CHARACTER(2),SAVE :: corder_day(limit_day)
  CHARACTER(2),SAVE :: corder_6hr(limit_6hr)
  CHARACTER(2),SAVE :: corder_glob(limit_glob)

!--  �ēc���j�^���o�͂��邩�ǂ����̃t���b�O�B
!--  1 : �o�͂���B   0 : �o�͂����B
  INTEGER,SAVE :: lsdisk_2(limit_2)
  INTEGER,SAVE :: lsdisk_3(limit_3)
  INTEGER,SAVE :: lsdisk_3eta(limit_3eta)
  INTEGER,SAVE :: lsdisk_day(limit_day)
  INTEGER,SAVE :: lsdisk_6hr(limit_6hr)
  INTEGER,SAVE :: lsdisk_glob(limit_glob)

!--  �ēc���j�^�̍ő�l�B
  REAL(8),SAVE :: smax_2(limit_2)
  REAL(8),SAVE :: smax_3(limit_3)
  REAL(8),SAVE :: smax_3eta(limit_3eta)
  REAL(8),SAVE :: smax_day(limit_day)
  REAL(8),SAVE :: smax_6hr(limit_6hr)
  REAL(8),SAVE :: smax_glob(limit_glob)

!--  �ēc���j�^�̍ŏ��l�B
  REAL(8),SAVE :: smin_2(limit_2)
  REAL(8),SAVE :: smin_3(limit_3)
  REAL(8),SAVE :: smin_3eta(limit_3eta)
  REAL(8),SAVE :: smin_day(limit_day)
  REAL(8),SAVE :: smin_6hr(limit_6hr)
  REAL(8),SAVE :: smin_glob(limit_glob)

!--  �ēc���j�^�̊�l�B
  REAL(8),SAVE :: sl_2(limit_2)
  REAL(8),SAVE :: sl_3(limit_3)
  REAL(8),SAVE :: sl_3eta(limit_3eta)
  REAL(8),SAVE :: sl_day(limit_day)
  REAL(8),SAVE :: sl_6hr(limit_6hr)
  REAL(8),SAVE :: sl_glob(limit_glob)

!--  �ēc���j�^�ŁA�|����l�B*smag
  REAL(8),SAVE :: smag_2(limit_2)
  REAL(8),SAVE :: smag_3(limit_3)
  REAL(8),SAVE :: smag_3eta(limit_3eta)
  REAL(8),SAVE :: smag_day(limit_day)
  REAL(8),SAVE :: smag_6hr(limit_6hr)
  REAL(8),SAVE :: smag_glob(limit_glob)
!
CONTAINS

  SUBROUTINE set_com_monit

!--  �z��̑傫���𓮓I�Ɋ���t������B

    ALLOCATE( sum_2   (ijmax,jlmax      ,mxptr_2   ) )
    ALLOCATE( sum_3   (ijmax,jlmax,kmaxm,mxptr_3   ) )
    ALLOCATE( sum_3eta(ijmax,jlmax,kmax ,mxptr_3eta) )
    ALLOCATE( sum_day (ijmax,jlmax      ,mxptr_day ) )
    ALLOCATE( sum_6hr (ijmax,jlmax      ,mxptr_6hr ) )

  END SUBROUTINE set_com_monit



END MODULE com_monit




