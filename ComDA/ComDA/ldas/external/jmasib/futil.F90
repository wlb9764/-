! futil.F90 - ���o�͊֌W�̌���@�\��⊮����T�u���[�`��
!=======================================================================
! get_unused_unit - ���g�p�ŗ��p�\�ȑ��u�ԍ� unit ��T������B
! unified-sibs ��z�肵�đ��u�ԍ� 51--69 ���D��I�Ɋ��蓖�Ă���
!
subroutine get_unused_unit(unit)
  implicit none
  integer, intent(out):: unit 
  logical:: exist, opened
  do, unit = 51, 69
    inquire(unit=unit, exist=exist, opened=opened)
    if (exist .and. .not. opened) return
  enddo
  do, unit = 1, 1001, 2
    inquire(unit=unit, exist=exist, opened=opened)
    if (exist .and. .not. opened) return
  enddo
  unit = -1
end subroutine

!=======================================================================
! read_grads_date - GrADS �R���g���[���t�@�C���ɋ�����鎞�������̓ǂݎ��
! string format: [hh[:mm]Z][dd]mmm[cc]yy
!   mmm �͒萔 mmm ���Q��
! idate �� (/iy, imon, id, ih, isec/) ����Ȃ�z��

subroutine read_grads_date(string, idate)
  implicit none
  character(len = *), intent(in):: string
  integer, intent(out):: idate(5)
  character(len = 15):: prefix, word, suffix
  character(len = 3), parameter:: mmm(12) = &
    & (/'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', &
    & 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'/)
  integer:: i, ofs
continue
  word = string
  call uppercase(word)

  ! ���������o��
  idate(2) = 0
  do, i = 1, 12
    ofs = index(word, mmm(i))
    if (ofs == 0) cycle
    ! �������o�����Ύc������
    idate(2) = i
    prefix = word(1: ofs-1)
    suffix = word(ofs+3: len(word))
    read(unit=suffix, fmt='(I4)') idate(1)
    if (len_trim(suffix) <= 2) then
      if (idate(1) < 50) idate(1) = idate(1) + 2000
      if (idate(1) < 100) idate(1) = idate(1) + 1900
    endif
    exit
  enddo
  if (idate(2) == 0) then
    print *, 'warning: read_grads_date error <', trim(string), '>'
    idate(:) = 0
    return
  endif

  ! Z �����o��
  word = prefix
  ofs = index(word, 'Z')
  if (ofs == 0) then
    prefix = "00:00"
  else
    prefix = word(1:ofs-1)
  endif
  suffix = word(ofs+1: len(word))
  
  if (suffix == '') then
    idate(3) = 1
  else
    read(suffix, '(I2)') idate(3)
  endif

  ! : �����o��
  word = prefix
  ofs = index(word, ':')
  if (ofs == 0) then
    prefix = word
    suffix = "00"
  else
    prefix = word(1:ofs-1)
    suffix = word(ofs+1: len(word))
  endif

  if (suffix == '') then
    idate(5) = 0
  else
    read(suffix, '(I2)') idate(5)
    idate(5) = idate(5) * 60
  endif
  if (prefix == '') then
    idate(4) = 0
  else
    read(prefix, '(I2)') idate(4)
  endif
end subroutine

!=======================================================================
! read_grads_increment - GrADS �R���g���[���t�@�C���̎��ԍ��݂̓ǂݎ��
! string format: xxMN|xxHR|xxDY|xxMO|xxYR
! idate �� (/iy, imon, id, ih, isec/) ����Ȃ�z��

subroutine read_grads_increment(string, idate)
  implicit none
  character(len = *), intent(in):: string
  integer, intent(out):: idate(5)
  character(len = 4):: word
  integer:: ofs, value
continue
  ofs = verify(string, ' -0123456789')
  word = string(1: ofs-1)
  read(word, '(I4)') value
  word = string(ofs: ofs+1)
  call uppercase(word)
  idate(:) = 0
  if (word == 'YR') then
    idate(1) = value
  else if (word == 'MO') then
    idate(2) = value
  else if (word == 'DY') then
    idate(3) = value
  else if (word == 'HR') then
    idate(4) = value
  else if (word == 'MN') then
    idate(5) = value * 60
  else
    print *, 'warning: read_grads_increment error <', trim(string), '>'
  endif
end subroutine
