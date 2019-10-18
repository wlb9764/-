! date.F90 - GSM ���������[�`��
! vi: set sw=2 ts=72:
!
! date ���W���[���͒��� 5 �̐����^�z��Ƃ��ĕۑ������������Z��񋟂���B
!
! �����œ����͈ȉ��̂悤�Ɋi�[�����:
!
!       id(1): ����N
!       id(2): ��
!       id(3): ��
!       id(4): ��
!       id(5): ��*60+�b
!
! ���ɁA����N�ƌ��� 0 �ɂȂ��Ă��邱�Ƃ�����B���̂Ƃ��̓��̗���
! 0 �N 0 �� 1 �� (�܂�I���O2�N12��1��) �� 1 �Ƃ���ʓ��ł���B
! �������Ȃǂ̉��Z�ł͒ʓ���p���邪�A�ʓ��ƕ��ʂ̕\�L����ʂ��Ȃ���
! �悢�悤�ɏ�L�I�����I������Ă���B
!
! ����: �ʓ��̌v�Z�ȂǁA�����^�� 16bit �ł͂ł��Ȃ�����������B

module date

! ��@
!       ��@�Ƃ͒ʓ�����N���𓾂�i���邢�͋t���Z�́j�����ł���B
! 
!       360: ���� 30 ���̗�
!       365: ���N 365 ���̗�
!       36525: �����E�X��
!       3652425: �O���S���I�E�����E�X����؊� (1752 �N 9 �� 3 ��)
!       ���̑��̒l: 3652425 �Ƃ݂Ȃ����
!
  integer, save:: calendar_type = 3652425

contains

!=======================================================================
! date_diff - �����̍�
!       idate ���� idate_base ������������ idate_diff �Ɋi�[����B
!       ���͓��A���A�b�����ŕ\������A���� -23 .. 23, �b�� -3599 .. 3599
!       date_calendar �ɂ���@�ݒ�ɂ���ē��삪�ς��.

subroutine date_diff(idate, idate_base, idate_diff)
  integer, intent(in):: idate(5), idate_base(5)
  integer, intent(out):: idate_diff(5)
  integer:: now(5), base(5)
  now(:) = idate(:)
  base(:) = idate_base(:)
  call date_compact(now)
  call date_compact(base)
  idate_diff(:) = now(:) - base(:)
  call date_diff_normalize(idate_diff)
end subroutine

!=======================================================================
! date_diff_normalize - �����̍����킩��₷���`���ɏ�������
!       ���t�̍� id ��\���ɓK�����`���ɏ���������B

subroutine date_diff_normalize(id)
  integer, intent(inout):: id(5)
  ! �N���͓����Ɖ�łȂ��̂ł���ł����܂�
  id(2) = id(1) * 12 + id(2) - 1
  id(1) = id(2) / 12
  id(2) = mod(id(2), 12) + 1
  ! ��������ƕb�ɕ������� (�S���b�ɂ���Ɛ��\�N�ň��邽��)
  id(3) = id(3) + id(4) / 24 + id(5) / 86400
  id(5) = mod(id(5), 86400) + mod(id(4), 24)
  id(4) = 0
  ! �������ƕb�̕������t�Ȃ�
  if (id(5) < 0 .and. id(3) > 0) then
    id(3) = id(3) - 1
    id(5) = id(5) + 86400
  else if (id(5) > 0 .and. id(3) < 0) then
    id(3) = id(3) + 1
    id(5) = id(5) - 86400
  endif
  ! �b���玞�𐶐�
  id(4) = id(5) / 3600
  id(5) = mod(id(5), 3600)
end subroutine

!=======================================================================
! date_compare - �����̑O���r
!       ���t id, id_base ���r���A���茋�ʂ� cmp �ɏ������ށB
!       cmp = 1: date ����, cmp = 0: ����, cmp = -1: date ���O
!       �������͈Ӗ����Ȃ��̂Ŗ����B

subroutine date_compare(id, id_base, cmp)
  integer, intent(in):: id(5), id_base(5)
  integer, intent(out):: cmp
  integer:: id_diff(5), i
  call date_diff(id, id_base, id_diff)
  do, i = 1, 5
    cmp = sign(id_diff(i), id_diff(i))
    if (cmp /= 0) exit
  enddo
end subroutine

!=======================================================================
! date_diff_compact - �����̍���ʌ��E�ʓ��E�ʕb�ɏ�������
!       ���t�̍� id �����Z�ɓK�����`���ɏ���������B

subroutine date_diff_compact(id)
  integer, intent(inout):: id(5)
  id(3) = id(3) + id(4) / 24 + id(5) / 86400 
  id(5) = mod(id(5), 86400) + mod(id(4), 24) * 3600
  id(4) = 0
  id(2) = id(2) + id(1) * 12 
  id(1) = 0
end subroutine

!=======================================================================
! date_diff_div - �����̍������Z
!       �����Ԋu a ������Ԋu b �Ŋ��������� f �����߂�B
!       �����Ԋu�͔N���Ɠ����̒P�ʂ��������Ă͂Ȃ�Ȃ��B

subroutine date_diff_div(a, b, f)
  integer, intent(in):: a(5), b(5)
  double precision:: f
  integer:: ia(5), ib(5)
  ia(:) = a(:)
  call date_diff_compact(ia)
  ib(:) = b(:)
  call date_diff_compact(ib)
  if (ib(2) /= 0) then
    f = dble(ia(2)) / dble(ib(2))
  else if (ib(3) /= 0) then
    f = dble(ia(3)) + dble(ia(5)) / 86400.0
    f = f / (dble(ib(3)) + dble(ib(5)) / 86400.0)
  else if (ib(5) /= 0) then
    f = (ia(5) + ia(3) * 86400.0d0) / dble(ib(5))
  else
    print *, "date_diff_div: division by zero, a=", a
    f = 0.0d0
  endif
end subroutine

!=======================================================================
! date_modulo - ���Ԏ���̓�������������Ő܂�Ԃ�
!       ���� id �� id_origin ���� id_cycle �͈̔͂Ɏ��܂�悤��
!       id_cycle �̐����{����������B

subroutine date_modulo(id, id_origin, id_cycle)
  integer, intent(inout):: id(5)
  integer, intent(in):: id_origin(5), id_cycle(5)
  integer:: idiff(5), idiff_cycle(5)
  double precision:: ratio
  call date_diff(id, id_origin, idiff)
  call date_diff(id_origin + id_cycle, id_origin, idiff_cycle)
  call date_diff_div(idiff, idiff_cycle, ratio)
  if (ratio >= 0.0d0 .and. ratio < 1.0d0) goto 1000
  id = id - id_cycle * floor(ratio)
  1000 continue
  call date_normalize(id)
end subroutine

!=======================================================================
! date_calendar - ��@��ݒ肷��
!       caltype == 0 �ŌĂԂƖ₢���킹
!       ����ȊO�̏ꍇ�͐ݒ�B�Ӗ��� calendar_type �̃R�����g�Q��

subroutine date_calendar(caltype)
  integer, intent(inout):: caltype
  if (caltype == 0) then
    caltype = calendar_type
  else
    calendar_type = caltype
  endif
end subroutine

!=======================================================================
! date_compact - �����\�L��ʓ��E�b�ɕϊ�
!       idate ���I���O1�N3���������0�Ƃ���ʓ��A�����ʕb �����ŕ\���������B
!       date_calendar �ɂ���@�ݒ�ɂ���ē��삪�ς��.

subroutine date_compact(idate)
  integer, intent(inout):: idate(5)
  integer, parameter:: four_years = 365 * 4 + 1
  integer:: second, hour, iday_sec, iday_hour, year, month, century
  ! ���E�b����ƒʕb�ɕ����B�ʕb�͕��ɂ��Ȃ�
  second = modulo(idate(5), 86400)
  hour = modulo(idate(4), 24)
  iday_sec = (idate(5) - second) / 86400
  iday_hour = (idate(4) - hour) / 24
  idate(5) = second + hour * 3600
  idate(3) = idate(3) + iday_sec + iday_hour
  idate(4) = 0
  ! 1����2���͑O�N�̈����ɂ���
  month = modulo(idate(2) - 3, 12) + 3
  year = idate(1) + (idate(2) - month) / 12
  century = (year - modulo(year, 100)) / 100 + 1
  idate(1:2) = 0
  if (calendar_type == 360) then
    ! 1 �N�� 360 ���̗�
    idate(3) = idate(3) + (year * 12 + month) * 30
    return
  endif
  ! �����𖈔N3��1���� 1 �Ƃ���ʓ��ɕϊ�
  idate(3) = idate(3) + (month * 306 - 914) / 10
  ! �N�ƔN���ʓ����琢�I�ʓ����Z�o
  if (calendar_type == 365) then
    ! 1 �N�� 365 ���̗�
    idate(3) = idate(3) + year * 365 + 90
    return
  else
    idate(3) = idate(3) + (year * four_years - modulo(year * four_years, 4))/ 4
    ! �f�t�H���g�ł̃O���S���I��ڍs�̓��t�͉p���̂��̂ł���
    if (calendar_type == 36525 .or. idate(3) < 640116) then
      ! �����E�X��
      idate(3) = idate(3) + 91
    else
      ! ���I�ɂ��␳: �O���S���I��, �ʓ��̓����E�X��ƌ݊�
      idate(3) = idate(3) - (century * 3 - modulo(century * 3, 4)) / 4 + 93
    endif
  endif
end subroutine

!=======================================================================
! date_normalize - �ʓ��E�ʕb����Z���ʂȂǂɂ��s�������𒼂�
!       date_calendar �ɂ���@�ݒ�ɂ���ē��삪�ς��.

subroutine date_normalize(idate)
  integer, intent(inout):: idate(5)
  integer:: second, hour, iday_sec, iday_hour, day, year, month
  integer, parameter:: four_year = 365 * 4 + 1
  integer, parameter:: four_century = 365 * 400 + 97

  ! ���͂��ʓ��ɂȂ��Ă��Ȃ���Βʓ��ϊ�
  if (idate(1) /= 0 .or. idate(2) /= 0) then
    call date_compact(idate)
  endif

  ! �ʕb���玞�b�𕪗��B�ʕb�͕��ɂ��Ȃ�
  second = modulo(idate(5), 86400)
  hour = modulo(idate(4), 24)
  iday_sec = (idate(5) - second) / 86400
  iday_hour = (idate(4) - hour) / 24
  idate(5) = modulo(second, 3600)
  idate(4) = hour + second / 3600
  idate(3) = idate(3) + iday_sec + iday_hour

  ! ��@�ɂ���ē�����N���̎Z�o�͈قȂ�
  if (calendar_type == 360) then
    day = modulo(idate(3) - 31, 360)
    idate(1) = (idate(3) - 31 - day) / 360
    idate(2) = day / 30 + 1
    idate(3) = modulo(day, 30) + 1
    return
  endif
  if (calendar_type == 365) then
    day = modulo(idate(3) - 91, 365)
    idate(1) = (idate(3) - 91 - day) / 365
  else
    ! �I�����s�b�N�̂���N��3��1����0�Ƃ���ʓ����v�Z
    if (calendar_type == 36525 .or. idate(3) < 640196) then
      ! �����E�X��
      day = modulo(idate(3) - 92, four_year)
      year = (idate(3) - 92 - day) / four_year * 4
    else
      ! �O���S���I��
      day = modulo(idate(3) - 94, four_century)
      year = (idate(3) - 94 - day) / four_century * 400
      if (day == four_century - 1) then
        year = year + 300
        day = 36524
      else
        year = year + day / 36524 * 100
        day = modulo(day, 36524)
      endif
      year = year + day / four_year * 4
      day = modulo(day, four_year)
    endif
    ! �I�����s�b�N�̂���N��3��1����0�Ƃ���ʓ�����
    ! 3���ł͂��܂�N�ƔN���ʓ����v�Z
    if (day == four_year - 1) then
      idate(1) = year + 3
      day = 365
    else
      idate(1) = year + day / 365
      day = modulo(day, 365)
    endif
  endif
  ! 3��1����0�Ƃ���ʓ����猎�����v�Z���A�N������N�n�ɏC��
  day = day * 10 + 922
  month = day / 306
  idate(2) = mod(month - 1, 12) + 1
  idate(1) = idate(1) + (month - idate(2)) / 12
  idate(3) = mod(day, 306) / 10 + 1
end subroutine

!=======================================================================
end module