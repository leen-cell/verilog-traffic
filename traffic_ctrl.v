
module traffic_ctrl (
	input clk,rst,
	input VS, PB,
	output reg [1:0] light_main,
	output reg [1:0] light_side,
	output reg walk);
	wire  timer_done;	 
	assign timer_done = (timer_count >= timer_limit);
	   reg Req_flag;
	reg [2:0] prstate,nxtstate;  
	//light encoding
	 parameter green_car =  2'b00, red_car = 2'b01, yellow_car = 2'b10; //green, red and yellow for the main and side road		
	 parameter green_walk =  1'b0, red_walk = 1'b1; //green and red for the walk
		 
	//state encoding
	parameter 	M_GREEN = 3'b000, M_YELLOW = 3'b001, ALL_RED = 3'b010, S_GREEN = 3'b011, S_YELLOW=3'b100, P_GREEN = 3'b101;
	
	// timer values 
	parameter T_MGREEN  = 6'd60;	  //in seconds 
	parameter T_YELLOW = 6'd5;
	parameter T_RED    = 6'd5;	
	parameter T_SGREEN = 6'd40;
	parameter T_PGREEN = 6'd40;

	 	reg [5:0] timer_count;
		reg [5:0] timer_limit;

	
	always @(posedge clk or negedge rst) begin  
		if (!rst) prstate <= M_GREEN;
			else prstate <= nxtstate;
	end	   
	//to select the timer duration
	always @(*) begin 
		timer_limit = T_MGREEN;
  		case (prstate)
   			 M_GREEN:  timer_limit = T_MGREEN;	
			 S_GREEN:   timer_limit = T_SGREEN;
   			 M_YELLOW, S_YELLOW:timer_limit = T_YELLOW;
  			ALL_RED: timer_limit = T_RED;
   			 P_GREEN: timer_limit = T_PGREEN;
  
  			endcase
	end	
	//counting logic
		always @(posedge clk or negedge rst) begin
 			 if (!rst)
 			   timer_count <= 6'd0;
		  else if (prstate != nxtstate)
   			 timer_count <= 6'd0;        // when we change the state the timer is reseted
  		else if (timer_count < timer_limit)
    	timer_count <= timer_count + 1'b1; //add to the counter, counter = counter+1 
		end
	 //request flag logic 
	 always @(posedge clk or negedge rst) begin
 		 if (!rst)
 		   Req_flag <= 1'b0;
 		 else if (prstate == P_GREEN)
 		   Req_flag <= 1'b0;          // request served
 		 else if (PB && prstate != ALL_RED)
 		   Req_flag <= 1'b1;          // remember request if it was while s_green
			end


		  //FSM logic
	always @(prstate or VS or PB or timer_done or Req_flag) begin  
		nxtstate = prstate;
		case (prstate) 
		M_GREEN:if (timer_done && (PB || VS)) nxtstate = M_YELLOW;	
			
		M_YELLOW:if (timer_done) nxtstate = ALL_RED;   
			
		ALL_RED:
 				 if (timer_done && (PB || Req_flag)) nxtstate = P_GREEN;
 				 else if (timer_done && !PB && !Req_flag && VS) nxtstate = S_GREEN;
 				 else if (timer_done) nxtstate = M_GREEN;
			
		S_GREEN:   if (timer_done) nxtstate = S_YELLOW;
		
		S_YELLOW:  if (timer_done) nxtstate = ALL_RED;
		
		P_GREEN:   if (timer_done) nxtstate = ALL_RED;
		endcase
		
	end	 
	
 		 // output logic
  		always @(*) begin
  			  light_main = red_car;
  			  light_side = red_car;
  			  walk = red_walk;

    		case (prstate)
    		  M_GREEN:   light_main = green_car;
     		 M_YELLOW:  light_main = yellow_car;
     			 S_GREEN:   light_side = green_car;
     				 S_YELLOW:  light_side = yellow_car;
    			  P_GREEN:   walk = green_walk;
  			  endcase
 			 end
	
	
endmodule	 

  //i am here
	   

module tb ;	  
	
	reg	 clk,rst,VS, PB;
	wire  [1:0] main, side;
	wire walk;
	reg error_flag;	 
	reg TT;
	reg Req_flag_tb;

	 
	traffic_ctrl tc(clk,rst,VS,PB,main,side,walk);	
	
	// reference model
function [2:0] expected;
  input VS;
  input PB;
  input TT;   // timer done flag
  input Req_flag_tb;
  begin
    case (tc.prstate)

      
      // M_GREEN
    
      3'b000: begin
        if (!TT)
          expected = 3'b000;         
        else if (VS || PB)
          expected = 3'b001;          
        else
          expected = 3'b000;          
      end

      
      // M_YELLOW
      
      3'b001: begin
        if (!TT)
          expected = 3'b001;          
        else
          expected = 3'b010;          
      end

      // ALL_RED
    
      3'b010: begin
        if (!TT)
          expected = 3'b010;          
        else if (PB || Req_flag_tb)
          expected = 3'b101;          
        else if (VS)
          expected = 3'b011;        
        else
          expected = 3'b000;          
      end
      // S_GREEN
     
      3'b011: begin
        if (!TT)
          expected = 3'b011;         
        else
          expected = 3'b100;         
      end

      
      // S_YELLOW
      
      3'b100: begin
        if (!TT)
          expected = 3'b100;          
        else
          expected = 3'b010;          
      end
      // P_GREEN
      
      3'b101: begin
        if (!TT)
          expected = 3'b101;        
        else
          expected = 3'b010;          
      end

      default: expected = 3'b000;

    endcase
  end
endfunction	

	   always @(posedge clk or negedge rst) begin
    if (!rst)
      Req_flag_tb <= 1'b0;
    else if (tc.prstate == 3'b101) 
      Req_flag_tb <= 1'b0;         
    else if (PB && tc.prstate != 3'b010) 
      Req_flag_tb <= 1'b1;        
  end 
  //clock
  always #5 clk = ~clk;
	  always @(*) TT = tc.timer_done;

	initial begin 
	 clk = 0;
    rst = 0;
    VS  = 0;
    PB  = 0; 
	error_flag = 0;	 
	Req_flag_tb = 1'b0;
	
    $display("Time clk rst VS PB main side walk");


	//i am testing reset first since it is not a partt of the logic	 
  #10 rst = 0;
    #10;
    if (tc.prstate != 3'b000) begin
      $display("ERROR: Reset failed we expected M_GREEN");
      error_flag = 1;
    end
    else
      $display("Reset test PASSED");
			//timer flag to see if it is finished or no 
    rst = 1;  
	
	repeat (25) begin
	//test and compare with the reference model 
	
	  
	//TEST BEOFRE TIMER DONE  
	      #10;  
		    
	    
	
	      if (TT == 0) begin
        if (tc.prstate != expected(VS,PB,TT, Req_flag_tb)) begin
          $display("ERROR before timer_done");
		  $display("  current state=%b VS=%b PB=%b TT=%b Req=%b | exp=%b got=%b",
         tc.prstate, VS, PB, TT, Req_flag_tb,
         expected(VS,PB,TT,Req_flag_tb), tc.prstate);

          error_flag = 1;
        end
        else begin
          $display("PASS before timer_done");
		  $display("  current state=%b VS=%b PB=%b TT=%b Req=%b | exp=%b got=%b",
         tc.prstate, VS, PB, TT, Req_flag_tb,
         expected(VS,PB,TT,Req_flag_tb), tc.prstate);
			end
      end
	  
	  //TEST AFTER TIMER IS DONE
	    while (tc.timer_done == 0)
  			#10;
	  	
	if (tc.nxtstate == expected(VS,PB,TT, Req_flag_tb)) begin
		$display("PASS after timer_done"); 
	$display("  current state=%b VS=%b PB=%b TT=%b Req=%b | exp=%b got=%b",
         tc.prstate, VS, PB, TT, Req_flag_tb,
         expected(VS,PB,TT,Req_flag_tb), tc.nxtstate);

		end else begin
		$display("ERROR after timer_done");  
	$display("  current state=%b VS=%b PB=%b TT=%b Req=%b | exp=%b got=%b",
         tc.prstate, VS, PB, TT, Req_flag_tb,
         expected(VS,PB,TT,Req_flag_tb), tc.nxtstate);

 		 error_flag = 1;
			end
		   #10;
	  {VS,PB} = {VS,PB} + 2'b01;
    	end
	//print final result accept or noo
	     if (error_flag)
		      $display("THERE WERE PROBLEMS IN THE LOGIC");
    else
      $display("ALL TESTS PASSED SUCCESSFULLY");
	
	     
	end
	
endmodule