! replace.F90 - ������֌W�̌���@�\��⊮����T�u���[�`��
! vi: set ts=70 sw=2:
! 2000-06-01 TOYODA Eizi

!=======================================================================
! uppercase - ��������啶���ɒu������
! �����^�ϐ� string �̒��ɉp������������ΑΉ�����p�啶���ɒu������B

subroutine uppercase(string)
  character(len = *), intent(inout):: string
  character(len = *), parameter:: UC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  character(len = *), parameter:: LC = 'abcdefghijklmnopqrstuvwxyz'
  integer:: i, idx
  do, i = 1, len(string)
    idx = index(LC, string(i:i))
    if (idx == 0) cycle
    string(i:i) = UC(idx:idx)
  enddo
end subroutine

!=======================================================================
! getword - ������̐擪�̌�𔲂��o��
! �����^�ϐ� string ���󔒂ŋ�؂�A�ŏ��̌�� word �Ɋi�[���A
! ���̌�ȍ~�� string �Ɋi�[����B�ꂪ�Ȃ���� word �͋󔒂ƂȂ�

subroutine getword(string, word)
  character(len = *), intent(inout):: string
  character(len = *), intent(out):: word
  integer:: idx, strlen
  strlen = len(string)

  ! �擪�̋󔒂̏���
  idx = verify(string, ' ')
  if (idx == 0) then
    word = ''
    return
  endif
  string = string(idx: strlen)

  ! �擪�̌�̔����o��
  idx = scan(string, ' ')
  if (idx == 0) then
    word = string
    string = ''
    return
  endif
  word = string(1: idx-1)
  string(1: idx-1) = ' '
  idx = verify(string, ' ')
  if (idx == 0) idx = 1
  string = string(idx:strlen)
end subroutine

!=======================================================================
! replace_int - �����񒆂ɐ����l�𖄂ߍ���
! �����^�ϐ� string �̒��� pattern �Ƃ������������񂪂���΁A���� int ��
! 10 �i�\���������̂ɒu��������Bpattern ���݂���Ȃ���Ή����N����Ȃ��B
! pattern �̌������傫������ꍇ�͉E�l�ō��� 0 ������B

subroutine replace_int(string, pattern, int)
  character(len = *), intent(inout):: string
  character(len = *), intent(in):: pattern
  integer, intent(in):: int
  character(len = 32):: format
  integer:: head, length, tail
  intrinsic index, trim, len_trim
continue
  head = index(string, trim(pattern))
  if (head < 1) return
  length = len_trim(pattern)
  tail = head + length - 1
  write(format, "('(i', i4, '.', i4, ')')") length, length
  write(string(head:tail), format) int
end subroutine

!=======================================================================
! replace_char - �������ʂ̕�����Œu��������
! �����^�ϐ� string �̒��� pattern �Ƃ������������񂪂���΁Achar ��
! �u��������Bpattern ���݂���Ȃ���Ή����N����Ȃ��B
! pattern �� char �̒������Ⴄ�ꍇ�͎c��̕������K�؂ɃV�t�g�����B

subroutine replace_char(string, pattern, char)
  character(len = *), intent(inout):: string
  character(len = *), intent(in):: pattern
  character(len = *), intent(in):: char
  integer:: head, shift, tail, i
  intrinsic index, trim, len_trim
continue
  head = index(string, trim(pattern))
  if (head < 1) return
  shift = len_trim(char) - len_trim(pattern)
  tail = head + len_trim(char) - 1
  if (shift > 0) then
    do i = len(string), tail, -1
      string(i:i) = string(i-shift:i-shift)
    enddo
  else if (shift < 0) then
    do i = tail, len(string) + shift, 1
      string(i:i) = string(i-shift:i-shift)
    enddo
    string(len(string) + shift: len(string)) = ''
  endif
  string(head: tail) = trim(char)
end subroutine

!/* for debugging */
#if DEBUG_MAIN
program main
  character(len = 60):: buffer
  character(len = 60):: homedir
  buffer = '$HOME/data/test%YYY_%M_%D_%H'
  call getenv('HOME', 4, homedir, len(homedir))
  print *, buffer
  call replace_char(buffer, '$HOME', homedir)
  print *, buffer
  call replace_char(buffer, 'data', 'dat')
  print *, buffer
  call replace_int(buffer, '%YYY', 2000)
  print *, buffer
  call replace_int(buffer, '%M', 5)
  print *, buffer
  call replace_int(buffer, '%D', 25)
  print *, buffer
  call replace_int(buffer, '%H', 23)
  print *, buffer
end program
#endif