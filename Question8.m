W = zeros(size(1:7));%Pseudo Bayesian approximation delay (Theoretical)
D = zeros(size(1:7));%Average simulated delay (Real)
index = 1;%This variable will be used to iterate through W and D arrays

for lambda=0.05:0.05:0.35
    
    m=100;%Total number of nodes
    n=0;%Real backlog
    backlog=zeros(size(1:1000));%Real backlog array
    n_estimated=0;%Estimated backlog
    backlog_estimate=zeros(size(1:1000));%Estimated backlog array
    node_status=zeros(size(1:100));%Status of nodes ( 1 stands for backlogged/ 0 for unbacklogged ) 
    Pr = zeros(size(1:100));%Probability of k packets arriving in a node at a given time slot
    packets_arrival=zeros(size(1:1000));%Number of packets arriving at a time slot
    packets_leaving=zeros(size(1:1000));%Number of packets leaving at a time slot
    track_time=zeros(size(1:100));%Track packet delay array
    real_delay=[];%Accumulated real delay
    
    for j = 0:101
          %Poisson arrival of packets at a node
          Pr(j+1) = poisspdf(j, lambda/m);
    end

    for t = 1:1000
            
        transmit=zeros(size(1:100));%Temporary array to see how many nodes are trying to transmit in the system

            %Part 01: Figure our which nodes are backlogged
            count=0;
            for j = 1:100 %Loop over all nodes 
                a=rand(1);%Random realization of Pr (probability that k packets arrived at node j)
                if node_status(j) == 0 %Unbacklogged node
                    if 0 <= a && a <= Pr(1)% No packet arrival: Pr(x <= 0)
                        %Nothing changes
                    elseif a > sum(Pr(1:1))%More than one arrival
                        node_status(j)=1; %1. Node becomes backlogged
                        track_time(j)=1;%Note arrival time
                        n=n+1;%2. Update the backlog of the system
                        count=count+1;
                    end
                else %Backlogged nodes
                    %Nothing changes
                end
            end
            packets_arrival(t) = count;%Update number of arrivals at this time slot

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
                       transmit(j) = 1;%This node is transmitting
                   else%The node is not transmitting
                       track_time(j)=track_time(j)+1;%Increment the delay time of this node (packet)
                   end    
               end
            end

            if sum(transmit(1:100)) == 0 %Idle slot
                n_estimated=max(lambda, n_estimated + lambda - 1);%Based on feedback 0
                packets_leaving(t) = 0;
            elseif sum(transmit) == 1 %Successful slot
                n = n-1;%n decreases
                n_estimated = max(lambda, n_estimated + lambda - 1);%Based on feedback 1               
                packets_leaving(t) = 1;
                %Update node_status : one backlogged node has to become unbacklogged
                for x =1:100
                    if transmit(x) == 1
                        node_status(x)=0;%Free one node to become unbacklogged
                        real_delay= [real_delay, track_time(x)];
                        track_time(x)=0;
                        break;
                    end
                end
            else %Collision slot
                n_estimated = n_estimated + lambda + (exp(1)-2)^-1;%Based on feedback e
                packets_leaving(t) = 0;
                track_time = track_time + node_status;
            end
            
            %Save backlog results at time t
            backlog(t) = n;
            backlog_estimate(t) = n_estimated; 
    
    end

    packets_arrived=1:1000;%Total packets arrived from the begining
    packets_left=1:1000;%Total packets leaving from the begining
    for x=1:1000
            packets_arrived(x)= sum(packets_arrival(1:x));
            packets_left(x)= sum(packets_leaving(1:x));
    end
    
    D(index) = mean(real_delay);
    W(index) = ((exp(1)-0.5)/(1-lambda*exp(1)))-(((exp(1)-1)*((exp(1)^lambda)-1))/(lambda*(1-((exp(1)-1)*((exp(1)^lambda)-1)))));
    index = index + 1;
end


lambdaArray = [0.05 0.1 0.15 0.2 0.25 0.3 0.35]; 
figure(3)
plot(lambdaArray,D)
hold on
plot(lambdaArray,W,'r')
grid on
xlabel('X: Lambda')
ylabel('Y: Average Delay')
title('Average delay using P-B approximation formula and simulation results')
legend('Average simulated delay','P-B Approximate Delay')



