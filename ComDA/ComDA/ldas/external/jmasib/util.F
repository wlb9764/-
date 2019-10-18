! SiB �p���[�e�B���e�B�[�T�u���[�`���p�b�P�[�W
! 99/07/xx �ۍ␪�G
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE RESET ( WORK , IMAX )
!
      IMPLICIT NONE 
!
      INTEGER,INTENT(IN)    :: IMAX      
!
      REAL(8),INTENT(INOUT) :: WORK(IMAX)
!
      INTEGER               :: I
!
      DO 100 I=1,IMAX
        WORK(I) = 0.D0
 100  CONTINUE
!
      RETURN
      END
!===========================================================
      SUBROUTINE COPY ( WORK_IN , WORK_OUT , IMAX )
!
      IMPLICIT NONE 
!
      INTEGER,INTENT(IN)    :: IMAX      
      REAL(8),INTENT(IN)    :: WORK_IN  (IMAX)
      REAL(8),INTENT(OUT)   :: WORK_OUT (IMAX)
!
      INTEGER               :: I
!
      DO 100 I=1,IMAX
        WORK_OUT(I) = WORK_IN(I) 
 100  CONTINUE
!
      RETURN
      END
!=============================================================
      SUBROUTINE IRESET ( IWORK , IMAX )
!
      IMPLICIT NONE 
!
      INTEGER,INTENT(IN)    :: IMAX      
!
      INTEGER,INTENT(INOUT) :: IWORK(IMAX)
!
      INTEGER               :: I
!
      DO 100 I=1,IMAX
        IWORK(I) = 0
 100  CONTINUE
!
      RETURN
      END
!==========================================================
      SUBROUTINE CON_SET ( WORK , IMAX , CON )
!
      IMPLICIT NONE 
!
      INTEGER,INTENT(IN)    :: IMAX      
      REAL(8),INTENT(IN)    :: CON 
!
      REAL(8),INTENT(INOUT) :: WORK(IMAX)
!
      INTEGER               :: I
!
      DO 100 I=1,IMAX
        WORK(I) = CON
 100  CONTINUE
!
      RETURN
      END
!==========================================================
      SUBROUTINE SET_UNDEF ( WORK , IMAX )
!
      IMPLICIT NONE 
!
      INTEGER,INTENT(IN)    :: IMAX      
!
      REAL(8),INTENT(INOUT) :: WORK(IMAX)
!
      INTEGER               :: I
!
      DO 100 I=1,IMAX
        WORK(I) = -9.99D33
 100  CONTINUE
!
      RETURN
      END