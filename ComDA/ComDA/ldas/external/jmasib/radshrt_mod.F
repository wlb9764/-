      SUBROUTINE RADSHRT_MOD (
     I    NMAX              , ILIST             , JL         , 
     I    CVR_SNW           , CVR_SNW_NEXT      , 
     I    INFO_SNOW         , INFO_SNOW_NEXT    , 
     M    RAD_SHRT_NOS_SAVE   , R_STM_BAR_PAR_NOS_SAVE  , 
     M    RAD_SHRT_SNW_SAVE   , R_STM_BAR_PAR_SNW_SAVE  ) 
!
!  ��̔핢�����ς�����Ƃ��ŒZ�g���ˌv�Z�̒��O�ȊO�̃X�e�b�v�ŁA
!  �Z�g���ˊ֘A�̏��ʂ��C������B
!
!   �E�Z�g�t���b�N�X�ɂ��ẮA
!     (1) ����`��ɒl���ł����Ƃ��̓R�s�[
!     (2) �ʐς��ς�����ꍇ�͕��ϒl���ς��Ȃ��悤�ɏC��
!   �E�C�E��R�ɂ��Ă�
!     (1) ����`��ɒl���ł����Ƃ��̓R�s�[
!
!  �Ƃ����΍���Ƃ�B
!
      USE PRM  , ONLY :
     1    IJPHY , 
     1    JLPHY , 
     1    ISPT  
!
      USE SIBPRM , ONLY : 
     1     IDX   ,
     1     ICG 
!
! INPUT
!
      INTEGER,INTENT(IN)   ::  NMAX
      INTEGER,INTENT(IN)   ::  JL
      INTEGER,INTENT(IN)   ::  ILIST  (IDX)    ! SiB -> �SSiB 
!
      REAL(8),INTENT(IN)   ::  CVR_SNW       (IDX)
      REAL(8),INTENT(IN)   ::  CVR_SNW_NEXT  (IDX)
      INTEGER,INTENT(IN)   ::  INFO_SNOW     (IDX)
      INTEGER,INTENT(IN)   ::  INFO_SNOW_NEXT(IDX)
!
! INOUT
!
      REAL(8),INTENT(INOUT):: RAD_SHRT_NOS_SAVE  (ISPT*IJPHY,JLPHY,ICG)  
      REAL(8),INTENT(INOUT):: RAD_SHRT_SNW_SAVE  (ISPT*IJPHY,JLPHY,ICG)  
!
      REAL(8),INTENT(INOUT):: 
     1            R_STM_BAR_PAR_NOS_SAVE(ISPT*IJPHY,JLPHY,ICG) ,
     1            R_STM_BAR_PAR_SNW_SAVE(ISPT*IJPHY,JLPHY,ICG) 
!
! WORK
!
      INTEGER  :: I
      REAL(8)  :: FAC_NOS_NOS       (IDX)
      REAL(8)  :: FAC_SNW_SNW       (IDX)
      REAL(8)  :: RAD_SHRT_NOS      (IDX,ICG)
      REAL(8)  :: RAD_SHRT_SNW      (IDX,ICG)
!
      REAL(8),PARAMETER  :: R_STM_MAX = 1.D10 
!
! ================================
! >> �ᖳ���i�q�ɐႪ�������Ƃ� <<
! ================================
!
#include "indep_fixedform"
      DO I = 1,NMAX
        J = ILIST(I) 
        IF ( INFO_SNOW_NEXT(I).GE.0 .AND. INFO_SNOW(I).LT.0 ) THEN
          RAD_SHRT_SNW_SAVE (J,JL,1) = RAD_SHRT_NOS_SAVE (J,JL,1)  
          RAD_SHRT_SNW_SAVE (J,JL,2) = RAD_SHRT_NOS_SAVE (J,JL,2)  
!
          R_STM_BAR_PAR_SNW_SAVE(J,JL,1)
     1                               = R_STM_BAR_PAR_NOS_SAVE(J,JL,1)
        ENDIF
      ENDDO
!
! ======================================
! >> �S�ʐ�i�q�ɐᖳ���悪�������Ƃ� <<
! ======================================
!    �����͍���̂ŁA�傫���l��^���Ă��܂����B
!
#include "indep_fixedform"
      DO I = 1,NMAX
        J = ILIST(I) 
        IF ( INFO_SNOW_NEXT(I).LE.0 .AND. INFO_SNOW(I).GE.1 ) THEN
          RAD_SHRT_NOS_SAVE (J,JL,1) = RAD_SHRT_SNW_SAVE (J,JL,1)  
          RAD_SHRT_NOS_SAVE (J,JL,2) = RAD_SHRT_SNW_SAVE (J,JL,2)  
          R_STM_BAR_PAR_NOS_SAVE(J,JL,1)
     1                               = R_STM_BAR_PAR_SNW_SAVE(J,JL,1)
          R_STM_BAR_PAR_NOS_SAVE(J,JL,2)
     1                               = R_STM_MAX 
        ENDIF
      ENDDO
!
! ============================
! >> �Z�g���˃Z�[�u�l�̕ύX <<
! ============================
!    �S�i�q���ς��ς��Ȃ��悤�ɕ␳����B
!
      DO I=1,NMAX
        IF     ( CVR_SNW_NEXT(I) .EQ. CVR_SNW(I) ) THEN
          FAC_NOS_NOS(I) = 1.                                ! ���� -> ����
          FAC_SNW_SNW(I) = 1.                                ! ���� -> ����
        ELSEIF ( CVR_SNW_NEXT(I) .GT. CVR_SNW(I) ) THEN  ! �Ⴊ������
          FAC_NOS_NOS(I) = 1.                                ! ���� -> ����
          FAC_SNW_SNW(I) = CVR_SNW(I) / CVR_SNW_NEXT(I)      ! ���� -> ����
        ELSEIF ( CVR_SNW_NEXT(I) .LT. CVR_SNW(I) ) THEN  ! �Ⴊ����
          FAC_NOS_NOS(I) = ( 1 - CVR_SNW(I) ) 
     1                       / ( 1 - CVR_SNW_NEXT(I) )       ! ���� -> ����
          FAC_SNW_SNW(I) = 1.                                ! ���� -> ����
        ENDIF
      ENDDO
!
#include "indep_fixedform"
      DO I=1,NMAX
        J = ILIST(I) 
        IF ( CVR_SNW_NEXT(I) .NE. CVR_SNW(I) ) THEN  
          RAD_SHRT_NOS(I,1)                                   
     1       =   RAD_SHRT_NOS_SAVE (J,JL,1) * FAC_NOS_NOS(I)          
     1         + RAD_SHRT_SNW_SAVE (J,JL,1) * ( 1 - FAC_NOS_NOS(I) )  
          RAD_SHRT_NOS(I,2)                                   
     1       =   RAD_SHRT_NOS_SAVE (J,JL,2) * FAC_NOS_NOS(I)          
     1         + RAD_SHRT_SNW_SAVE (J,JL,2) * ( 1 - FAC_NOS_NOS(I) )  
!
          RAD_SHRT_SNW(I,1)                                   
     1       =   RAD_SHRT_NOS_SAVE (J,JL,1) * ( 1 - FAC_SNW_SNW(I) )  
     1         + RAD_SHRT_SNW_SAVE (J,JL,1) * FAC_SNW_SNW(I)          
          RAD_SHRT_SNW(I,2)                                   
     1       =   RAD_SHRT_NOS_SAVE (J,JL,2) * ( 1 - FAC_SNW_SNW(I) )  
     1         + RAD_SHRT_SNW_SAVE (J,JL,2) * FAC_SNW_SNW(I)          
        ENDIF
      ENDDO
!
      DO I=1,NMAX
        J = ILIST(I) 
        IF ( CVR_SNW_NEXT(I) .NE. CVR_SNW(I) ) THEN  
          RAD_SHRT_NOS_SAVE (J,JL,1) = RAD_SHRT_NOS      (I,1)    
          RAD_SHRT_NOS_SAVE (J,JL,2) = RAD_SHRT_NOS      (I,2)    
          RAD_SHRT_SNW_SAVE (J,JL,1) = RAD_SHRT_SNW      (I,1)    
          RAD_SHRT_SNW_SAVE (J,JL,2) = RAD_SHRT_SNW      (I,2)    
        ENDIF
      ENDDO
!
      RETURN
      END