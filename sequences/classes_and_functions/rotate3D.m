function [GX, GY, GZ ] = rotate3D(gradient, theta, phi)

if ~strcmp('x',gradient.channel)
    error 'the input gradient has to be in channel 'x''
end

if isempty(gradient)
    GX = []; GY = []; GZ =[];
else
    GX = scaleGrad(gradient, sin(theta) * cos(phi));
    GY = scaleGrad(gradient, sin(theta) * sin(phi));
    GZ = scaleGrad(gradient, cos(theta));
    GY.channel = 'y';   GZ.channel = 'z';
end

    function grad = scaleGrad(grad, scale) % taken from pulseq
        if strcmp(grad.type,'trap')
            grad.amplitude = grad.amplitude*scale;
            grad.area = grad.area*scale;
            grad.flatArea = grad.flatArea*scale;
        else
            grad.waveform = grad.waveform*scale;
        end
    end

end
