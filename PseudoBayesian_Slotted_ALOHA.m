%Implementation of Pseudo Bayesian stabilization for Slotted ALOHA

m=100;%Total number of nodes
n=0;%Real backlog
backlog=zeros(size(1:1000));%Backlog array
n_estimated=0;%Estimated backlog
backlog_estimate=zeros(size(1:1000));%Estimated backlog array
node_status=zeros(size(1:100));%Status of nodes (1 stands for backlogged/0 for unbacklogged)
Pr = zeros(size(1:20));%Probability of k packets arriving in a node at a given time slot
packets_arrival=zeros(size(1:1000));%Number of packets arriving at a time slot
packets_leaving=zeros(size(1:1000));%Number of packets leaving at a time slot
lambda=1/exp(1);%Arrival rate

%Simulation of up to 20 packets arrival
for j = 0:21
  %Poisson arrival of packets at a node
  Pr(j+1) = poisspdf(j, lambda/m);
end

for t = 1:1000
    
    transmit = 0;%Temporary variable to see how many packets are there in the system

    %Part 01: Figure our which nodes are backlogged
    count=0;
    for j = 1:100 %Loop over all nodes 
        a=rand(1);%Random realization of Pr (probability that k packets arrived at node j)
        if node_status(j) == 0 %Unbacklogged node
            if 0 <= a && a <= Pr(1)% No packet arrival: Pr(x <= 0)
                %Nothing changes
            elseif a > sum(Pr(1:1))%More than one arrival
                node_status(j)=1; %1. Node becomes backlogged
                n=n+1;%2. Update the backlog of the system
                count=count+1;
            end
        else %Backlogged nodes
            %Nothing changes
        end
    end
    %Update number of packets that entered the system at this time slot
    packets_arrival(t) = count;
    
    %At this stage we know which nodes are backlogged
    
    %Calculate qr
    if n_estimated >= 0 && n_estimated < 1
       q_r = 1;
    else
       q_r = 1/n_estimated;
    end
    
    for j = 1:100 %Loop over all nodes and test the backlogged nodes
       if node_status(j) == 1 %Backlogged node (has a packet)
           b=rand(1);%Random outcome for each backlogged node
           if b <= q_r 
               transmit = transmit +1;
           end
       end
    end
          
    if transmit == 0 %Idle slot
        n_estimated=max(lambda, n_estimated + lambda - 1);%Based on feedback 0
        packets_leaving(t) = 0;
    elseif transmit == 1 %Successful slot
        n = n-1;%Backlog decreases
        n_estimated = max(lambda, n_estimated + lambda - 1);%Based on 1 feedback               
        packets_leaving(t) = 1;
        %Update node_status : one backlogged node has to become unbacklogged
        for x =1:100
            if node_status(x) == 1
                node_status(x)=0;%Free one backlogged to become unbacklogged
                break;
            end
        end
    else %Collision slot
        n_estimated = n_estimated + lambda + (exp(1)-2)^-1;%Based on e feedback
        packets_leaving(t) = 0;
    end
    
    %Save backlog results at time t
    backlog(t) = n;
    backlog_estimate(t) = n_estimated; 
end

slots=1:1000;
figure(1) %Setting up the plotting environment for the backlog of the system
xlabel('Slot number, n')
ylabel('Backlogged packets')
plot(slots, backlog)
hold on
plot(slots,backlog_estimate,'g')
title('Real backlog vs. Pseudo Bayesian Estimated backlog')
legend('Backlog', 'Estimated backlog')



%Figure 02: Setting up the plotting environment for the packets entering/leaving the system      
packets_arrived=1:1000;%Count total number of packets entering from the begining
packets_left=1:1000;%Count total number of packets leaving from the begining

for x=1:1000
    packets_arrived(x)= sum(packets_arrival(1:x));
    packets_left(x)= sum(packets_leaving(1:x));
end
figure(2)
plot(slots,packets_arrived)
hold on
plot(slots,packets_left,'k')
grid on
xlabel('X: Slots')
ylabel('Y: Number of packets')
title('Number of packets entering/leaving the system VS. the slot number')
legend('Packets entering', 'Packets leaving')

