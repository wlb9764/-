! module com_step 
! 99/07/20 �ۍ␪�G  ���f���̂����K�v�Ȃ��̂�؂�o���B
! 00/08/24 �ۍ␪�G  mj98 �ɂ�����̂̂ݎc���B�c��� com_step_sib0007 ��
!
!  �X�e�b�v���ɕς��ϐ�/�t���O
!  �T�u���[�`�� time_step �Őݒ肳��Ă���B
!
      MODULE COM_STEP 
!
      IMPLICIT NONE
!
      REAL(8),SAVE  :: SCN_DELT                ! ���ԍ����̂��� 
      REAL(8),SAVE  :: SCN_2DELTX              ! ���[�v�t���b�O�̂Ƃ�
!     REAL(8),SAVE  :: SCNDTSW                 ! �Z�g���˗p DELT ���ԏd��
      INTEGER,SAVE  :: ICNSW                   ! �Z�g���ˌv�Z
      INTEGER,SAVE  :: ICNIR                   ! ���g���ˌv�Z
      INTEGER,SAVE  :: ICNMNTMON               ! �����j�^���o�͂���
      INTEGER,SAVE  :: ICNFST                  ! �����n�߂̃X�e�b�v 
      INTEGER,SAVE  :: ICNLAST                 ! �����ŏI�X�e�b�v
!
      END MODULE 




