% Returning the closest node to the query start node.

function [min_distance, min_distance_ind, x_start, trajectory_index] = query_state(...
    x_query, x_data, p, S, beta)

    % We find the closest point according to the p norm
    M = length(x_data);
    
    x_delta_init = x_query - x_data{1}(:, 1);
    cost_init = (x_delta_init.'*S*x_delta_init)^2;
    
    min_distance = beta*norm(x_delta_init, p) + ...
        (1 - beta)*cost_init;
    
    min_distance_ind = 1;
    k = 1;
    trajectory_index = 1;
    
    for i=1:M
        
        N = size(x_data{i}, 2);
        
        for j=1:N
            
            x_delta = x_query - x_data{i}(:, j);
            cost = (x_delta.'*S*x_delta)^2;
                 
            distance = beta*norm(x_delta, p) + (1 - beta)*cost;
            if distance < min_distance

               min_distance = distance;
               min_distance_ind = k;
               trajectory_index = i;
               
            end
            
            k = k + 1;
            
        end
        
    end  
    
    x_start = get_state_from_index(x_data, min_distance_ind);
    
end