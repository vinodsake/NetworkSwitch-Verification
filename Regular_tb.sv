module tb;
  bit clk;
  bit nrst;
  bit sop;
  bit eop;
  bit in_valid;
  bit [31:0] port_in;
  bit [31:0] A;
  bit [31:0] B;
  bit [31:0] C;
  bit [31:0] D;
  bit A_valid;
  bit B_valid;
  bit C_valid;
  bit D_valid;
  bit A_sop, B_sop, C_sop, D_sop;
  bit A_eop, B_eop, C_eop, D_eop;
  bit A_ready, B_ready, C_ready, D_ready;

  int count;
  
  switch s1(.*);

  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end

  initial begin
    $dumpfile("dump.vcd");
    /*
    //Common
    $dumpvars(0,  s1.clk, s1.nrst,
                s1.sop, s1.eop, s1.in_valid, s1.port_in
             );
    
    //Input FSM - A
  	$dumpvars(0,  s1.clk, s1.nrst,
                s1.sop, s1.eop, s1.in_valid, s1.port_in, 
                s1.A_ready,
                s1.In_counter, s1.In_counter_next, s1.IN_state, s1.IN_next,
                s1.pkt_type, s1.A_ptr, s1.A_pkt_process,
                s1.checkA1,s1.checkA2, s1.checkA3,s1.checkA4, s1.checkA5, s1.checkA6,
              	s1.checkA1_1,s1.checkA1_2, s1.checkA1_3,s1.checkA1_4, s1.checkA1_5, s1.checkA1_6
              	//s1.checkA2_1,s1.checkA2_2, s1.checkA2_3,s1.checkA2_4, s1.checkA2_5, s1.checkA2_6,
              	//s1.checkA3_1,s1.checkA3_2, s1.checkA3_3,s1.checkA3_4, s1.checkA3_5, s1.checkA3_6
    );
    
    //Central system - A
    $dumpvars(0, s1.A_pkt_process, s1.A_pop, s1.A_out_ptr, s1.A_ready

  	);
    
    //Ouput FSM - A
    $dumpvars(0,  s1.A_state, s1.A_next, s1.A_counter, s1.A_counter_next, s1.A_start_count,
              s1.A_out_ptr_buff, s1.A_length, s1.A_sop, s1.A_eop, s1.A, A_valid

    );
    */
    
    //Input and Outputs
    $dumpvars(0,  s1.clk, s1.nrst,
                s1.sop, s1.eop, s1.in_valid, s1.port_in,
              	s1.A_ready, s1.B_ready, s1.C_ready, s1.D_ready,
              	s1.A_sop, s1.A_eop, s1.A, A_valid,
              	s1.B_sop, s1.B_eop, s1.B, B_valid,
              	s1.C_sop, s1.C_eop, s1.C, C_valid,
              	s1.D_sop, s1.D_eop, s1.D, D_valid
             );
    
    count = 0;
    nrst = 1;
    #50;
    nrst = 0;
    #20;
    nrst = 1;
    #20;
    
    //A port
    pkt(0,5);
    #30;
 
    pkt(0,3);
	#30;
    pkt(0,0);
    #30;
    
    pkt(0,2);
	#30;
    pkt(0,1);
    #30;
    
    //B port
    pkt(1,5);
    #30;
 
    pkt(1,3);
	#30;
    pkt(1,0);
    #30;
    
    pkt(1,2);
	#30;
    pkt(1,1);
    #30;
    
    //C port
    pkt(2,5);
    #30;
 
    pkt(2,3);
	#30;
    pkt(2,0);
    #30;
    
    pkt(2,2);
	#30;
    pkt(2,1);
    #30;
    
    //D port
    pkt(9,5);
    #30;
 
    pkt(9,3);
	#30;
    pkt(9,0);
    #30;
    
    pkt(9,2);
	#30;
    pkt(9,1);
    #30;
    /*
    pkt(1,5);
    #30;
 
    pkt(2,3);
	#30
    pkt(9,0);
    */
    #50;
    $finish;
  end

  task pkt(input bit [7:0] id, input int size);
    in_valid = 1;
	port_in = 0;
    if(size == 0) begin
      @(negedge clk) sop = 1; eop = 1;
      	port_in[31:24] = id;
      @(negedge clk) sop = 0; eop = 0;
    end
    else begin
    	@(negedge clk) sop = 1;
      	port_in[31:24] = id;

      for(int i=1+count; i<=size+count; i++) begin
      		@(negedge clk) sop = 0; port_in = i;
        if(i == size+count) eop = 1;
    	end

    	@(negedge clk) eop = 0;
      	count++;
    end
    in_valid = 0;
  endtask
endmodule
