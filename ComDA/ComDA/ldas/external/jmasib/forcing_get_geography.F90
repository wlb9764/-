! forcing_get_geography.F90 - SiB �����̓t�@�C������i�q�����E�o�ܓx���擾
! vi: set sw=2 ts=72:

!=======================================================================
! forcing_get_geography(glon, glat, imask) - �A���E�o�ܓx�̓ǂݎ��
!   cmark='VEG' �Ƃ��ĊJ�����t�@�C������A�� imask, �o�ܓx glon, glat ��
!   �ǂݎ��B
!   islscp_config_set �ɑΉ�����B

subroutine forcing_get_geography(glon, glat, imask)
  use forcing, only: IDIM, JDIM, CUR_FILE
  implicit none
  integer, parameter:: DOUBLE = kind(0.0D0) ! i.e. 8 for most systems
  real(DOUBLE), intent(out):: glon(IDIM, JDIM)
  real(DOUBLE), intent(out):: glat(IDIM, JDIM)
  integer, intent(out), target:: imask(IDIM, JDIM)
  real:: glon_real(IDIM, JDIM)
  real:: glat_real(IDIM, JDIM)
  integer:: i, j

  !
  ! �A�����ނ̓ǂݎ��
  !
  call forcing_read_int('VEG ', -1, imask)
  ! C4 �A�������^�A�����ނ� SiB �A�����ނɕϊ�
  ! 0..14 �� SiB �A�����ނ���͂����ꍇ 0..13 �̕��ނɒu������
  where (imask == 14) imask = 6
  where (imask == 15) imask = 7

  !
  ! �o�ܓx�̓ǂݎ��
  !
  call forcing_read_cmark('LON ', glon_real, 'LON ')
  if (glon_real(1, 1) /= -999.0) then
    glon(:, :) = glon_real(:, :)
  else
    do, i = 1, IDIM
      glon(i, :) = cur_file%lon_origin &
        + real(i - 1, kind=DOUBLE) * cur_file%lon_increment
    enddo
  endif

  call forcing_read_cmark('LAT ', glat_real, 'LAT ')
  if (glat_real(1, 1) /= -999.0) then
    glat(:, :) = glat_real(:, :)
  else
    do, j = 1, JDIM
      glat(:, j) = cur_file%lat_origin &
        + real(j - 1, kind=DOUBLE) * cur_file%lat_increment
    enddo
  endif

  ! JMA/SiB �� 25 ��A�����ނɕϊ�
  ! �X (����13) �� 25 �ԂɁA�씼���̐A�� 1..12 �� 13..24 �ɒu������
  where (imask == 13) imask = 25
  do, j = 1, JDIM
    do, i = 1, IDIM
      if (imask(i, j) <= 0) cycle
      if (imask(i, j) >= 13) cycle
      if (glat(i, j) >= 0) cycle
      imask(i, j) = imask(i, j) + 12
    enddo
  enddo

  ! �ȒP�ȕ�
  write(6, "(' veg. :', 13(i4))") (i, i = 0, 12)
  write(6, "(' count:', 13(i4))") (count(imask == i), i = 0, 12)
  write(6, "(' veg. :', 14(i4))") (i, i = 13, 25)
  write(6, "(' count:', 14(i4))") (count(imask == i), i = 13, 25)
  write(6, *) real(count(imask == 0)) / size(imask) * 100, '% water'
  write(6, *) real(count(imask == 25)) / size(imask) * 100, '% ice'

  !
  ! ���̕ϐ��̓��͎��Ɍ������s���͈͂�ݒ�
  !
  call forcing_maxmin_region(imask /= 0)
end subroutine