! �n�\�ʁiSiB�j���󂯎��Z�g���˗ʂ́A���ԕ␳
! 99/05/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE RAD_SHRT_COR (
     I  NMAX    , NMAX_01 , 
     I  ZMEAN   , ZTEMP   , 
     M  RAD_SHRT_NOS      ,  RAD_SHRT_SNW       )  
!
! �n�\�ʁiSiB�j���󂯎��Z�g���˗ʂ́A���ԕ␳
!   �Z�g���˂͈ꎞ�ԂɈ�x�����v�Z���Ȃ����A
!   SiB �͖��X�e�b�v�v�Z���邽�߂ɕK�v�ɂȂ�B
!
! ���ӓ_
!   �ERAD_CG �͂��̎��_�ł́A�Z�g��^���̂݁B���ƂŒ��g�����������܂��B
!     �܂��A��ʂɂ��ẮA���̎��_�ł̓[���łȂ��l�������Ă���B
!     �i������ RAD_SNW �� RAD_DS1 �ɐU�蕪�����A�[���ɂȂ�j
!
!   �E�]���� SiB �ł͓����o���h���̗��i�q�����o���ď��ɂ߂�΂悩�������A
!     ���E�ۍ� SiB �ł͐ᖳ����ƐႠ����ʁX�ɂ���K�v����B
!     �i�Ⴀ���� RAD_CG,RADN �Ɛᖳ����� RAD_CG,RADN �Ƃ�ʁX�ɓ��邽�߁B�j
!
! �ۑ� �i�o�O??? �j
!   �␳�̎d�����G�l���M�[�ۑ��I�łȂ�?! 
!   �܂�A
!     ��C�Z�g���ˌv�Z�ňꎞ�Ԃɒn�ʂ��z�������ł��낤���˃G�l���M�[�ʂ�
!     �n�\�ʂ����ۂɎ󂯎�������˃G�l���M�[�ʂɂ��ꂪ����B
!   �v�`�F�b�N
!   
!
      USE SIBPRM , ONLY : 
     1   IDX    , 
     1   ICG    
!
      IMPLICIT NONE 
!
! ����
      INTEGER,INTENT(IN)   :: NMAX
      INTEGER,INTENT(IN)   :: NMAX_01(3)
!
      REAL(8),INTENT(IN)   :: ZMEAN  (IDX)
      REAL(8),INTENT(IN)   :: ZTEMP  (IDX)
!
! OUTPUT 
!
      REAL(8),INTENT(INOUT):: RAD_SHRT_NOS (IDX,ICG) ! �Z�g�z���� BD,WV���v�B
      REAL(8),INTENT(INOUT):: RAD_SHRT_SNW (IDX,ICG) ! �Z�g�z���� BD,WV���v�B
!
! WORK 
!
      INTEGER   :: N 
      REAL(8),PARAMETER  :: D01 = 0.01D0
!

      LOGICAL LFIRST
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'RAD_SHRT_COR 99/07 POCHAKA '
        LFIRST = .FALSE.
      ENDIF 
!
!   --------------------
!   >>  ���ʓ��˒Z�g  <<
!   --------------------
!     ����͂��Ƃ��� XRAD_CG �� SiB �i�q�ł���B
!     �Ⴀ�莞�͉����͂Ȃ��B
!
      DO 1000 N=1,NMAX_01(3)
        RAD_SHRT_NOS(N,1  ) = RAD_SHRT_NOS (N,1) 
     1                * ZTEMP(N) / MAX(D01,ZMEAN(N))    ! �␳  ppp
        RAD_SHRT_NOS(N,2  ) = RAD_SHRT_NOS (N,2) 
     1                * ZTEMP(N) / MAX(D01,ZMEAN(N))    ! �␳  ppp
 1000 CONTINUE
!
      DO 2000 N=NMAX_01(2),NMAX
        RAD_SHRT_SNW(N,1  ) = RAD_SHRT_SNW (N,1) 
     1                * ZTEMP(N) / MAX(D01,ZMEAN(N))    ! �␳  ppp
        RAD_SHRT_SNW(N,2  ) = RAD_SHRT_SNW (N,2) 
     1                * ZTEMP(N) / MAX(D01,ZMEAN(N))    ! �␳
 2000 CONTINUE
!
      RETURN
      END