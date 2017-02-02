%Name: Tinhinene AIT HAMOUDA
%Personal Number: 920612-T403
%Implementation of slotted ALOHA
%Use s_aloha_test to test slotted_aloha with different values of lambda, q_r
function out=slotted_aloha(lambda,q_r,m)
%*******************************************************************
% lambda: total arrival rate
% q_a: transm. prob. of an unbacklogged node
% q_r: retransmission prob. of backlogged nodes
% m: total number of nodes
% n: number of backlogged nodes
% m-n: number of unbacklogged nodes
% t: time
%********************************************************************
t=1000;%Time in slots
slots=1:t;%Slots array
n=0;%Backlogged nodes at the begining = 0
backlog=zeros(size(1:t));%Backlog array of the system
packet_arr = 1:t;%Array of packets arriving
packet_leav = 1:t;%Array of packets leaving
succ=0;%Counter of the successful transmissions
state_probs=zeros(size(1:m));
Att_Rate = 1:t; %Attemp rate array

%Check lambda and m value
if lambda<=0 || lambda >1
  fprintf ('Syntax: s_aloha(lambda,q_r,m)');
  error ('Bad parameter: lambda shoud be between 0 and 0.36 ');
elseif m~=ceil(m)||m==0
  fprintf ('Syntax: s_aloha(lambda,q_r,m)');
  error ('Bad parameter: m should be a positive integer ');
end

%Calculate q_a: The prob. of an unbacklogged node to send a packet
q_a=1-exp(1)^(-lambda/m); 
fprintf('q_a is %f \n',q_a);

%Check q_r value
if q_r<q_a || q_r>=1
  fprintf ('Syntax: s_aloha(lambda,q_r,m)');
  error ('Bad parameter: q_r should be between q_a and 1 ');
end

%Print values
fprintf('lambda is %f \n',lambda);
fprintf('q_r is %f \n',q_r);
fprintf('m is %d \n',m);
pwd

%Overall loop from slot 1 to 1000
for i=1:t
   
   %Calculate Qa and Qr probabilities of the system
   Qa = zeros(size(1:101));
   Qr = zeros(size(1:101));
   for j=0:100
       Qa(j+1)=binopdf(j,m-n,q_a);
   end
   for j=0:100
      Qr(j+1)=binopdf(j,n,q_r);
   end
   
   %Generation of two random probabilities for the sake of comparison
   pQa = rand(1);
   pQb = rand(1);
   
   %We have two overall cases:
   %1. No backlogged node (n==0)
   %2. There is at least one backlogged node (n!=0)
   
   %Case 01: No backlogged node
   if n == 0
      if 0 <= pQa && pQa <= sum(Qa(1:1)) %Idle slot (Note that Qa(1) means j=0, no unbacklogged node is transmitting)
         packet_arr(i)=0;
         packet_leav(i)=0;
      elseif sum(Qa(1:1))<pQa && pQa<=sum(Qa(1:2)) %Succssful slot (1 unbacklogged node is transmitting)
          packet_arr(i)=1;
          packet_leav(i)=1;
          succ=succ+1;%Update succssful
      elseif sum(Qa(1:2))< pQa && pQa <=1 %Collision slot (More than 1 unbacklogged node is transmitting)
          x=1;
          while x<101
            if sum(Qa(1:x))>=pQa
                k=x-1; %k represents the number of unbacklogged node which are transmitting at the same time
                break;
            end
            x = x+1;    
          end
          n = n+k; %Update the backlog of the system
          packet_arr(i)=k;
          packet_leav(i)=0; %No packet will leave because it is a collision case
      end 
   %Case 02: There is at least one backlogged node  
   else  
      if 0 <= pQa && pQa <= sum(Qr(1:1)) %No backlogged node is transmitting
            if 0 <= pQb && pQb <= sum(Qa(1:1)) %Idle slot
                packet_arr(i)=0;
                packet_leav(i)=0;
            elseif sum(Qa(1:1)) < pQb && pQb <= sum(Qa(1:2)) %Succssful slot
                packet_arr(i)=1;
                packet_leav(i)=1;
                succ=succ+1;
            elseif sum(Qa(1:2))<pQb && pQb<=1 %Collision slot
                x=1;
                while x<101
                    if sum(Qa(1:x))>=pQb
                        k=x-1;
                        break;
                    end
                    x = x+1;    
                end
                n=n+k;
                packet_arr(i)=k;
                packet_leav(i)=0;
            end        
        elseif sum(Qr(1:1)) < pQa && pQa <= sum(Qr(1:2)) %One backlogged node is retransmitting
            if 0 <= pQb && pQb <= sum(Qa(1:1)) %Succssful slot (No unbacklogged node is transmitting)
                n=n-1; %Update backlog of the system (goes from state n to n-1)
                packet_arr(i)=1;%No new arrival
                packet_leav(i)=1;
                succ=succ+1;
            elseif sum(Qa(1:1))< pQb && pQb <=1 %Collision slot (1 or more unbacklogged node is transmitting)
                %Calculate the number of unbacklogged node that just
                %received a new packet
                x=1;
                while x<101
                    if sum(Qa(1:x))>=pQb
                        k=x-1;
                        break;
                    end
                    x = x+1;    
                end
                n = n+k;
                packet_arr(i)=k;%k corresponds to the number of new arrivals
                packet_leav(i)=0;
            end
            
        elseif sum(Qr(1:2)) < pQa && pQa <= 1 %Two or more backlogged node are retransmitting
            
            if  0 <= pQb && pQb <= sum(Qa(1:1)) %No unbacklogged node is transmitting 
                packet_arr(i)=0;
                packet_leav(i)=0;
            elseif sum(Qa(1:1))<pQb && pQb <=1 %One or more unbacklogged is transmitting
                x=1;
                while x<101
                    if sum(Qa(1:x))>=pQb
                        k = x-1;
                        break;
                    end
                    x = x+1;    
                end
                
                n =n+k;
                packet_arr(i)=k;
                packet_leav(i)=0;  
            end
      end
    backlog(i) = n; %Fill the array of the system's backlog  
   end  
end

%Figure 01: Setting up the plotting environment for the backlog of the system
figure(1) 
plot(slots,backlog);
xlabel('X: Slots')
ylabel('Y: Backlog of the system')
title('Backlog of the system VS. the slot number')
 
%Figure 02: Setting up the plotting environment for packets entering/leaving the system      
packets_arrived=1:t;
packets_left=1:t;
%At t(n+1) sum the number of packets arrived/left with the packets that
%arrived/left the system at t(n)
for x=1:t
    packets_arrived(x)=sum(packet_arr(1:x));
    packets_left(x)=sum(packet_leav(1:x));
end
figure(2)
plot(slots,packets_arrived)
hold on
plot(slots,packets_left,'r')
grid on
xlabel('X: Slots')
ylabel('Y: Number of packets')
title('Number of Packets entering/leaving the system VS. the slot number')
legend('Packets entering','Packets leaving')


%Figure 03: Setting up the plotting environment for the histogram of the backlog of the system
figure(3)
M = max(backlog);
hist(backlog,M) %Array with the counts of the times in each state
nelements = hist(backlog,100); %Count how many times element x was seen
for x = 1:m
    state_probs(x) = nelements(x)/1000;
end
xlabel('X: Number of state n')
ylabel('Y: Frequency of each state')
title('Histogram of the backlog')

%Figure 04: Setting up the plotting environment for the attempt rate
%Calculation of attempt rate plot (theoretical value):
for z = 1:1000
    Att_Rate(z) = q_a*(m-backlog(z))*q_a + q_r*(backlog(z));
end
figure(4)
plot(slots,Att_Rate)
xlabel('X: Slots')
ylabel('Y: Attempt rate G(n)')
title('Attempt rate G(n)')


%%Setting up the environment to compare frequency of success to the theoretical probability of sucess
%1. Calculation of average probability of success derived from simulation
Ps_sim = succ/t;
%2. Calculation of average theoretical probability of success
Ps_theor = 0;
for i = 1:m
    %tmp: Qr(1,n)*Qa(0,n)+Qa(1,0)*Qr(0,n)
    tmp = (binopdf(1,m-(i-1),q_a)*binopdf(0,(i-1),q_r))+(binopdf(0,m-(i-1),q_a)*binopdf(1,i-1,q_r));
    %tmp2 : tmp*the probability that this state n happens
    tmp2 = tmp * state_probs(i);
    Ps_theor = Ps_theor + tmp2;%Update Ps_theor
end

%Display values of simulation/theoretical probability of success
fprintf('Simulated Probability of Success is %f \n',Ps_sim);
fprintf('Theoretical Probability of Success is %f \n',Ps_theor);

