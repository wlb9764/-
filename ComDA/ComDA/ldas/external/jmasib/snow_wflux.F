! ����w������ ���i�B����������̂Ƃ���͂���܂łƂ��܂�ς��Ȃ��ꍇ�B
! 99/07/10 �ۍ␪�G   �V�K�쐬
! 99/08/04 �ۍ␪�G ��򂳂�ɓn���o�[�W�����t�B�b�N�X
!
      SUBROUTINE SNOW_WFLUX (
     I   NMAX         , 
     I   NMAX_01      , NMAX_2    , NMAX_3    , 
     I   H2O_PRECIPI  , ENG_PRECIPI   , RHO_PRECIPI_INV       , 
     I   H2O_SNOW     , ENG_SNOW      , RHO_SNOW_INV        , 
     I   I_SNOW_LEV   , 
     M   IFLG_SLEV_CHANGE      , 
     O   ENG_SNOW_NEXT , H2O_SNOW_NEXT       , 
     O   RHO_SNOW_INV_NEXT   , 
     O   ENH_BUCKET_SNOW_TO_SNSL  , WTR_BUCKET_SNOW_TO_SNSL  ,    
     O   INFO_SNOW_NEXT         )  
!
!   �E�o�P�c�̒P�ʂ͂���ł悢�B������v�Z�ł͊i�q���ϒl�ł��邽�߁B
!     
      USE SIBPRM , ONLY :
     1   IDX  ,
     1   ISN 
!
      USE SIBCON , ONLY :
     1   HL_W2G_c        , 
     1   H2O_SNOW1_MIN_c , 
     1   H2O_SNOW1_MAX_c , 
     1   H2O_SNOW2_MIN_c , 
     1   H2O_SNOW2_MAX_c , 
     1   H2O_SNOW3_MIN_c , 
     1   H2O_SNOW3_MAX_c  
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)   :: NMAX
      INTEGER,INTENT(IN)   :: NMAX_01(3)
      INTEGER,INTENT(IN)   :: NMAX_2 (3)
      INTEGER,INTENT(IN)   :: NMAX_3 (3)
!     INTEGER,INTENT(IN)   :: NMAX_4 (3)
!
      REAL(8),INTENT(IN)   :: ENG_SNOW         (IDX,ISN)
      REAL(8),INTENT(IN)   :: H2O_SNOW         (IDX,ISN)
      REAL(8),INTENT(IN)   :: RHO_SNOW_INV     (IDX,ISN)  
      REAL(8),INTENT(IN)   :: ENG_PRECIPI      (IDX)
      REAL(8),INTENT(IN)   :: H2O_PRECIPI      (IDX)
      REAL(8),INTENT(IN)   :: RHO_PRECIPI_INV  (IDX)       ! �~��̖��x
!
      INTEGER,INTENT(IN)   :: I_SNOW_LEV       (IDX)

!
! OUTPUT
!
      REAL(8),INTENT(OUT)  :: H2O_SNOW_NEXT     (IDX,ISN)
      REAL(8),INTENT(OUT)  :: ENG_SNOW_NEXT     (IDX,ISN)
      REAL(8),INTENT(OUT)  :: RHO_SNOW_INV_NEXT (IDX,ISN)
!
      REAL(8),INTENT(OUT)  :: WTR_BUCKET_SNOW_TO_SNSL (IDX)
      REAL(8),INTENT(OUT)  :: ENH_BUCKET_SNOW_TO_SNSL (IDX)
!
      INTEGER,INTENT(OUT)    :: INFO_SNOW_NEXT   (IDX)
!
! INOUT
!
      INTEGER,INTENT(INOUT):: IFLG_SLEV_CHANGE  (IDX) 
!
! WORK
      INTEGER  :: I 
      REAL(8)  :: H2O_1_TO_2 (IDX)   
      REAL(8)  :: H2O_2_TO_3 (IDX)
      REAL(8)  :: H2O_3_TO_4 (IDX)
!
      REAL(8)  :: H2O_TO_SOIL(IDX)  
!
      REAL(8),PARAMETER :: ZERO_IDX   (IDX) = 0.
!
      REAL(8)  :: FR
!
      LOGICAL,SAVE :: LFIRST 
      DATA LFIRST / .TRUE. /
      IF ( LFIRST ) THEN
        WRITE(6,*) 'SNOW_OLD_LAYER POCHAKA 99/08/09' 
        LFIRST = .FALSE.
      ENDIF
!
      H2O_TO_SOIL(:) = 0. 
!
! ==================
! >> ���w������ <<
! ==================
!  �~���������
!
      CALL MK_SNOW_LAYER (
     I   NMAX_01(2)        , NMAX             , 1           ,
     I   ENG_PRECIPI       , H2O_PRECIPI      , 
     I   H2O_SNOW1_MIN_c   , H2O_SNOW1_MAX_c  , 
     I   ENG_SNOW          , H2O_SNOW         ,    
     O   H2O_1_TO_2        , 
     M   IFLG_SLEV_CHANGE  , H2O_TO_SOIL      )
!
! ==================
! >> ���w������ <<
! ==================
!
      CALL MK_SNOW_LAYER (
     I   NMAX_2(2)         , NMAX             , 2          ,
     I   ZERO_IDX          , H2O_1_TO_2       , 
     I   H2O_SNOW2_MIN_c   , H2O_SNOW2_MAX_c , 
     I   ENG_SNOW          , H2O_SNOW      ,    
     O   H2O_2_TO_3        , 
     M   IFLG_SLEV_CHANGE  , H2O_TO_SOIL      )
!
! ==================
! >> ��O�w������ <<
! ==================
!
      CALL MK_SNOW_LAYER (
     I   NMAX_3(2)         , NMAX             , 3         ,
     I   ZERO_IDX          , H2O_2_TO_3       , 
     I   H2O_SNOW3_MIN_c   , H2O_SNOW3_MAX_c , 
     I   ENG_SNOW          , H2O_SNOW      ,    
     O   H2O_3_TO_4        , 
     M   IFLG_SLEV_CHANGE  , H2O_TO_SOIL      )
!
! ==============
! >> �X�V��� <<   
! ==============
!    �������A�w�؂蒼���ł͂Ȃ��ꍇ
!
      INFO_SNOW_NEXT(:) = -1                    ! �����l�͐ᖳ��
!
      ENH_BUCKET_SNOW_TO_SNSL(:) = 0.
      WTR_BUCKET_SNOW_TO_SNSL(:) = 0.
      H2O_SNOW_NEXT(:,:) = 0.
      ENG_SNOW_NEXT(:,:) = 0.
      RHO_SNOW_INV_NEXT (:,:) = 0. 
!
      DO I=NMAX_01(2),NMAX
        IF ( IFLG_SLEV_CHANGE(I).EQ.0 ) THEN
!
! ----------
! > �w�̐� < 
! ----------
!
          INFO_SNOW_NEXT(I) = I_SNOW_LEV(I)     ! �w������ 
!
! ----------
! > ���w < 
! ----------
!
!    ���x�̌v�Z�B���̗����͖������Ĕ�����ς���B�i��������?�j
!
          FR  = H2O_PRECIPI(I) / ( H2O_PRECIPI(I) + H2O_SNOW(I,1) ) 
!                
          RHO_SNOW_INV_NEXT (I,1) 
     1            =   FR      * RHO_PRECIPI_INV (I)
     1              + (1-FR)  * RHO_SNOW_INV    (I,1)
!
!     ���ƃG�l���M�[�̌v�Z
!
          H2O_SNOW_NEXT (I,1) = H2O_SNOW (I,1) 
     1                         + H2O_PRECIPI(I) - H2O_1_TO_2(I)       
          ENG_SNOW_NEXT (I,1) = ENG_SNOW (I,1) 
     1                         + ENG_PRECIPI(I) 
!
       ENDIF 
      ENDDO 
!
!
! --------------
! > ���w < 
! --------------
!
!    ���x�̌v�Z�B���̗����͖������Ĕ�����ς���B�i��������?�j
!      ----> ���w�̖��x�̂܂܂Ƃ������Ƃ��B
!
      DO I=NMAX_2(2),NMAX
        IF ( IFLG_SLEV_CHANGE(I).EQ.0 ) THEN

          RHO_SNOW_INV_NEXT (I,2) = RHO_SNOW_INV (I,2)
!
!    ���ƃG�l���M�[�̌v�Z
!
          H2O_SNOW_NEXT (I,2) = H2O_SNOW(I,2) 
     1                         + H2O_1_TO_2(I) - H2O_2_TO_3(I)       
          ENG_SNOW_NEXT (I,2) = ENG_SNOW(I,2) 
        ENDIF   
      ENDDO
!

!
! ----------
! > ��O�w < 
! ----------
!
!    ���x�̌v�Z�B���̗����͖������Ĕ�����ς���B�i��������?�j
!      ----> ��O�w�̖��x�̂܂܂Ƃ������Ƃ��B
!
      DO I=NMAX_3(2),NMAX
        IF ( IFLG_SLEV_CHANGE(I).EQ.0 ) THEN
          RHO_SNOW_INV_NEXT (I,3) = RHO_SNOW_INV(I,3)
!
!    ���ƃG�l���M�[�̌v�Z
!
          H2O_SNOW_NEXT (I,3) = H2O_SNOW(I,3) 
     1                         + H2O_2_TO_3(I) - H2O_3_TO_4(I)       
          ENG_SNOW_NEXT (I,3) = ENG_SNOW(I,3) 
        ENDIF
      ENDDO
!
! ================================
! >> �y��ւ̐��t���b�N�X�̌v�Z <<
! ================================
!        ( ���ɗ����Ȃ����Ƃ�O��Ƃ��Ă���΁A�s�v )
!
      DO I=NMAX_01(2),NMAX_3(3)
        IF ( IFLG_SLEV_CHANGE(I).EQ.0 ) THEN
          WTR_BUCKET_SNOW_TO_SNSL(I) = H2O_TO_SOIL(I)             
          ENH_BUCKET_SNOW_TO_SNSL(I) = 0. 
        ENDIF
      ENDDO
!
      RETURN
      END
!===============================================
      SUBROUTINE MK_SNOW_LAYER (
     I   NSTR   , NEND    , KLEV      ,
     I   ENG_FROM_UPPER   , H2O_FROM_UPPER   , 
     I   H2O_SNOW_MIN     , H2O_SNOW_MAX     , 
     I   ENG_SNOW         , H2O_SNOW         ,    
     O   H2O_TO_LOWER     , 
     M   IFLG_SLEV_CHANGE , H2O_TO_SOIL     )
!
! �ォ�痈�����i�ŏ�w�ł� +�X�j�Ɗ����̕X+����������B
! �O�a�ܐ��ʈȏ�̐�������ꍇ�͂�������ɗ����B
! 
! �E����
!     �X�͉��ɂ͗����Ȃ��B
!     �X�𗎂��˂΂Ȃ�Ȃ��悤�ȏ󋵂ł́A�w�̐؂蒼�����K�v�B
!
      USE SIBPRM , ONLY :
     1   IDX      , 
     1   ISN  
! 
      USE SIBCON , ONLY : 
     1   HL_W2G_c        , 
     1   HL_W2G_INV_c    , 
     1   FR_SNOWWTR_MAX_c         ! ��w�ɂ����đS H2O ���Ŏ��Ă�t���̊���
!
      IMPLICIT NONE
!
! INPUT 
!
      INTEGER,INTENT(IN)   :: NSTR
      INTEGER,INTENT(IN)   :: NEND
      INTEGER,INTENT(IN)   :: KLEV                 ! �������x��
!
      REAL(8),INTENT(IN)   :: H2O_SNOW_MIN          ! ���� KLEV �w�ł̉���
      REAL(8),INTENT(IN)   :: H2O_SNOW_MAX          ! ���� KLEV �w�ł̏��
!
      REAL(8),INTENT(IN)   :: ENG_FROM_UPPER (IDX)    
      REAL(8),INTENT(IN)   :: H2O_FROM_UPPER (IDX)    
      REAL(8),INTENT(IN)   :: ENG_SNOW       (IDX,ISN-1)
      REAL(8),INTENT(IN)   :: H2O_SNOW       (IDX,ISN-1)
!
! OUTPUT
!
      REAL(8),INTENT(OUT)    :: H2O_TO_LOWER (IDX)    
      REAL(8),INTENT(INOUT)  :: H2O_TO_SOIL  (IDX)    
!
! INOUT
!
      INTEGER,INTENT(INOUT)  :: IFLG_SLEV_CHANGE (IDX) 
!
! WORK
!
      INTEGER  :: I
      REAL(8)  :: H2O_0
      REAL(8)  :: H2O_1
      REAL(8)  :: ENG_0
      REAL(8)  :: ENX_0
      REAL(8)  :: ENX_2
      REAL(8)  :: H2O_DEL
      REAL(8),PARAMETER  :: ZERO = 0. 
!
      DO 1000 I=NSTR,NEND 
      IF ( IFLG_SLEV_CHANGE(I).EQ.0 ) THEN  
!
!  �G�l���M�[�E���̘a���Ƃ�
!
        ENG_0  = ENG_SNOW(I,KLEV) + ENG_FROM_UPPER(I) 
        H2O_0  = H2O_SNOW(I,KLEV) + H2O_FROM_UPPER(I)  
!
        ENX_0  = ENG_0 + HL_W2G_c * H2O_0
        ENX_2  = - ENG_0 * FR_SNOWWTR_MAX_c 
!
! ���̑w���Z����ꍇ�B
! ���邢�́A���̑w���炩�Ȃ�̗ʂ̐������ɗ�����ꍇ   �X�V�t���O A 
!
        IF     ( ENG_0.GT.0. .OR. ENX_0.GT.ENX_2*4 ) THEN
          IFLG_SLEV_CHANGE (I) = 3
!
! ���̑w���炠����x�̗ʂ̐������ɗ�����ꍇ   �X�V�t���O B
!
        ELSEIF ( ENX_0 .GT. ENX_2*2 ) THEN
          IFLG_SLEV_CHANGE (I) = 2
!
! ���̑w����͐���������Ɖ��ɗ�����A�܂��͗����Ȃ��B
!   --> �X�V�t���O�͐ݒ肹���A���̂܂ܐi�ށB
!
!      ������   ... ENX_0 - ENX_2 > 0 �̎��B���̂Ƃ� ENX_1 = ENX_2 �ɂȂ�B
!      �����Ȃ� ... ENX_0 - ENX_2 < 0 �̎��B���̂Ƃ� ENX_1 = ENX_0 �B
!
        ELSE
!
          H2O_DEL = MAX ( ENX_0 - ENX_2 , ZERO ) * HL_W2G_INV_c
          H2O_1 = H2O_0 - H2O_DEL
!
!   ���� H2O_1 ���㉺���Ɏ��܂�Ζ��Ȃ�? 
!         H2O_SNOW , ENG_SNOW �̃[���N���A
!         H2O_SNOW_NEXT      ���ւ̑���͂��Ȃ��B
!
          IF (       H2O_1 .GE. H2O_SNOW_MIN 
     1         .AND. H2O_1 .LE. H2O_SNOW_MAX ) THEN 
            H2O_TO_LOWER (I)   = H2O_DEL
            H2O_TO_SOIL  (I)   = H2O_DEL
!
!   ���� H2O_1 ���㉺���Ɏ��܂�Ȃ���΁A�w�̐؂蒼�����K�v�B�X�V�t���O C 
!
          ELSE
            IFLG_SLEV_CHANGE (I) = 1  
          ENDIF
!
        ENDIF
      ENDIF
 1000 CONTINUE
!
      RETURN
      END