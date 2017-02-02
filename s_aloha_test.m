%Use this script to test slotted_aloha.m 
%with different values of q_r and lambda
%s_aloha(lamda,q_r,m)
%lambda: total arrival rate of m nodes
%q_r: retrans. prob.
%m: number of nodes

% function y = s_aloha_test

lambda=input('type overall arrival rate: ');
q_r=input('type retransmission arrival rate: ');
slotted_aloha(lambda,q_r,100);
