Library IEEE ;
Use IEEE.STD_Logic_1164.All ;
Use IEEE.Numeric_STD.All ;

Entity FIR_Filter_Transposed_Direct_Form Is
	
    Generic(
        Filter_Order                   : Integer := 15 ;
        
        Length_Of_Input_Words          : Integer := 8 ;
        Length_Of_Input_Fractions      : Integer := 7 ;
		
        Length_Of_Output_Words         : Integer := 9 ;
        Length_Of_Output_Fractions     : Integer := 7 ;

        Length_Of_Numerators_Words     : Integer := 10 ;
        Length_Of_Numerators_Fractions : Integer := 7 ;

        Numerator_0                    : Integer := -6 ;
        Numerator_1                    : Integer := 4 ;
        Numerator_2                    : Integer := 8 ;
        Numerator_3                    : Integer := 2 ;
        Numerator_4                    : Integer := -10 ;
        Numerator_5                    : Integer := -5 ;
        Numerator_6                    : Integer := 24 ;
        Numerator_7                    : Integer := 53 ;
        Numerator_8                    : Integer := 53 ;
        Numerator_9                    : Integer := 24 ;
        Numerator_10                   : Integer := -5 ;
        Numerator_11                   : Integer := -10 ;
        Numerator_12                   : Integer := 2 ;
        Numerator_13                   : Integer := 8 ;
        Numerator_14                   : Integer := 4 ;
        Numerator_15                   : Integer := -6 ;
        Numerator_16                   : Integer := 0 ;
        Numerator_17                   : Integer := 0 ;
        Numerator_18                   : Integer := 0 ;
        Numerator_19                   : Integer := 0 ;
        Numerator_20                   : Integer := 0 ;
        Numerator_21                   : Integer := 0 ;
        Numerator_22                   : Integer := 0 ;
        Numerator_23                   : Integer := 0 ;
        Numerator_24                   : Integer := 0 ;
        Numerator_25                   : Integer := 0 ;
        Numerator_26                   : Integer := 0 ;
        Numerator_27                   : Integer := 0 ;
        Numerator_28                   : Integer := 0 ;
        Numerator_29                   : Integer := 0 ;
        Numerator_30                   : Integer := 0 ;
        Numerator_31                   : Integer := 0 
    ) ;

    Port(
        Clock              : In  STD_Logic ;
        Synchronous_Reset  : In  STD_Logic ;
        Clock_Enable       : In  STD_Logic ;
        Input              : In  Signed(Length_Of_Input_Words-1 Downto 0) ;
        Output             : Out Signed(Length_Of_Output_Words-1 Downto 0)
    ) ;
  
End FIR_Filter_Transposed_Direct_Form ;

Architecture Behavioral Of FIR_Filter_Transposed_Direct_Form Is

   Signal Synchronous_Reset_Register : STD_Logic                                 := '0' ;
   Signal Clock_Enable_Register      : STD_Logic                                 := '0' ;
   Signal Input_Register             : Signed(Length_Of_Input_Words-1 Downto 0)  := To_Signed(0,Length_Of_Input_Words) ;
   Signal Output_Register            : Signed(Length_Of_Output_Words-1 Downto 0) := To_Signed(0,Length_Of_Output_Words) ;
    
   Type Input_1_Delay_Type Is Array (0 To Filter_Order) Of Signed(Length_Of_Input_Words-1 Downto 0) ;
   Signal Input_1_Delay              : Input_1_Delay_Type                        := (Others=>To_Signed(0,Length_Of_Input_Words));
   Signal Input_2_Delay              : Input_1_Delay_Type                        := (Others=>To_Signed(0,Length_Of_Input_Words));
    
   Type Numerator_Type Is Array (0 To (32-1)) Of Integer Range ((-1)* 2**(Length_Of_Numerators_Words-1)) To (2**(Length_Of_Numerators_Words-1) -1) ;
   Constant Numerator                : Numerator_Type                            := (Numerator_0,Numerator_1,Numerator_2,Numerator_3,Numerator_4,Numerator_5,Numerator_6,Numerator_7,
                                                                                     Numerator_8,Numerator_9,Numerator_10,Numerator_11,Numerator_12,Numerator_13,Numerator_14,Numerator_15,
                                                                                     Numerator_16,Numerator_17,Numerator_18,Numerator_19,Numerator_20,Numerator_21,Numerator_22,Numerator_23,
                                                                                     Numerator_24,Numerator_25,Numerator_26,Numerator_27,Numerator_28,Numerator_29,Numerator_30,Numerator_31) ;

   Type Accumulator_Type Is Array (0 To Filter_Order) Of Signed(Length_Of_Output_Words+Length_Of_Numerators_Words-1 Downto 0) ;
   Signal Accumulator                : Accumulator_Type                          := (Others=>To_Signed(0,Length_Of_Output_Words+Length_Of_Numerators_Words));
   Alias  First_Accumulator_Quantize : Signed(Length_Of_Output_Words-1 Downto 0) Is Accumulator(0)(Length_Of_Output_Words+Length_Of_Numerators_Fractions-1 Downto Length_Of_Numerators_Fractions) ;
	
Begin

    Process(Clock)
    Begin
       
        If Rising_Edge(Clock) Then
       
        --  Registering Input Ports
            Synchronous_Reset_Register <= Synchronous_Reset ;
            Clock_Enable_Register      <= Clock_Enable ;
            Input_Register             <= Input ;
        --  %%%%%%%%%%%%%%%%%%%%%%%
        
        --  Reset Internal Registers
            If Synchronous_Reset_Register='1' Then
               
               Input_1_Delay             <= (Others=>To_Signed(0,Length_Of_Input_Words)) ;
               Input_2_Delay             <= (Others=>To_Signed(0,Length_Of_Input_Words)) ;
               Accumulator               <= (Others=>To_Signed(0,Length_Of_Output_Words+Length_Of_Numerators_Words)) ;
               Output_Register           <= To_Signed(0,Length_Of_Output_Words) ;
        --  %%%%%
        
            Elsif Clock_Enable_Register='1' Then
               
               For i In 0 To Filter_Order Loop
                  Input_1_Delay(i)       <= Input_Register ;
                  Input_2_Delay(i)       <= Input_1_Delay(i) ;
               End Loop ;
               
               Accumulator(Filter_Order) <= Resize(Input_2_Delay(Filter_Order)*To_Signed(Numerator(Filter_Order),Length_Of_Numerators_Words),Length_Of_Output_Words+Length_Of_Numerators_Words) ;
               For i In 0 To (Filter_Order-1) Loop
                  Accumulator(i)         <= Input_2_Delay(i)*To_Signed(Numerator(i),Length_Of_Numerators_Words) + Accumulator(i+1) ;
               End Loop ;
               
               Output_Register           <= First_Accumulator_Quantize ;
					 
            End If ;
           
        End If ;
       
    End Process ;
    
--  Registering Output Ports 
    Output <= Output_Register ;
--  %%%%%%%%%%%%%%%%%%%%%%%
    
End Behavioral ;