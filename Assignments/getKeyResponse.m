%{
    Name: Lena Kemmelmeier
    Code Buddy: Jenna Pablo
    Date: October 24th, 2024
    Assignment: Experiment 1 Task Script
%}


function responses = getKeyResponse(responses, deadline, respKey, disallowedKeys, whileLoopDelta, itrial, timeFrom)

    %{
        Usage: responses = getKeyResponse(responses, deadline, respKey, disallowedKeys)
    
        Inputs
        responses: struct cont to be continued....
        type1: string for the first type of image, used to match the file-naming scheme
        type2: string for the second type of image, used to match the file-naming scheme
        numImagesPerBlock: total number of images to select for each block, this willl be split evenly between type1 and type2
    
        Outputs
        selectedFileNames: horizontal array of randomly selected image file names, half from type1 and half from type2, shuffled into a random order
    %}

    while GetSecs < deadline
        [keyDown, rt, keyCode, deltaTime] = KbCheck;
        if keyDown && keyCode(respKey)
            % record response
            responses(itrial).rtAbsolute = rt;
            responses(itrial).rt = rt - timeFrom;
            responses(itrial).deltaTime = deltaTime;
            break
        elseif keyDown && any(keyCode(KbName(disallowedKeys)))
            error("Manual quit!")
        end
        % Allow operating system to do its thing for 1 ms
        WaitSecs(whileLoopDelta);
    end

end