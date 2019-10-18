      SUBROUTINE WATER_OUT ( 
     I     NSTR       , NEND       , 
     I     PR_TRAP    , PR_TRAP_MAX, 
     I     A_PR_COEF  , B_PR_COEF  , C_PR_COEF  , 
     O     PR_DROP     )
!
! �A���E�y����w�ň�U�g���b�v���� PR_TRAP �̂����A
! �\�����e�� PR_TRAP_MAX ���z���镪 PR_DROP �𗎉�������B
!
      USE SIBPRM , ONLY :
     1    IDX 
!
      IMPLICIT NONE
!
! INPUT 
      INTEGER,INTENT(IN)    :: NSTR 
      INTEGER,INTENT(IN)    :: NEND
      REAL(8),INTENT(IN)    :: PR_TRAP     (IDX)  ! ��U�ߑ������J��
      REAL(8),INTENT(IN)    :: PR_TRAP_MAX (IDX)  ! �ߑ��ł������l
                                                  !    = �O�a - ���L
      REAL(8),INTENT(IN)    :: A_PR_COEF   (IDX)   
      REAL(8),INTENT(IN)    :: B_PR_COEF 
      REAL(8),INTENT(IN)    :: C_PR_COEF   (IDX)   
!
! OUTPUT 
      REAL(8),INTENT(OUT)   :: PR_DROP     (IDX)  ! ���������
!
! WORK 
      INTEGER    :: I
!
      REAL(8)    :: ARG 
      REAL(8)    :: X_SAT
      REAL(8)    :: ARG_MIN     
      REAL(8)    :: DZERO
      REAL(8)    :: DONE
      REAL(8)    :: TRAP_MIN     ! PR_TRAP_MAX ������ȉ��̏ꍇ�͑S�ė���
!
      LOGICAL,SAVE ::  LFIRST 
!
      DATA ARG_MIN  / 1.D-12 /   ! B_PR_COEF ��菬�������ƁB
      DATA TRAP_MIN / 1.D-12 /   
      DATA DZERO    / 0.D0 /
      DATA DONE     / 1.D0 /
!
      DATA LFIRST /.TRUE./
!
      IF ( LFIRST ) THEN
        WRITE(6,*) 'LDRAIN 99/07 POCHAKA'
        LFIRST = .FALSE. 
      ENDIF
!
      DO 100 I=NSTR,NEND
!
! �J�ʂ����Ȃ���ΑS�ĕߑ� 
!      �i�[������̃G���[�����̂��߁B���ɖO�a���Ă���ꍇ�͍Ō�j
!
        IF ( PR_TRAP(I) .LT. 1.0D-20 ) THEN
          PR_DROP (I) = 0.0D0
!
! �J�ʂ������͂����
        ELSE
          ARG = ( PR_TRAP_MAX(I) / PR_TRAP(I) - C_PR_COEF(I) ) 
     1           / A_PR_COEF(I)
!
          IF ( ARG .GE. ARG_MIN ) THEN                  ! �J�ʂ������Ȃ�
            X_SAT = - 1.0D0 / B_PR_COEF * LOG ( ARG )
            X_SAT = MIN ( X_SAT , DONE  )
            X_SAT = MAX ( X_SAT , DZERO )
          ELSE                                          ! �J�ʂ�����
            X_SAT  = 1.0D0
          END IF
!
          PR_DROP(I) 
     1      =  PR_TRAP(I) * A_PR_COEF(I) / B_PR_COEF 
     1                    * ( 1.0D0 - DEXP ( - B_PR_COEF * X_SAT ) )  
     1         + ( C_PR_COEF(I) * PR_TRAP(I) - PR_TRAP_MAX(I) ) * X_SAT     
!
        END IF
!
! �����O�a���Ă�����

        IF ( PR_TRAP_MAX (I) .LT. TRAP_MIN ) THEN
          PR_DROP (I) = PR_TRAP (I)
        ENDIF
  100 CONTINUE
!
      RETURN
      END