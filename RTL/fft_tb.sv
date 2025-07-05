`timescale 1ns/1ps
module fft_tb #(parameter  SAMPLE_WORD_LENGTH_tb  = 9, SAMPLE_INT_LENGTH_tb  = 0, SAMPLE_FLOAT_LENGTH_tb  = 8, 
                        TWIDDLE_WORD_LENGTH_tb = 8, TWIDDLE_INT_LENGTH_tb = 0, TWIDDLE_FLOAT_LENGTH_tb = 7) ();


wire signed [SAMPLE_WORD_LENGTH_tb -1 : 0]  fifo1_dout_i_tb;
wire signed [SAMPLE_WORD_LENGTH_tb -1 : 0]  fifo1_dout_q_tb;
wire signed [SAMPLE_WORD_LENGTH_tb -1 : 0]  fifo2_dout_i_tb;
wire signed [SAMPLE_WORD_LENGTH_tb -1 : 0]  fifo2_dout_q_tb;

reg  signed [SAMPLE_WORD_LENGTH_tb -1 : 0]  din_i_tb;
reg  signed [SAMPLE_WORD_LENGTH_tb -1 : 0]  din_q_tb;
reg                                         strt_pulse_tb;
reg                                         valid_in_tb;
reg                                         rst_tb;
reg                                         clk_tb;


localparam clk_period = 10;

//CLK GEN
always #(clk_period/2) clk_tb =~clk_tb;


integer testvectors_ip,testvectors_s1_op,testvectors_s2_op,testvectors_s3_op,testvectors_s4_op,k_radix,Failed,Passed;
integer ad1,ad2,ad3,ad4,Trials,Trials_Passed,Trials_Failed,Latency,increment;

//TESTVECTORS
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out1_i_reg_s1_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out1_q_reg_s1_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out2_i_reg_s1_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out2_q_reg_s1_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out1_i_reg_s2_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out1_q_reg_s2_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out2_i_reg_s2_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out2_q_reg_s2_test [7 : 0];


bit [2*SAMPLE_WORD_LENGTH_tb -1:0] stage3_outputs_test [16];// unpacked array,depth=2*sample , 16 wide variable //= byte [2] stage3_outputs[16]
bit [2*SAMPLE_WORD_LENGTH_tb -1:0] stage3_outputs [16]; 
bit [2*SAMPLE_WORD_LENGTH_tb -1:0] stage4_outputs_test [16];
bit [2*SAMPLE_WORD_LENGTH_tb -1:0] stage4_outputs [16]; 

reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out1_i_reg_s4_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out1_q_reg_s4_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out2_i_reg_s4_test [7 : 0];
reg  [SAMPLE_WORD_LENGTH_tb -1 :0] out2_q_reg_s4_test [7 : 0];


initial begin
    do_initialize;
    do_reset(clk_period);
    testvectors_ip = $fopen("Test_i_v.txt", "rb");
    if(testvectors_ip == 0) $error("Could not open testvectors_ip file");
    testvectors_s1_op = $fopen("Test_o_s1_v.txt", "rb");
    if(testvectors_s1_op == 0) $error("Could not open testvectors_s1_op file");
    testvectors_s2_op = $fopen("Test_o_s2_v.txt", "rb");
    if(testvectors_s2_op == 0) $error("Could not open testvectors_s2_op file");
    testvectors_s3_op = $fopen("Test_o_s3_v.txt", "rb");
    if(testvectors_s3_op == 0) $error("Could not open testvectors_s3_op file");
    testvectors_s4_op = $fopen("Test_o_s4_v.txt", "rb");
    if(testvectors_s4_op == 0) $error("Could not open testvectors_s4_op file");
    @(posedge clk_tb)
    #(2.5*clk_period)
    valid_in_tb = 1;
    strt_pulse_tb = 1;
    while (1) begin
        ad1 = 0;
        ad2 = 0;
        ad3 = 0; 
        ad4 = 0;
        Failed = 0;
        Passed = 0;
        Latency = 0;
        if (!$feof(testvectors_s1_op)) begin
            repeat (8) begin
                $fscanf(testvectors_s1_op,"%b",out1_i_reg_s1_test[ad1]);
                $fscanf(testvectors_s1_op,"%b",out1_q_reg_s1_test[ad1]);
                $fscanf(testvectors_s1_op,"%b",out2_i_reg_s1_test[ad1]);
                $fscanf(testvectors_s1_op,"%b",out2_q_reg_s1_test[ad1]);
                ad1 = ad1 + 1;
            end
        end
        

        if (!$feof(testvectors_s2_op)) begin
            repeat (2) begin
                $fscanf(testvectors_s2_op,"%b",out1_i_reg_s2_test[ad2]);
                $fscanf(testvectors_s2_op,"%b",out1_q_reg_s2_test[ad2]);
                $fscanf(testvectors_s2_op,"%b",out1_i_reg_s2_test[ad2+1]);
                $fscanf(testvectors_s2_op,"%b",out1_q_reg_s2_test[ad2+1]);
                $fscanf(testvectors_s2_op,"%b",out1_i_reg_s2_test[ad2+2]);
                $fscanf(testvectors_s2_op,"%b",out1_q_reg_s2_test[ad2+2]);
                $fscanf(testvectors_s2_op,"%b",out1_i_reg_s2_test[ad2+3]);
                $fscanf(testvectors_s2_op,"%b",out1_q_reg_s2_test[ad2+3]);
    
                $fscanf(testvectors_s2_op,"%b",out2_i_reg_s2_test[ad2]);
                $fscanf(testvectors_s2_op,"%b",out2_q_reg_s2_test[ad2]);
                $fscanf(testvectors_s2_op,"%b",out2_i_reg_s2_test[ad2+1]);
                $fscanf(testvectors_s2_op,"%b",out2_q_reg_s2_test[ad2+1]);
                $fscanf(testvectors_s2_op,"%b",out2_i_reg_s2_test[ad2+2]);
                $fscanf(testvectors_s2_op,"%b",out2_q_reg_s2_test[ad2+2]);
                $fscanf(testvectors_s2_op,"%b",out2_i_reg_s2_test[ad2+3]);
                $fscanf(testvectors_s2_op,"%b",out2_q_reg_s2_test[ad2+3]);
                ad2 = ad2 + 4;
            end
            
        end
        

        if (!$feof(testvectors_s3_op)) begin
            repeat(16) begin
                $fscanf(testvectors_s3_op,"%b",stage3_outputs_test[ad3][2*SAMPLE_WORD_LENGTH_tb-1:SAMPLE_WORD_LENGTH_tb]);
                $fscanf(testvectors_s3_op,"%b",stage3_outputs_test[ad3][SAMPLE_WORD_LENGTH_tb-1:0]);
                ad3 = ad3 + 1;
            end
        end

        if (!$feof(testvectors_s4_op)) begin
            repeat(16) begin
                $fscanf(testvectors_s4_op,"%b",stage4_outputs_test[ad4][2*SAMPLE_WORD_LENGTH_tb-1:SAMPLE_WORD_LENGTH_tb]);
                $fscanf(testvectors_s4_op,"%b",stage4_outputs_test[ad4][SAMPLE_WORD_LENGTH_tb-1:0]);
                ad4 = ad4 + 1;
            end
            
        end
        

        if(!$feof(testvectors_ip)) begin
            repeat(16) begin
                $fscanf(testvectors_ip,"%b",din_i_tb);
                $fscanf(testvectors_ip,"%b",din_q_tb);
                #(clk_period)
                strt_pulse_tb = 0;
            end
        end else begin

            $display("#Trials Tested = %0d", Trials);
            $display("#Trials Passed = %0d", Trials_Passed);
            $display("#Trials Failed = %0d", Trials_Failed);
            $finish;
        end

        wait(DUT.ctrl_U0.stage4_done)
        
        #(5*clk_period);
        strt_pulse_tb = 1;
        
    end

end

always @(posedge clk_tb) begin
    if (DUT.ctrl_U0.fft_strt) increment = 1;
    if (DUT.ctrl_U0.fft_done) increment = 0;
    if (increment)            Latency = Latency +1;
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////STAGE #1 CHECKER/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

integer i;
always @(posedge clk_tb) begin
    if (DUT.ctrl_U0.stage1_done) begin
        #(4*clk_period)
        for (i = 0; i<8; i=i+2) begin
            if ( ({out1_i_reg_s1_test[i],out1_q_reg_s1_test[i]} == DUT.fifo_U0.fifo[i] ) && ({out2_i_reg_s1_test[i],out2_q_reg_s1_test[i]} == DUT.fifo_U0.fifo[i+1]) ) begin
                $display("STAGE #1 test case %0d PASSED",i+1);
                Passed = Passed +1;
            end
            else begin
                $display("STAGE #1 test case %0d FAILED!!!!!!!!!!",i+1);
                $display("out1    EXPECTED %b      FOUND %b",{out1_i_reg_s1_test[i],out1_q_reg_s1_test[i]},DUT.fifo_U0.fifo[i]);
                $display("out2    EXPECTED %b      FOUND %b",{out2_i_reg_s1_test[i],out2_q_reg_s1_test[i]},DUT.fifo_U0.fifo[i+1]);
                Failed = Failed +1;
            end

            if ( ({out1_i_reg_s1_test[i+1],out1_q_reg_s1_test[i+1]} == DUT.fifo_U1.fifo[i] ) && ({out2_i_reg_s1_test[i+1],out2_q_reg_s1_test[i+1]} == DUT.fifo_U1.fifo[i+1]) ) begin
                $display("STAGE #1 test case %0d PASSED",i+2);
                Passed = Passed +1;
            end
            else begin
                $display("STAGE #1 test case %0d FAILED!!!!!!!!!!",i+2);
                $display("out1    EXPECTED %b      FOUND %b",{out1_i_reg_s1_test[i+1],out1_q_reg_s1_test[i+1]},DUT.fifo_U1.fifo[i]);
                $display("out2    EXPECTED %b      FOUND %b",{out2_i_reg_s1_test[i+1],out2_q_reg_s1_test[i+1]},DUT.fifo_U1.fifo[i+1]);
                Failed = Failed +1;
            end
        end
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////STAGE #2 CHECKER/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk_tb) begin
    if (DUT.ctrl_U0.stage2_done) begin
        #(1*clk_period)
        for (i = 0; i<8; i=i+4) begin
            if ( ({out1_i_reg_s2_test[i],out1_q_reg_s2_test[i]} == DUT.fifo_U0.fifo[i+8] ) && ({out1_i_reg_s2_test[i+1],out1_q_reg_s2_test[i+1]} == DUT.fifo_U0.fifo[i+9]) && ({out1_i_reg_s2_test[i+2],out1_q_reg_s2_test[i+2]} == DUT.fifo_U0.fifo[i+10] ) && ({out1_i_reg_s2_test[i+3],out1_q_reg_s2_test[i+3]} == DUT.fifo_U0.fifo[i+11]) ) begin
                $display("STAGE #2 test case %0d PASSED",(2*i/4)+1);
                Passed = Passed +1;
            end
            else begin
                $display("STAGE #2 test case %0d FAILED!!!!!!!!!!",(2*i/4)+1);
                $display("out1    EXPECTED %b      FOUND %b",{out1_i_reg_s2_test[i  ],out1_q_reg_s2_test[i  ]},DUT.fifo_U0.fifo[i+8]);
                $display("out2    EXPECTED %b      FOUND %b",{out1_i_reg_s2_test[i+1],out1_q_reg_s2_test[i+1]},DUT.fifo_U0.fifo[i+9]);
                $display("out3    EXPECTED %b      FOUND %b",{out1_i_reg_s2_test[i+2],out1_q_reg_s2_test[i+2]},DUT.fifo_U0.fifo[i+10]);
                $display("out4    EXPECTED %b      FOUND %b",{out1_i_reg_s2_test[i+3],out1_q_reg_s2_test[i+3]},DUT.fifo_U0.fifo[i+11]);
                Failed = Failed +1;
            end
    
            if ( ({out2_i_reg_s2_test[i],out2_q_reg_s2_test[i]} == DUT.fifo_U1.fifo[i+8] ) && ({out2_i_reg_s2_test[i+1],out2_q_reg_s2_test[i+1]} == DUT.fifo_U1.fifo[i+9]) && ({out2_i_reg_s2_test[i+2],out2_q_reg_s2_test[i+2]} == DUT.fifo_U1.fifo[i+10] ) && ({out2_i_reg_s2_test[i+3],out2_q_reg_s2_test[i+3]} == DUT.fifo_U1.fifo[i+11]) ) begin
                $display("STAGE #2 test case %0d PASSED",(2*i/4)+2);
                Passed = Passed +1;
            end
            else begin
                $display("STAGE #2 test case %0d FAILED!!!!!!!!!!",(2*i/4)+2);
                $display("out1    EXPECTED %b      FOUND %b",{out2_i_reg_s2_test[i  ],out2_q_reg_s2_test[i  ]},DUT.fifo_U1.fifo[i+8]);
                $display("out2    EXPECTED %b      FOUND %b",{out2_i_reg_s2_test[i+1],out2_q_reg_s2_test[i+1]},DUT.fifo_U1.fifo[i+9]);
                $display("out3    EXPECTED %b      FOUND %b",{out2_i_reg_s2_test[i+2],out2_q_reg_s2_test[i+2]},DUT.fifo_U1.fifo[i+10]);
                $display("out4    EXPECTED %b      FOUND %b",{out2_i_reg_s2_test[i+3],out2_q_reg_s2_test[i+3]},DUT.fifo_U1.fifo[i+11]);
                Failed = Failed +1;
            end
        end
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////STAGE #3 CHECKER/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk_tb) begin
    
    bit found;
    if (DUT.ctrl_U0.stage3_done) begin
        #(1*clk_period)
        foreach(stage3_outputs[i]) begin // i here refers to the depth
            if (i<8) begin
                stage3_outputs[i] = DUT.fifo_U0.fifo[i];
            end
            else begin
                stage3_outputs[i] = DUT.fifo_U1.fifo[i-8];
            end
        end

        foreach(stage3_outputs_test[i]) begin // i here refers to the depth
        found = 0;
            foreach(stage3_outputs[j]) begin
                if (stage3_outputs[j] == stage3_outputs_test[i]) begin
                    $display("STAGE #3 test case %0d PASSED",i+1);
                    $display("Test Sample #%0d found in position #%0d in the mem",i,j);
                    Passed = Passed +1;
                    found = 1;
                    break;
                end 
            end
            if (found == 0) begin
                $display("STAGE #3 test case %0d FAILED!!!!!!!!!!",i+1);
                Failed = Failed +1;
            end
        end
        
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////STAGE #4 CHECKER/////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge clk_tb) begin
    
    bit found;
    if (DUT.ctrl_U0.stage4_done) begin
        #(1*clk_period)
        foreach(stage4_outputs[i]) begin // i here refers to the depth
            if (i<8) begin
                stage4_outputs[i] = DUT.fifo_U0.fifo[i+8];
            end
            else begin
                stage4_outputs[i] = DUT.fifo_U1.fifo[i];
            end
        end

        foreach(stage4_outputs_test[i]) begin // i here refers to the depth
        found = 0;
            foreach(stage4_outputs[j]) begin
                if (stage4_outputs[j] == stage4_outputs_test[i]) begin
                    $display("STAGE #4 test case %0d PASSED",i+1);
                    $display("Test Sample #%0d found in position #%0d in the mem",i,j);
                    Passed = Passed +1;
                    found = 1;
                    break;
                end 
            end
            if (found == 0) begin
                $display("STAGE #4 test case %0d FAILED!!!!!!!!!!",i+1);
                Failed = Failed +1;
            end
        end
        
    end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////END REPORT////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge DUT.ctrl_U0.stage4_done) begin
    #(3*clk_period)
    if (Failed == 'd0) begin
        $display("*******************Trial #%0d Passed*********************",Trials+1);
        Trials_Passed++;
    end else begin
        $display("*******************Trial #%0d Failed!!!!!!!!!!!!",Trials+1);
        Trials_Failed++;
    end
    $display("*******************Latency = #%0d************************",Latency+1);
    Latency = 0;
    Trials++;
end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////TASKS//////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

task do_reset;
input clk_period;
begin
    rst_tb = 1;
    #(0.1*clk_period) 
    rst_tb = 0;
    #(0.1*clk_period) 
    rst_tb = 1;
end
endtask

task do_initialize;
begin
    clk_tb          = 0;
    din_i_tb        = 0;
    din_q_tb        = 0;
    k_radix         = 0;
    Failed          = 0;
    Passed          = 0;
    ad1             = 0;
    ad2             = 0;
    ad3             = 0;
    ad4             = 0;
    Trials          = 0;
    Trials_Passed   = 0;
    Trials_Failed   = 0;
    valid_in_tb     = 0;
    strt_pulse_tb   = 0;
    din_i_tb        = 'd0;
    din_q_tb        = 'd0;

end
endtask



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////INSTANTIATION//////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fft #(   .SAMPLE_FLOAT_LENGTH(SAMPLE_FLOAT_LENGTH_tb) , .SAMPLE_WORD_LENGTH(SAMPLE_WORD_LENGTH_tb) , .SAMPLE_INT_LENGTH(SAMPLE_INT_LENGTH_tb)) DUT (

    .fifo1_dout_i(fifo1_dout_i_tb),
    .fifo1_dout_q(fifo1_dout_q_tb),
    .fifo2_dout_i(fifo2_dout_i_tb),
    .fifo2_dout_q(fifo2_dout_q_tb),
    .din_i       (din_i_tb),
    .din_q       (din_q_tb),
    .strt_pulse  (strt_pulse_tb),
    .valid_in    (valid_in_tb),
    .rst         (rst_tb),
    .clk         (clk_tb)
);

endmodule