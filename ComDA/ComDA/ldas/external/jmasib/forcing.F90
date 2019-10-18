! forcing.F90 - ISLSCP �݊������͓��̓��[�`���̋��L���
! vi: set sw=2 ts=72:
!
! �� islscp.F90 �� islscp_file_unit.F90 �̏��𗼕������Ă���B
! forcing_open ���ŏ��̓ǂݍ��ݎ��ɏ���������B

module forcing

  use prm, only: IDIM, JDIM
  implicit none

  ! ���̓t�@�C���̐�
  integer, parameter:: IDATE_LENGTH = 5
  integer, parameter:: CMARK_LENGTH = 4

  ! ���鎞���̋L�^��ǂݎ�������́B�o�b�t�@�����O�̂��߂Ɏg���B

  type FORCING_RECORD
    ! �L�^�ԍ�
    integer:: irec
    ! �N�������b
    integer:: id(5)   
    ! �f�[�^�{��
    real, pointer:: buf(:, :)
    ! ��ʖ�
    character(len = CMARK_LENGTH):: cmark
  end type

  ! �ǂݏo�������ʂ��Ƃ� FORCING_FILE �\���̂��\������B
  ! ���ׂĂ� FORCING_FILE �\���̂͘A�����X�g�\���ɂȂ��Ă��āA
  ! �ǂݎ�莞�ɂ� cmark �̈�v����m�[�h��T���o���ė��p����B

  type FORCING_FILE
    ! ���ɊJ���ꂽ������
    type(FORCING_FILE), pointer:: next
    ! �����ʖ���
    character(len = CMARK_LENGTH):: cmark
    ! ���u�ԍ�
    integer:: unit
    ! �o�b�t�@�����O�p
    type(FORCING_RECORD):: last
    type(FORCING_RECORD):: before
    ! ���o�͂Ɏ����␳���s���ꍇ�͔���
    integer:: id_offset(IDATE_LENGTH)
    ! �t�@�C���`��: 'MABIKI' = mabiki �o��, 'GRADS' = GrADS �`��
    character(len = 8):: form
    ! form="GRADS" �̏ꍇ�Ɏg�p����闓
    integer:: id_origin(IDATE_LENGTH)  ! ���L�^�̎���
    integer:: id_increment(IDATE_LENGTH)  ! ���ԊԊu
    integer:: tmax  ! �����ő�l
    integer:: varlevs  ! 1����������̃��x����
    integer:: levoffset  ! cmark �ϐ��̎����Q���ł̃I�t�Z�b�g(�ŏ���1)
    real:: lat_origin, lat_increment  ! �R���g���[���t�@�C���̌o�ܓx
    real:: lon_origin, lon_increment
    ! �����I���o�͂��s�����A�����s���Ȃ�΁A�N�_�Ǝ���
    logical:: cyclic
    integer:: id_start(IDATE_LENGTH)
    integer:: id_cycle(IDATE_LENGTH)
    ! ���͂��Ƃɓ��v�������s���ꍇ�́A�}�X�N�z��
    logical, pointer:: maxmin_mask(:, :)
  end type

  ! ���ׂĂ� FORCING_FILE �\���̂�ێ�����A�����X�g�\���̐擪
  type(FORCING_FILE), pointer, save:: FIRST_FILE

  ! cmark �̈�v����m�[�h��T���o�������ʂ̈ꎞ�u����
  type(FORCING_FILE), pointer, save:: cur_file

  !
  ! �����Ȃ�̂ł����ɂ͒u���Ȃ����A�ȉ��̃T�u���[�`��������B
  ! (����Ȃӂ��� interface �����������Ă����΃��W���[���葱��
  ! �悤�Ɉ����̌^�������R���p�C��������Ă���邩��A�Ȃ����܂��B)
  !

  interface

    !
    ! forcing/forcing_open.F90 ����
    !

    subroutine forcing_open(cmark, file, iostat)
      character(len = 4), intent(in):: cmark
      character(len = *), intent(in):: file
      integer, intent(out):: iostat
    end subroutine

    subroutine forcing_set_offset(year, month, day, hour, sec)
      integer, intent(in), optional:: year
      integer, intent(in), optional:: month
      integer, intent(in), optional:: day
      integer, intent(in), optional:: hour
      integer, intent(in), optional:: sec
    end subroutine

    subroutine forcing_seek(rec)
      integer, intent(in):: rec
    end subroutine

    subroutine forcing_select(cmark)
      character(len = *), intent(in):: cmark
    end subroutine

    subroutine forcing_close_files()
    end subroutine

    subroutine forcing_maxmin_region(mask)
      use prm, only: IDIM, JDIM
      logical, intent(in):: mask(IDIM, JDIM)
    end subroutine

    !
    ! forcing/forcing_read.F90 ����
    !

    subroutine forcing_read_id(cmark, data, id)
      use prm, only: IDIM, JDIM
      character(len = 4), intent(in):: cmark
      real(8), intent(out):: data(IDIM, JDIM)
      integer, intent(in):: id(5)
    end subroutine

    subroutine forcing_read_nearest_id(cmark, data, id, halfpoint)
      use prm, only: IDIM, JDIM
      character(len = 4), intent(in):: cmark
      real(8), intent(out):: data(IDIM, JDIM)
      integer, intent(in):: id(5)
      real(8), intent(in):: halfpoint
    end subroutine

    subroutine forcing_read_id2(cmark, id, &
      & id1, data1, id2, data2, weight, update)
      use prm, only: IDIM, JDIM
      character(len = 4), intent(in):: cmark
      integer, intent(in):: id(5)
      integer, intent(out):: id1(5)
      integer, intent(out):: id2(5)
      real, intent(out):: data1(IDIM, JDIM)
      real, intent(out):: data2(IDIM, JDIM)
      real(8), intent(out):: weight
      logical, intent(out):: update
    end subroutine

    subroutine forcing_read_cmark(cmark_f, data, cmark)
      use prm, only: IDIM, JDIM
      character(len = 4), intent(in):: cmark_f, cmark
      real, intent(out):: data(IDIM, JDIM)
    end subroutine

    subroutine forcing_read_real(cmark, irec, data)
      use prm, only: IDIM, JDIM
      character(len = 4), intent(in):: cmark
      integer, intent(in):: irec
      real, intent(out):: data(IDIM, JDIM)
    end subroutine

    subroutine forcing_read_int(cmark, irec, data)
      use prm, only: IDIM, JDIM
      character(len = 4), intent(in):: cmark
      integer, intent(in):: irec
      integer, intent(out):: data(IDIM, JDIM)
    end subroutine

    subroutine forcing_fetch(cmark, irec)
      character(len = 4), intent(in):: cmark
      integer, intent(in):: irec
    end subroutine

    !
    ! forcing/forcing_setup.F90 ����
    !

    subroutine forcing_setup()
    end subroutine

    !
    ! forcing/forcing_ini.F90 ����
    !

    subroutine forcing_ini(id_now, delt_atm, rsec, imask, glon, glat)
      use prm, only: IDIM, JDIM
      integer, intent(in):: id_now(5)
      real(8), intent(in):: delt_atm
      real(8), intent(in):: rsec
      integer, intent(in):: imask(IDIM, JDIM)
      real(8), intent(in):: glon(IDIM, JDIM)
      real(8), intent(in):: glat(IDIM, JDIM)
    end subroutine

    !
    ! forcing/forcing_main.F90 ����
    !
    subroutine forcing_main(& 
      id_now_in, id_pre_in, id_now5,id_pre5, &
      delt_atm, rday, rsec, imask, glon, glat, &! IN
      u_phy, v_phy, pd_phy, ps_phy, pf_phy, tmp_phy, q_phy, &! OUT
      zmean_phy, ztemp_phy, ppli_phy, ppci_phy, &! OUT
      rvisb, rvisd, rnirb, rnird, dlwb)  ! OUT
      !
      use prm, only: IDIM, JDIM
      !
      ! input
      !
      integer, intent(in):: id_now_in(5)  ! �{�X�e�b�v�̎���
      integer, intent(in):: id_pre_in(5)  ! �{�X�e�b�v�̎���
      integer, intent(in):: id_now5
      integer, intent(in):: id_pre5
      real(8), intent(in):: rsec 
      real(8), intent(in):: rday 
      real(8), intent(in):: delt_atm
      real(8), intent(in):: glon(IDIM, JDIM)  !  �o�x�i�P�ʁA�x�j
      real(8), intent(in):: glat(IDIM, JDIM)  ! �ܓx�i�P�ʁA�x�j
      integer, intent(in):: imask(IDIM, JDIM)  !
      !
      ! output 
      !
      real(8), intent(out):: u_phy(IDIM, JDIM)  ! u
      real(8), intent(out):: v_phy(IDIM, JDIM)  ! v 
      real(8), intent(out):: pd_phy(IDIM, JDIM)  ! (ps-ph)*2  
      real(8), intent(out):: ps_phy(IDIM, JDIM)  ! �n�[�t���x�� = pS hpA
      real(8), intent(out):: pf_phy(IDIM, JDIM)  ! �t�����x�� hpA 
      real(8), intent(out):: tmp_phy(IDIM, JDIM)  ! ���x 
      real(8), intent(out):: q_phy(IDIM, JDIM)  ! �䎼 KG/KG
      real(8), intent(out):: zmean_phy(IDIM, JDIM)  ! �ꎞ��?���ϓV���p
      real(8), intent(out):: ztemp_phy(IDIM, JDIM)  ! �e�X�e�b�v�V���p
      real(8), intent(out):: ppli_phy(IDIM, JDIM)  ! ��K�͋Ì����~��
      real(8), intent(out):: ppci_phy(IDIM, JDIM)  ! �ω_���~��
      real(8), intent(out):: rvisb(IDIM * JDIM)  ! ���ˌv�Z�������B
      real(8), intent(out):: rvisd(IDIM * JDIM)  ! ���ˌv�Z�����U��
      real(8), intent(out):: rnirb(IDIM * JDIM)  ! ���ˌv�Z���ߐԒ��B
      real(8), intent(out):: rnird(IDIM * JDIM)  ! ���ˌv�Z���ߐԎU��
      real(8), intent(out):: dlwb(IDIM * JDIM)  ! ���ˌv�Z�����g
    end subroutine

    subroutine monit_regist_forcing()
    end subroutine

    !
    ! forcing/forcing_get_geography.F90 ����
    !

    subroutine forcing_get_geography(out_glon, out_glat, out_imask)
      use prm, only: IDIM, JDIM
      integer, parameter:: DOUBLE = kind(0.0D0) ! i.e. 8 for most systems
      real(DOUBLE), intent(out):: out_glon(IDIM, JDIM)
      real(DOUBLE), intent(out):: out_glat(IDIM, JDIM)
      integer, intent(out), target:: out_imask(IDIM, JDIM)
    end subroutine

    !
    ! forcing/forcing_shortwave.F90 ����
    !

    subroutine forcing_read_shortwave( &
      cmark_swdn, cmark_cld, id, delt_atm, glon, glat, imask, &! IN
      swdn, rvisb, rvisd, rnirb, rnird, zmean_phy, ztemp_phy, cloudiness &! OUT
    )
      use prm, only: IDIM, JDIM
      character(len = 4), intent(in):: cmark_swdn
      character(len = 4), intent(in):: cmark_cld
      integer, intent(in):: id(5)
      real(8), intent(in):: delt_atm
      real(8), intent(in):: glon(IDIM, JDIM)
      real(8), intent(in):: glat(IDIM, JDIM)
      integer, intent(in):: imask(IDIM, JDIM)
      real(8), intent(out):: swdn(IDIM, JDIM)
      real(8), intent(out):: rvisb(IDIM, JDIM)
      real(8), intent(out):: rvisd(IDIM, JDIM)
      real(8), intent(out):: rnirb(IDIM, JDIM)
      real(8), intent(out):: rnird(IDIM, JDIM)
      real(8), intent(out):: zmean_phy(IDIM, JDIM)
      real(8), intent(out):: ztemp_phy(IDIM, JDIM)
      real(8), intent(out):: cloudiness(IDIM, JDIM)
    end subroutine

  end interface

end module