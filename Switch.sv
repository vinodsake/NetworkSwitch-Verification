// Cycles to reflect the output
// A - 10 cycles
// B - 4 cycles
// C - 40 cycles
// D - 2 cycles
// Each port has it own structure which can hold upto 4 pkts (header+payload(max = 255))
module switch 
  #(
   parameter A_id = 0,
   parameter B_id = 1,
   parameter C_id = 2)
  (
    input clk,
    input nrst,
    input sop,
    input eop,
    input in_valid,
    input [31:0] port_in,
    output reg [31:0] A,
    output reg [31:0] B,
    output reg [31:0] C,
    output reg [31:0] D,
    output reg A_valid,
    output reg B_valid,
    output reg C_valid,
    output reg D_valid,
    output reg A_sop, B_sop, C_sop, D_sop,
    output reg A_eop, B_eop, C_eop, D_eop,
    output A_ready,
    output B_ready,
    output C_ready,
    output D_ready
);
    parameter A_delay = 10;
    parameter B_delay = 4;
    parameter C_delay = 40;
    parameter D_delay = 2;

    // Memory
    bit [31:0] A_mem[0:3][1:257];
    bit [31:0] B_mem[0:3][1:257];
    bit [31:0] C_mem[0:3][1:257];
    bit [31:0] D_mem[0:3][1:257];

    // States
    typedef enum bit[1:0] {IDLE, HEADER,PAYLOAD, UPDATE} STATE_e;
    typedef enum bit[1:0] {A_type,B_type,C_type,D_type} PKTTYPE_e;
  
    STATE_e IN_state, IN_next, A_state, A_next, B_state, B_next, C_state, C_next, D_state, D_next;
    PKTTYPE_e pkt_type;
  
    // Internal wires
    bit [7:0] A_length, B_length, C_length, D_length;
    bit [7:0] In_counter, In_counter_next, A_counter, A_counter_next, B_counter, B_counter_next, C_counter, C_counter_next, D_counter, D_counter_next;
    bit [1:0] A_ptr, B_ptr, C_ptr, D_ptr;
    bit [1:0] A_out_ptr, B_out_ptr, C_out_ptr, D_out_ptr;
    bit [1:0] A_out_ptr_buff, B_out_ptr_buff, C_out_ptr_buff, D_out_ptr_buff;
    bit [31:0] ecc_check;
    bit [3:0] A_pkt_process, B_pkt_process, C_pkt_process, D_pkt_process;
    bit A_pop, B_pop, C_pop, D_pop;
    bit [3:0] In_encoderA, In_encoderB, In_encoderC, In_encoderD;
    bit [1:0] Out_encoderA, Out_encoderB, Out_encoderC, Out_encoderD;
    bit [3:0] In_encoderAout, In_encoderBout, In_encoderCout, In_encoderDout;
    bit [1:0] Out_encoderAout, Out_encoderBout, Out_encoderCout, Out_encoderDout;
    bit A_start_count, B_start_count, C_start_count, D_start_count;
  
    bit [31:0] checkA0 , checkA1, checkA2 , checkA3, checkA4 , checkA5, checkA6;
    assign checkA1 = A_mem[0][1];
    assign checkA2 = A_mem[0][2];
    assign checkA3 = A_mem[0][3];
    assign checkA4 = A_mem[0][4];
    assign checkA5 = A_mem[0][5];
    assign checkA6 = A_mem[0][6];

    bit [31:0] checkA1_0 , checkA1_1, checkA1_2 , checkA1_3, checkA1_4 , checkA1_5, checkA1_6;
    assign checkA1_1 = A_mem[1][1];
    assign checkA1_2 = A_mem[1][2];
    assign checkA1_3 = A_mem[1][3];
    assign checkA1_4 = A_mem[1][4];
    assign checkA1_5 = A_mem[1][5];
    assign checkA1_6 = A_mem[1][6];

    bit [31:0] checkA2_0 , checkA2_1, checkA2_2 , checkA2_3, checkA2_4 , checkA2_5, checkA2_6;
    assign checkA2_1 = A_mem[2][1];
    assign checkA2_2 = A_mem[2][2];
    assign checkA2_3 = A_mem[2][3];
    assign checkA2_4 = A_mem[2][4];
    assign checkA2_5 = A_mem[2][5];
    assign checkA2_6 = A_mem[2][6];

    bit [31:0] checkA3_0 , checkA3_1, checkA3_2 , checkA3_3, checkA3_4 , checkA3_5, checkA3_6;
    assign checkA3_1 = A_mem[3][1];
    assign checkA3_2 = A_mem[3][2];
    assign checkA3_3 = A_mem[3][3];
    assign checkA3_4 = A_mem[3][4];
    assign checkA3_5 = A_mem[3][5];
    assign checkA3_6 = A_mem[3][6];


    bit [31:0] checkB0 , checkB1, checkB2 , checkB3, checkB4 , checkB5, checkB6;
    assign checkB1 = B_mem[0][1];
    assign checkB2 = B_mem[0][2];
    assign checkB3 = B_mem[0][3];
    assign checkB4 = B_mem[0][4];
    assign checkB5 = B_mem[0][5];
    assign checkB6 = B_mem[0][6];

    bit [31:0] checkC0 , checkC1, checkC2 , checkC3, checkC4 , checkC5, checkC6;
    assign checkC1 = C_mem[0][1];
    assign checkC2 = C_mem[0][2];
    assign checkC3 = C_mem[0][3];
    assign checkC4 = C_mem[0][4];
    assign checkC5 = C_mem[0][5];
    assign checkC6 = C_mem[0][6];

    bit [31:0] checkD0 , checkD1, checkD2 , checkD3, checkD4 , checkD5, checkD6;
    assign checkD1 = D_mem[0][1];
    assign checkD2 = D_mem[0][2];
    assign checkD3 = D_mem[0][3];
    assign checkD4 = D_mem[0][4];
    assign checkD5 = D_mem[0][5];
    assign checkD6 = D_mem[0][6];

    assign In_counter_next = (in_valid)?(In_counter + 1):1;
    assign A_counter_next = (A_start_count)?(A_counter + 1):1;
    assign B_counter_next = (B_start_count)?(B_counter + 1):1;
    assign C_counter_next = (C_start_count)?(C_counter + 1):1;
    assign D_counter_next = (D_start_count)?(D_counter + 1):1;

    // Assign which ever slot is first zero
    assign In_encoderA = ((~A_pkt_process&(~A_pkt_process-1))^(~A_pkt_process));
    assign In_encoderB = ((~B_pkt_process&(~B_pkt_process-1))^(~B_pkt_process));
    assign In_encoderC = ((~C_pkt_process&(~C_pkt_process-1))^(~C_pkt_process));
    assign In_encoderD = ((~D_pkt_process&(~D_pkt_process-1))^(~D_pkt_process));

    assign Out_encoderA = {(In_encoderA[3]|In_encoderA[2]),(In_encoderA[3]|In_encoderA[1])};
    assign Out_encoderB = {(In_encoderB[3]|In_encoderB[2]),(In_encoderB[3]|In_encoderB[1])};
    assign Out_encoderC = {(In_encoderC[3]|In_encoderC[2]),(In_encoderC[3]|In_encoderC[1])};
    assign Out_encoderD = {(In_encoderD[3]|In_encoderD[2]),(In_encoderD[3]|In_encoderD[1])};

    assign A_ptr = Out_encoderA;
    assign B_ptr = Out_encoderB;
    assign C_ptr = Out_encoderC;
    assign D_ptr = Out_encoderD;

    assign A_pop = (nrst == 0)?0:(|A_pkt_process == 0)?0:1;
    assign B_pop = (nrst == 0)?0:(|B_pkt_process == 0)?0:1;
    assign C_pop = (nrst == 0)?0:(|C_pkt_process == 0)?0:1;
    assign D_pop = (nrst == 0)?0:(|D_pkt_process == 0)?0:1;

    // Assign first occurance of one
    assign In_encoderAout = (A_pkt_process&(A_pkt_process-1))^A_pkt_process;
    assign In_encoderBout = (B_pkt_process&(B_pkt_process-1))^B_pkt_process;      
    assign In_encoderCout = (C_pkt_process&(C_pkt_process-1))^C_pkt_process;
    assign In_encoderDout = (D_pkt_process&(D_pkt_process-1))^D_pkt_process;

    assign Out_encoderAout = {(In_encoderAout[3]|In_encoderAout[2]),(In_encoderAout[3]|In_encoderAout[1])};
    assign Out_encoderBout = {(In_encoderBout[3]|In_encoderBout[2]),(In_encoderBout[3]|In_encoderBout[1])};
    assign Out_encoderCout = {(In_encoderCout[3]|In_encoderCout[2]),(In_encoderCout[3]|In_encoderCout[1])};
    assign Out_encoderDout = {(In_encoderDout[3]|In_encoderDout[2]),(In_encoderDout[3]|In_encoderDout[1])};

    assign A_out_ptr = Out_encoderAout;
    assign B_out_ptr = Out_encoderBout;
    assign C_out_ptr = Out_encoderCout;
    assign D_out_ptr = Out_encoderDout;

    assign A_ready = (nrst == 0)?0:(&A_pkt_process == 0)?1:0; 
    assign B_ready = (nrst == 0)?0:(&B_pkt_process == 0)?1:0;
    assign C_ready = (nrst == 0)?0:(&C_pkt_process == 0)?1:0;
    assign D_ready = (nrst == 0)?0:(&D_pkt_process == 0)?1:0;

    always @(posedge clk) begin
      if(!nrst) begin
        //outputs
        {A_valid, B_valid, C_valid, D_valid} <= {1'b0, 1'b0, 1'b0, 1'b0};
        {A_sop, B_sop, C_sop, C_sop} <= {1'b0, 1'b0, 1'b0, 1'b0};
        {A_eop, B_eop, C_eop, D_eop} <= {1'b0, 1'b0, 1'b0, 1'b0};
        //states
        //{IN_state, A_state, B_state, C_state, D_state} <= {HEADER, HEADER, HEADER, HEADER, HEADER};
        {IN_state, A_state, B_state, C_state, D_state} <= {HEADER, IDLE, IDLE, IDLE, IDLE};
        //Internal variables
        {In_counter, A_counter, B_counter, C_counter, D_counter} <= {8'b0, 8'b0, 8'b0, 8'b0, 8'b0};
        {A_valid, B_valid, C_valid, D_valid} <= {1'b0, 1'b0, 1'b0, 1'b0};
        {A_pkt_process, B_pkt_process, C_pkt_process, D_pkt_process} <= {2'b0, 2'b0, 2'b0, 2'b0};
        ecc_check <= 0;
      end
      else begin
        IN_state <= IN_next;
        A_state <= A_next;
        B_state <= B_next;
        C_state <= C_next;
        D_state <= D_next;
        In_counter <= In_counter_next;
        A_counter <= A_counter_next;
        B_counter <= B_counter_next;
        C_counter <= C_counter_next;
        D_counter <= D_counter_next;
      end
    end
    
    // Input combination circuit
    always @(IN_state, in_valid, sop, eop, In_counter) begin
      case(IN_state)
        HEADER: begin
                if(in_valid && sop) begin
                  if(port_in[31:24] == A_id)
                    pkt_type = A_type;
                  else if(port_in[31:24] == B_id)
                    pkt_type = B_type;
                  else if(port_in[31:24] == C_id)
                    pkt_type = C_type;
                  else 
                    pkt_type = D_type;

                  IN_next = PAYLOAD;
                end
                else begin
                  IN_next = HEADER;  
                end

                if(in_valid && sop && eop) begin
                  IN_next = UPDATE;
                end
              end 

        PAYLOAD:   begin
                    if(eop) begin
                      IN_next = HEADER;
                    end
                    else begin
                      IN_next = PAYLOAD;
                    end
                  end

        UPDATE:   begin       
                      IN_next = HEADER;
                  end
      endcase 
    end 

    task capture(input bit [31:0] port_in, input PKTTYPE_e pkt_type, input bit header_payload);
      case(pkt_type)
        A_type: A_mem[A_ptr][In_counter] <= port_in;
        B_type: B_mem[B_ptr][In_counter] <= port_in;
        C_type: C_mem[C_ptr][In_counter] <= port_in;
        D_type: D_mem[C_ptr][In_counter] <= port_in;
      endcase
      if(header_payload)
        ecc_check <= ecc_check ^ port_in;
    endtask 

    task update(input PKTTYPE_e pkt_type);
      case(pkt_type)
        // -1 to remove header count from payload
        A_type: A_mem[A_ptr][1][23:16] <= {In_counter-1};
        B_type: B_mem[B_ptr][1][23:16] <= {In_counter-1}; 
        C_type: C_mem[C_ptr][1][23:16] <= {In_counter-1}; 
        D_type: D_mem[C_ptr][1][23:16] <= {In_counter-1}; 
      endcase
    endtask 

    task update_buffers(input PKTTYPE_e pkt_type);
      case(pkt_type)
        A_type: A_pkt_process[A_ptr] <= 1;
        B_type: B_pkt_process[B_ptr] <= 1; 
        C_type: C_pkt_process[C_ptr] <= 1; 
        D_type: D_pkt_process[C_ptr] <= 1; 
      endcase
    endtask 

    //Input sequential circuit
    always @(posedge clk) begin
      case(IN_state)
        HEADER: begin
                  if(in_valid)
                    capture(port_in,pkt_type,0);
                end
        PAYLOAD: begin
                  capture(port_in,pkt_type,1);
                  if(eop) begin
                    update(pkt_type);
                    update_buffers(pkt_type);
                  end  
                 end

        UPDATE: begin
                  update(pkt_type);
                  update_buffers(pkt_type);
                end                  
      endcase  
    end     

    
    // A output comb
    always @(A_state, A_pop, A_out_ptr, A_counter) begin
      case(A_state)
        IDLE: begin
                if(A_pop) begin
                  A_next = HEADER;
                  A_out_ptr_buff = A_out_ptr;
                end
              end

        HEADER: begin
                  A_length = A_mem[A_out_ptr_buff][1][23:16]; //Including header
                  A_next = PAYLOAD;
                end
 
        PAYLOAD:  begin
                    if(A_counter == A_length+1) begin //Adding header to count
                      A_next = UPDATE;
                    end
                    else begin
                      A_next = PAYLOAD;
                    end
                  end

        UPDATE:   begin
                    A_next = IDLE;
                  end
      endcase
    end

    // A output port
    always @(posedge clk) begin
        case(A_state)
          IDLE: begin
                  A_valid <= 0;
                  A_eop <= 0;
                  A_sop <= 0;
                  if(A_pop)
                    A_start_count <= 1;
                end
          HEADER: begin
                      A_valid <= 1;
                      A_sop <= 1;
                      A_eop <= 0;
                      A <= A_mem[A_out_ptr_buff][A_counter];
                  end
          PAYLOAD:  begin
                      A_valid <= 1;
                      A_sop <= 0;
                      A_eop <= 0;
                      A <= A_mem[A_out_ptr_buff][A_counter];
                      if(A_counter == A_length+1) begin
                          A_eop <= 1;
                      end 
                    end
          UPDATE:   begin
                      A_eop <= 0;
                      A_valid <= 0;
                      A_pkt_process[A_out_ptr_buff] <= 0;
                      A_start_count <= 0;
                    end          
        endcase
    end
    
    // B output comb
    always @(B_state, B_pop, B_out_ptr, B_counter) begin
      case(B_state)
        IDLE: begin
                if(B_pop) begin
                  B_next = HEADER;
                  B_out_ptr_buff = B_out_ptr;
                end
              end

        HEADER: begin
                  B_length = B_mem[B_out_ptr_buff][1][23:16]; //Including header
                  B_next = PAYLOAD;
                end
 
        PAYLOAD:  begin
                    if(B_counter == B_length+1) begin //Adding header to count
                      B_next = UPDATE;
                    end
                    else begin
                      B_next = PAYLOAD;
                    end
                  end

        UPDATE:   begin
                    B_next = IDLE;
                  end
      endcase
    end

    // B output port
    always @(posedge clk) begin
        case(B_state)
          IDLE: begin
                  B_valid <= 0;
                  B_eop <= 0;
                  B_sop <= 0;
                  if(B_pop)
                    B_start_count <= 1;
                end
          HEADER: begin
                      B_valid <= 1;
                      B_sop <= 1;
                      B_eop <= 0;
                      B <= B_mem[B_out_ptr_buff][B_counter];
                  end
          PAYLOAD:  begin
                      B_valid <= 1;
                      B_sop <= 0;
                      B_eop <= 0;
                      B <= B_mem[B_out_ptr_buff][B_counter];
                      if(B_counter == B_length+1) begin
                          B_eop <= 1;
                      end 
                    end
          UPDATE:   begin
                      B_eop <= 0;
                      B_valid <= 0;
                      B_pkt_process[B_out_ptr_buff] <= 0;
                      B_start_count <= 0;
                    end          
        endcase
    end

    // C output comb
    always @(C_state, C_pop, C_out_ptr, C_counter) begin
      case(C_state)
        IDLE: begin
                if(C_pop) begin
                  C_next = HEADER;
                  C_out_ptr_buff = C_out_ptr;
                end
              end

        HEADER: begin
                  C_length = C_mem[C_out_ptr_buff][1][23:16]; //Including header
                  C_next = PAYLOAD;
                end
 
        PAYLOAD:  begin
                    if(C_counter == C_length+1) begin //Adding header to count
                      C_next = UPDATE;
                    end
                    else begin
                      C_next = PAYLOAD;
                    end
                  end

        UPDATE:   begin
                    C_next = IDLE;
                  end
      endcase
    end

    // C output port
    always @(posedge clk) begin
        case(C_state)
          IDLE: begin
                  C_valid <= 0;
                  C_eop <= 0;
                  C_sop <= 0;
                  if(C_pop)
                    C_start_count <= 1;
                end
          HEADER: begin
                      C_valid <= 1;
                      C_sop <= 1;
                      C_eop <= 0;
                      C <= C_mem[C_out_ptr_buff][C_counter];
                  end
          PAYLOAD:  begin
                      C_valid <= 1;
                      C_sop <= 0;
                      C_eop <= 0;
                      C <= C_mem[C_out_ptr_buff][C_counter];
                      if(C_counter == C_length+1) begin
                          C_eop <= 1;
                      end 
                    end
          UPDATE:   begin
                      C_eop <= 0;
                      C_valid <= 0;
                      C_pkt_process[C_out_ptr_buff] <= 0;
                      C_start_count <= 0;
                    end          
        endcase
    end

    // D output comb
    always @(D_state, D_pop, D_out_ptr, D_counter) begin
      case(D_state)
        IDLE: begin
                if(D_pop) begin
                  D_next = HEADER;
                  D_out_ptr_buff = D_out_ptr;
                end
              end

        HEADER: begin
                  D_length = D_mem[D_out_ptr_buff][1][23:16]; //Including header
                  D_next = PAYLOAD;
                end
 
        PAYLOAD:  begin
                    if(D_counter == D_length+1) begin //Adding header to count
                      D_next = UPDATE;
                    end
                    else begin
                      D_next = PAYLOAD;
                    end
                  end

        UPDATE:   begin
                    D_next = IDLE;
                  end
      endcase
    end

    // D output port
    always @(posedge clk) begin
        case(D_state)
          IDLE: begin
                  D_valid <= 0;
                  D_eop <= 0;
                  D_sop <= 0;
                  if(D_pop)
                    D_start_count <= 1;
                end
          HEADER: begin
                      D_valid <= 1;
                      D_sop <= 1;
                      D_eop <= 0;
                      D <= D_mem[D_out_ptr_buff][D_counter];
                  end
          PAYLOAD:  begin
                      D_valid <= 1;
                      D_sop <= 0;
                      D_eop <= 0;
                      D <= D_mem[D_out_ptr_buff][D_counter];
                      if(D_counter == D_length+1) begin
                          D_eop <= 1;
                      end 
                    end
          UPDATE:   begin
                      D_eop <= 0;
                      D_valid <= 0;
                      D_pkt_process[D_out_ptr_buff] <= 0;
                      D_start_count <= 0;
                    end          
        endcase
    end
endmodule
