clear;
clc;
N = 16;
k1 = 1;%randi([0 15],1,1);
k2 = 1;%randi([0 15],1,1);
sample_wordlength = 9;
sample_fractionlength = 8;

twiddle_wordlength = 8;
twiddle_fractionlength = 7;

I = 1j;

%% OPEN FILES
Test_i_v = fopen('Test_i_v.txt','w');
Test_o_s1_v = fopen('Test_o_s1_v.txt','w');
Test_o_s2_v = fopen('Test_o_s2_v.txt','w');
Test_o_s3_v = fopen('Test_o_s3_v.txt','w');
Test_o_s4_v = fopen('Test_o_s4_v.txt','w');
Test_c   = fopen('Test_c.txt'  ,'w');

%% Trials loop
for trial=1:5
    
%% #######################################################################%%
%% ############################## STAGE #1 ###############################%%
%% #######################################################################%%
%% TWIDDLE FACTORS GENERATION
n1 = [0 0 0 0 0 0 0 0];
n2 = [0 4 0 4 0 4 0 4];
twiddle1 = exp(-2*pi*I*k1*n1/N);
twiddle2 = exp(-2*pi*I*k2*n2/N);
twiddle1_fp = fi([twiddle1], 1, twiddle_wordlength, twiddle_fractionlength);
twiddle2_fp = fi([twiddle2], 1, twiddle_wordlength, twiddle_fractionlength);

%% INPUT GENERATION
in_t = rand(16,1)/5 + rand(16,1)/5 * I;
in_t_fp = fi([in_t], 1, sample_wordlength, sample_fractionlength);
in = [in_t(1) in_t(9) in_t(5) in_t(13) in_t(3) in_t(11) in_t(7) in_t(15) in_t(2) in_t(10) in_t(6) in_t(14) in_t(4) in_t(12) in_t(8) in_t(16)];
in1 = [in(1) in(3) in(5) in(7) in(9)  in(11) in(13) in(15)];
in2 = [in(2) in(4) in(6) in(8) in(10) in(12) in(14) in(16)];
in1_fp = fi([in1], 1, sample_wordlength, sample_fractionlength);
in2_fp = fi([in2], 1, sample_wordlength, sample_fractionlength);

%% RADIX-2 BUTTERFLY
out1 = ( in1_fp + in2_fp ) .* twiddle1_fp;
out2 = ( in1_fp - in2_fp ) .* twiddle2_fp;
out1_fp = fi([out1], 1, sample_wordlength, sample_fractionlength);
out2_fp = fi([out2], 1, sample_wordlength, sample_fractionlength);
%% WRITING INTO A FILE (FOR HW)
for p = 1:8
fprintf(Test_i_v,['%s\n%s\n'],real(in1_fp(p)).bin,imag(in1_fp(p)).bin);
fprintf(Test_i_v,['%s\n%s\n'],real(in2_fp(p)).bin,imag(in2_fp(p)).bin);
%fprintf(Test_i_v,['%s\n%s\n'],real(twiddle1_fp(p)).bin,imag(twiddle1_fp(p)).bin);
%fprintf(Test_i_v,['%s\n%s\n'],real(twiddle2_fp(p)).bin,imag(twiddle2_fp(p)).bin);
fprintf(Test_o_s1_v,['%s\n%s\n'],real(out1_fp(p)).bin,imag(out1_fp(p)).bin);
fprintf(Test_o_s1_v,['%s\n%s\n'],real(out2_fp(p)).bin,imag(out2_fp(p)).bin);

end
%% #######################################################################%%
%% ############################## STAGE #2 ###############################%%
%% #######################################################################%%
%% TWIDDLE FACTORS GENERATION 
n1 = [0 0 0 2 0 0 0 2];
n2 = [0 0 4 6 0 0 4 6];
twiddle1 = exp(-2*pi*I*k1*n1/N);
twiddle2 = exp(-2*pi*I*k2*n2/N);
twiddle1_fp = fi([twiddle1], 1, twiddle_wordlength, twiddle_fractionlength);
twiddle2_fp = fi([twiddle2], 1, twiddle_wordlength, twiddle_fractionlength);

%% INPUT GENERATION
in1_fp = [out1_fp(1) out2_fp(1) out1_fp(3) out2_fp(3) out1_fp(5) out2_fp(5) out1_fp(7) out2_fp(7)];
in2_fp = [out1_fp(2) out2_fp(2) out1_fp(4) out2_fp(4) out1_fp(6) out2_fp(6) out1_fp(8) out2_fp(8)];

%% RADIX-2 BUTTERFLY
out1 = ( in1_fp + in2_fp ) .* twiddle1_fp;
out2 = ( in1_fp - in2_fp ) .* twiddle2_fp;
out1_fp = fi([out1], 1, sample_wordlength, sample_fractionlength);
out2_fp = fi([out2], 1, sample_wordlength, sample_fractionlength);

%% WRITING INTO A FILE (FOR HW)
for p = 1:8
fprintf(Test_o_s2_v,['%s\n%s\n'],real(out1_fp(p)).bin,imag(out1_fp(p)).bin);
fprintf(Test_o_s2_v,['%s\n%s\n'],real(out2_fp(p)).bin,imag(out2_fp(p)).bin);

end

%% #######################################################################%%
%% ############################## STAGE #3 ###############################%%
%% #######################################################################%%
%% TWIDDLE FACTORS GENERATION
n1 = [0 0 0 0 0 1 2 3]; 
n2 = [0 0 0 0 4 5 6 7]; 
twiddle1 = exp(-2*pi*I*k1*n1/N);
twiddle2 = exp(-2*pi*I*k2*n2/N);
twiddle1_fp = fi([twiddle1], 1, twiddle_wordlength, twiddle_fractionlength);
twiddle2_fp = fi([twiddle2], 1, twiddle_wordlength, twiddle_fractionlength);

%% INPUT GENERATION
in1_fp = [out1_fp(1) out1_fp(2) out2_fp(1) out2_fp(2) out1_fp(5) out1_fp(6) out2_fp(5) out2_fp(6)];
in2_fp = [out1_fp(3) out1_fp(4) out2_fp(3) out2_fp(4) out1_fp(7) out1_fp(8) out2_fp(7) out2_fp(8)];

%% RADIX-2 BUTTERFLY
out1 = ( in1_fp + in2_fp ) .* twiddle1_fp;
out2 = ( in1_fp - in2_fp ) .* twiddle2_fp;
out1_fp = fi([out1], 1, sample_wordlength, sample_fractionlength);
out2_fp = fi([out2], 1, sample_wordlength, sample_fractionlength);

%% WRITING INTO A FILE (FOR HW)
for p = 1:8
fprintf(Test_o_s3_v,['%s\n%s\n'],real(out1_fp(p)).bin,imag(out1_fp(p)).bin);
fprintf(Test_o_s3_v,['%s\n%s\n'],real(out2_fp(p)).bin,imag(out2_fp(p)).bin);


end
%% ####################################################################### %%
%% ############################## STAGE #4 ############################### %%
%% ####################################################################### %%
%% TWIDDLE FACTORS GENERATION
n1 = [0 0 0 0 0 0 0 0]; 
n2 = [0 0 0 0 0 0 0 0]; 
twiddle1 = exp(-2*pi*I*k1*n1/N);
twiddle2 = exp(-2*pi*I*k2*n2/N);
twiddle1_fp = fi([twiddle1], 1, twiddle_wordlength, twiddle_fractionlength);
twiddle2_fp = fi([twiddle2], 1, twiddle_wordlength, twiddle_fractionlength);

%% INPUT GENERATION
in1_fp = [out1_fp(1) out1_fp(2) out1_fp(3) out1_fp(4) out2_fp(1) out2_fp(2) out2_fp(3) out2_fp(4)];
in2_fp = [out1_fp(5) out1_fp(6) out1_fp(7) out1_fp(8) out2_fp(5) out2_fp(6) out2_fp(7) out2_fp(8)];

%% RADIX-2 BUTTERFLY
out1 = ( in1_fp + in2_fp ) .* twiddle1_fp;
out2 = ( in1_fp - in2_fp ) .* twiddle2_fp;
out1_fp = fi([out1], 1, sample_wordlength, sample_fractionlength);
out2_fp = fi([out2], 1, sample_wordlength, sample_fractionlength);
fft_out = transpose([out1_fp out2_fp]);
%% WRITING INTO A FILE (FOR HW)
for p = 1:8
fprintf(Test_o_s4_v,['%s\n%s\n'],real(out1_fp(p)).bin,imag(out1_fp(p)).bin);
fprintf(Test_o_s4_v,['%s\n%s\n'],real(out2_fp(p)).bin,imag(out2_fp(p)).bin);


end
end
%% CLOSE FILES
fclose (Test_i_v);
fclose (Test_o_s1_v);
fclose (Test_o_s2_v);
fclose (Test_o_s3_v);
fclose (Test_o_s4_v);
fclose (Test_c);

%% FFT FUNCTION
in_fft = in_t_fp.data;
out_fft = fft(in_fft,16);
out_fft = fi([out_fft], 1, sample_wordlength, sample_fractionlength).data;
compare = [out_fft fft_out];
temp = fi([fft(in_fft)], 1, sample_wordlength, sample_fractionlength).data;