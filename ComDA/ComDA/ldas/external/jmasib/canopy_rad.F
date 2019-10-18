! ���˃t���b�N�X �i�e�퉷�x�ˑ����̔��W���j�v�Z
!
! 99/06/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
! 99/08/30 �ۍ␪�G DRAD_DX �̕����ύX�B���������ɂȂ�悤�ɂ���B
!
!
      SUBROUTINE CANOPY_RAD (
     I  NSTR       , NEND        , 
     I  TMP_CNP    , TMP_SKIN    , 
     I  THERMK     , 
     I  CVR_VEG_msx, 
!    I  FLAG_TMPMOD_CNP  , FLAG_TMPMOD_SKIN  , 
     O  DRAD_DX    )
!
! ���ӁB
!     RC ... �L���E�n�ʁE��ʎˏo���g���˃l�b�g�ŁA�L�����o������
!     RG ... �L���E�n�ʁE��ʎˏo���g���˃l�b�g�ŁA�n�ʂ��o������
!     RS ... �L���E�n�ʁE��ʎˏo���g���˃l�b�g�ŁA��ʂ��o������
! 
!     RC    �ɂ� CVR_VEG(I,1) ���������Ă���I
!     RG,TS �ɂ� CVR_SNW �͂������Ă��Ȃ��B
!
!     ��̂���Ƃ���A�����Ƃ��다�ʁB
!
!     DRAD_DX �́A�󂯎������i�����j����!
!
      USE SIBPRM , ONLY : 
     1    IDX    , 
     1    ICG    , 
     1    ICGR
!
      USE SIBCON , ONLY : 
     1    STB4_C    
!
      IMPLICIT NONE 
!
! INPUT
!
      REAL(8),INTENT(IN)    :: TMP_CNP   (IDX)      ! �L���m�s�[���x
      REAL(8),INTENT(IN)    :: TMP_SKIN  (IDX)      ! �n�ʁE��ʏ�[���x
      REAL(8),INTENT(IN)    :: THERMK    (IDX)      ! �L�����g���ߗ�
      REAL(8),INTENT(IN)    :: CVR_VEG_msx(IDX,ICG)
      INTEGER,INTENT(IN)    :: NSTR
      INTEGER,INTENT(IN)    :: NEND
!
!     REAL(8),INTENT(IN)    :: FLAG_TMPMOD_CNP  (IDX)
!     REAL(8),INTENT(IN)    :: FLAG_TMPMOD_SKIN (IDX)
!
! OUTPUT
!
      REAL(8),INTENT(OUT)   :: DRAD_DX     (IDX,ICGR,ICG) 
!
! WORK
!    
      REAL(8)               :: S4_TMP_C3 (IDX)
      REAL(8)               :: S4_TMP_G3 (IDX)
      REAL(8)               :: FAC       (IDX)     ! �L���z���� * Cv 
!
      INTEGER               :: I
!
      LOGICAL,SAVE :: LFIRST
      DATA  LFIRST /.TRUE. /
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'CANOPY_IR 99/07 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      DO 1000 I=NSTR,NEND
!
! �L���m�s�[�̒��g���ˋz����
!
        FAC (I)   = CVR_VEG_msx(I,1) * (1.0D0-THERMK (I))
!
! ��ƕϐ�
!
        S4_TMP_C3 (I) = STB4_c * TMP_CNP (I)**3
        S4_TMP_G3 (I) = STB4_c * TMP_SKIN (I)**3 
!
!     TC �ω��ɂ��t���b�N�X�ω� 
!
        DRAD_DX(I,1,1) = 0                       ! TC �ω��� C-C �̕ω�
        DRAD_DX(I,2,1) =   FAC(I) * S4_TMP_C3(I) ! TC �ω��� C-G �̕ω�
        DRAD_DX(I,3,1) = - FAC(I) * S4_TMP_C3(I) ! TC �ω��� A-C �̕ω�
!
!     TG �ω��ɂ��t���b�N�X�ω� 
!
        DRAD_DX(I,1,2) = - FAC(I) * S4_TMP_G3(I) ! TG �ω��� C-G �̕ω�
        DRAD_DX(I,2,2) = 0. 
        DRAD_DX(I,3,2) = - (1-FAC(I))* S4_TMP_G3(I)! TG �ω��� A-G �̕ω�
!
 1000 CONTINUE 
!
#ifdef KILLRAD
      call reset ( drad_dx_tmp , idx * icg * icg ) ! zzz
#endif
!
      RETURN
      END


